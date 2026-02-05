-- Enable IPC for command-line control
require("hs.ipc")

-- White border for kitty quick-access terminal
local borders = {}
local quickAccessBundleID = "net.kovidgoyal.kitty-quick-access"
local borderWidth = 3

function drawBorder(window)
	local windowFrame = window:frame()
	local canvas = hs.canvas.new({
		x = windowFrame.x - borderWidth,
		y = windowFrame.y - borderWidth,
		w = windowFrame.w + (borderWidth * 2),
		h = windowFrame.h + (borderWidth * 2),
	})

	canvas:appendElements({
		type = "rectangle",
		action = "stroke",
		strokeColor = { white = 1.0, alpha = 1.0 },
		strokeWidth = borderWidth,
		roundedRectRadii = { xRadius = 8, yRadius = 8 },
	})

	canvas:level("overlay")
	canvas:behavior("canJoinAllSpaces")
	canvas:show()

	return canvas
end

function updateBorder(window, canvas)
	if not canvas then
		return nil
	end

	local windowFrame = window:frame()
	canvas:frame({
		x = windowFrame.x - borderWidth,
		y = windowFrame.y - borderWidth,
		w = windowFrame.w + (borderWidth * 2),
		h = windowFrame.h + (borderWidth * 2),
	})

	return canvas
end

-- Watch for quick-access terminal window
local watcher = hs.window.filter.new(true)

watcher:subscribe(hs.window.filter.windowCreated, function(window)
	local app = window:application()
	if app and app:bundleID() == quickAccessBundleID then
		borders[window:id()] = drawBorder(window)
	end
end)

watcher:subscribe(hs.window.filter.windowMoved, function(window)
	local app = window:application()
	if app and app:bundleID() == quickAccessBundleID then
		borders[window:id()] = updateBorder(window, borders[window:id()])
	end
end)

watcher:subscribe(hs.window.filter.windowDestroyed, function(window)
	local windowID = window:id()
	if borders[windowID] then
		borders[windowID]:delete()
		borders[windowID] = nil
	end
end)

-- Screen border and label for aerospace modes
local screenBorder = nil
local screenLabel = nil

function showScreenBorder(opts)
	hideScreenBorder()
	opts = opts or {}
	local color = opts.color or { red = 1, green = 0.3, blue = 0.3, alpha = 1 }
	local label = opts.label

	local screen = hs.screen.mainScreen()
	local frame = screen:fullFrame()
	local borderWidth = 4

	screenBorder = hs.canvas.new(frame)
	screenBorder:appendElements({
		type = "rectangle",
		action = "stroke",
		strokeColor = color,
		strokeWidth = borderWidth,
		frame = { x = borderWidth / 2, y = borderWidth / 2, w = frame.w - borderWidth, h = frame.h - borderWidth },
	})
	screenBorder:level(hs.canvas.windowLevels.overlay)
	screenBorder:show()

	if label then
		label = label:gsub("|", "\n"):gsub("=", " = ")
		local lineCount = select(2, label:gsub("\n", "\n")) + 1
		local fontSize = 17
		local lineSpacing = 10
		local lineHeight = fontSize + lineSpacing
		local paddingTop = 12
		local paddingBottom = 30
		local paddingLeft = 16
		local labelHeight = (lineCount * lineHeight) - lineSpacing + paddingTop + paddingBottom
		local labelWidth = 250
		local labelFrame = {
			x = (frame.w - labelWidth) / 2,
			y = (frame.h - labelHeight) / 2,
			w = labelWidth,
			h = labelHeight,
		}
		screenLabel = hs.canvas.new(labelFrame)
		local bgColor = { red = color.red * 0.3, green = color.green * 0.3, blue = color.blue * 0.3, alpha = 0.9 }
		local styledText = hs.styledtext.new(label, {
			font = { name = "Menlo", size = fontSize },
			color = { white = 1, alpha = 1 },
			paragraphStyle = { alignment = "left", lineSpacing = lineSpacing },
		})
		screenLabel:appendElements({
			type = "rectangle",
			action = "fill",
			fillColor = bgColor,
		}, {
			type = "rectangle",
			action = "stroke",
			strokeColor = { white = 1, alpha = 1 },
			strokeWidth = 2,
		}, {
			type = "text",
			text = styledText,
			frame = { x = paddingLeft, y = paddingTop, w = labelWidth - paddingLeft * 2, h = labelHeight },
		})
		screenLabel:level(hs.canvas.windowLevels.overlay)
		screenLabel:show()
	end
end

function hideScreenBorder()
	if screenBorder then
		screenBorder:delete()
		screenBorder = nil
	end
	if screenLabel then
		screenLabel:delete()
		screenLabel = nil
	end
end

-- hs.alert.show("Hammerspoon config loaded")
