#!/Users/tobbe/.volta/bin/node

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title js test
// @raycast.mode fullOutput

// Optional parameters:
// @raycast.icon 🤖

// @raycast.author Tobbbe


const FgBlack = '\x1b[30m';
const FgRed = '\x1b[31m';
const FgGreen = '\x1b[32m';
const FgYellow = '\x1b[33m';
const FgBlue = '\x1b[34m';
const FgMagenta = '\x1b[35m';
const FgCyan = '\x1b[36m';
const FgWhite = '\x1b[37m';

;(async () => {
  try {
    const numPart = `# 22: `
    const titlePart = FgYellow + "Title" + ` | ${FgRed}PR # ${FgCyan}${42}` + '\n'
    const urlPart = '     ' + 'https://google.com' + '\n\n'
  
    const row = numPart + titlePart + urlPart

    process.stdout.write(row)
  } catch (err) {
    console.error(err)
  }
})()
