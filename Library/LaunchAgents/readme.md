## For scheduled jobs etc

http://www.launchd.info/
https://blog.jan-ahrens.eu/2017/01/13/cron-is-dead-long-live-launchd.html
https://superuser.com/a/126928/359722
https://www.christianengvall.se/schedule-script-in-osx/

## IMPORTANT
I dont think you need to put the plist-files in /LaunchAgens-folder. you can just do:
start with `launchctl load dev/dir/com.example.plist`
stop with `launchctl unload dev/dir/com.example.plist`

BUT! files that are placed in /LaunchAgens-folder are autostarted when computer starts

list daemons running `launchctl list`
find if your script is running `launchctl list | grep com.example`

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>

    <key>Label</key>
    <string>com.example.name</string>

    <key>RunAtLoad</key>
    <true/>

    <key>StartInterval</key>
    <integer>100</integer>

    <!-- <key>StandardErrorPath</key>
    <string>/Users/tobbe/Dev/directory/stderr.log</string>

    <key>StandardOutPath</key>
    <string>/Users/tobbe/Dev/directory/stdout.log</string> -->

    <!-- <key>EnvironmentVariables</key>
    <dict>
      <key>PATH</key>
      <string><![CDATA[ put output from echo path here ]]></string>
    </dict> -->

    <key>WorkingDirectory</key>
    <string>/Users/tobbe/Dev/directory/</string>

    <key>ProgramArguments</key>
    <array>
      <string>/Users/tobbe/.nvm/versions/node/v10.12.0/bin/node</string>
      <string>index.js</string>
    </array>

  </dict>
</plist>
```