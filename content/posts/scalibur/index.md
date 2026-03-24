---
title: "Scalibur: Reading Body Composition from a Cheap Bluetooth Scale"
subtitle: "A journey through BLE packet sniffing, protocol reverse-engineering, and Raspberry Pi deployment"
description: "How I built a Raspberry Pi dashboard to capture and visualize body composition data from a GoodPharm TY5108 Bluetooth scale"
author: "Guy Freeman"
date: 2025-12-22
lastmod: 2025-12-31
categories: [python, iot, raspberry-pi, health, data, ble, hardware]
image: og-image.png
---

Body composition scales are, on their own terms, genuinely useful devices. Step on, wait a few seconds, receive a small dossier on your own physical form: weight, body fat percentage, muscle mass, and several other numbers whose accuracy I'm diplomatically not questioning here. The problem is what happens next. Your data vanishes into whichever proprietary app the manufacturer saw fit to build, typically bundled with aggressive upsells and privacy practices that would make a data broker wince.

I bought a cheap GoodPharm TY5108 scale (it announces itself as "tzc" over Bluetooth LE) for around £20. It measures things competently enough, but I wanted to own the resulting numbers. So I built [Scalibur](https://github.com/gfrmin/scalibur): a Raspberry Pi system that captures raw BLE advertisements, decodes the measurements, calculates body composition metrics, and presents everything on a web dashboard of modest visual ambition.

{{< callout type="note" >}}
For a less technical take on why I built this, see [On Owning Your Data](/posts/on-owning-your-data/).
{{< /callout >}}

Here is how the whole thing came together.

## The Hardware

Not much to report on this front:

- **GoodPharm TY5108 scale** - A cheap body composition scale with BLE. It measures weight via load cells and impedance through electrodes on the surface (bare feet required for the full reading, which is a sentence I never expected to type in a technical specification).
- **Raspberry Pi** - Any model with Bluetooth LE will do. I used a Pi 4, though a Pi Zero W would manage perfectly well.

The scale broadcasts its measurements as BLE advertisements. Unlike connected BLE devices that require pairing and a persistent connection, advertisement-based devices simply shout their data into the surrounding air. Anyone listening can pick it up. The scale has the operational security of a man on a megaphone.

## Reverse-Engineering the Protocol

My first attempt used `bleak`, a popular Python BLE library. I could see the device advertising, but the high-level APIs abstracted away the manufacturer-specific data I actually needed. The scale wasn't exposing GATT services in the conventional manner --- all the interesting data lived in the advertisement packets themselves.

So I switched to `aioblescan`, which gives you raw HCI (Host Controller Interface) packets. This is the low-level interface between the Bluetooth controller and the host system, and it is where the fun begins, if your definition of fun accommodates hex dumps.

```python
def parse_hci_packet(data: bytes) -> tuple[str | None, int | None, bytes | None]:
    """Parse raw HCI LE advertising packet."""
    if len(data) < 14 or data[0:2] != b'\x04\x3e':
        return None, None, None

    if data[3] != 0x02:  # Not LE Advertising Report
        return None, None, None

    adv_len = data[13]
    adv_data = data[14:14 + adv_len]

    device_name = None
    manufacturer_id = None
    manufacturer_data = None

    i = 0
    while i < len(adv_data):
        if i + 1 >= len(adv_data):
            break
        length = adv_data[i]
        if length == 0 or i + length >= len(adv_data):
            break
        ad_type = adv_data[i + 1]
        ad_value = adv_data[i + 2:i + 1 + length]

        if ad_type == 0x09:  # Complete Local Name
            device_name = ad_value.decode('utf-8')
        elif ad_type == 0xFF and len(ad_value) >= 2:  # Manufacturer Specific Data
            manufacturer_id = int.from_bytes(ad_value[0:2], "little")
            manufacturer_data = ad_value[2:]

        i += 1 + length

    return device_name, manufacturer_id, manufacturer_data
```

The BLE advertising data structure is a series of TLV (Type-Length-Value) entries. We want type `0xFF` --- manufacturer-specific data --- which contains the actual scale reading.

### The Byte Offset Saga

Getting the byte offsets right consumed several iterations and a quantity of dignity. My git history preserves the evidence:

```
f477996 Fix packet decoding: weight in data bytes, not manufacturer_id
28de4a4 Fix packet decoding: weight is in manufacturer ID field
```

I initially believed the weight was encoded in the manufacturer ID field (the first two bytes of the manufacturer-specific data). Then I believed the opposite. Both were wrong, though in interestingly different ways --- I was consistently off by exactly one byte, which is the kind of systematic error that makes you feel like you're nearly right when you're actually just consistently wrong.

The actual layout, once I stopped theorising and started reading correctly:

| Bytes | Description |
|-------|-------------|
| 0-1 | Weight (big-endian, divide by 10 for kg) |
| 2-3 | Impedance (big-endian, divide by 10 for ohms; 0 = not measured) |
| 4-5 | User ID |
| 6 | Status: 0x20 = weight only, 0x21 = weight + impedance |
| 7+ | MAC address (ignored) |

That status byte turned out to be crucial. The scale first broadcasts `0x20` when it has a stable weight reading, then `0x21` once it has also measured impedance (which takes a few more seconds and requires bare feet on the electrodes). Two phases of revelation, like a mediocre firework.

```python
def decode_packet(manufacturer_id: int, manufacturer_data: bytes) -> ScaleReading | None:
    """Decode tzc scale advertisement packet."""
    if len(manufacturer_data) < 7:
        return None

    weight_raw = int.from_bytes(manufacturer_data[0:2], "big")
    weight_kg = weight_raw / 10

    impedance_raw = int.from_bytes(manufacturer_data[2:4], "big")
    impedance_ohm = impedance_raw / 10 if impedance_raw > 0 else None

    user_id = int.from_bytes(manufacturer_data[4:6], "big")

    status = manufacturer_data[6]
    is_complete = status == 0x21 or (status == 0x20 and impedance_raw == 0)

    return ScaleReading(
        weight_kg=weight_kg,
        impedance_raw=impedance_raw,
        impedance_ohm=impedance_ohm,
        user_id=user_id,
        is_complete=is_complete,
        is_locked=is_complete,
    )
```

## Body Composition Mathematics

Once you have weight and impedance, body composition follows from BIA (Bioelectrical Impedance Analysis) formulae. These are well-documented --- I used formulae compatible with [openScale](https://github.com/oliexdev/openScale), an open-source Android app for body composition scales.

The governing principle: lean tissue conducts electricity more readily than fat. Measure the body's impedance, combine with height, age, and gender, and you can estimate lean body mass. The word "estimate" is doing heavy lifting in that sentence, but the approach is standard.

```python
def calculate_body_composition(
    weight_kg: float,
    impedance_ohm: float,
    height_cm: int,
    age: int,
    gender: str,
) -> BodyComposition:
    """Calculate body composition using standard BIA formulas."""
    height_sq = height_cm**2

    # Lean Body Mass
    if gender == "male":
        lbm = 0.485 * (height_sq / impedance_ohm) + 0.338 * weight_kg + 5.32
    else:
        lbm = 0.474 * (height_sq / impedance_ohm) + 0.180 * weight_kg + 5.03

    # Body Fat
    fat_mass_kg = weight_kg - lbm
    body_fat_pct = (fat_mass_kg / weight_kg) * 100

    # BMR (Mifflin-St Jeor equation)
    if gender == "male":
        bmr = 88.36 + (13.4 * weight_kg) + (4.8 * height_cm) - (5.7 * age)
    else:
        bmr = 447.6 + (9.2 * weight_kg) + (3.1 * height_cm) - (4.3 * age)

    # ... plus body water, muscle mass, bone mass, BMI
```

These formulae are not perfectly accurate --- consumer BIA scales are notoriously inconsistent --- but they suffice for tracking trends over time. The numbers need not be right in absolute terms; they merely need to be wrong in the same way each morning.

## The ETL Problem I Didn't Anticipate

The scale sends multiple packets per measurement. First you receive weight-only packets (`0x20`), then eventually a complete packet with impedance (`0x21`). Sometimes the impedance reading arrives seconds after the weight, like a slow friend catching up at a pedestrian crossing.

I needed an ETL pipeline that could:

1. Group packets into "sessions" (measurements within 30 seconds of each other)
2. Select the best packet from each session (prefer `0x21` over `0x20`)
3. Detect which user profile the measurement belongs to (by weight range)
4. Calculate body composition only if the profile has complete parameters
5. Update existing measurements if superior data arrives later

```python
def group_into_sessions(packets: list[dict], gap_seconds: int = 30) -> list[list[dict]]:
    """Group packets into sessions based on time gaps."""
    if not packets:
        return []

    sessions = []
    current_session = [packets[0]]

    for packet in packets[1:]:
        prev_time = datetime.fromisoformat(current_session[-1]["timestamp"])
        curr_time = datetime.fromisoformat(packet["timestamp"])

        if curr_time - prev_time > timedelta(seconds=gap_seconds):
            sessions.append(current_session)
            current_session = [packet]
        else:
            current_session.append(packet)

    sessions.append(current_session)
    return sessions
```

The ETL also handles the case where you step on the scale without bare feet (weight-only mode). If impedance arrives later for an existing weight measurement, it updates the record rather than creating a duplicate. Idempotency: the quiet virtue.

## The Dashboard

The web interface is a Flask app with Chart.js for visualisation and HTMX for dynamic updates. It presents:

- Latest measurement (weight, body fat %)
- 30-day weight trend chart
- Measurement history table
- Profile selector dropdown
- Profile management modal

![The Scalibur dashboard showing weight trends and body composition metrics](dashboard.png)

```python
@app.route("/")
def index():
    """Render the dashboard."""
    run_etl()  # Process any new packets
    profiles = db.get_profiles()
    profile_id = request.args.get("profile", profiles[0]["id"] if profiles else None)
    latest = db.get_latest_measurement(profile_id=profile_id)
    recent = db.get_measurements(limit=10, profile_id=profile_id)
    return render_template("index.html", latest=latest, recent=recent,
                          profiles=profiles, selected_profile=profile_id)
```

The ETL runs on every page load, so new measurements appear immediately. Not the most elegant architectural decision, but elegance is a luxury for systems that have more than one user at a time. All queries filter by selected profile, so each household member sees only their own data.

## Multi-User Support

After the initial version worked, I encountered a problem I should perhaps have foreseen: my household contains more than one person. The original design assumed a single user with hardcoded height, age, and gender values. Several people in my house objected to being described by my physical parameters.

### Why Not the Scale's User ID?

The BLE packets include a user ID field (bytes 4-5). I tried using this to distinguish users. The scale's internal user management, however, proved to have its own opinions about identity --- the IDs would change unpredictably, in ways I never fully diagnosed and eventually stopped trying to.

### Nearest-Neighbour Classification in One Dimension

The solution was almost disappointingly simple: identify users by weight. Household members typically have non-overlapping weight ranges, so a measurement of 75kg obviously belongs to a different person than one of 55kg. No elaborate biometric scheme required.

```python
def detect_profile(weight_kg: float, profiles: list[dict]) -> dict | None:
    """Find profile where weight falls within min/max range."""
    for profile in profiles:
        min_w = profile.get("min_weight_kg")
        max_w = profile.get("max_weight_kg")
        if min_w is not None and max_w is not None and min_w <= weight_kg <= max_w:
            return profile
    return None
```

Each profile stores a weight range (min/max) plus the body composition parameters (height, age, gender). When a measurement arrives, the ETL matches it to the appropriate profile and calculates body composition accordingly. The system breaks down if two household members converge to the same weight, but at that point you have bigger problems than software architecture.

### Profile Management

The dashboard includes an HTMX-powered modal for managing profiles. Add, edit, or delete without page reloads. When you update a profile's height, age, or gender, all existing measurements for that profile get recalculated with the new values:

```python
@app.route("/api/profiles/<int:profile_id>", methods=["PUT"])
def update_profile(profile_id: int):
    """Update an existing profile."""
    # ... validation and save ...
    db.recalculate_profile_measurements(profile_id)
    return jsonify({"id": profile_id})
```

Retroactive recalculation. Correct your age and your entire body fat history shifts accordingly, which is either reassuring or unsettling depending on temperament.

## Deployment

Getting it onto a Raspberry Pi is a single command:

```bash
PI_USER=pi ./deploy.sh raspberrypi.local
```

This rsyncs the code, installs dependencies via `uv`, and sets up two systemd services:

- `scalibur-scanner.service` - The BLE scanner daemon (needs `CAP_NET_RAW` for raw socket access)
- `scalibur-dashboard.service` - The Flask dashboard on port 5000

SQLite with WAL mode handles concurrent access between the scanner writing packets and the dashboard reading measurements. The dashboard runs database migrations on startup, so existing installations upgrade themselves when new schema changes arrive (like the addition of the profiles table). Hopefully inside the bus rather than under it, but I won't make the perfect the enemy of the good.

## What I Learned

**Low-level BLE is tricky but gratifying.** Most BLE tutorials concern themselves with GATT services and characteristics. Advertisement-based protocols are less commonly documented, but simpler once you grasp HCI packets. The documentation is sparse enough that you feel like an archaeologist.

**Iterative debugging with real hardware is slow.** I spent a lot of time stepping on and off the scale, waiting for packets, scrutinising hex dumps. A proper test suite with captured packets would have saved hours. I did not build one until far too late, because I am a human being and not a pedagogical example.

**Owning your data is worth the bother.** The scale's original app functions well enough. But now I have a SQLite database I can query however I please --- export to CSV, build custom visualisations, integrate with other systems. The entire pipeline from bare feet to bar chart lives under my roof.

**Weight-based identification is surprisingly robust.** My first instinct for multi-user support was to use the scale's built-in user ID field. That proved unreliable. The simpler approach --- identifying people by their weight range --- works better in practice and requires no coordination with the scale's internal state. Sometimes the unsophisticated solution is the correct one, which is a lesson I keep having to relearn.

The code is on [GitHub](https://github.com/gfrmin/scalibur) if you want to try it with your own TY5108 scale or adapt it for similar hardware. The packet parsing logic may work for other cheap BLE scales with minor adjustments --- the protocol appears fairly common among generic Chinese body composition scales, which is either a de facto standard or a shared ancestor. Hard to tell.
