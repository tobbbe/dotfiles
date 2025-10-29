const fs = require('fs')

// Check if path argument is provided
const path = process.argv[2]
if (!path) {
  console.error('Please provide a file path as argument')
  process.exit(1)
}

const originalContent = fs.readFileSync(path, 'utf8')
const json = JSON.parse(originalContent)

// Configuration object for all formatting settings
const CONFIG = {
  maxLineLength: 122, // Maximum line length for compact formatting
  maxCompactKeys: 3, // Max object keys before forcing multiline
  indentChar: '  ', // Indentation character
}

function formatCompact(obj) {
  const str = JSON.stringify(obj)
  let result = ''
  let inString = false
  let escaped = false
  let lastNonSpace = ''

  for (let i = 0; i < str.length; i++) {
    const char = str[i]
    const nextChar = str[i + 1]

    if (char === '\\' && !escaped) {
      escaped = true
      result += char
      lastNonSpace = char
      continue
    }

    if (char === '"' && !escaped) {
      inString = !inString
      result += char
      lastNonSpace = char
      continue
    }

    if (escaped) {
      result += char
      lastNonSpace = char
      escaped = false
      continue
    }

    if (!inString) {
      if (char === ':' || char === ',') {
        result += char + ' '
        lastNonSpace = char
        continue
      }
      if (char === '{' && nextChar === '"') {
        result += char + ' '
        lastNonSpace = char
        continue
      }
      if (char === '}' && (lastNonSpace === '"' || lastNonSpace === ']')) {
        result += ' ' + char
        lastNonSpace = char
        continue
      }
    }

    result += char
    if (char !== ' ') {
      lastNonSpace = char
    }
  }

  return result
}

function format(obj, indent = 0) {
  // Handle null
  if (obj === null) {
    return 'null'
  }

  // Handle undefined (though JSON.parse won't produce undefined)
  if (obj === undefined) {
    return 'undefined'
  }

  // Handle primitive types at the top level
  const type = typeof obj
  if (type === 'string' || type === 'number' || type === 'boolean') {
    return JSON.stringify(obj)
  }

  const ind = CONFIG.indentChar.repeat(indent)
  const ind1 = CONFIG.indentChar.repeat(indent + 1)

  if (Array.isArray(obj)) {
    if (obj.length === 0) {
      return '[]'
    }

    if ((obj.length === 1 && typeof obj[0] !== 'object') || obj[0] === null) {
      return formatCompact(obj)
    }

    if (
      obj.length === 1 &&
      typeof obj[0] === 'object' &&
      obj[0] !== null &&
      !Array.isArray(obj[0])
    ) {
      const compact = formatCompact(obj)
      if (compact.length <= CONFIG.maxLineLength) {
        return compact
      }
    }

    const items = obj.map((item) => {
      if (typeof item === 'object' && item !== null && !Array.isArray(item)) {
        const keys = Object.keys(item)
        if (
          keys.length <= CONFIG.maxCompactKeys &&
          !keys.some((k) => typeof item[k] === 'object' && item[k] !== null)
        ) {
          return ind1 + formatCompact(item)
        }
      }
      return ind1 + format(item, indent + 1).trim()
    })
    return '[\n' + items.join(',\n') + '\n' + ind + ']'
  }

  // Ensure we're dealing with an actual object (not null)
  if (typeof obj === 'object' && obj !== null) {
    const keys = Object.keys(obj)

    if (keys.length === 1) {
      const val = obj[keys[0]]
      if (
        Array.isArray(val) &&
        val.length === 1 &&
        (typeof val[0] !== 'object' || val[0] === null)
      ) {
        return formatCompact(obj)
      }
    }

    if (keys.length <= CONFIG.maxCompactKeys) {
      const compact = formatCompact(obj)
      if (compact.length <= CONFIG.maxLineLength) {
        return compact
      }
    }

    const sortedKeys = keys.sort((a, b) => {
      const aType = typeof obj[a]
      const bType = typeof obj[b]
      const aIsPrimitive =
        aType === 'string' ||
        aType === 'boolean' ||
        aType === 'number' ||
        obj[a] === null
      const bIsPrimitive =
        bType === 'string' ||
        bType === 'boolean' ||
        bType === 'number' ||
        obj[b] === null

      if (aIsPrimitive && !bIsPrimitive) return -1
      if (!aIsPrimitive && bIsPrimitive) return 1
      return 0
    })

    const entries = sortedKeys.map((key) => {
      const val = obj[key]
      const formatted =
        typeof val === 'object' && val !== null
          ? format(val, indent + 1)
          : JSON.stringify(val)
      return `${ind1}"${key}": ${formatted}`
    })
    return '{\n' + entries.join(',\n') + '\n' + ind + '}'
  }

  return JSON.stringify(obj)
}

try {
  const output = format(json) + '\n'
  // Parse the output without the newline for validation
  JSON.parse(output.trim())
  fs.writeFileSync(path, output)
} catch (e) {
  fs.writeFileSync(path, originalContent)
  throw new Error('Formatting failed, rolled back: ' + e.message)
}
