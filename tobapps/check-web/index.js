const request = require('request');
const cheerio = require('cheerio');
const chalk = require('chalk');
const fs = require('fs');

// https://github.com/mikaelbr/node-notifier

// launchctl load ~/Library/LaunchAgents/tobbe.check-web.plist
// launchctl unload ~/Library/LaunchAgents/tobbe.check-web.plist
// launchctl load ~/dotfiles/Library/LaunchAgents/tobbe.check-web.plist

const debug = false;
const cachePath = `${__dirname}/check-web-cache.json`;
const logPath = `${__dirname}/log.json`;

const itemsToCheck = [
	new ItemToCheck('react releases', 'https://github.com/facebook/react/releases', '.release-header a'),
	new ItemToCheck('create-react-app releases', 'https://github.com/facebook/create-react-app/releases', '.release-header a'),
	new ItemToCheck('react-native releases', 'https://github.com/facebook/react-native/releases', '.release-header a'),
	new ItemToCheck('fluidity', 'https://github.com/umco/umbraco-fluidity/releases', '.release-header a'),
	new ItemToCheck('authu', 'https://github.com/mattbrailsford/umbraco-authu/releases', '.release-header a'),
]

let cache = {
	items: {}
};
if (!fs.existsSync(cachePath)) {
	fs.writeFileSync(cachePath, JSON.stringify(cache), (err) => { })
}
else {
	try {
		cache = JSON.parse(fs.readFileSync(cachePath, { encoding: 'utf8' }));
	} catch (error) {
		debug && console.log(error)
	}
}

let requests_completed = 0;
let newLogs = [{ type: 'info', message: 'Check started', time: new Date() }];

itemsToCheck.forEach(item => {
	request.get(item.url, (error, response, html) => {

		if (!error && response.statusCode == 200) {
			const cacheItem = cache.items[item.url] || {};
			const items = cheerio(item.selector, html);
			const checkedValue = items.first().text();

			cacheItem.lastCheckDate = new Date();
			cache.items[item.url] = cacheItem;

			if (cacheItem.lastCheckedValue !== checkedValue) {
				cacheItem.lastCheckedValue = checkedValue;
				cacheItem.lastChange = new Date();
				console.log(`${chalk.green('CHANGED')} ${chalk.underline(item.url)} ${chalk.green('NOW')}`)
			}
			else {
				console.log(`${chalk.gray('not changed')} ${chalk.underline(item.url)} ${chalk.gray('last change: ' + getFormattedDatetime(cacheItem.lastChange))} `)
			}
		}
		else {
			debug && console.log('error', { error, statusCode: response.statusCode })
			newLogs.push({ time: new Date(), error, statusCode: response.statusCode, type: 'error' })
		}

		requests_completed++;
		if (requests_completed === itemsToCheck.length) {
			removeUnusedItems()
			logErrors()
		}

		fs.writeFileSync(cachePath, JSON.stringify(cache), (err) => { })
	})
})

function ItemToCheck(name, url, selector) {
	this.name = name;
	this.url = url;
	this.selector = selector;
}

function removeUnusedItems() {
	const cacheKeys = Object.keys(cache.items);
	const itemsToCheckUrls = itemsToCheck.map(x => x.url);

	cache.items = cacheKeys.reduce((newCache, cacheKey) => itemsToCheckUrls.includes(cacheKey) ? { ...newCache, [cacheKey]: cache.items[cacheKey] } : newCache, {})

	debug && console.log('new cache', JSON.stringify(cache, null, 4))
}

function logErrors() {
	debug && console.log('new logs', newLogs)

	if (newLogs.length) {
		let log = [];

		if (fs.existsSync(logPath)) {
			let oldLogs = JSON.parse(fs.readFileSync(logPath, { encoding: 'utf8' }) || '[]');
			log = Array.isArray(oldLogs) ? [...oldLogs, ...newLogs] : newLogs;
		}
		else {
			log = newLogs;
		}

		log = log.sort((a, b) => new Date(a.time) < new Date(b.time))

		if (log.length > 30) log.length = 30;

		fs.writeFileSync(logPath, JSON.stringify(log), (err) => { })
	}
}

var dateOptions = { month: 'numeric', day: 'numeric' };
var timeOptions = { hour12: false };
function getFormattedDatetime(date) {
	if (!(date instanceof Date)) {
		date = new Date(date);
	}

	const dateString = date.toLocaleDateString('sv-SE', dateOptions).split('/');
	const formattedDatestring = dateString[1] + '/' + dateString[0];

	return `${chalk.gray(formattedDatestring)} ${chalk.gray(date.toLocaleTimeString('sv-SE', timeOptions))}`;
}
