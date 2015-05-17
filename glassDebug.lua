-- GlassDebug - Terminal Glasses Bridge
-- Written 2015 by Tobias Maedel (t.maedel@alfeld.de)
-- Thanks to @TobleMiner
-- Licensed under MIT
Configuration = {}
Configuration.ModemSide  = "top"
Configuration.BridgeSide = "left"

Configuration.Width      = 300
Configuration.LineCount  = 10
Configuration.LeftOffset = 10
Configuration.TopOffset  = 10
Configuration.BackgroundOpacity = 0.5
Configuration.BackgroundColor   = 0
Configuration.DefaultFade = 10
Configuration.Key = "Fluttershy"

ScreenBuffer = {}

rednet.open("top")
glasses = peripheral.wrap("left")

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function writeText(text, color, displayTime)
	if (#ScreenBuffer >= Configuration.LineCount) then
		table.remove(ScreenBuffer, 1)
	end

	if (color == nil) then
		color = 0xFFFFFF
	end

	if (displayTime == nil) then
		displayTime = Configuration.DefaultFade
	end

	newItem = {}
	newItem.Color       = color
	newItem.Text        = text
	newItem.DisplayTime = displayTime
	newItem.Opacity     = 1
	table.insert(ScreenBuffer, newItem)

	os.queueEvent("renderBuffer")
end

function renderLoop()
	while true do
		renderBuffer()
		os.pullEvent( "renderBuffer" )
	end
end

function renderBuffer()
	glasses.clear()

	if (#ScreenBuffer > 0) then
		glasses.addBox(Configuration.LeftOffset - 5,    -- x
		 			   Configuration.TopOffset - 5,     -- y
					   Configuration.Width ,            -- width
					   (10 * #ScreenBuffer) + 7,        -- height
					   Configuration.BackgroundColor,   -- color
					   Configuration.BackgroundOpacity) -- opacity
	end

	for k,v in pairs(ScreenBuffer) do
		text = glasses.addText(Configuration.LeftOffset, k * 10 , v.Text)
		text.setColor(v.Color)
		text.setAlpha(v.Opacity)
	end
	glasses.sync()
end

function textDecay()
	while true do
		local toRemove = {}
		local changed = false
		for k,v in pairs(ScreenBuffer) do
			changed = true
			v.DisplayTime = v.DisplayTime - 0.2

			if (v.DisplayTime <= 5) then
				v.Opacity = math.abs((v.DisplayTime * (1 / 5)))
				if (v.Opacity < 0.1) then
					v.Opacity = 0
				end
			end
			if (v.Opacity < 0.1) then
				table.insert(toRemove, k)
			end
		end
		for k,v in pairs(toRemove) do
			table.remove(ScreenBuffer, v)
		end
		if (changed) then
			os.queueEvent("renderBuffer")
		end
		sleep(0.2)
	end
end

counter = 0
function waitForRedNetData()
	while true do
		local senderId, message, protocol = rednet.receive()
		message = textutils.unserialize(message)
		if (message ~= nil) then
			if (message.Key == Configuration.Key) then
				if (message.Text ~= "" and message.Text ~= nil) then
					writeText(message.Text, message.Color, message.DisplayTime)
				end
			end
		end
	end
end

parallel.waitForAll(renderLoop, waitForRedNetData, textDecay)
