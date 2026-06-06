#!/usr/bin/env bash
# gfrm.in PostHog check-in. One command -> the numbers that matter.
#
# Queries the CORRECT project (320861) — NOT the generic keyring POSTHOG_PROJECT_ID
# (137079), which is the unrelated pdm/webbsite project. Creds come from the
# gnome-keyring (service=env), never from ~/.env.
#
# Usage:
#   scripts/posthog-report.sh            # last 30 days
#   DAYS=90 scripts/posthog-report.sh    # custom window
#
# Requires: curl, jq, secret-tool (gnome-keyring).
set -euo pipefail

DAYS="${DAYS:-30}"
PROJECT_ID="${POSTHOG_PROJECT_ID_GFRMIN:-$(secret-tool lookup service env key POSTHOG_PROJECT_ID_GFRMIN 2>/dev/null || echo 320861)}"
KEY="$(secret-tool lookup service env key POSTHOG_PERSONAL_API_KEY 2>/dev/null || true)"
HOST="https://us.posthog.com"

if [ -z "$KEY" ]; then
  echo "Missing POSTHOG_PERSONAL_API_KEY in keyring." >&2
  echo "  printf '%s' \"\$VALUE\" | secret-tool store --label=POSTHOG_PERSONAL_API_KEY service env key POSTHOG_PERSONAL_API_KEY" >&2
  exit 1
fi

# Run a HogQL query, print results as a compact table via jq.
hog() {
  local sql="$1"
  curl -s -X POST \
    -H "Authorization: Bearer $KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -nc --arg q "$sql" '{query: {kind: "HogQLQuery", query: $q}}')" \
    "$HOST/api/projects/$PROJECT_ID/query/" \
    | jq -r '(.columns // ["?"]) as $c
        | ($c | @tsv), (.results[]? | map(tostring) | @tsv)' \
    | column -t -s $'\t'
}

W="interval $DAYS day"
echo "=== gfrm.in PostHog report — last $DAYS days (project $PROJECT_ID) ==="

echo; echo "## Totals ($DAYS d vs prior $DAYS d)"
hog "select 'current' as period, count() as pageviews, count(distinct distinct_id) as visitors
     from events where event='\$pageview' and timestamp > now() - $W
     union all
     select 'previous', count(), count(distinct distinct_id)
     from events where event='\$pageview'
       and timestamp <= now() - $W and timestamp > now() - interval $((DAYS*2)) day"

echo; echo "## Top pages"
hog "select properties.\$pathname as path, count() as views, count(distinct distinct_id) as visitors
     from events where event='\$pageview' and timestamp > now() - $W
     group by path order by views desc limit 20"

echo; echo "## Traffic sources (referrer + utm_source)"
hog "select coalesce(nullif(properties.\$referring_domain,''),'(none)') as referrer,
            coalesce(properties.utm_source,'-') as utm,
            count() as n
     from events where event='\$pageview' and timestamp > now() - $W
     group by referrer, utm order by n desc limit 15"

echo; echo "## Visitors by country"
hog "select properties.\$geoip_country_name as country, count(distinct distinct_id) as visitors
     from events where event='\$pageview' and timestamp > now() - $W
     group by country order by visitors desc limit 12"

echo; echo "## Device"
hog "select properties.\$device_type as device, count(distinct distinct_id) as visitors
     from events where event='\$pageview' and timestamp > now() - $W
     group by device order by visitors desc"

echo; echo "## Language split (EN vs HE)"
hog "select coalesce(properties.site_lang, multiIf(properties.\$pathname like '/he/%','he','en')) as lang,
            count() as views, count(distinct distinct_id) as visitors
     from events where event='\$pageview' and timestamp > now() - $W
     group by lang order by views desc"

echo; echo "## Read-completion by post (needs analytics-events.html deployed)"
hog "select pv.path as post,
            pv.readers as readers,
            pp.finishers as finishers,
            if(pv.readers>0, round(100.0*pp.finishers/pv.readers), 0) as pct_finished
     from (
       select properties.\$pathname as path, count(distinct distinct_id) as readers
       from events where event='\$pageview' and properties.\$pathname like '%/posts/%'
         and timestamp > now() - $W group by path
     ) pv
     left join (
       select slug, count(distinct distinct_id) as finishers
       from (select distinct_id, properties.slug as slug from events
             where event='post_progress' and properties.depth=100
               and timestamp > now() - $W)
       group by slug
     ) pp on pv.path = pp.slug
     order by readers desc limit 15"

echo; echo "## Engagement & conversion events"
hog "select event, count() as n, count(distinct distinct_id) as people
     from events
     where event in ('outbound_click','cta_click','share_click','lang_switch','contact_submitted','post_progress')
       and timestamp > now() - $W
     group by event order by n desc"

echo; echo "## Outbound destinations"
hog "select properties.href as destination, count() as clicks
     from events where event='outbound_click' and timestamp > now() - $W
     group by destination order by clicks desc limit 15"

echo; echo "Done. (Host sanity: every row above is gfrm.in — project $PROJECT_ID.)"
