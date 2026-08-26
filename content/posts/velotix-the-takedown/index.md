---
title: "The Velotix Files, Part 4: The Takedown"
linkTitle: "Part 4: The Takedown"
subtitle: "How a fraudulent DMCA notice filed from Bangladesh, citing an unrelated Israeli newspaper article, tried to take down Part 1 of this series"
description: "On 18 May 2026, Cloudflare forwarded a DMCA copyright complaint targeting the Velotix investigation. The submitter used a disposable email, a Chittagong address, and an Israeli newspaper article about Moshe Kahlon that has nothing to do with Velotix."
author: "Guy Freeman"
date: 2026-05-19
series: [velotix]
series_order: 4
draft: false
categories: [investigation, startups, israel, cyber, policy]
---

## The Notice

On 18 May 2026 at 19:43 UTC — fifty-nine days after [Part 1](/posts/velotix-investigation/) was published — Cloudflare's Trust & Safety team forwarded a DMCA copyright infringement complaint to the abuse address registered on the account that fronts this site. It claimed that the URL

> `https://gfrm.in/posts/velotix-investigation/`

infringed the copyright of themarker.com, the Israeli business daily owned by the Haaretz Group.

The submitter, as recorded in the notice:

| Field | Value |
|---|---|
| Name | Akash Ahmed |
| Email | `akash723@mail4.uk` |
| Address | Chittagong, Bangladesh |
| Country | BD |

Cloudflare assigned the complaint report ID `8582385eacc6ebe8` and forwarded it to this site's hosting provider, GitHub Pages, per its [standard abuse-handling policy](https://www.cloudflare.com/trust-hub/abuse-approach/). The full text of the notice, including all headers, can be [viewed here](velotix-dmca.txt) or [downloaded as a `.eml` file](velotix-dmca.eml). The recipient address has been redacted; nothing else has been altered.

## The Cited Work

The notice identifies one URL as the "original copyrighted work" the submitter claims has been infringed:

> `https://www.themarker.com/news/internal-info/2026-05-18/ty-article/.premium/0000019e-3a86-d394-addf-fbbee3e00000`

The URL resolves to a real article published by themarker.com on the same day the DMCA notice was filed. The headline:

> **אם כבר מודים באשמה, כחלון צריך לשלם על עוד חטא אחד — מידע פנים**
>
> If we're already admitting guilt, Kahlon needs to pay for one more sin — insider information

The article, by columnist Rotem Shtarkman ([רותם שטרקמן](https://www.themarker.com/ty-WRITER/0000017f-da29-d938-a17f-fe2b28340000)), is a daily economic-news round-up published at 18:30 Israel time on 18 May 2026. Its lead item concerns Moshe Kahlon, the former Israeli finance minister, and allegations under the Israeli Securities Law that, while serving as chairman of a company, he failed for approximately four months to disclose material irregularities at its Nazareth branch to the board and to the public. Other items in the same column cover the global economy, AI21 Labs' announcement that it was parting with more than 60% of its employees, and the salary of the CEO of construction firm Tidhar.

It does not mention Velotix.

It does not mention Dr Adi Hod, Uriel Ekstein, PipelBiz, the January 2026 angel investment campaign, the Ministry of Labour enforcement finding, OurCrowd, Sarona Ventures, the insolvency petition, or any subject covered in [Part 1](/posts/velotix-investigation/), [Part 2](/posts/velotix-the-ceo/), or [Part 3](/posts/velotix-marketing-machine/) of this series.

It does not mention this site, this author, or any subject covered on this site.

[Part 1](/posts/velotix-investigation/) of this series, which the notice seeks to remove, contains no quotation from, paraphrase of, or reference to the themarker article cited in the notice. The cited article had not been published when [Part 1](/posts/velotix-investigation/) was written. There is no part of [Part 1](/posts/velotix-investigation/) — or of any other post on this site — that could have infringed the copyright in the cited article.

## The Submitter

`akash723@mail4.uk` is an address at a disposable email provider. The domain mail4.uk is operated by [InstAddr](https://m.kuku.lu/en.php), a service that generates unlimited throwaway email addresses without requiring registration. The domain itself was [registered](https://www.who.is/whois/mail4.uk) on 17 May 2024 via Cloudflare Registrar; its WHOIS record is privacy-shielded. [IPQualityScore](https://www.ipqualityscore.com/domain-reputation/mail4.uk) classifies it as disposable and rates it 95 out of 100 for abuse risk. It appears on the canonical community-maintained [disposable-email-domains blocklist](https://github.com/disposable-email-domains/disposable-email-domains) used by major email providers to filter throwaway addresses.

The address fields in the notice contain no street name, no apartment number, and no postal code. "Chittagong" is entered three times, followed by "BD."

A search of the [Lumen Database](https://lumendatabase.org/notices/search) on 19 May 2026 returned no prior DMCA notices filed by `akash723@mail4.uk`, by any other `@mail4.uk` address, by "Akash Ahmed" of Chittagong, or against the domain `gfrm.in`. The 2026-05-18 notice has not yet been forwarded by Cloudflare to Lumen — such notices are often published only after a delay of days or weeks — and may appear later.

A DMCA notice does not require the submitter to verify their identity, to demonstrate authority to act for the rights holder, or to produce the work allegedly infringed. It does require the submitter to declare a good-faith belief that the targeted use is not authorised. 17 U.S.C. § 512(f) imposes liability on any person who knowingly materially misrepresents that material is infringing.

themarker.com is published by Haaretz Newspapers Ltd., headquartered in Tel Aviv.

## The Pattern

The reputation-management industry that monetises fraudulent DMCA notices is well-documented. The cases on the public record fall into roughly three families.

**Backdated articles.** The Spanish firm Eliminalia, later rebranded iData Protection S.L., was exposed by the [Forbidden Stories consortium](https://forbiddenstories.org/story-killers/the-gravediggers-eliminalia/) and the [Washington Post](https://www.washingtonpost.com/investigations/interactive/2023/eliminalia-fake-news-misinformation/) in 2023. Leaked documents revealed nearly 1,500 clients, more than 600 fake news websites used as laundering vehicles, and thousands of fraudulent copyright complaints. The technique: clone the target article to a fabricated news site, alter its publication date to predate the original, then file a DMCA notice claiming the original is the infringement.

**Fake journalist personas.** The Indian firm Initiatrix Technologies, operating from Noida, was [traced by Qurium Media Foundation](https://www.qurium.org/alerts/the-delete-negative-links-industry/) in April 2024 after attempting to suppress an investigation by the Peruvian newspaper *Ojo Público*. The notice was filed under the name Alissa Muncy, purportedly acting for a former Newsweek correspondent; the article it claimed had been infringed did not exist. Timezone metadata in the filing (GMT+05:30) placed the operation in India.

**Unrelated genuine articles.** The third variant cites a real, current article from a real publication — but one the target has never seen and does not refer to. Techdirt [documented](https://www.techdirt.com/2026/04/09/someone-filed-a-bogus-dmca-notice-to-kill-a-story-about-a-sketchy-seo-firm-it-worked-briefly/) a recent example in April 2026: an investigation into the SEO firm Clickout Media was briefly removed by Google after a DMCA notice cited an unrelated article in The Verge about Google's enforcement against sketchy SEO practices.

The notice received on 18 May 2026 fits the third pattern.

The economics are straightforward. The Lumen Database's 2022 [study](https://lumendatabase.org/blog_entries/over-thirty-thousand-dmca-notices-reveal-an-organized-attempt-to-abuse-copyright-law) of roughly 34,000 coordinated fraudulent notices targeting more than 550 domains found that just 0.8% of them succeeded in delisting legitimate content. Volume makes it profitable even so. The labour is cheap and outsourced: "remove negative Google result" services are openly advertised on freelance marketplaces such as Fiverr and Upwork, sold largely by operators in India, Pakistan, and increasingly Bangladesh, where the gap between local wages and Western ones is the whole point.

The notice does not identify who, if anyone, retained Akash Ahmed of Chittagong to file a DMCA complaint in themarker.com's name.

themarker.com has not, to my knowledge, asked anyone to take down Part 1 of this series.

## Next

Cloudflare has forwarded the notice to GitHub Pages. As of writing, GitHub has not acted on it. If GitHub does, a counter-notice under [17 U.S.C. § 512(g)](https://www.copyright.gov/title17/92chap5.html#512) will follow; the cited "original work" being an unrelated article about a former Israeli finance minister is, on the face of it, a sufficient response.

As of writing, no DMCA notices have been filed in respect of [Part 2](/posts/velotix-the-ceo/), [Part 3](/posts/velotix-marketing-machine/), or this post. This page will be updated if that changes.

The complete notice, with all mail headers preserved, can be [viewed as text](velotix-dmca.txt) or [downloaded as a `.eml` file](velotix-dmca.eml).

