# Internship Tracker + ARIA AI Assistant v4.1 (Gemini)

A single-service Node/Express deployment that preserves the internship dashboard and runs ARIA through the Gemini Developer API. Gemini is called only from the server; the browser never receives the API key.

## What's included

- Internship Dashboard: live countdown, workday/hour calculations, calendar, editable holidays, work logs, reports, CSV/PDF export, and JSON backup/restore.
- ARIA assistant: Thai natural-language conversation using Gemini `generateContent` (default model: `gemini-3.1-flash-lite`; configurable with `GEMINI_MODEL`).
- Function/tool calling: current Bangkok time, date/holiday status, internship progress, work-log summary/search (only after user opt-in), and current/3-day weather.
- Browser voice input/output using the Thai speech voices available on the device.
- Weather based on browser-granted coordinates and Open-Meteo. Location is optional.
- Security controls: server-side API key, password gate, signed HttpOnly session cookie, same-origin checks, rate limits, request-size limits, and Helmet security headers.

## Important privacy notes

- **Do not enter patient names, hospital numbers, diagnoses, medical records, credentials, or confidential hospital information** into Work Log or ARIA.
- Gemini API Free Tier usage is subject to Google's current free-tier terms. Google's pricing page states that free-tier content may be used to improve products. Do not send confidential or sensitive information to the free tier. Review Google's current [Gemini API Terms](https://ai.google.dev/gemini-api/terms) before use.
- Work-log access is off by default. When the user enables consent, the app sends only date/title/category/hours/status (not the free-text detail field) with an AI question. ARIA receives the work-log data only when it calls the relevant tool.
- Browser geolocation is requested only after the user clicks the location button. Coordinates are kept in page memory and are sent to the backend only for an AI weather question; they are not saved in server files or Local Storage.
- The Gemini API key is read only by `server.js` from `GEMINI_API_KEY`. Never put it in `public/index.html`, `public/app.js`, GitHub, or a committed `.env` file.
- The login password is configured server-side and should be at least 12 characters. Sessions use a signed HttpOnly cookie and expire after 12 hours. Login and chat endpoints are rate-limited.
- Conversation context is held in memory in the current browser tab and submitted to Gemini for follow-up context. It is not written to the app's Local Storage or a server database.
- Work logs and holidays remain in the browser's Local Storage using the existing v3/v4 key. They are not moved into a server database and do not sync between devices.

## Local development (Windows / PowerShell)

1. Install Node.js 20 or newer.
2. Open PowerShell in this project folder.
3. Install packages:

   ```powershell
   npm install
   ```

4. Copy `.env.example` to `.env` and set:
   - `GEMINI_API_KEY`: your key from [Google AI Studio](https://aistudio.google.com/api-keys).
   - `GEMINI_MODEL`: defaults to `gemini-3.1-flash-lite`.
   - `ARIA_ACCESS_PASSWORD`: a private password of at least 12 characters.
   - `SESSION_SECRET`: random text of at least 32 characters. Generate one with:

   ```powershell
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

5. Start the app:

   ```powershell
   npm start
   ```

6. Open `http://localhost:10000`.

The browser geolocation and microphone features work on HTTPS sites and on localhost. Weather requires an internet connection.

## Deploy to Render

This app must run as a **Render Web Service**, not a Static Site, because it includes the server-side Gemini integration.

### GitHub file structure

Upload the complete project contents into the repository root:

```text
.
├── public/
│   ├── index.html
│   └── app.js
├── server.js
├── package.json
├── render.yaml
├── .env.example
├── .gitignore
└── README.md
```

Do not upload `node_modules` or a real `.env` file. Keep any old v3 root-level `index.html` as a backup until the new Web Service is confirmed.

### Render setup

1. Push the project files to GitHub.
2. In [Render Dashboard](https://dashboard.render.com/), choose **New → Web Service** and connect the repository.
3. Use:
   - Runtime: `Node`
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Node version: `20`
4. In the Render service's **Environment** page, add:

   | Key | Value |
   |---|---|
   | `GEMINI_API_KEY` | Paste your Gemini API key here (secret) |
   | `GEMINI_MODEL` | `gemini-3.1-flash-lite` |
   | `ARIA_ACCESS_PASSWORD` | Your own password, at least 12 characters |
   | `SESSION_SECRET` | Random secret, at least 32 characters |
   | `NODE_ENV` | `production` |

   If the Render service still has old `OPENAI_API_KEY` or `OPENAI_MODEL` variables, remove them; this Gemini build does not use them. Never share the API key in chat or commit it to GitHub.

5. Save the environment settings and deploy. Check:

   `https://YOUR-SERVICE.onrender.com/api/health`

   Expected response after all variables are set: `{"ok":true,"ready":true}`.

6. Open the service URL, enter the `ARIA_ACCESS_PASSWORD`, and test:
   - `พรุ่งนี้เป็นวันอะไร`
   - `วันที่ 10 ธันวาคม 2569 เป็นวันหยุดไหม`
   - `ฉันเหลือวันทำงานอีกกี่วัน`
   - `ช่วยอธิบายความแตกต่างระหว่าง API กับ Backend ให้หน่อย`

7. For weather questions, first press **ใช้ตำแหน่งปัจจุบัน** and allow location access.

### If you already deployed the OpenAI v4 service

You can update the existing Node Web Service by replacing its GitHub project files with this Gemini package, then change Environment Variables as shown above and redeploy. A Static Site cannot run this backend; create a Web Service if the current deployment is still Static Site. Keep the old deployment until the Gemini version passes your tests.

## Free tier and limits

Gemini API has a free tier for selected models, but it is quota-limited and is not unlimited service. Google's published pricing currently lists free input/output for `gemini-3.1-flash-lite`; quotas and model availability can change by account, region, and date. Check [official Gemini API pricing](https://ai.google.dev/gemini-api/docs/pricing) and AI Studio usage before relying on it. If the model returns HTTP 429, wait for the quota window to reset or choose an eligible model/tier. This app does not automatically switch providers or bypass quotas.

Render Free Web Services may spin down when idle. The first request after sleep can take longer while the service starts. A paid always-on plan is needed if consistent response time is important.

## Weather provider

Weather uses [Open-Meteo](https://open-meteo.com/). The app requests precise browser location only after user action. Forecasts are approximate and should not be used for emergency decisions.
