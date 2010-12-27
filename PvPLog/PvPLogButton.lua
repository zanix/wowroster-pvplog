--[[
    PvPLogButton
    Author:           Brad Morgan
    Based on Work by: Dan Gilbert
    Version:          3.2.2
    Last Modified:    2010-12-23
--]]

function PvPLogButton_OnClick(self, button, down)
	if (button == "RightButton") then
		PvPLog_MiniMap_RightClick();
    elseif (button == "LeftButton") then
		PvPLog_MiniMap_LeftClick();
	end
end

function PvPLogButton_Init()
    realm = GetCVar("realmName");
    player = UnitName("player");
	PvPLogButtonIcon:SetTexture(PvPLogGetFactionIcon() or "Interface\\Icons\\INV_Misc_QuestionMark")
	if(PvPLogData[realm][player].MiniMap.enabled) then
		PvPLogButtonFrame:Show();
	else
		PvPLogButtonFrame:Hide();
	end
end

function PvPLogButton_Radius(value)
    if (tonumber(value)) then
        -- PvPLogDebugMsg('value = '..tostring(value));
        PvPLogData[realm][player].MiniMap.radius = tonumber(value);
		PvPLogButton_UpdatePosition();
	else
        PvPLogChatMsg(PVPLOG.RADIUS.." = "..tostring(PvPLogData[realm][player].MiniMap.radius));
    end
end

function PvPLogButton_Position(value)
    if (tonumber(value)) then
        -- PvPLogDebugMsg('value = '..tostring(value));
        PvPLogData[realm][player].MiniMap.position = tonumber(value);
		PvPLogButton_UpdatePosition();
	else
        PvPLogChatMsg(PVPLOG.POSITION.." = "..tostring(PvPLogData[realm][player].MiniMap.position));
    end
end

function PvPLogButton_UpdatePosition()
    local radius = PvPLogData[realm][player].MiniMap.radius;
	local position = PvPLogData[realm][player].MiniMap.position;
	-- PvPLogDebugMsg('PvPLogButton_UpdatePosition() radius= '..tostring(radius)..', position= '..tostring(position));
	if (radius ~= nil and position ~= nil) then
		PvPLogButtonFrame:SetPoint(
			"TOPLEFT",
			"Minimap",
			"TOPLEFT",
			54 - (radius * cos(position)), (radius * sin(position)) - 55);
	end
end

-- Thanks to Yatlas for this code
function PvPLogButton_BeingDragged()
    -- Thanks to Gello for this code
    local xpos,ypos = GetCursorPosition() 
    local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom() 

    xpos = xmin-xpos/UIParent:GetScale()+70 
    ypos = ypos/UIParent:GetScale()-ymin-70 

    PvPLogButton_SetPosition(math.deg(math.atan2(ypos,xpos)));
end

function PvPLogButton_SetPosition(v)
    if(v < 0) then
        v = v + 360;
    end

    PvPLogData[realm][player].MiniMap.position = v;
    PvPLogButton_UpdatePosition();
end

function PvPLogButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT");
    GameTooltip:SetText(PVPLOG.UI_RIGHT_CLICK .. PVPLOG.UI_TOGGLE .."\n".. PVPLOG.UI_LEFT_CLICK .. PVPLOG.UI_TOGGLE2);
	GameTooltipTextLeft1:SetTextColor(1, 1, 1);
    GameTooltip:AddLine(PVPLOG.UI_RIGHT_DRAG..PVPLOG.UI_MINIMAP_BUTTON);
    GameTooltip:Show();
end