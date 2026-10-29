---
title: "Station by Station"
kicker: "Election night"
subtitle: "On election night my live seat projection put an Arab party out of the Knesset that every exit poll had at seven seats. It wasn't a modelling mistake."
description: "A live election projection on bechirot.fyi failed on the night of Israel's 26th Knesset election, 27–28 October 2026. The cause was not the model but the data: the Central Elections Committee's results file now lists a town only once it reports, and reports it as its polling stations come in, so the projection filled in nothing and treated half-counted cities as complete. The fix was first a refusal, then a rebuild at the level of the polling station."
author: "Guy Freeman"
date: 2026-10-28
draft: false
categories: [essays, bayesian, israel, data]
---

*What the count showed by morning, polling place by polling place, is in [Polling Place by Polling Place](/posts/election-2026-polling-place-by-polling-place/).*

At sixteen minutes past two in the morning, Israel time, [bechirot.fyi/live](https://bechirot.fyi/en/live) started showing the count of the election to the 26th Knesset. Above the count sat a seat projection: the 120 seats as they would fall once everything was counted. It put Likud on 31 and Ra'am, the United Arab List, below the electoral threshold, out of the Knesset.

Four hours earlier, every television exit poll had given Ra'am seven seats.

There are two lazy readings of a gap like that. One is that the exit polls were wrong, as they sometimes are. The other is that the projection was wrong, as new models usually are. Both readings skip the useful question, which is *what was the projection looking at?* The answer turned out to be: almost nothing, labelled as almost everything.

I was in Hong Kong, six hours ahead, where the exit polls had come out at four in the morning. The site was being run by a coding agent, Claude Code, against a checklist we had written beforehand: the same habit I have written about in [disciplining the coding agent](/series/coding-agents/), applied to a night rather than a codebase. What follows is what it found and what we built in the next few hours.

{{< callout type="note" >}}
**In short**

- **What the live page showed.** From 02:16, Israel time, a seat projection with Likud on 31 and Ra'am out of the Knesset. The fix went live shortly after 03:26, and a second projection, built station by station, went up at 03:45. By 05:58 both projections had Likud on 27 and the Netanyahu bloc on 54; they still differed on Ra'am, 5 or 7.
- **Why.** Not the model but the data: the committee's 2026 file lists a town only once it reports, and reports it in pieces, so the projection filled in nothing and took half-counted cities as complete.
- **What I would keep.** Rehearse on the shape of the next file, not the contents of the last one. Let the estimator say "not yet", and make that the default. Keep every version of every file.

Written while the count was still running: the tables run to the committee's 05:58 file. What the count showed by 10:02 is in [Polling Place by Polling Place](/posts/election-2026-polling-place-by-polling-place/).
{{< /callout >}}

## The projection had been rehearsed on the wrong file

The method behind the projection is not exotic. The Central Elections Committee publishes a results file during the count, with one row per locality, updated as polling stations report. For every town not yet counted, the projection predicts its vote from towns that voted like it last time. It does this with a regression on a few principal components of each town's past results, it sorts towns into two camps by how they voted before, and it scales by the turnout change seen in the towns already counted. It had been backtested on four previous elections, replaying each count in several orders, and its error band came from those replays.

All of that was rehearsed against the final file from the previous election, in 2022. The projection was written to fill in *the localities the file lists*, a sensible guard to stop a town that has since been merged into another from being counted twice. It assumed the file lists every locality whether or not it has reported. Only the final version of the 2022 file is archived, so I cannot now check whether that was ever true during a count. The code simply assumed it.

The 2026 file lists a locality only once it reports. At 02:14 it had 146 rows. So "the localities the file lists" meant "the localities already counted". The projection dutifully filled in every one of the uncounted towns it was allowed to fill in, which was none of them. It then reported the 93,680 votes it had been given as "80% of the expected vote". The real figure was under 2%.

There was a second assumption hiding behind the first: that a town appears once it is fully counted. The 2026 file reports it as its stations come in. Haifa was in the file with 12,907 votes, a fraction of its electorate. The projection took every listed town as complete. So it read the half-counted cities as a collapse in turnout and scaled everything else down to match.

Neither of these is a bug you can find by staring at the model. The model was fine. The world it was rehearsed in was not the world it was deployed into, and the difference was in the shape of a CSV file. I have [written before](/posts/the-gate-that-said-no/) about measurements that flatter the thing you built. This is the cousin of that failure: a rehearsal that flatters you because it replays the last performance rather than the next one.

## The first fix was a refusal

Correcting the two data errors was quick. A town under 70% of its previous election's vote is treated as partly counted: its votes are a floor, and the rest of it is filled in. The file's list of localities restricts the fill-in only when the file also lists towns that have not reported.

With both fixes the projection's total came to about 5.5 million valid votes, which is plausible for 77.7% turnout. It still put Ra'am at zero.

That is when the useful question changed from *what is wrong with the arithmetic* to *what can this thing possibly know*. The model sorts localities into two camps, learned from past voting. One of them is, in practice, the Arab-majority towns: Nazareth, Akko, Rahat, Tayibe, Sakhnin. At 02:14, four of its 143 towns had reported, with 1,523 votes between them. A regression asked to predict Ra'am's vote in Rahat from a hundred small Jewish towns and four Arab ones is not making a forecast. It is extrapolating a party's support into the only places it has none of the evidence for.

So the fix that mattered was a gate: no projection until each camp has at least ten whole towns counted. Until then the page shows the counted seats, labelled as counted so far, which is all the data can honestly support. Running the fixed code on the 02:14 file produced exactly the answer it should have: nothing.

The pattern I keep relearning is that the most useful thing an estimator can do on a hard night is decline. A projection that stays silent while a whole sector of the electorate is unseen is a better instrument than one that speaks for that sector with the confidence it has about the rest.

## What the exit polls were doing at one in the morning

While the count crawled, the channels kept [updating their exit polls](https://www.israelhayom.co.il/news/politics/article/21720077). Channel 13's moved Likud from 25 to 27. Channel 14's took Yisrael Beiteinu below the threshold and gave the Netanyahu bloc 62. My first reaction was the reader's reaction: how are they predicting final results already?

They are not predicting from the count the way the projection does. An exit poll is built from interviews with voters leaving a sample of polling stations. When those same stations are counted, the pollster sees how far the interviews were off *in those stations*: refusals, shy voters, sectors the interviewers under-sampled. They then correct the whole poll by that error. The final turnout gives a second correction: the interviews stop before the polls close, and the people who vote late are not the people who vote early. One pollster revised his poll after the final turnout figure and said so on air.

That is a station-level method, and it pointed at the better design. The problem with the town projection was never the regression. It was that the town is the wrong unit when towns are reported in pieces.

## Station by station

The Central Elections Committee also publishes the count per polling station, and its 2022 per-station file is still online. Polling station numbers are mostly stable between elections. Of the 908 stations counted at 02:38, 564 matched a 2022 station in the same locality with the same number. Their eligible-voter counts agreed: median ratio 1.01, with 94% within 20%.

With stations matched, the classic tool is the one political scientists call ecological regression, after Goodman. In each counted station, each 2026 list's vote is modelled as a mixture of that station's 2022 votes by list, plus its 2022 non-voters:

$$ y_{j}(s) = \sum_k \beta_{jk} \, x_k(s), $$

where \(x_k(s)\) is the 2022 vote for list \(k\) in station \(s\), scaled by the change in its eligible voters, with one extra \(k\) for the people who did not vote in 2022. Each \(\beta_{jk}\) reads, loosely, as the share of list \(k\)'s 2022 voters who voted for list \(j\) this time. It is fitted by non-negative least squares, because a negative flow of voters is not a thing. The non-voter column is what lets it see a turnout surge rather than mistake it for a shift between parties: this was an election in which Arab turnout was reported near 80% (76.9% in the polling places the Arab lists won in 2022, on the committee's 10:02 file).

Goodman's method rests on one strong assumption: that the flows are the same everywhere, so that a 2022 Joint List voter in Rahat moves like one in Haifa. The \(\beta\)s are fitted once, from whichever stations have been counted, and applied to every station that has not.

Every 2022 station not yet counted is then predicted from its own 2022 result. A counted 2026 station with no 2022 match adds its votes, and takes its eligible voters off its town's uncounted stations, so nothing is counted twice. Because it works station by station, a half-counted city is not a problem at all: its counted stations are counted, and its others are predicted.

On the 02:38 file it gave:

| List | Projected seats | 90% range (too narrow) |
|---|---|---|
| Likud | 28 | 27–29 |
| Yashar! (Eisenkot) | 21 | 20–22 |
| Joint List | 13 | 11–16 |
| Together (Bennett) | 11 | 10–11 |
| The Democrats | 8 | 7–8 |
| Yisrael Beiteinu | 8 | 7–8 |
| Otzma Yehudit | 7 | 7–8 |
| Religious Zionism | 7 | 6–7 |
| Shas | 7 | 6–7 |
| UTJ | 6 | 6–7 |
| Ra'am | 4 | 4–5 |

The blocs came to Netanyahu 55, the change bloc 48 and the Arab lists 17. Five TV exit polls averaged 53, 50 and 17.

It went on the live page, under a heading that says *experimental*. The page carries three caveats in so many words:

- It was built on the night and never tested on a past election.
- Its ranges are too narrow.
- While few Arab-majority stations are counted, the split between the two Arab lists is not to be relied on. This is the constancy assumption failing in plain sight. At 02:38 it was 9 of the 1,606 stations that had an Arab majority in 2022, nearly all of them in Haifa and the Galilee, where the Joint List is strong. Ra'am's base in the Negev and the Triangle had not reported, which is why Ra'am's 4 is almost certainly too low and the Joint List's 13 too high. Their sum matched the exit polls.

The ranges deserve a sentence of their own. They come from a bootstrap that resamples the towns already counted. A bootstrap can only tell you how much your answer would move if you had drawn a different sample *from the same population*. The stations counted by 02:38 are not a sample from the same population as the stations counted by 06:00: small kibbutzim count fast, cities and the Negev count slowly. The honest uncertainty is the bootstrap's plus the error of assuming the uncounted resemble the counted, and only a backtest over real counting orders can measure the second. For the town projection we had that backtest. For the station projection we did not, because the 2022 per-station file holds only the final count, with no record of which station came in when.

## Four numbers on one page

By four in the morning the live page carried four different answers to the question "how many seats?", and it is worth being exact about what each one is.

- **The exit polls.** Five channels' estimates at 22:00: Kan 11, Channel 12, Channel 13, Channel 14 and i24NEWS. Each was copied by hand from the channel's own published figures, each summed to 120, and each is linked to its source on the live page. They are interviews, not counts.
- **The seats if the count stopped now.** Bader-Ofer on the votes counted so far: the 3.25% threshold, then the division, with the six surplus agreements the committee published in October. No modelling at all. It answers a question nobody is asking, but it is the only one of the four that is a fact.
- **The town projection.** Every town not yet counted filled in from towns that voted like it in the past, as above. It shows nothing until each camp has ten whole towns counted. Its range is the error it made at that much counted when the last four elections were replayed.
- **The station projection.** Every station not yet counted filled in from its own 2022 result, through the flows estimated from the counted stations. Its range is the bootstrap, and it is too narrow.

## The night, file by file

Through the night the committee kept publishing new versions of its results files. Each locality file had a station file with the same vote total beside it, released within minutes. Every version is kept, so each one can be run again. The tables below are those reruns: the town projection as the code on the site now stands, and the station script as it ran on the night. They are not screenshots of the page. The page showed the broken town projection until the fix deployed, shortly after 03:26, and the station panel went up at 03:45. The time in each row is the earlier of the two files. The early station rows were never on the page; I ran them afterwards, to see what the method would have said.

The blocs are the newspapers' grouping, which the exit polls themselves were reported in, not a judgement of mine. Netanyahu's bloc is Likud, Otzma Yehudit, Religious Zionism, Shas and UTJ. The change bloc is Yashar!, Together, the Democrats and Yisrael Beiteinu. The Arab lists are the Joint List and Ra'am. The share counted is the votes counted over the 5.5 million or so valid votes both projections expected by the end.

{{< election-night-table table="blocs" >}}

Four things stand out.

**The count on its own is the worst guide.** On the first file, 2,661 votes from fifteen polling stations, the counted seats gave Netanyahu's bloc 75 and Religious Zionism 22. Five hours later it still gave Likud 29 and Ra'am 4. The Arab lists sat at zero until two in the morning and at half or less of the weight either projection gave them until nearly five. That is not noise. It is the counting order: Arab towns, and big cities generally, count late. A graphic of the count alone, which is what most of the night's coverage showed, tells you mostly which places count fast.

**The station projection was wild until it was not.** On fifteen stations it put Yisrael Beiteinu on 19. On 128 it had Likud on 29, close, but its 13 seats for the Arab lists rested on a single Arab-majority station. At 02:14, with three Arab-majority stations counted out of 1,606, it gave the Joint List 18 seats: three stations' flows, applied to the whole Arab electorate. This is exactly the failure the caveat on the panel describes, and it is why the panel carries a warning on the Arab split until a quarter of those stations are in. (These are stations, matched to their 2022 selves, so the count is not the same thing as the town projection's camp of towns.) By that rule the warning was still up at 05:14, with 138 of 1,606 counted. From 03:25, with 27 Arab-majority stations counted, it hardly moved again: Likud 27, Yashar! 21, the Joint List 11 or 12, Ra'am 7 or 8, and blocs of 54, 47 or 48, and 18 or 19.

**The town projection never said anything silly, because it said nothing until it could.** Its gate opened on the 03:25 file, at about 11% counted on this measure and 12% on its own. From then its blocs moved by at most one seat a file. That is the refusal paying for itself.

**Where the two disagree is where the evidence is thinnest.** At 05:14, a third counted:

{{< election-night-table table="lists" at="05:14" >}}

The town projection's backtested error at this much counted is two seats a list either way, and every station figure falls inside it. The town figure falls outside the station projection's range twice, for Yashar! and Ra'am, which says more about how narrow those ranges are than about either figure. What matters is that the small differences all lean the same way, and they add up in the bloc that decides the government. The town projection gives the change bloc 50 and the Arab lists 16, the station projection 47 and 19. Ra'am is the largest single gap: 5 against 7. The exit polls all said 7. On this one the station projection agrees with the polls and the town projection does not. That is not a verdict either way. The exit polls are interviews in a sample of stations. And at 05:14 the stations counted had held only 6% of Ra'am's 2022 vote: none of Rahat's 64 stations, none of Kafr Qasim's 29 or Tamra's 42. Both projections were filling in Ra'am almost entirely from its 2022 map. They differ in how they carry that map forward, and the next files will say which carried it better.

*Update, 29 October.* They have, provisionally. On the committee's 07:00 file Ra'am stands at 8 as counted, 8 on the station projection and 7 on the town projection. The town projection under-filled Ra'am's strongholds and caught up as Rahat, Kafr Qasim and Tamra reported; the station projection was right or slightly low throughout. The envelope ballots, which usually trim the Arab lists, are still to come.

Two methods agreeing is also weaker evidence than it sounds. Both read the same early, fast-counting places, so where they agree they may share one error.

## How it did

The count was still running when I wrote this. This is the latest file the tables include:

{{< election-night-table table="lists" >}}

The real test is the certified result. Every version of every file is kept, so the comparison can be made at each one: the station projection against the final seats, with the town projection beside it from the moment its gate opened. Three questions will settle it. At what share counted did each projection come within a seat of the final result for every list? Did the Arab split converge once the Negev and the Triangle reported, and how fast? And how often did the final seat count fall outside the bootstrap's 90% range? That last one measures how much too narrow it was.

By 10:02 on the 28th the committee's file held 3.76 million valid votes. What that file shows, polling place by polling place, is in [Polling Place by Polling Place](/posts/election-2026-polling-place-by-polling-place/).

## What I would keep

Three things, none of them about elections in particular.

**Rehearse on the next file, not the last one.** Every check before the night was run against the 2022 file, because that was the file we had. The first 2026 results file was online at 19:20, hours before the polls closed: the right column headers and no rows. A count that starts from no rows cannot list every locality from the start, so the first broken assumption was visible then. A rehearsal that diffs the new source's *shape* against the old one, not just its contents, would have caught both.

**Make the estimator able to say "not yet," and make that the default.** The gate that held the town projection back did more good on the night than any of the arithmetic. It cost a few lines and one constant: ten whole towns in each camp.

**Keep every version of everything.** All night, every distinct version of every file the committee published was kept, content-addressed and never overwritten, then copied offsite every ten minutes. That is what makes the "how it did" section above possible to write honestly. Without the versions it would be reconstructed from memory, which is the one source I trust least on a night like this.
