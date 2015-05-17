-- GlassDebug - Client Script
-- Written 2015 by Tobias Maedel (t.maedel@alfeld.de)
-- Thanks to @TobleMiner
-- Licensed under MIT
local Key
local Receiver = nil
function open (side, key, id)
    if (not rednet.isOpen(side)) then
        rednet.open(side)
    end
    Key = key
    Receiver = id
end
function writeText(text, color, displayTime)
    message = {}
    message.Key = Key
    message.Text = text
    message.Color = color
    message.DisplayTime = displayTime
    if (Receiver == nil) then
        rednet.broadcast(textutils.serialize(message))
    else
        rednet.send(Receiver, textutils.serialize(message))
    end
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
    if (Receiver == nil) then
        rednet.broadcast(textutils.serialize(message))
    else
        rednet.send(Receiver, textutils.serialize(message))
    end
end
function hookGlobal()
    _G.print = ownPrint
end
