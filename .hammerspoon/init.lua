-- ~/.hammerspoon/init.lua
local activeWindow = nil

-- Track and update window opacity
local function updateOpacity()
	local focusedWindow = hs.window.focusedWindow()

	-- Restore previous window opacity
	if activeWindow and activeWindow ~= focusedWindow and activeWindow:isStandard() then
		pcall(function()
			activeWindow:setAlpha(0.6)
		end)
	end

	-- Set focused window to full opacity
	if focusedWindow and focusedWindow:isStandard() then
		pcall(function()
			focusedWindow:setAlpha(1.0)
			activeWindow = focusedWindow
		end)
	end
end

-- Watch for focus changes
local windowFilter = hs.window.filter.new()
windowFilter:subscribe(hs.window.filter.windowFocused, updateOpacity)
windowFilter:subscribe(hs.window.filter.windowUnfocused, updateOpacity)

-- Restore all windows on reload
hs.hotkey.bind({ "cmd", "shift" }, "R", function()
	hs.fnutils.each(hs.window.allWindows(), function(w)
		pcall(function()
			w:setAlpha(1.0)
		end)
	end)
	hs.reload()
end)
