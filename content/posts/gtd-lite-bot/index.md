---
title: "I Built a GTD Telegram Bot in Under an Hour with Claude Code"
subtitle: "Using Claude Haiku for natural language task parsing"
description: "How I built a Getting Things Done Telegram bot with natural language parsing using Claude Haiku, Python, and PostgreSQL - all in under an hour with Claude Code."
author: "Guy Freeman"
date: 2025-12-20
categories: [telegram, ai, productivity, python]
image: og-image.png
---

Every GTD app I've tried commits one of two sins. Either it's a Byzantine fortress of features --- Kanban boards, team collaboration, productivity gamification, the full catastrophe (looking at you, OmniFocus) --- or it's simple but demands you learn its particular syntax for categorising things, which rather defeats the purpose of a system meant to get tasks out of your head quickly.

What I actually wanted was to type "buy milk tomorrow" into my phone and have it land in the right place. No app switching. No form fields. No learning a miniature programming language just to add a grocery item.

## The Absence

Todoist, to its credit, has excellent natural language parsing. You can type "Call dentist next Tuesday at 2pm #errands" and it does the right thing. But Todoist is a jumbo jet when I need a bicycle. I don't want team collaboration features. I want a scratchpad that understands English.

Telegram, meanwhile, is already on my phone, always running, and has an excellent bot API. The intersection of these two facts seemed promising. Surely someone had built a proper GTD bot?

I looked. There are todo list bots, reminder bots, note-taking bots. But nothing that implements actual GTD methodology --- the inbox/next/scheduled/someday workflow that David Allen describes --- with natural language understanding. The niche was sitting there, unoccupied, like a parking space in central London. Suspicious, but real.

So I built one.

## The Solution: 839 Lines of Python

[Jarvis Lite](https://github.com/gfrmin/jarvis-lite) is a single-file Python bot that implements GTD principles with Claude Haiku handling all the natural language parsing. The entire thing took under an hour to build using [Claude Code](https://claude.ai/code), which I mention not to brag but because it still surprises me.

The stack:

- **python-telegram-bot** for the Telegram integration
- **PostgreSQL** for persistent storage
- **Claude Haiku** for parsing natural language into structured actions
- **APScheduler** for the daily morning digest

One-click deployment to Render with a managed Postgres database.

## How It Works

### Natural Language Parsing with Claude Haiku

The key realisation is that you don't need custom NLP libraries or bespoke models for this. Claude Haiku is fast, cheap, and remarkably good at intent classification. Every message gets parsed through this system prompt:

```python
system_prompt = f"""You are a GTD task parser. Parse the user's message into a JSON action.

Today's date is {today_date}.

Actions:
- add: Add a new task. Extract the task text (keep @tags in the text) and determine the list.
- complete: Mark a task as done. Look for "done", "finished", "complete", etc.
- delete: Remove a task. Look for "delete", "remove", etc.
- move: Move a task to a different list. Look for "move X to Y", "X to next", "X scheduled tomorrow".
- show: Display tasks. Look for "show", "list", "what's next", etc. Can filter by @tag.
- review: Weekly review. Look for "review", "weekly review", etc.
- today: Mark a task for today's focus. Look for "today X", "focus X", "star X".
- clear_today: Clear all today markers.
- process: Start inbox processing. Look for "process", "process inbox", "triage".
- help: User needs help.

Lists:
- inbox: Default for new tasks without a specific list
- next: Tasks to do within 7 days. Look for "#next", "next:", or context implying urgency
- scheduled: Tasks with a due date. Parse dates like "tomorrow", "next monday", "Dec 15", etc.
- someday: Future/maybe tasks. Look for "someday", "maybe", "later", etc.

Context tags (@work, @home, @errands, etc.) should be kept in the task text as-is.

Respond with ONLY valid JSON, no other text:
{{
  "action": "add|complete|delete|move|show|review|today|clear_today|process|help|unknown",
  "text": "task text if adding (include @tags)",
  "list": "inbox|next|scheduled|someday|today|null",
  "task_id": null or number,
  "due_date": null or "YYYY-MM-DD",
  "text_match": "partial text to match for completion",
  "tag": "tag name without @ for filtering"
}}"""
```

The examples section (omitted for brevity) shows Haiku how to handle inputs like:

- "Buy milk" → `{"action": "add", "text": "Buy milk", "list": "inbox"}`
- "Call bank tomorrow" → `{"action": "add", "text": "Call bank", "list": "scheduled", "due_date": "2025-12-21"}`
- "#next: finish report @work" → `{"action": "add", "text": "finish report @work", "list": "next"}`
- "Done: buy milk" → `{"action": "complete", "text_match": "buy milk"}`
- "3 to next" → `{"action": "move", "task_id": 3, "list": "next"}`

Haiku returns structured JSON that the bot acts on. If parsing fails or the action is unrecognised, the message gets added to inbox as a fallback --- you never lose a thought. This is important. The whole point of GTD is that capture should have approximately zero friction, and "I typed something ambiguous and the system ate it" is the opposite of that.

### The GTD Data Model

The database schema is minimal:

```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    text TEXT NOT NULL,
    list VARCHAR(20) NOT NULL DEFAULT 'inbox',
    due_date DATE,
    is_today BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
)
```

Four lists, matching GTD methodology:

- **inbox**: Capture everything, process later
- **next**: Actionable tasks for this week
- **scheduled**: Tasks with specific due dates
- **someday**: Maybe/future items

The `is_today` flag lets you pick 3--5 tasks for daily focus --- a key GTD concept that most apps quietly ignore, presumably because it doesn't look good in screenshots. Context tags like `@work` or `@errands` live in the task text itself and are searchable via "show @work".

### Morning Digest

APScheduler sends a daily summary at 7am containing:

- Your today's focus tasks
- Overdue items
- Tasks due today
- Suggested next actions

This replaces the need to open an app and manually review. The bot comes to you, which is how a productivity system should work --- the tool should be more organised than you are.

## Building with Claude Code

The entire bot --- from nothing to deployed --- took under an hour with Claude Code. The process was roughly:

1. I described what I wanted: a GTD Telegram bot with natural language parsing
2. Claude Code generated the initial bot.py with the Haiku integration
3. We iterated on the prompt engineering to improve parsing accuracy
4. Claude Code added the database layer, then deployment configs for Render
5. I deployed, tested with real messages, and refined

The prompt engineering phase was the bulk of the work, and this is where the Claude Code workflow earns its keep. Refining how Haiku interprets ambiguous messages --- does "milk tomorrow" mean "add a task about milk, due tomorrow" or "add a task called 'milk tomorrow'"? --- is fiddly work that benefits from having a collaborator who doesn't get bored of the iteration cycle.

## Try It

The bot is live at [@gtdlitebot](https://t.me/gtdlitebot) --- though it's currently single-user (me). The code is on [GitHub](https://github.com/gfrmin/jarvis-lite) if you want to deploy your own instance.

## What's Missing

This is a v0.1, and the list of things it doesn't do is longer than the list of things it does, which is normal for anything built in an hour.

**Recurring tasks**: "Water plants every Sunday" doesn't work yet. Would need a recurrence pattern in the schema and logic to regenerate tasks. The plants are, for now, at the mercy of my memory.

**Projects and areas**: Real GTD has hierarchical projects. Currently everything is flat. You can approximate it with tags, but it's not the same and I'm not going to pretend otherwise.

**Voice input**: Telegram supports voice messages. Whisper transcription could make capture even more frictionless --- you'd just mutter at your phone, which is how I add most tasks mentally anyway.

**Time-based reminders**: Push notifications at specific times, not just the morning digest.

**Calendar sync**: Export scheduled tasks to Google Calendar.

**Analytics**: What days am I most productive? What contexts get neglected? The data is there; the dashboard isn't.

For now, though, it does what I need. I type a thought in natural language, it lands in the right GTD bucket, and my inbox gets processed. 839 lines of Python, one LLM as a parsing layer, built in an hour. The ratio of usefulness to effort is, upon consideration, rather good.
