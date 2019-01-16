## For scheduled jobs etc

http://www.launchd.info/
https://blog.jan-ahrens.eu/2017/01/13/cron-is-dead-long-live-launchd.html
https://superuser.com/a/126928/359722

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>KeepAlive</key>
		<true/>
		<key>Label</key>
		<string>local.Safari.keepAlive</string>
		<key>ProgramArguments</key>
		<array>
			<string>/usr/bin/open</string>
			<string>-W</string>
			<string>/Applications/Safari.app</string>
		</array>
	</dict>
</plist>
```