# Internship Tracker + ARIA Assistant

A lightweight, dependency-free static website for tracking an internship period from **16 November 2026, 08:00** to **12 March 2027, 16:00** (Asia/Bangkok).

## Features

- Live countdown, remaining workdays and remaining working hours.
- Today's work/holiday status and timeline progress.
- Monthly calendar with weekdays, weekends, public holidays and days with logs.
- Daily work log with create, edit, delete, category, status and manually entered hours.
- Monthly summaries and lightweight CSS-based charts.
- Export work logs as Excel-compatible CSV (UTF-8 BOM).
- Backup/restore all logs and editable holidays using JSON.
- Print the current report or save it as PDF using the browser's print dialog.
- Editable public-holiday list for organization-specific schedule changes.
- **ARIA Assistant:** animated 3D-style particle orb drawn with Canvas (no image or 3D library).
- ARIA can answer locally about current Bangkok date/time, weekdays, relative dates, the configured holidays, remaining workdays and the internship countdown.
- Optional Thai speech input/output through the browser's Web Speech APIs. Voice replies are off by default and can be enabled by the user.

## Performance and compatibility

- Single HTML file; no framework, external JavaScript library, external font, image request, API request, or backend required.
- The particle animation uses a capped canvas pixel ratio and pauses when the page is in the background or the orb is off-screen. Reduced-motion preferences are respected.
- For voice input, use a supported browser such as current Chrome or Edge and grant microphone permission. Speech recognition availability can vary by browser and may use the browser vendor's online recognition service.
- Thai speech output uses a Thai voice installed/available in the browser. The app prefers a voice whose name suggests a feminine Thai voice when one is available; actual voice/gender depends on the device.
- If speech recognition is unavailable, type questions into the ARIA input instead.

## ARIA example questions

- `วันนี้วันอะไร เวลาเท่าไร`
- `อีก 5 วันเป็นวันอะไร`
- `วันที่ 10 ธันวาคม 2569 เป็นวันหยุดไหม`
- `พรุ่งนี้เป็นวันหยุดไหม`
- `เหลือวันทำงานกี่วัน`
- `เหลืออีกกี่วันถึงวันสิ้นสุดการฝึกงาน`

The local calendar/holiday answers use the holidays configured inside this dashboard. They are not a live official-holiday feed. Add or edit holidays in the Calendar tab when your organization announces additional days off.

## Storage and privacy

This is a static site. Work logs and custom holiday settings are saved in the current browser's `localStorage`. They are **not uploaded to GitHub, Render, or a server**, and do not automatically sync between devices. Use the JSON backup/export and import feature to move data between browsers or devices. ARIA question/answer text is temporary and is not saved. The voice preference is stored locally. Do not enter patient information, personal identifiers, passwords, or other confidential hospital data.

## Deploy to Render

1. Upload `index.html` and `README.md` to the root of a GitHub repository (replace the old files).
2. In Render, choose **New → Static Site** and connect that repository.
3. Configure: Branch `main` (or your deployment branch), Root Directory blank, Build Command `echo "No build step required"`, Publish Directory `.`.
4. Create the Static Site. New commits to the connected branch trigger a new deployment.

## Default schedule

- Working time: 08:00–12:00 and 13:00–16:00 (7 net hours/day).
- Scheduled period: 117 calendar days, 79 workdays, 38 off-days, 553 planned net working hours.
- Default weekday holidays: 7 Dec 2026, 10 Dec 2026, 16 Dec 2026, 31 Dec 2026, 1 Jan 2027 and 22 Feb 2027.
- Holiday settings can be changed in the Calendar tab and are stored locally in the browser.
