-- Enable IPC for command-line control
require("hs.ipc")
hs.window.animationDuration = 0

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
local ok, err = pcall(function()
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
end)
if not ok then
	print("Window filter failed to start: " .. tostring(err))
end

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

function autoResize()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local app = win:application():name():lower()
	if app:find("kitty") then
		resizeToPercent(64)
	else
		centerFloating(40, 60)
	end
end

function centerFloating(widthPercent, heightPercent)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local screen = win:screen():frame()
	local w = math.floor(screen.w * widthPercent / 100)
	local h = math.floor(screen.h * heightPercent / 100)
	win:setFrame({
		x = screen.x + math.floor((screen.w - w) / 2),
		y = screen.y + math.floor((screen.h - h) / 2),
		w = w,
		h = h,
	})
end

function resizeToPercent(percent)
	local win = hs.window.focusedWindow()
	if not win then
		return
	end
	local screen = win:screen():frame()
	local targetWidth = math.floor(screen.w * percent / 100)
	local diff = math.floor(targetWidth - win:frame().w)
	if diff > 0 then
		os.execute("/opt/homebrew/bin/aerospace resize width +" .. diff)
	elseif diff < 0 then
		os.execute("/opt/homebrew/bin/aerospace resize width " .. diff)
	end
end

-- Top-center on-screen notification
local notificationCanvas = nil
local notificationTimer = nil

function showNotification(text)
	if notificationCanvas then
		notificationCanvas:delete()
		notificationCanvas = nil
	end
	if notificationTimer then
		notificationTimer:stop()
		notificationTimer = nil
	end

	local screen = hs.screen.mainScreen()
	local frame = screen:fullFrame()
	local fontSize = 22
	local paddingX = 30
	local paddingY = 14
	local labelWidth = 400
	local labelHeight = fontSize + paddingY * 2
	local labelFrame = {
		x = (frame.w - labelWidth) / 2,
		y = 10 + labelHeight * 2,
		w = labelWidth,
		h = labelHeight,
	}

	notificationCanvas = hs.canvas.new(labelFrame)
	local styledText = hs.styledtext.new(text, {
		font = { name = "Menlo-Bold", size = fontSize },
		color = { red = 0.05, green = 0.1, blue = 0.05, alpha = 1 },
		paragraphStyle = { alignment = "center" },
	})
	notificationCanvas:appendElements({
		type = "rectangle",
		action = "fill",
		fillColor = { red = 0.68, green = 1.0, blue = 0.68, alpha = 0.9 },
		roundedRectRadii = { xRadius = 8, yRadius = 8 },
	}, {
		type = "text",
		text = styledText,
		frame = { x = paddingX, y = paddingY, w = labelWidth - paddingX * 2, h = labelHeight - paddingY * 2 },
	})
	notificationCanvas:level(hs.canvas.windowLevels.overlay)
	notificationCanvas:show()

	notificationTimer = hs.timer.doAfter(4, function()
		if notificationCanvas then
			notificationCanvas:delete()
			notificationCanvas = nil
		end
		notificationTimer = nil
	end)
end

-- hs.alert.show("Hammerspoon config loaded")
