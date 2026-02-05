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

-- Screen border for aerospace modes
local screenBorder = nil

function showScreenBorder(color)
	hideScreenBorder()
	local screen = hs.screen.mainScreen()
	local frame = screen:fullFrame()
	local borderWidth = 4

	screenBorder = hs.canvas.new(frame)
	screenBorder:appendElements({
		type = "rectangle",
		action = "stroke",
		strokeColor = color or { red = 1, green = 0.3, blue = 0.3, alpha = 1 },
		strokeWidth = borderWidth,
		frame = { x = borderWidth / 2, y = borderWidth / 2, w = frame.w - borderWidth, h = frame.h - borderWidth },
	})
	screenBorder:level(hs.canvas.windowLevels.overlay)
	screenBorder:show()
end

function hideScreenBorder()
	if screenBorder then
		screenBorder:delete()
		screenBorder = nil
	end
end

-- hs.alert.show("Hammerspoon config loaded")
