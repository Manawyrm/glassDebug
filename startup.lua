-- GlassDebug - Client Script
-- Written 2015 by Tobias Maedel (t.maedel@alfeld.de)
-- Thanks to @TobleMiner
-- Licensed under MIT
local Key
function open (side, key)
    if (not rednet.isOpen(side)) then
        rednet.open(side)
    end
    Key = key
end
function writeText(text, color, displayTime)
    message = {}
    message.Key = Key
    message.Text = text
    message.Color = color
    message.DisplayTime = displayTime
    rednet.broadcast(textutils.serialize(message))
end
function ownPrint (...)
    text = ""
    for k,v in pairs(arg) do
        if (type(v) == "string") then
            text = text .. v
        end
    end
    message = {}
    message.Key = Key
    message.Text = text
    rednet.broadcast(textutils.serialize(message))
end
function hookGlobal()
    _G.print = ownPrint
end
