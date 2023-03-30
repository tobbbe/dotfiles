#!/Users/tobbe/.volta/bin/node

// Required parameters:
// @raycast.schemaVersion 1
// @raycast.title Info
// @raycast.mode fullOutput

// Optional parameters:
// @raycast.icon 👨‍🔬

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
    // const numPart = `# 22: `
    // const titlePart = FgYellow + "Title" + ` | ${FgRed}PR # ${FgCyan}${42}` + '\n'
    // const urlPart = '     ' + 'https://google.com' + '\n\n'
  
    // const row = numPart + titlePart + urlPart
    // process.stdout.write(row)

    process.stdout.write(`

    Week: ${getCurrentWeekNr()}

    `.trim() + '\n\n\n\n')

  } catch (err) {
    console.error(err)
  }
})()

function getCurrentWeekNr() {
  const today = new Date();
  const weekNumber = getISOWeek(today);

  return weekNumber;

  // Function to calculate the week number based on the ISO 8601 standard
  function getISOWeek(date) {
    const dayOfWeek = (date.getDay() + 6) % 7; // Adjust for Sunday being 0
    const january4 = new Date(date.getFullYear(), 0, 4);
    const startOfWeek = new Date(january4.setDate(january4.getDate() - january4.getDay() + 1));
    const weekNumber = Math.ceil(((date - startOfWeek) / 86400000 + 1) / 7);
    return weekNumber;
  }
}