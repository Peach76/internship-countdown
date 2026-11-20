# Live Countdown Dashboard

A single-file static website (HTML, CSS, JavaScript). No backend, framework, or dependency installation is required.

## Deploy to Render

1. Create a GitHub repository and upload `index.html` (and this README, if desired) to the repository root.
2. In Render, choose **New → Static Site** and connect the GitHub repository.
3. Configure:
   - Branch: `main` (or the branch that contains `index.html`)
   - Root Directory: leave blank
   - Build Command: `echo "No build step required"`
   - Publish Directory: `.`
4. Click **Create Static Site**. Render will provide an `onrender.com` URL.

The countdown updates in each visitor's browser every second. It does not require a server process. If the page is closed, the visible timer stops updating; opening the site again recalculates the current time automatically.

After connecting GitHub to Render, new commits to the selected branch automatically trigger a redeploy.
