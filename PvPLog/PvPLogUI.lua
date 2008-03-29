--[[
    PvPLogUI
    Author:           Brad Morgan
    Based on Work by: Josh Estelle, Daniel S. Reichenbach, Atolicus, Matthew Musgrove
    Version:          3.0.0
    Last Modified:    2008-03-27
]]

local realm = "";
local player = "";
local CYAN    = "|cff00ffff";
local WHITE   = "|cffffffff";
local RED     = "|cffff0000";
local GREEN   = "|cff00ff00";
local MAGENTA = "|cffff00ff";
local FIRE    = "|cffde2413";
local ORANGE  = "|cffd06c01";
local statsValue = 1;
local statsTotal = 0;
startCount = 0;
endCount = 0;
statCount  = 0;
local pvpPlayerList = "";
local pvpRaceList = "";
local pvpClassList = "";
local pvpLevelList = "";
local pvpGuildList = "";
local pvpWinsList = "";
local pvpLossList = "";
local pvpRealmList = "";
PVPLOG.STATS_TYPE = "";

-------------------
-- Configuration --
-------------------

function PvPLogConfig_OnLoad()
    realm = GetCVar("realmName");
    player = UnitName("player");
end

function PvPLogConfig_OnShow()
    PvPLogConfig_SetValues();
end

function PvPLogConfig_SetValues()
    txtPvPLogConfigFrame_HeaderText:SetText("PvPLog " .. PVPLOG.VER_NUM);
    txtPvPLogConfig_NotifyKillsToggle_Header:SetText(PVPLOG.UI_NOTIFY_KILLS);
    txtPvPLogConfig_NotifyDeathsToggle_Header:SetText(PVPLOG.UI_NOTIFY_DEATHS);
    txtPvPLogConfig_NotifyKillsCustomChannel_Header:SetText(PVPLOG.UI_CUSTOM);
    txtPvPLogConfig_NotifyDeathsCustomChannel_Header:SetText(PVPLOG.UI_CUSTOM);
    cbxPvPLogConfig_MiniMapButtonToggle:SetChecked(PvPLogData[realm][player].MiniMap.enabled);
    
    cbxPvPLogConfig_EnableToggle:SetChecked(PvPLogData[realm][player].enabled);
    cbxPvPLogConfig_MouseoverToggle:SetChecked(PvPLogData[realm][player].mouseover);
    cbxPvPLogConfig_DingToggle:SetChecked(PvPLogData[realm][player].ding);
    cbxPvPLogConfig_DispToggle:SetChecked(PvPLogData[realm][player].display);
    cbxPvPLogConfig_RecordBGToggle:SetChecked(PvPLogData[realm][player].recordBG);
    cbxPvPLogConfig_RecordDuelToggle:SetChecked(PvPLogData[realm][player].recordDuel);
    cbxPvPLogConfig_NotifyBGToggle:SetChecked(PvPLogData[realm][player].notifyBG);
    cbxPvPLogConfig_NotifyDuelToggle:SetChecked(PvPLogData[realm][player].notifyDuel);

    if (PvPLogData[realm][player].recordBG) then
        cbxPvPLogConfig_NotifyBGToggle:Enable();
        cbxPvPLogConfig_NotifyBGToggleText:SetTextColor(NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b);
    else
        cbxPvPLogConfig_NotifyBGToggle:Disable();
        cbxPvPLogConfig_NotifyBGToggleText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
    end
    if (PvPLogData[realm][player].recordDuel) then
        cbxPvPLogConfig_NotifyDuelToggle:Enable();
        cbxPvPLogConfig_NotifyDuelToggleText:SetTextColor(NORMAL_FONT_COLOR.r,NORMAL_FONT_COLOR.g,NORMAL_FONT_COLOR.b);
    else
        cbxPvPLogConfig_NotifyDuelToggle:Disable();
        cbxPvPLogConfig_NotifyDuelToggleText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
    end
    
    if (not PvPLogData[realm][player].notifyKill) then
        PvPLogData[realm][player].notifyKill = PVPLOG.NONE;
    end
    
    ebxPvPLogConfig_NotifyKillsChannel:SetText(PvPLogData[realm][player].notifyKill);
    
    if (PvPLogData[realm][player].notifyKill == PVPLOG.NONE) then
        cbxPvPLogConfig_NotifyKillsNone:SetChecked(true);
        ebxPvPLogConfig_NotifyKillsChannel:SetText(PVPLOG.NONE);
    else
        cbxPvPLogConfig_NotifyKillsNone:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyKill == PVPLOG.SELF) then
        cbxPvPLogConfig_NotifyKillsSelf:SetChecked(true);
        ebxPvPLogConfig_NotifyKillsChannel:SetText(PVPLOG.SELF);
    else
        cbxPvPLogConfig_NotifyKillsSelf:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyKill == PVPLOG.PARTY) then
        cbxPvPLogConfig_NotifyKillsParty:SetChecked(true);
        ebxPvPLogConfig_NotifyKillsChannel:SetText(PVPLOG.PARTY);
    else
        cbxPvPLogConfig_NotifyKillsParty:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyKill == PVPLOG.GUILD) then
        cbxPvPLogConfig_NotifyKillsGuild:SetChecked(true);
        ebxPvPLogConfig_NotifyKillsChannel:SetText(PVPLOG.GUILD);
    else
        cbxPvPLogConfig_NotifyKillsGuild:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyKill == PVPLOG.SAY) then
        cbxPvPLogConfig_NotifyKillsSay:SetChecked(true);
        ebxPvPLogConfig_NotifyKillsChannel:SetText(PVPLOG.SAY);
    else
        cbxPvPLogConfig_NotifyKillsSay:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyKill == PVPLOG.RAID) then
        cbxPvPLogConfig_NotifyKillsRaid:SetChecked(true);
        ebxPvPLogConfig_NotifyKillsChannel:SetText(PVPLOG.RAID);
    else
        cbxPvPLogConfig_NotifyKillsRaid:SetChecked(false);
    end
    
    if (not PvPLogData[realm][player].notifyDeath) then
        PvPLogData[realm][player].notifyDeath = PVPLOG.NONE;
    end
    
    ebxPvPLogConfig_NotifyDeathsChannel:SetText(PvPLogData[realm][player].notifyDeath);
    
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.NONE) then
        cbxPvPLogConfig_NotifyDeathsNone:SetChecked(true);
        ebxPvPLogConfig_NotifyDeathsChannel:SetText(PVPLOG.NONE);
    else
        cbxPvPLogConfig_NotifyDeathsNone:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.SELF) then
        cbxPvPLogConfig_NotifyDeathsSelf:SetChecked(true);
        ebxPvPLogConfig_NotifyDeathsChannel:SetText(PVPLOG.SELF);
    else
        cbxPvPLogConfig_NotifyDeathsSelf:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.PARTY) then
        cbxPvPLogConfig_NotifyDeathsParty:SetChecked(true);
        ebxPvPLogConfig_NotifyDeathsChannel:SetText(PVPLOG.PARTY);
    else
        cbxPvPLogConfig_NotifyDeathsParty:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.GUILD) then
        cbxPvPLogConfig_NotifyDeathsGuild:SetChecked(true);
        ebxPvPLogConfig_NotifyDeathsChannel:SetText(PVPLOG.GUILD);
    else
        cbxPvPLogConfig_NotifyDeathsGuild:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.SAY) then
        cbxPvPLogConfig_NotifyDeathsSay:SetChecked(true);
        ebxPvPLogConfig_NotifyDeathsChannel:SetText(PVPLOG.SAY);
    else
        cbxPvPLogConfig_NotifyDeathsSay:SetChecked(false);
    end
    
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.RAID) then
        cbxPvPLogConfig_NotifyDeathsRaid:SetChecked(true);
        ebxPvPLogConfig_NotifyDeathsChannel:SetText(PVPLOG.RAID);
    else
        cbxPvPLogConfig_NotifyDeathsRaid:SetChecked(false);
    end
end

function PvPLogConfig_OnHide()
    if (MYADDONS_ACTIVE_OPTIONSFRAME == this) then
        ShowUIPanel(myAddOnsFrame);
    end
end

function PvPLogConfig_OnMouseDown(arg1)
    if (arg1 == "LeftButton") then
        PvPLogConfigFrame:StartMoving();
    end
end

function PvPLogConfig_OnMouseUp(arg1)
    if (arg1 == "LeftButton") then
        PvPLogConfigFrame:StopMovingOrSizing();
    end
end

function PvPLogEnabled_Toggle_OnClick()
    if (PvPLogData[realm][player].enabled) then
        PvPLogSetEnabled("off");
    else
        PvPLogSetEnabled("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogMouseover_Toggle_OnClick()
    if (PvPLogData[realm][player].mouseover) then
        PvPLogSetMouseover("off");
    else
        PvPLogSetMouseover("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogDing_Toggle_OnClick()
    if (PvPLogData[realm][player].ding) then
        PvPLogSetDing("off");
    else
        PvPLogSetDing("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogDing_Toggle_OnEnter(button)
    GameTooltip:SetOwner(button, "ANCHOR_NONE");
    GameTooltip:SetPoint("TOPLEFT", button:GetName(), "BOTTOMLEFT", -10, -4);
    GameTooltip:SetText(PVPLOG.UI_DING_TIP);
    GameTooltip:Show();
end;

function PvPLogDing_Toggle_OnLeave()
    GameTooltip:Hide();
end;

function PvPLogDisp_Toggle_OnClick()
    if (PvPLogData[realm][player].display) then
        PvPLogSetDisplay("off");
    else
        PvPLogSetDisplay("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogRecordBG_Toggle_OnClick()
    if (PvPLogData[realm][player].recordBG) then
        PvPLogSetRecordBG("off");
    else
        PvPLogSetRecordBG("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogRecordDuel_Toggle_OnClick()
    if (PvPLogData[realm][player].recordDuel) then
        PvPLogSetRecordDuel("off");
    else
        PvPLogSetRecordDuel("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogNotifyBG_Toggle_OnClick()
    if (PvPLogData[realm][player].notifyBG) then
        PvPLogSetNotifyBG("off");
    else
        PvPLogSetNotifyBG("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogNotifyDuel_Toggle_OnClick()
    if (PvPLogData[realm][player].notifyDuel) then
        PvPLogSetNotifyDuel("off");
    else
        PvPLogSetNotifyDuel("on");
    end
    PvPLogConfig_SetValues();
end

function PvPLogNotifyKills_Toggle_OnClick(value)
    PvPLogSlashHandler(PVPLOG.NOTIFYKILL.." "..value);
    PvPLogConfig_SetValues();
end

function PvPLogNotifyDeaths_Toggle_OnClick(value)
    PvPLogSlashHandler(PVPLOG.NOTIFYDEATH.." "..value);
    PvPLogConfig_SetValues();
end

function PvPLogConfigShow()
    if (not initialized) then
        PvPLogInitialize();
    end
    PvPLogData[realm][player].MiniMap.config = 1;
    PvPLogConfigFrame:Show();
end

function PvPLogConfigHide()
    if (not initialized) then
        PvPLogInitialize();
    end
    PvPLogData[realm][player].MiniMap.config = 0;
    PvPLogConfigFrame:Hide();
end

function PvPLogConfig_btnClose_OnClick()
    PvPLogConfigHide();
end

function PvPLogConfig_NotifyKillsCustomChannel_UpdateString()
    PvPLogData[realm][player].notifyKill = ebxPvPLogConfig_NotifyKillsChannel:GetText();
    PvPLogConfig_SetValues();
end

function PvPLogConfig_NotifyKillsCustomChannel_Message()
    local value = ebxPvPLogConfig_NotifyKillsChannel:GetText();
    PvPLogFloatMsg(CYAN .. "PvPLog: " .. WHITE .. PVPLOG.NOTIFYKILL .. CYAN .. PVPLOG.TO .. FIRE .. value);  
end

function PvPLogConfig_NotifyDeathsCustomChannel_UpdateString()
    PvPLogData[realm][player].notifyDeath = ebxPvPLogConfig_NotifyDeathsChannel:GetText();
    PvPLogConfig_SetValues();
end

function PvPLogConfig_NotifyDeathsCustomChannel_Message()
    local value = ebxPvPLogConfig_NotifyDeathsChannel:GetText();
    PvPLogFloatMsg(CYAN .. "PvPLog: " .. WHITE .. PVPLOG.NOTIFYDEATH .. CYAN .. PVPLOG.TO .. FIRE .. value);
end

------------------------
-- PvP and Duel Stats --
------------------------

function PvPLogStatsShow()
    if (not initialized) then
        PvPLogInitialize();
    end
    PvPLogData[realm][player].MiniMap.stats = 1;
    PvPLogStatsFrame:Show();
end

function PvPLogStatsHide()
    if (not initialized) then
        PvPLogInitialize();
    end
    PvPLogData[realm][player].MiniMap.stats = 0;
    PvPLogStatsFrame:Hide();
end

function PvPLogStats_ShowTab(name)
    if (name == "PvP") then
        PVPLOG.STATS_TYPE = PVPLOG.UI_PVP;
    elseif (name == "Recent") then
        PVPLOG.STATS_TYPE = PVPLOG.RECENT;
    elseif (name == "Duel") then
        PVPLOG.STATS_TYPE = PVPLOG.DUEL;
    elseif (name == "Target") then
        PVPLOG.STATS_TYPE = PVPLOG.TARGET;
    end
    statsValue = 1;
    PvPLogStats_SetValues(statsValue);
end

function PvPLog_PvPLogStats_OnLoad()
    realm = GetCVar("realmName");
    player = UnitName("player");
end

function PvPLog_PvPLogStats_OnShow(statsType)
    statsValue = 1;
    PvPLogStats_SetValues(statsValue);
end

function PvPLogStats_SetValues(statsValue)
    local isEnemy;
    if (PVPLOG.STATS_TYPE == PVPLOG.UI_PVP) then
        txtPvPLogStatsFrame_HeaderText:SetText("PvPLog " .. PVPLOG.VER_NUM .. "  -  " .. PVPLOG.UI_PVP .. " " ..PVPLOG.STATS);
        isEnemy = 1;
    elseif (PVPLOG.STATS_TYPE == PVPLOG.DUEL) then
        txtPvPLogStatsFrame_HeaderText:SetText("PvPLog " .. PVPLOG.VER_NUM .. "  -  " .. PVPLOG.DUEL .. " " ..PVPLOG.STATS);
        isEnemy = 0;
    elseif (PVPLOG.STATS_TYPE == PVPLOG.RECENT) then
        txtPvPLogStatsFrame_HeaderText:SetText("PvPLog " .. PVPLOG.VER_NUM .. "  -  " .. PVPLOG.RECENT .. " " ..PVPLOG.STATS);
        isEnemy = 1;
    elseif (PVPLOG.STATS_TYPE == PVPLOG.TARGET) then
        txtPvPLogStatsFrame_HeaderText:SetText("PvPLog " .. PVPLOG.VER_NUM .. "  -  " .. PVPLOG.TARGET .. " " ..PVPLOG.RECORDS);
        isEnemy = 1;
    else
        return;
    end
    txtPvPLogStats_PlayersHeader:SetText(CYAN .. PVPLOG.UI_NAME);
    txtPvPLogStats_ClassHeader:SetText(CYAN .. PVPLOG.UI_CLASS);
    txtPvPLogStats_GuildsHeader:SetText(MAGENTA .. PVPLOG.GUILD);
    txtPvPLogStats_RaceHeader:SetText(CYAN .. PVPLOG.UI_RACE);
    if (PVPLOG.STATS_TYPE == PVPLOG.RECENT) then
        txtPvPLogStats_LevelHeader:SetText(CYAN .. PVPLOG.UI_LDIFF);
        txtPvPLogStats_RealmsHeader:SetText(ORANGE .. PVPLOG.PLAYER);
        txtPvPLogStats_WinsHeader:SetText(GREEN .. PVPLOG.UI_WINS);
        txtPvPLogStats_LossesHeader:SetText(RED .. PVPLOG.UI_FLAGS);
    elseif (PVPLOG.STATS_TYPE == PVPLOG.TARGET) then
        txtPvPLogStats_LevelHeader:SetText(CYAN .. PVPLOG.UI_LEVEL);
        txtPvPLogStats_RealmsHeader:SetText(ORANGE .. PVPLOG.REALM);
        txtPvPLogStats_WinsHeader:SetText(" ");
        txtPvPLogStats_LossesHeader:SetText(GREEN .. "GUID");
    else
        txtPvPLogStats_LevelHeader:SetText(" ");
        txtPvPLogStats_RealmsHeader:SetText(ORANGE .. PVPLOG.REALM);
        txtPvPLogStats_WinsHeader:SetText(GREEN .. PVPLOG.UI_WINS);
        txtPvPLogStats_LossesHeader:SetText(RED .. PVPLOG.UI_LOSSES);
    end
    txtPvPLogStats_PlayerList:SetText("");
    txtPvPLogStats_RaceList:SetText("");
    txtPvPLogStats_ClassList:SetText("");
    txtPvPLogStats_LevelList:SetText("");
    txtPvPLogStats_GuildList:SetText("");
    txtPvPLogStats_RealmsList:SetText("");
    txtPvPLogStats_WinsList:SetText("");
    txtPvPLogStats_LossesList:SetText("");
    pvpPlayerList = "";
    pvpRaceList = "";
    pvpClassList = "";
    pvpLevelList = "";
    pvpGuildList = "";
    pvpRealmList = "";
    pvpWinsList = "";
    pvpLossList = "";
    startCount = ((statsValue*30+1)-30);
    endCount = (statsValue*30);
    statCount  = 1;
    statsTotal = 0;

    if (PVPLOG.STATS_TYPE == PVPLOG.RECENT) then
        local now = time();
        local dayago = now - 24 * 60 * 60;
        local flag;
        PvPLogDebugUI('now = '..tostring(now)..', dayago = '..tostring(dayago));
        table.foreach(PurgeLogData[realm], function( character, v1 )
            PvPLogDebugUI('character = '..tostring(character)..
                ', recordBG = '..tostring(PvPLogData[realm][character].recordBG)..
                ', recordDuel = '..tostring(PvPLogData[realm][character].recordDuel));
            table.foreach(PurgeLogData[realm][character].battles, function( counter, v2 )
                if (v2.time and v2.time > dayago) then
                    if (((PvPLogData[realm][character].recordBG or (v2.bg and v2.bg == 0)) and v2.enemy == 1) or
                        (PvPLogData[realm][character].recordDuel and v2.enemy == 0)) then
                        if (statCount >= startCount and statCount <= endCount) then
                            pvpPlayerList = pvpPlayerList..v2.name.."\n";
                            pvpLevelList = pvpLevelList..v2.lvlDiff.."\n";
                            if (v2.race) then
                                pvpRaceList = pvpRaceList..v2.race.."\n";
                            else
                                pvpRaceList = pvpRaceList.." \n";
                            end
                            if (v2.class) then
                                pvpClassList = pvpClassList..v2.class.."\n";
                            else
                                pvpClassList = pvpClassList.." \n";
                            end
                            if (v2.guild) then
                                pvpGuildList = pvpGuildList..v2.guild.."\n";
                            else
                                pvpGuildList = pvpGuildList.." \n";
                            end
                            pvpRealmList = pvpRealmList..character.."\n";
                            pvpWinsList = pvpWinsList..v2.win.."\n";
                            flag = " ";
                            if (v2.bg and v2.bg ~= 0) then
                                flag = "BG";
                            end
                            if (v2.enemy == 0) then
                                flag = "D";
                            end
                            pvpLossList = pvpLossList..flag.."\n";
                        end
                        statCount = statCount + 1;
                        statsTotal = statsTotal + 1;
                    end
                end
            end);
        end);
    elseif (PVPLOG.STATS_TYPE == PVPLOG.TARGET) then
        PvPLogDebugUI('startCount = '..tostring(startCount)..', endCount = '..tostring(endCount));
        for i = table.getn(targetList),1,-1 do
            if (statCount >= startCount and statCount <= endCount) then
                PvPLogDebugUI('character = '..tostring(targetList[i])..", statCount = "..tostring(statCount));
                v2 = targetRecords[targetList[i]];
                PvPLogDebugUI('    Race = '..tostring(v2.race)..', Class = '..tostring(v2.class));
                PvPLogDebugUI('    Level = '..tostring(v2.level)..', Rank = '..tostring(v2.rank));
                PvPLogDebugUI('    Guild = '..tostring(v2.guild)..', Realm = '..tostring(v2.realm));
                PvPLogDebugUI('    GUID = '..tostring(v2.guid)..', Owner = '..tostring(v2.owner));
                pvpPlayerList = pvpPlayerList..targetList[i].."\n";
                if (v2.race) then
                    pvpRaceList = pvpRaceList..v2.race.."\n";
                else
                    pvpRaceList = pvpRaceList.." \n";
                end
                if (v2.class) then
                    pvpClassList = pvpClassList..v2.class.."\n";
                else
                    pvpClassList = pvpClassList.." \n";
                end
                if (v2.level) then
                    pvpLevelList = pvpLevelList..v2.level.."\n";
                else
                    pvpLevelList = pvpLevelList.." \n";
                end
                if (v2.guild) then
                    pvpGuildList = pvpGuildList..v2.guild.."\n";
                else
                    pvpGuildList = pvpGuildList.." \n";
                end
                if (v2.realm) then
                    pvpRealmList = pvpRealmList..v2.realm.."\n";
                else
                    pvpRealmList = pvpRealmList.." \n";
                end
                if (v2.guid) then
                    pvpWinsList = pvpWinsList..v2.guid.."\n";
                else
                    pvpWinsList = pvpWinsList.." \n";
                end
                    pvpLossList = pvpLossList.." \n";
            end
            statCount = statCount + 1;
            statsTotal = statsTotal + 1;
        end
        PvPLogDebugUI('statCount = '..tostring(statCount)..', statsTotal = '..tostring(statsTotal));
    else
        table.foreach( PvPLogData[realm][player].battles, function( name, v1 )
            if ((statCount >= startCount) and (statCount <= endCount) and (v1.enemy == isEnemy)) then
                pvpPlayerList = pvpPlayerList..name.."\n";

                local ClassNotFound = true;
                local RaceNotFound = true;
                local RealmNotFound = true;
                local GuildNotFound = true;
                if (v1.class) then
                    pvpClassList = pvpClassList..v1.class.."\n";
                    ClassNotFound = false;
                end    
                if (v1.race) then
                    pvpRaceList = pvpRaceList..v1.race.."\n";
                    RaceNotFound = false;
                end    
                if (v1.realm) then
                    pvpRealmList = pvpRealmList..v1.realm.."\n";
                    RealmNotFound = false;
                end    
                if (v1.guild) then
                    pvpGuildList = pvpGuildList..v1.guild.."\n";
                    GuildNotFound = false;
                end    

-- After a while this code could be removed.
                table.foreach(PurgeLogData[realm][player].battles, function( counter, v2 )
                    if (name == v2.name) then
                        if (ClassNotFound and v2.class) then
                            pvpClassList = pvpClassList..v2.class.."\n";
                            ClassNotFound = false;
                            if (not v1.class) then
                                v1.class = v2.class;
                            end
                        end
                        if (RaceNotFound and v2.race) then
                            pvpRaceList = pvpRaceList..v2.race.."\n";
                            RaceNotFound = false;
                            if (not v1.race) then
                                v1.race = v2.race;
                            end
                        end
                        if (RealmNotFound and v2.realm) then
                            pvpRealmList = pvpRealmList..v2.realm.."\n";
                            RealmNotFound = false;
                            if (not v1.realm) then
                                v1.realm = v2.realm;
                            end
                        end
                        if (GuildNotFound and v2.guild) then
                            pvpGuildList = pvpGuildList..v2.guild.."\n";
                            GuildNotFound = false;
                            if (not v1.guild) then
                                v1.guild = v2.guild;
                            end
                        end
                    end
                end);
-- End of code that could be removed.

                if (RaceNotFound) then
                    pvpRaceList = pvpRaceList.." \n";
                end
                if (ClassNotFound) then
                    pvpClassList = pvpClassList.." \n";
                end
                if (RealmNotFound) then
                    pvpRealmList = pvpRealmList.." \n";
                end
                if (GuildNotFound) then
                    pvpGuildList = pvpGuildList.." \n";
                end
                pvpLevelList = pvpLevelList.." \n";
                pvpWinsList = pvpWinsList..v1.wins.."\n";
                pvpLossList = pvpLossList..v1.loss.."\n";
            end
            statCount = statCount + 1;
            statsTotal = statsTotal + 1;
        end);
    end
    txtPvPLogStats_PlayerList:SetText(CYAN .. pvpPlayerList);
    txtPvPLogStats_RaceList:SetText(CYAN .. pvpRaceList);
    txtPvPLogStats_ClassList:SetText(CYAN .. pvpClassList);
    txtPvPLogStats_LevelList:SetText(CYAN .. pvpLevelList);
    txtPvPLogStats_GuildList:SetText(MAGENTA .. pvpGuildList);
    txtPvPLogStats_RealmsList:SetText(ORANGE .. pvpRealmList);
    txtPvPLogStats_WinsList:SetText(GREEN .. pvpWinsList);
    txtPvPLogStats_LossesList:SetText(RED .. pvpLossList);
end

function PvPLog_PvPLogStats_OnHide()
    if (MYADDONS_ACTIVE_OPTIONSFRAME == this) then
        ShowUIPanel(myAddOnsFrame);
    end
end

function PvPLog_PvPLogStats_OnMouseDown(arg1)
    if (arg1 == "LeftButton") then
        PvPLogStatsFrame:StartMoving();
    end
end

function PvPLog_PvPLogStats_OnMouseUp(arg1)
    if (arg1 == "LeftButton") then
        PvPLogStatsFrame:StopMovingOrSizing();
    end
end

function PvPLog_btnPvPLogStats_Close_OnClick()
    PvPLogStatsHide();
end

function PvPLog_btnPvPLogStats_Previous_OnClick()
    if (statsValue > 1) then
        statsValue = statsValue - 1;
    end
    PvPLogStats_SetValues(statsValue);
end

function PvPLog_btnPvPLogStats_Next_OnClick()
    if (statsValue < (statsTotal/5)) then
        statsValue = statsValue + 1;
    end
    PvPLogStats_SetValues(statsValue);
end

function MiniMapButton_Toggle_OnClick()
    if (PvPLogData[realm][player].MiniMap.enabled == 1) then
        MyMinimapButton:SetEnable("PvPLog", 0)
    elseif (PvPLogData[realm][player].MiniMap.enabled == 0) then
        MyMinimapButton:SetEnable("PvPLog", 1)
    else
        PvPLogData[realm][player].MiniMap = PvPLogMinimapButtonInit();
        PvPLogCreateMinimapButton();
        MyMinimapButton:SetEnable("PvPLog", 1)
    end
end

function PvPLog_OnMouseDown(arg1)
    if (arg1 == "LeftButton") then
        PvPLogTargetFrame:StartMoving();
    end
end

function PvPLog_OnMouseUp(arg1)
    if (arg1 == "LeftButton") then
        PvPLogTargetFrame:StopMovingOrSizing();
    end
end

