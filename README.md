# Internship Tracker Dashboard

A lightweight, dependency-free static website for tracking an internship period from **16 November 2026, 08:00** to **12 March 2027, 16:00** (Asia/Bangkok).

## Features

- Live countdown, remaining workdays and remaining working hours.
- Today's work/holiday status and timeline progress.
- Monthly calendar with weekdays, weekends, public holidays and days with logs.
- Daily work log with create, edit, delete, category, status and manually entered hours.
- Monthly summaries and simple CSS-based charts.
- Export work logs as Excel-compatible CSV (UTF-8 BOM).
- Backup/restore all logs and editable holidays using JSON.
- Print the current report or save it as PDF using the browser's print dialog.
- Editable public-holiday list for organization-specific schedule changes.

## Storage and privacy

This is a static site. Work logs and custom holiday settings are saved in the current browser's `localStorage`. They are **not uploaded to GitHub, Render, or a server**, and do not automatically sync between devices. Use the JSON backup/export and import feature to move data between browsers or devices. Do not enter patient information, personal identifiers, passwords, or other confidential hospital data.

The dashboard is intentionally built without external libraries, APIs, fonts, a database, or a server-side runtime to keep it fast and simple to deploy.

## Deploy to Render

1. Upload `index.html` and `README.md` to the root of a GitHub repository (replace the old files).
2. In Render, choose **New → Static Site** and connect that repository.
3. Configure:
   - Branch: `main` (or the branch containing the files)
   - Root Directory: leave blank
   - Build Command: `echo "No build step required"`
   - Publish Directory: `.`
4. Create the Static Site. Render will provide the public URL.

New commits to the connected branch trigger a new deployment.

## Default schedule

- Working time: 08:00–12:00 and 13:00–16:00 (7 net hours/day).
- Scheduled period: 117 calendar days, 79 workdays, 38 off-days, 553 planned net working hours.
- Default weekday holidays: 7 Dec 2026, 10 Dec 2026, 16 Dec 2026, 31 Dec 2026, 1 Jan 2027 and 22 Feb 2027.
- Holiday settings can be changed in the Calendar tab and are stored locally in the browser.
