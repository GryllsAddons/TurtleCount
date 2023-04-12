local turtle = (TargetHPText or TargetHPPercText)
if not turtle then return end

local TurtleCount = CreateFrame("Button", "TurtleCount", Minimap)
TurtleCount:Hide()
TurtleCount:SetFrameLevel(64)
TurtleCount:SetFrameStrata("MEDIUM")
TurtleCount:SetWidth(63)
TurtleCount:SetHeight(23)
TurtleCount:SetBackdrop({
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 8, edgeSize = 16,
  insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
TurtleCount:SetBackdropBorderColor(.9,.8,.5,1)
TurtleCount:SetBackdropColor(.4,.4,.4,1)

TurtleCount:SetMovable(true)
TurtleCount:SetClampedToScreen(true)
TurtleCount:SetUserPlaced(true)
TurtleCount:EnableMouse(true)
TurtleCount:RegisterForDrag("LeftButton")
TurtleCount:SetScript("OnDragStart", function() 
    if (IsShiftKeyDown() and IsControlKeyDown()) then
        this:StartMoving()
    end
end)
TurtleCount:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
TurtleCount:RegisterForClicks("RightButtonDown")
TurtleCount:SetScript("OnClick", function()
    if (IsShiftKeyDown() and IsControlKeyDown()) then
        this:SetUserPlaced(false)            
        TurtleCount:Position()
    end
end)

function TurtleCount:Position()
    TurtleCount:ClearAllPoints()
    TurtleCount:SetPoint("TOP", Minimap, "BOTTOM", 0, -12)
end

TurtleCount.text = TurtleCount:CreateFontString("Status", "LOW", "GameFontNormal")
TurtleCount.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
TurtleCount.text:SetPoint("RIGHT", TurtleCount, "RIGHT", -5, 1)
TurtleCount.text:SetFontObject(GameFontWhite)

TurtleCount.icon = TurtleCount:CreateTexture(nil, 'ARTWORK')
TurtleCount.icon:SetWidth(13)
TurtleCount.icon:SetHeight(13)
TurtleCount.icon:SetPoint("LEFT", TurtleCount, "LEFT", 5, 0)
TurtleCount.icon:SetTexture("Interface\\Addons\\TurtleCount\\img\\turtle.tga")

local refreshTime = 0
local onlineCount
local maxCount
local highCount
local lowCount
local queried

TurtleCount.Commas = function(number)
    number = tonumber(number)
    if number > 1000000 then
        return gsub(number, "(%d)(%d%d%d)(%d%d%d)$", "%1,%2,%3")
    else
        return gsub(number, "(%d)(%d%d%d)$", "%1,%2")
    end
end

function TurtleCount:UpdateText(count)
    count = TurtleCount.Commas(count)
    TurtleCount.text:SetText(count) 
end

function TurtleCount:ServerInfo()
    SendChatMessage(".server info")
    queried = true    
end

function TurtleCount:RefreshTime()
    refreshTime = GetTime() + 60
end

-- Examples of Turtle WoW Server Info:
-- Players online: 1111 (0 queued). Max online: 2222 (33 queued).
-- Server uptime: 11 Hours 22 Minutes 33 Seconds.
-- Server Time: Mon, [01.01.2023] 01:02:03

TurtleCount:RegisterEvent("CHAT_MSG_SYSTEM")
TurtleCount:SetScript("OnEvent", function()
    if not queried then return end
    local online
    local max
    local serverTime

    _, _, online = string.find(arg1,"Players online:%s*(%d+)")
    _, _, max = string.find(arg1,"Max online:%s*(%d+)")
    _, _, serverTime = string.find(arg1,"Server Time:%s*(.+)")

    if (online and max) then        
        onlineCount = online
        maxCount = max
        TurtleCount:UpdateText(onlineCount)
        
        if (not highCount) then
            highCount = onlineCount
            lowCount = onlineCount
        end
    
        if (highCount < onlineCount) then
            highCount = onlineCount
        end
    
        if ((lowCount > onlineCount)) then
            lowCount = onlineCount
        end        
    end

    if serverTime then
        ChatFrame_AddMessageGroup(ChatFrame1, "SYSTEM")
        queried = nil
    end
end)

TurtleCount:SetScript("OnUpdate", function()
    if (refreshTime) and (GetTime() > refreshTime) then
        ChatFrame_RemoveMessageGroup(ChatFrame1, "SYSTEM")
        TurtleCount:ServerInfo()
        TurtleCount:RefreshTime()
    end
end)

TurtleCount:SetScript("OnEnter", function()
    GameTooltip:ClearLines()
    GameTooltip:SetOwner(this, ANCHOR_BOTTOMLEFT)
    GameTooltip:AddLine("Turtles Online")
    GameTooltip:AddDoubleLine("Max", TurtleCount.Commas(maxCount).." players", 1,1,1,1,1,1)
    GameTooltip:AddDoubleLine("High", TurtleCount.Commas(highCount).." players", 1,1,1,1,1,1)
    GameTooltip:AddDoubleLine("Low", TurtleCount.Commas(lowCount).." players", 1,1,1,1,1,1)
    GameTooltip:Show()
end)

TurtleCount:SetScript("OnLeave", function()
    GameTooltip:Hide()
end)

TurtleCount:Position()
TurtleCount:Show()
