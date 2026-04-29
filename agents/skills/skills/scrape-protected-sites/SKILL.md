---
name: scrape-protected-sites
description: Scrape sites protected by Akamai/Cloudflare bot detection by launching real Chrome with remote debugging (CDP). Use when headless browsers or playwright get blocked with "Access Denied".
---

# Scraping Bot-Protected Sites via Chrome Remote Debugging

**Problem:** Akamai/Cloudflare block all automated browsers (Playwright, chrome-devtools-mcp) — even with real Chrome binaries — due to automation flags or IP reputation.

**Solution:** Launch the user's real Chrome with remote debugging, then control it via WebSocket (Chrome DevTools Protocol).

## Steps

1. **Chrome must not already be running** — relaunch won't apply the flag to an existing session. Ask the user before killing an existing Chrome session.

2. **Launch Chrome:**
```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug \
  '--remote-allow-origins=*' \
  "https://target-url.com" &
```
- `--user-data-dir` is required (CDP refuses the default profile)
- `--remote-allow-origins=*` is required or WebSocket returns 403

3. **Install dep if needed:** `pip3 install websocket-client`

4. **Get page WebSocket ID:**
```bash
curl -s http://localhost:9222/json/list  # note the "id" field
```

5. **Run JS via CDP:**
```python
import json, websocket, time

ws = websocket.create_connection(
    "ws://localhost:9222/devtools/page/PAGE_ID",
    header={"Origin": "http://localhost:9222"}
)
time.sleep(8)  # wait for JS-rendered content

ws.send(json.dumps({"id": 1, "method": "Runtime.evaluate",
    "params": {"expression": "document.body.innerText", "returnByValue": True}}))
print(json.loads(ws.recv())['result']['result']['value'])
ws.close()
```

6. **Inspect DOM structure first** if selectors are unknown:
```python
"document.querySelector('.known-parent').innerHTML.substring(0, 3000)"
```
Then use `.innerText` on matching elements for clean text extraction.

## Gotchas
- Chrome must be freshly launched — if already open, the debug flag is ignored
- Both `--remote-allow-origins=*` and `--user-data-dir` are mandatory
- SPAs need 8–10s after navigation before content appears
