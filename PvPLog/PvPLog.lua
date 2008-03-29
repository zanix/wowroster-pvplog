--[[
    PvPLog 
    Author:           Brad Morgan
    Based on Work by: Josh Estelle, Daniel S. Reichenbach, Andrzej Gorski, Matthew Musgrove
    Version:          3.0.0
    Last Modified:    2008-03-28
]]

-- Local variables
local variablesLoaded = false;
local initialized = false;

local notifyQueued = false;
local queuedMessage = "";
local queuedChannel = "";

local realm = "";
local player = "";
local plevel = -1;
local mlevel = 70; -- Maximum player level
local dlevel = 11; -- Difference causing level of -1 to be returned

local softPL; -- soft PvPLog enable/disable

local bg_status;
local bg_mapName;
local bg_instanceId;
local bg_found = false;

local isDuel = false;
local duelInbounds = true;

local debug_flag = false;     -- Overridden by PvPLogDebug.flag after VARIABLES_LOADED event.
local debug_comm = false;     -- Overridden by PvPLogDebug.comm after VARIABLES_LOADED event.
local debug_ignore = true;    -- Overridden by PvPLogDebug.ignore after VARIABLES_LOADED event.
local debug_event1 = false;   -- Overridden by PvPLogDebug.event1 after VARIABLES_LOADED event.
local debug_event2 = false;   -- Overridden by PvPLogDebug.event2 after VARIABLES_LOADED event.
local debug_combat = false;   -- Overridden by PvPLogDebug.combat after VARIABLES_LOADED event.
local debug_pve = false;      -- Overridden by PvPLogDebug.pve after VARIABLES_LOADED event.
local debug_ui = false;       -- Overridden by PvPLogDebug.ui after VARIABLES_LOADED event.
local debug_ttm = false;
local debug_ptc = true;       -- Overridden by PvPLogDebug.ptc after VARIABLES_LOADED event.

local lastDamagerToMe = "";
local foundDamaged = false;
local foundDamager = false;

local NUMTARGETS = 60;
local NUMRECENTS = 10;
local recentDamager = { };
local recentDamaged = { };
local ignoreList = { };
local ignoreRecords = { };

local MAXDEBUG = 2000;

local lastDing = -1;        -- This will contain the GetTime() of the last ding and overhead message.
local lastRecent = -1;      -- This will contain the GetTime() of the last removal of a recentDamaged.
local nextRecent = 3.0;     -- Seconds between removing each recentDamaged.

local RED     = "|cffbe0303";
local GREEN   = "|cff6bb700";
local BLUE    = "|cff0863c3";
local MAGENTA = "|cffa800a8";
local YELLOW  = "|cffffd505";
local CYAN    = "|cff00b1b1";
local WHITE   = "|cffdedede";
local ORANGE  = "|cffd06c01";
local PEACH   = "|cffdec962";
local FIRE    = "|cffde2413";

PVPLOG.VER_NUM = GetAddOnMetadata("PvPLog", "Version");
PVPLOG.VENDOR = "wowroster.net";
PVPLOG.URL = "http://www."..PVPLOG.VENDOR;

-- Called OnLoad of the add on
function PvPLogOnLoad()
    
    if (PVPLOG.VER_NUM) then
        PVPLOG.STARTUP = string.gsub( PVPLOG.STARTUP, "%%v", PVPLOG.VER_NUM );
    end
    if (PVPLOG.VENDOR) then
        PVPLOG.STARTUP = string.gsub( PVPLOG.STARTUP, "%%w", PVPLOG.VENDOR );
    end
    PvPLogChatMsgCyan(PVPLOG.STARTUP);

    -- respond to saved variable load
    this:RegisterEvent("VARIABLES_LOADED");

    -- respond to player entering the world
    this:RegisterEvent("PLAYER_ENTERING_WORLD");

    -- channel stuff
    this:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE");

    -- respond to player name update
    this:RegisterEvent("UNIT_NAME_UPDATE");

    -- respond when player dies
    this:RegisterEvent("PLAYER_DEAD"); 

    -- respond when our target changes
    this:RegisterEvent("PLAYER_TARGET_CHANGED");

    -- respond to when you change mouseovers
    this:RegisterEvent("UPDATE_MOUSEOVER_UNIT");

    -- keep track of players level
    this:RegisterEvent("PLAYER_LEVEL_UP");

    -- enters/leaves combat (for DPS)
    this:RegisterEvent("PLAYER_REGEN_ENABLED");
    this:RegisterEvent("PLAYER_REGEN_DISABLED");

    this:RegisterEvent("UNIT_HEALTH");

    this:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end

function PvPLog_MiniMap_LeftClick()
    if (PvPLogData[realm][player].MiniMap.stats == 1) then
        PvPLogStatsHide();
    else
        PvPLogStatsShow();
    end
end
 
function PvPLog_MiniMap_RightClick()
    if (PvPLogData[realm][player].MiniMap.config == 1) then
        PvPLogConfigHide();
    else
        PvPLogConfigShow();
    end
end


function PvPLog_RegisterWithAddonManagers()
    -- Based on MobInfo2's MI_RegisterWithAddonManagers
    -- register with myAddons manager
    if ( myAddOnsFrame_Register ) then
        local PvPLogDetails = {
            name = "PvPLog",
            version = PVPLOG.VER_NUM,
            author = "Andrzej Gorski",
            website = PVPLOG.URL,
            category = MYADDONS_CATEGORY_OTHERS,
            optionsframe = "PvPLogConfigFrame"
        };
        myAddOnsFrame_Register( PvPLogDetails );
    end

    -- register with EARTH manager (mainly for Cosmos support)
    if EarthFeature_AddButton then
        EarthFeature_AddButton(
            {
                id = "PvPLog",
                name = "PvPLog",
                subtext = "v"..PVPLOG.VER_NUM,
                tooltip = PVPLOG.DESCRIPTION,
                icon = PvPLogGetFactionIcon(),
                callback = function(state) PvPLog_MiniMap_RightClick() end,
                test = nil
            }
        )
    
    -- register with KHAOS (only if EARTH not found)
    elseif Khaos then
        Khaos.registerOptionSet(
            "other",
            {
                id = "PvPLogOptionSet",
                text = "PvPLog",
                helptext = PVPLOG.DESCRIPTION,
                difficulty = 1,
                callback = function(state) end,
                default = true,
                options = {
                    {
                        id = "PvPLogOptionsHeader",
                        type = K_HEADER,
                        difficulty = 1,
                        text = "PvPLog v"..PVPLOG.VER_NUM,
                        helptext = PVPLOG.DESCRIPTION
                    },
                    {
                        id = "MobInfo2OptionsButton",
                        type = K_BUTTON,
                        difficulty = 1,
                        text = "PvPLog "..PVPLOG.UI_CONFIG,
                        helptext = "",
                        callback = function(state) PvPLog_MiniMap_RightClick() end,
                        feedback = function(state) end,
                        setup = { buttonText = PVPLOG.UI_OPEN }
                    }
                }
            }
        )
    end
end  -- PvPLog_RegisterWithAddonManagers()

function PvPLogMinimapButtonInit()
    local info = { };
    info.radius = 80; -- default only. after first use, SavedVariables used
    info.position = -45; -- default only. after first use, SavedVariables used
    info.drag = "CIRCLE"; -- default only. after first use, SavedVariables used
    info.tooltip = PVPLOG.UI_RIGHT_CLICK .. PVPLOG.UI_TOGGLE .."\n".. PVPLOG.UI_LEFT_CLICK .. PVPLOG.UI_TOGGLE2;
    info.enabled = 1; -- default only. after first use, SavedVariables used
    info.config = 0;
    info.stats = 0;
    info.icon = PvPLogGetFactionIcon();
    return info;
end

function PvPLogCreateMinimapButton()
    local info = PvPLogMinimapButtonInit();
    MyMinimapButton:Create("PvPLog", PvPLogData[realm][player].MiniMap, info);
    MyMinimapButton:SetRightClick("PvPLog", PvPLog_MiniMap_RightClick);
    MyMinimapButton:SetLeftClick("PvPLog", PvPLog_MiniMap_LeftClick);
end

function PvPLogOnEvent()   
    if (debug_event1) then 
        PvPLogDebugMsg("Event: "..event, GREEN);
    end
    if (debug_event2) then 
        PvPLogDebugAdd("Event: "..event); 
    end
    -- loads and initializes our variables
    if (event == "VARIABLES_LOADED") then
        variablesLoaded = true;
        if (PvPLogDebugFlags == nil) then
            PvPLogDebugFlags = { };
        end
        if (PvPLogDebugFlags.debug == nil) then
            PvPLogDebugFlags.debug = false;
        else
            debug_flag = PvPLogDebugFlags.debug; -- Manually set to true if you want to always debug.
        end
        if (PvPLogDebugFlags.comm == nil) then
            PvPLogDebugFlags.comm = false;
        else
            debug_comm = PvPLogDebugFlags.comm; -- Manually set to true if you want to always debug communications.
        end
        if (PvPLogDebugFlags.ignore == nil) then
            PvPLogDebugFlags.ignore = true;
        else
            debug_ignore = PvPLogDebugFlags.ignore; -- Manually set to false if you want to not ignore anything.
        end
        if (PvPLogDebugFlags.event1 == nil) then
            PvPLogDebugFlags.event1 = false;
        else
            debug_event1 = PvPLogDebugFlags.event1; -- Manually set to true if you want event debugging.
        end
        if (PvPLogDebugFlags.event2 == nil) then
            PvPLogDebugFlags.event2 = false;
        else
            debug_event2 = PvPLogDebugFlags.event2; -- Manually set to true if you want event debugging.
        end
        if (PvPLogDebugFlags.combat == nil) then
            PvPLogDebugFlags.combat = false;
        else
            debug_combat = PvPLogDebugFlags.combat; -- Manually set to true if you want combat debugging.
        end
        if (PvPLogDebugFlags.pve == nil) then
            PvPLogDebugFlags.pve = false;
        else
            debug_pve = PvPLogDebugFlags.pve; -- Manually set to true if you want to record pve (for debugging).
        end
        if (PvPLogDebugFlags.ui == nil) then
            PvPLogDebugFlags.ui = false;
        else
            debug_ui = PvPLogDebugFlags.ui; -- Manually set to true if you want to record pve (for debugging).
        end
        if (PvPLogDebugFlags.ptc == nil) then
            PvPLogDebugFlags.ptc = true;
        else
            debug_ptc = PvPLogDebugFlags.ptc; -- Manually set to false if you want not use PLAYER_TARGET_CHANGED (for debugging).
        end
        PvPLog_RegisterWithAddonManagers();
        
    -- initialize when entering world
    elseif (event == "PLAYER_ENTERING_WORLD") then
        PvPLogInitialize();
        local bg_found = false;
        local x, y = GetPlayerMapPosition("player");
        if ((x == 0) and (y == 0)) then
            SetMapToCurrentZone();
            x, y = GetPlayerMapPosition("player");
        end    
        -- Determines whether we are in an Instance or not 
        if (x == 0 and y == 0) then -- inside instance
        -- Check if the Instance is a Battleground
            if (PvPLogInBG()) then
                softPL = true;
            else
                softPL = false;
            end
        else
            softPL = true;
        end
        PvPLogCreateMinimapButton();

    -- keep track of name changes
    elseif (event == "UNIT_NAME_UPDATE") then
        player = UnitName("player");
        plevel = UnitLevel("player");

    -- keep track of players level
    elseif (event == "PLAYER_LEVEL_UP") then
        plevel = UnitLevel("player");

    -- send the queued message now that we are in the channel.
    elseif (event == "CHAT_MSG_CHANNEL_NOTICE") then
        if (notifyQueued) then
            PvPLogSendMessageOnChannel(queuedMessage, queuedChannel);
            notifyQueued = false;
        end
       
    -- add record to mouseover
    elseif (event == "UPDATE_MOUSEOVER_UNIT") then
        if (not PvPLogData[realm][player].enabled or not softPL) then
            return;
        end

        -- adds record to mouseover if it exists (and mouseover enabled)
        if (PvPLogData[realm][player].mouseover) then

            if (UnitExists("mouseover")) then
--***
-- Code for debugging the tooltip stuff
                if (debug_ttm) then
                    local v2 = { };
                    PvPLogGetTooltipText(v2, PvPLogUnitName("mouseover"), nil, nil);
                    PvPLogChatMsg("character = '"..PvPLogUnitName("mouseover").."'");
                    PvPLogChatMsg('    Race = '..tostring(v2.race)..', Class = '..tostring(v2.class));
                    PvPLogChatMsg('    Level = '..tostring(v2.level)..', Rank = '..tostring(v2.rank));
                    PvPLogChatMsg('    Guild = '..tostring(v2.guild)..', Realm = '..tostring(v2.realm));
                    PvPLogChatMsg('    GUID = '..tostring(v2.guid)..', Owner = '..tostring(v2.owner));
                end
--***
                local total = PvPLogGetPvPTotals(PvPLogUnitName("mouseover"));
                local guildTotal = PvPLogGetGuildTotals(GetGuildInfo("mouseover"));

                if (total and (total.wins > 0 or total.loss > 0)) then
                    if (not UnitIsFriend("mouseover", "player")) then 
                        GameTooltip:AddLine(CYAN .. PVPLOG.UI_PVP .. ": " .. GREEN .. total.wins .. 
                             CYAN .. " / " .. RED .. total.loss, 
                             1.0, 1.0, 1.0, 0);
                    else
                        GameTooltip:AddLine(CYAN .. PVPLOG.DUEL .. ": " .. GREEN .. total.wins .. 
                             CYAN.." / " .. RED .. total.loss, 
                             1.0, 1.0, 1.0, 0);
                    end
                    GameTooltip:SetHeight(GameTooltip:GetHeight() + 
                              GameTooltip:GetHeight() / 
                                 GameTooltip:NumLines());
                end

                if (guildTotal and (guildTotal.wins > 0 or guildTotal.loss > 0) and
                  (not total or total.wins ~= guildTotal.wins or 
                  total.loss ~= guildTotal.loss)) then
                    if (not UnitIsFriend("mouseover", "player")) then 
                        GameTooltip:AddLine(CYAN .. PVPLOG.GUILD .. " "..PVPLOG.UI_PVP..": " .. GREEN .. 
                               guildTotal.wins .. 
                               CYAN .. " / " .. RED .. guildTotal.loss, 
                               1.0, 1.0, 1.0, 0);
                    else
                        GameTooltip:AddLine(CYAN .. PVPLOG.GUILD.." "..PVPLOG.DUEL..": " .. GREEN .. 
                               guildTotal.wins .. 
                               CYAN .. " / " ..  RED .. guildTotal.loss, 
                               1.0, 1.0, 1.0, 0);
                    end
                    GameTooltip:SetHeight(GameTooltip:GetHeight() + 
                        GameTooltip:GetHeight() / 
                        GameTooltip:NumLines());
                end

                if (GetTime() > lastDing + PvPLogData[realm][player].dingTimeout and
                  not UnitInParty("mouseover") and UnitIsPlayer("mouseover") and
                  ((total and (total.wins > 0 or total.loss > 0)) or
                  (guildTotal and (guildTotal.wins > 0 or guildTotal.loss > 0)))) then
                    local msg = "PvP Record: ";
                    if (total and (total.wins > 0 or total.loss > 0)) then
                        msg = msg .. total.wins.. " / " .. total.loss;
                    end
                    if (guildTotal and (guildTotal.wins > 0 or guildTotal.loss > 0)) then
                        msg = msg .. "  Guild Record: "..guildTotal.wins.. " / "
                        .. guildTotal.loss;
                    end
                    PvPLogFloatMsg(msg, "fire");

                    msg = PvPLogUnitName("mouseover") ..
                        " -- [" .. UnitLevel("mouseover") .. "] " .. 
                        UnitRace("mouseover") .. " " .. UnitClass("mouseover");
                    if (GetGuildInfo("mouseover")) then
                        msg = msg .. " of <" .. GetGuildInfo("mouseover") .. ">";
                    end
                    PvPLogFloatMsg(msg, "peach");
                    if (PvPLogData[realm][player].ding) then
                        PlaySound(PvPLogData[realm][player].dingSound);
                    end
                    lastDing = GetTime();
                end
            end
        end

    -- Keep track of those we've targeted
    elseif (event == "PLAYER_TARGET_CHANGED") then
        local field = getglobal("PvPLogTargetText");
        field:Hide();
        field:SetText("");

        -- if we're enabled
        if (PvPLogData[realm][player].enabled and softPL) then
            PvPLogUpdateTarget(isDuel);
        end

    elseif (event == "PLAYER_DEAD") then
        -- make sure we have a last damager
        -- and are enabled
        if (lastDamagerToMe == "" or
          not PvPLogData[realm][player].enabled or 
          not softPL) then
            return;
        end
     
        -- search in player list
        local found = false;
        table.foreach(recentDamager,
            function(i,tname)
                if (tname == lastDamagerToMe) then
                    found = true;
                    return true;
                end
            end
        );
        if (found) then
            if (targetRecords[lastDamagerToMe]) then
                if (targetRecords[lastDamagerToMe].level) then
                    v = targetRecords[lastDamagerToMe];
                    PvPLogChatMsgCyan("PvP "..PVPLOG.DLKB..RED..lastDamagerToMe);
                    PvPLogRecord(lastDamagerToMe, v.level, v.race, v.class, v.guild, 1, 0, v.rank, v.realm);
                else
                    PvPLogDebugMsg("Empty targetRecords for: "..lastDamagerToMe, RED);
                end
            else
                PvPLogDebugMsg("No targetRecords for: "..lastDamagerToMe, RED);
            end
        else
            PvPLogDebugMsg("No recentDamager for: "..lastDamagerToMe, RED);
        end

        -- we are dead, clear the variables
        PvPLogDebugMsg('Recents cleared (dead).');
        -- recentDamaged = { }; -- Deferred because some of them may still die.
        recentDamager = { };
        lastDamagerToMe = "";

    -- Combat Events now all come here
    elseif ( event == "COMBAT_LOG_EVENT_UNFILTERED") then

        CombatLogSetCurrentEntry(-1,true);
        local timestamp, type, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, u1, u2, u3, u4, u5, u6, u7, u8 = CombatLogGetCurrentEntry(); 

        local message = "";
        if (debug_flag) then
            message = string.format("%s, %s, %s, 0x%x, %s, %s, 0x%x; %s, %s, %s, %s, %s, %s, %s, %s",
                tostring(type),
                tostring(srcGUID), srcName or "nil", srcFlags or 0,
                tostring(dstGUID), dstName or "nil", dstFlags or 0,
                tostring(u1), tostring(u2), tostring(u3), tostring(u4),
                tostring(u5), tostring(u6), tostring(u7), tostring(u8));
        end
--
-- This is where the fun begins. 
-- Decoding the combat events (type) into what damaged me and what I damaged.
--

        if (type == "PARTY_KILL") then
            if (debug_combat) then
                PvPLogDebugMsg(message, RED);
            else
                PvPLogDebugAdd(message);
            end
            if (debug_pve or bit.band(dstFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0) then
                PvPLogPlayerDeath(dstName);
            end
        elseif (type == "UNIT_DIED") then
            if (dstName ~= player) then
                -- The death of the player will be handled by the PLAYER_DEAD event.
                if (debug_combat) then
                    PvPLogDebugMsg(message, ORANGE);
                else
                    PvPLogDebugAdd(message);
                end
                if (debug_pve or bit.band(dstFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0) then
                    PvPLogPlayerDeath(dstName);
                end
            end
        elseif (srcName == player) then
            if (debug_combat) then
                PvPLogDebugMsg(message, GREEN);
            else
                PvPLogDebugAdd(message);
            end
            -- Don't keep track of damage to self (Life Tap)
            if (dstName ~= player) then
                if (bit.band(dstFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0) then
                    if (debug_pve or bit.band(dstFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0) then
                        PvPLogMyDamage(dstName, dstGUID);
                    elseif (debug_ignore) then
                        if (not ignoreRecords[dstName]) then
                            PvPLogDebugMsg('Ignore added (damaged): ' .. dstName);
                            PvPLogAddIgnore(dstName)
                        end
                        if (targetRecords[dstName]) then
                            -- It got into targetRecords, remove it.
                            PvPLogRemTarget(dstName);
                        end
                    end
                end
            end
        elseif (dstName == player) then
            if (debug_combat) then
                PvPLogDebugMsg(message, YELLOW);
            else
                PvPLogDebugAdd(message);
            end
            if (bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) ~= 0) then
                if (debug_pve or bit.band(srcFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) ~= 0) then
                    PvPLogDamageMe(srcName, srcGUID);
                elseif (debug_ignore) then
                    if (not ignoreRecords[srcName]) then
                        PvPLogDebugMsg('Ignore added (damager): ' .. srcName);
                        PvPLogAddIgnore(srcName)
                    end
                    if (targetRecords[srcName]) then
                        -- It got into targetRecords, remove it.
                        PvPLogRemTarget(srcName);
                    end
                end
            end
        else
            if (debug_combat) then
                PvPLogDebugMsg(message, WHITE);
            end
        end
    
    -- Player health changes, watch for full health and then start removing records of recentDamaged.
    elseif (event == "UNIT_HEALTH") then
        if (not UnitAffectingCombat("player") and UnitHealth("player") == UnitHealthMax("player")) then
            if ((recentDamager and table.getn(recentDamager) > 0) or lastDamagerToMe ~= "") then
                PvPLogDebugMsg('Recents cleared (healthy).');
                recentDamager = { };
                lastDamagerToMe = "";
            end
            if (GetTime() > lastRecent + nextRecent and recentDamaged and table.getn(recentDamaged) > 0) then 
                PvPLogDebugMsg('recentDamaged removed: ' .. recentDamaged[1]);
                table.remove(recentDamaged,1);
                lastRecent = GetTime();
            end
        end

    -- Events which signal entering and leaving combat.
    elseif (event == "PLAYER_REGEN_DISABLED") then
        if (debug_event2) then 
            -- PvPLogDebugMsg("Event: "..event, GREEN);
        end
        PvPLogStatsFrame:Hide();
        PvPLogConfigHide();
    elseif (event == "PLAYER_REGEN_ENABLED") then
        if (debug_event2) then 
            -- PvPLogDebugMsg("Event: "..event, GREEN);
        end
    end
end

function PvPLogPrintStats()
    local stats = PvPLogGetStats();
    PvPLogChatMsgCyan("PvPLog " .. PVPLOG.STATS .. ":");
    PvPLogChatMsg(MAGENTA.."   "..PVPLOG.TOTAL.." "..PVPLOG.WINS..":     ".. stats.totalWins ..
        " ("..PVPLOG.ALD..": "..(math.floor(stats.totalWinAvgLevelDiff*100)/100)..")");

    PvPLogChatMsg(MAGENTA.."   "..PVPLOG.TOTAL.." "..PVPLOG.LOSSES..":  ".. stats.totalLoss ..
        " ("..PVPLOG.ALD..": "..(math.floor(stats.totalLossAvgLevelDiff*100)/100)..")");

    PvPLogChatMsg(ORANGE .. "    "..PVPLOG.UI_PVP.." "..PVPLOG.WINS..":     ".. stats.pvpWins ..
        " ("..PVPLOG.ALD..": "..(math.floor(stats.pvpWinAvgLevelDiff*100)/100)..")");

    PvPLogChatMsg(ORANGE .. "    "..PVPLOG.UI_PVP.." "..PVPLOG.LOSSES..":  ".. stats.pvpLoss ..
        " ("..PVPLOG.ALD..": "..(math.floor(stats.pvpLossAvgLevelDiff*100)/100)..")");

    PvPLogChatMsg(GREEN .. "    "..PVPLOG.DUEL.." "..PVPLOG.WINS..":    ".. stats.duelWins ..
        " ("..PVPLOG.ALD..": "..(math.floor(stats.duelWinAvgLevelDiff*100)/100)..")");

    PvPLogChatMsg(GREEN .. "    "..PVPLOG.DUEL.." "..PVPLOG.LOSSES..": ".. stats.duelLoss ..
        " ("..PVPLOG.ALD..": "..(math.floor(stats.duelLossAvgLevelDiff*100)/100)..")");
end

function PvPLogDebugMsg(msg, color)
    if (debug_flag) then
        if (color) then
            PvPLogChatMsg('PvPLog: ' .. color .. msg);
        else
            PvPLogChatMsg('PvPLog: ' .. msg);
        end
        PvPLogDebugAdd(msg);
    end
end

function PvPLogDebugAdd(msg)
    if (debug_flag) then
        table.insert(PvPLogDebug,date()..": "..msg);
        if (table.getn(PvPLogDebug) > MAXDEBUG) then
            table.remove(PvPLogDebug,1);
        end
    end
end

function PvPLogDebugComm(msg, color)
    if (debug_comm) then
        if (color) then
            PvPLogChatMsg('PvPLog: ' .. color .. msg);
        else
            PvPLogChatMsg('PvPLog: ' .. msg);
        end
    end
end

function PvPLogDebugUI(msg, color)
    if (debug_ui) then
        if (color) then
            PvPLogChatMsg('PvPLog: ' .. color .. msg);
        else
            PvPLogChatMsg('PvPLog: ' .. msg);
        end
    end
end

function PvPLogChatMsg(msg)
    if (DEFAULT_CHAT_FRAME) then
        DEFAULT_CHAT_FRAME:AddMessage(msg);
    end
end

function PvPLogFloatMsg(msg, color)
    -- Display overhead message.  7 basic colors available
    -- Use at most 3 lines here - the rest get lost
    if (not PvPLogData[realm][player].display) then
        return;
    end
    local r, g, b
    if (color == nil) then 
        color = "white";
    end
    if (string.lower(color) == "red") then
        r, g, b = 190/255, 3/255, 3/255;
    elseif (string.lower(color) == "green") then
        r, g, b = 107/255, 183/255, 0.0;
    elseif (string.lower(color) == "blue") then
        r, g, b = 8/255, 99/255, 195/255;
    elseif (string.lower(color) == "magenta") then
        r, g, b = 168/255, 0.0, 168/255;
    elseif (string.lower(color) == "yellow") then
        r, g, b = 1.0, 213/255, 5/255;
    elseif (string.lower(color) == "cyan") then
        r, g, b = 0.0, 177/255, 177/255;
    elseif (string.lower(color) == "orange") then
        r, g, b = 208/255, 108/255, 0.0;
    elseif (string.lower(color) == "peach") then
        r, g, b = 222/255, 201/255, 98/255;
    elseif (string.lower(color) == "fire") then
        r, g, b = 222/255, 36/255, 19/255;
    else 
        r, g, b = 1.0, 1.0, 1.0;
    end
    UIErrorsFrame:AddMessage(msg, r, g, b, 1.0, UIERRORS_HOLD_TIME);
end

function PvPLogPlayerDeath(parseName)
    -- if we have a name
    if (parseName) then
        PvPLogDebugMsg("Processing death of: "..parseName, YELLOW);
        local found = false;
        local index = 0;
        table.foreach(recentDamaged,
            function(i,tname)
                if (tname == parseName) then
                    found = true;
                    index = i;
                    return found;
                end
            end
        );
        if (found) then
            table.remove(recentDamaged,index); -- We can't take credit for their future deaths.
            if (targetRecords[parseName]) then
                if (targetRecords[parseName].level) then
                    v = targetRecords[parseName];
                    PvPLogChatMsgCyan(PVPLOG.KL  .. GREEN .. parseName);
                    PvPLogRecord(parseName, v.level, v.race, v.class, v.guild, 1, 1, v.rank, v.realm);
                    if (parseName == lastDamagerToMe) then
                        lastDamagerToMe = "";
                    end
                else
                    PvPLogDebugMsg("Empty targetRecords for: "..parseName, RED);
                end
            else
                PvPLogDebugMsg("No targetRecords for: "..parseName, RED);
            end
        else
            PvPLogDebugMsg("No recentDamaged for: "..parseName, RED);
        end
    end
end

function PvPLogFindRealm(full)
    local left;
    local realm;
    _, _, left, realm = string.find(full,"(.*) %- (.*)");
    PvPLogDebugMsg("full = '"..tostring(full).."'");
    PvPLogDebugMsg("left = '"..tostring(left).."', realm = '"..tostring(realm).."'");
    return left, realm;
end

function PvPLogFindRank(full, name)
    local rank;
    local left, found = string.gsub(full, " "..name, "");
    if (found == 1) then
        rank = left;
    else
        left, found = string.gsub(full, name..", ", "");
        if (found == 1) then
            rank = left;
        end
    end
    PvPLogDebugMsg("full = '"..tostring(name).."', name = '"..tostring(name).."'");
    PvPLogDebugMsg("rank = '"..tostring(rank).."'");
    return rank;
end

function PvPLogUnitName(unit)
    local name = GetUnitName(unit, true);
    if (name) then
        name = string.gsub(name, " %- ", "-");
    end
    return name;
end

function PvPLogGetTooltipText(table, name, guid, addpet)
    local m = 0;
    local l = 0;
    local hide = false;
    local text = { };
    local level;

    if (guid) then
        PvPLogDebugMsg("name = '"..name.."', guid = '"..tostring(guid).."'");
        GameTooltip:SetHyperlink("unit:" .. guid);
        hide = true;
        table.guid = guid;
    end
    m = GameTooltip:NumLines();
    -- PvPLogDebugMsg("m = "..tostring(m));
    for n = 1, m do
        text[n] = getglobal('GameTooltipTextLeft'..n):GetText();
        PvPLogDebugMsg("text["..n.."] = "..tostring(text[n]));
        if (string.find(text[n], PVPLOG.TT_LEVEL)) then
            l = n;
        end    
    end
    if (hide) then
        GameTooltip:Hide();
    end
    if (l > 0) then
        _, _, level, table.race, table.class = string.find(text[l], PVPLOG.TT_PLAYER);
        if (level == "??") then
            table.level = -1;
        else
            table.level = tonumber(level);
        end
    end
    if (l == 3) then
        local left, found = string.gsub(text[2], PVPLOG.TT_PET, "");
        if (found == 1) then
            table.owner = left;
            if (addpet) then
                if (not targetRecords[left]) then
                    PvPLogDebugMsg("Owner Target Addition: "..left, RED);
                    PvPLogAddTarget(left);
                end
                targetRecords[left].pet = name;
            end
        else
            left, found = string.gsub(text[2], PVPLOG.TT_MINION, "");
            if (found == 1) then
                table.owner = left;
                if (addpet) then
                    if (not targetRecords[left]) then
                        PvPLogDebugMsg("Owner Target Addition: "..left, RED);
                        PvPLogAddTarget(left);
                    end
                    targetRecords[left].pet = name;
                end
            end
        end
        if (found == 1) then
            _, _, level = string.find(text[3], PVPLOG.TT_LEVEL2);
            if (level == "??") then
                table.level = -1;
            else
                table.level = tonumber(level);
            end
        else
            table.guild = text[2];
        end
    end
    if (m > 0) then
        local left;
        left, table.realm = PvPLogFindRealm(text[1]);
        if (left) then
            table.rank = PvPLogFindRank(left, name);
        else
            table.rank = PvPLogFindRank(text[1], name);
        end
    end
end

-- Add to recentDamaged or recentDamager Lists (if not already there).
function PvPLogPutInTable(tab, nam)
    local exists = false;
    table.foreach(tab,
        function(i,tar)
            if (tar == nam) then
                exists = true;
                return exists;
            end
        end
    );
    if (not exists) then
        table.insert(tab, nam);
        if (table.getn(tab) > NUMRECENTS) then
           table.remove(tab,1);
        end
    end
    return exists;
end

-- Add to ignoreRecords and ignoreList.
function PvPLogAddIgnore(name)
    ignoreRecords[name] = true;
    table.insert(ignoreList, name);
    if (table.getn(ignoreList) > NUMTARGETS) then
        PvPLogDebugMsg('Ignore removed: ' .. ignoreList[1]);
        ignoreRecords[ignoreList[1]] = nil;
        table.remove(ignoreList,1);
    end
end

-- Add to targetRecords and targetList.
function PvPLogAddTarget(name)
    targetRecords[name] = { };
    table.insert(targetList, name);
    if (table.getn(targetList) > NUMTARGETS) then
        PvPLogDebugMsg('Target removed: ' .. targetList[1]);
        targetRecords[targetList[1]] = nil;
        table.remove(targetList,1);
    end
end

-- Remove from targetRecords and targetList.
function PvPLogRemTarget(name)
    local index = -1;
    table.foreach(targetList,
        function(i,t)
            if(t == name) then
                index = i;
                return;
            end
        end
    );
    if (index ~= -1) then
        PvPLogDebugMsg('Target removed: ' .. targetList[index]);
        targetRecords[name] = nil;
        table.remove(targetList,index);
    else
        PvPLogDebugMsg('TargetRecord not found in TargetList for: '..targetName);
    end
end

function PvPLogMyDamage(res1,guid)
    if (res1) then
        if ((isDuel or not ignoreRecords[res1]) and not targetRecords[res1]) then
            PvPLogDebugMsg("Damaged Target Addition: "..res1, RED);
            PvPLogAddTarget(res1);
            PvPLogGetTooltipText(targetRecords[res1], res1, guid, true);
        end
        if (isDuel or not ignoreRecords[res1]) then
            if (not PvPLogPutInTable(recentDamaged, res1)) then
                PvPLogDebugMsg("recentDamaged["..table.getn(recentDamaged).."]: "..res1, ORANGE);
            end
            foundDamaged = true;
        end
        if (guid and targetRecords[res1]) then
            targetRecords[res1].guid = guid;
        end
    end
end

function PvPLogDamageMe(res1, guid)
    if (res1) then
        if ((isDuel or not ignoreRecords[res1]) and not targetRecords[res1]) then
            PvPLogDebugMsg("Damager Target Addition: "..res1, RED);
            PvPLogAddTarget(res1);
            PvPLogGetTooltipText(targetRecords[res1], res1, guid, true);
        end
        if (isDuel or not ignoreRecords[res1]) then
            if (not PvPLogPutInTable(recentDamager, res1)) then
                PvPLogDebugMsg("recentDamager["..table.getn(recentDamager).."]: "..res1, ORANGE);
            end
            lastDamagerToMe = res1;
            foundDamager = true;
        end
        if (guid and targetRecords[res1]) then
            targetRecords[res1].guid = guid;
        end
    end
end

-- This function is called whenever the player's target has changed.
-- In WoW V2, this is about the only place where we can be sure of capturing
-- information about our target.
-- In WoW 2.4, The GUID in the combat log gives us another method to collect target info.
function PvPLogUpdateTarget(dueling)
    local targetName = PvPLogUnitName("target")     
    local _, targetRealm = UnitName("target"); 
    local targetLevel = UnitLevel("target");
    local targetRace = UnitRace("target");
    local targetClass = UnitClass("target");
    local targetGuild = GetGuildInfo("target");
    local targetRank = UnitPVPName("target");
    local targetIsPlayer = UnitIsPlayer("target");
    local targetIsControlled = UnitPlayerControlled("target");
    local targetIsEnemy = UnitIsEnemy("player", "target");
    local targetName2 = PvPLogUnitName("target");
    if (targetName and targetName2 and targetName ~= targetName2) then
        PvPLogDebugMsg('Target changed from '.. targetName ..' to ' .. targetName2);
        return;
    end
    if (targetName) then
        -- We have a valid target
        if (dueling or ((targetIsPlayer or debug_pve) and targetIsEnemy)) then 
            -- Its a player and its an enemy
            -- (debug_pve only includes hostile NPCs, not neutral NPCs)
            -- for debugging purposes, we may not want to add records via targeting
            if (debug_ptc) then 
                if (not targetRecords[targetName]) then
                    PvPLogDebugMsg('Target added: ' .. targetName);
                    PvPLogAddTarget(targetName);
                end
                if (not targetRecords[targetName].level) then
                    PvPLogDebugMsg('Target populated: ' .. targetName);
                    targetRecords[targetName].realm = targetRealm;
                    targetRecords[targetName].level = targetLevel;
                    targetRecords[targetName].race = targetRace;
                    targetRecords[targetName].class = targetClass;
                    targetRecords[targetName].guild = targetGuild;
                    targetRecords[targetName].rank = PvPLogFindRank(targetRank, targetName);
                else
                    if (targetLevel > targetRecords[targetName].level) then
                        PvPLogDebugMsg('Target updated: ' .. targetName);
                        targetRecords[targetName].level = targetLevel;
                    end
                end
            end
        elseif (targetIsControlled and targetIsEnemy) then
            PvPLogDebugMsg('Target is an enemy pet ');
            -- If we could figure out who owned this pet then we could
            -- credit them with the damage instead of the pet.
        elseif (not debug_pve and debug_ignore) then
            -- Its not a player or its not an enemy
            if (not ignoreRecords[targetName]) then
                PvPLogDebugMsg('Ignore added (targeted): ' .. targetName);
                PvPLogAddIgnore(targetName)
            end
            if (targetRecords[targetName]) then
                -- It got into targetRecords, remove it.
                PvPLogRemTarget(targetName);
            end
        end

        local total = PvPLogGetPvPTotals(targetName);
        local guildTotal = PvPLogGetGuildTotals(targetGuild);
        local msg = "";
        local show = false;
        if (total and (total.wins > 0 or total.loss > 0)) then
            msg = msg .. CYAN .. PVPLOG.UI_PVP .. ": " .. GREEN .. total.wins.. CYAN .. 
            " / " .. RED .. total.loss;
            show = true;
        end
        if (guildTotal and (guildTotal.wins > 0 or guildTotal.loss > 0)) then
            if (show) then
                msg = msg .. CYAN .. " - ";
            end
            msg = msg .. CYAN .. PVPLOG.GUILD .. ": ";
            msg = msg .. GREEN .. guildTotal.wins.. CYAN .. " / ".. RED .. 
            guildTotal.loss;
            show = true;
        end
        local field = getglobal("PvPLogTargetText");
        if (show and PvPLogData[realm][player].display) then
            field:SetText(msg);
            field:Show();
        end
    end
end

function PvPLogInitialize()   
    -- get realm and player
    realm = GetCVar("realmName");
    player = UnitName("player");
    plevel = UnitLevel("player");

    -- check for valid realm and player
    if (initialized or (not variablesLoaded) or (not realm) or 
        (not plevel) or (not player)) then
        return;
    end

    isDuel = false;

    -- Register command handler and new commands
    SlashCmdList["PvPLogCOMMAND"] = PvPLogSlashHandler;
    SLASH_PvPLogCOMMAND1 = "/pvplog";
    SLASH_PvPLogCOMMAND2 = "/pl";

    -- initialize character data structures
    
    PvPLogDebugMsg('Recents cleared (initialize).');
    recentDamaged = { };
    recentDamager = { };
    lastDamagerToMe = "";
    foundDamaged = false;
    foundDamager = false;

    if (targetList == nil) then
        targetList = { };
    end
    if (targetRecords == nil) then
        targetRecords = { };
    end

    if (PvPLogData == nil) then
        PvPLogData = { };
    end
    if (PvPLogData[realm] == nil) then
        PvPLogData[realm] = { };
    end
    if (PvPLogData[realm][player] == nil) then
        PvPLogInitPvP();
    end
    PvPLogData[realm][player].version = PVPLOG.VER_NUM;
    PvPLogData[realm][player].vendor = PVPLOG.VENDOR;

    if (PvPLogData[realm][player].notifyKillText == nil) then
        PvPLogData[realm][player].notifyKillText = PVPLOG.DEFAULT_KILL_TEXT;
    end

    if (PvPLogData[realm][player].notifyKill == nil) then
        PvPLogData[realm][player].notifyKill = PVPLOG.NONE;
    end

    if (PvPLogData[realm][player].notifyDeathText == nil) then
        PvPLogData[realm][player].notifyDeathText = PVPLOG.DEFAULT_DEATH_TEXT;
    end

    if (PvPLogData[realm][player].notifyDeath == nil) then
        PvPLogData[realm][player].notifyDeath = PVPLOG.NONE;
    end

    if (PvPLogData[realm][player].MiniMap == nil) then
        PvPLogData[realm][player].MiniMap = { };
    end;

    if (PvPLogData[realm][player].display == nil) then
        PvPLogData[realm][player].display = true;
    end

    if (PvPLogData[realm][player].ding == nil) then
        PvPLogData[realm][player].ding = false;
    end

    if (PvPLogData[realm][player].mouseover == nil) then
        PvPLogData[realm][player].mouseover = true;
    end

    if (PvPLogData[realm][player].recordBG == nil) then
        PvPLogData[realm][player].recordBG = true;
    end

    if (PvPLogData[realm][player].notifyBG == nil) then
        PvPLogData[realm][player].notifyBG = true;
    end

    if (PvPLogData[realm][player].recordDuel == nil) then
        PvPLogData[realm][player].recordDuel = true;
    end

    if (PvPLogData[realm][player].notifyDuel == nil) then
        PvPLogData[realm][player].notifyDuel = true;
    end

    -- output file
    if (PurgeLogData == nil) then
        PurgeLogData = { };
    end
    if (PurgeLogData[realm] == nil) then
        PurgeLogData[realm] = { };
    end
    if (PurgeLogData[realm][player] == nil) then
        PvPLogInitPurge();
    end
    PurgeLogData[realm][player].version = PVPLOG.VER_NUM;
    PurgeLogData[realm][player].vendor = PVPLOG.VENDOR;

    if (PvPLogDebug == nil) then
        PvPLogDebug = { };
        PvPLogDebugSave = { };
    end

    local stats = PvPLogGetStats();
    local allRecords = stats.totalWins + stats.totalLoss;

    initialized = true;

    -- Report load
    PvPLogChatMsg("PvPLog variables loaded: " .. allRecords .. " records (" .. 
        stats.totalWins .. "/" .. stats.totalLoss .. ") for " .. 
        player .. " | " .. realm);
end

function PvPLogInitPvP()
    PvPLogData[realm][player] = { };
    PvPLogData[realm][player].battles = { };
    PvPLogData[realm][player].version = PVPLOG.VER_NUM;
    PvPLogData[realm][player].vendor = PVPLOG.VENDOR;
    PvPLogData[realm][player].enabled = true;
    PvPLogData[realm][player].display = true;
    PvPLogData[realm][player].ding = false;
    PvPLogData[realm][player].mouseover = true;
    PvPLogData[realm][player].recordBG = true;
    PvPLogData[realm][player].notifyBG = true;
    PvPLogData[realm][player].recordDuel = true;
    PvPLogData[realm][player].notifyDuel = true;
    
    PvPLogData[realm][player].MiniMap = { };
    PvPLogData[realm][player].dispLocation = "overhead";
    PvPLogData[realm][player].dingSound = "AuctionWindowOpen";
    PvPLogData[realm][player].dingTimeout = 30.0;
    PvPLogData[realm][player].notifyKill = PVPLOG.NONE;
    PvPLogData[realm][player].notifyDeath = PVPLOG.NONE;
    PvPLogData[realm][player].guilds = { };
    PvPLogData[realm][player].notifyKillText = PVPLOG.DEFAULT_KILL_TEXT;
    PvPLogData[realm][player].notifyDeathText = PVPLOG.DEFAULT_DEATH_TEXT;
end

function PvPLogInitPurge()
    PurgeLogData[realm][player] = { };
    PurgeLogData[realm][player].battles = { };
    PurgeLogData[realm][player].version = PVPLOG.VER_NUM;
    PurgeLogData[realm][player].vendor = PVPLOG.VENDOR;
    PurgeLogData[realm][player].PurgeCounter = 5000;
end

function PvPLogGetFaction()
    local englishFaction;
    local localizedFaction;
    englishFaction, localizedFaction = UnitFactionGroup("player");
    return englishFaction;
end

function PvPLogGetFactionIcon()
    local faction = PvPLogGetFaction();
    local icon;
    if (faction == "Horde") then
        icon = "Interface\\Icons\\INV_BannerPvP_01";
    else
        icon = "Interface\\Icons\\INV_BannerPvP_02";
    end
    return icon;
end

function PvPLogGetPvPTotals(name)
    if (not name) then
        return nil;
    end

    if (not PvPLogData[realm][player].battles[name]) then
        return nil;
    end

    local total = { };
    total.wins = 0 + PvPLogData[realm][player].battles[name].wins;
    total.loss = 0 + PvPLogData[realm][player].battles[name].loss;
    total.winsStr = "";
    total.lossStr = "";
    total.slashy  = true;

    if (total.wins == 1) then
        total.winsStr = "1 " .. PVPLOG.WIN;
    elseif (total.wins > 1) then
        total.winsStr = total.wins .. " " .. PVPLOG.WINS;
    else
        total.slashy = false;
    end

    if (total.loss == 1) then
        total.lossStr = "1 " .. PVPLOG.LOSS;
    elseif (total.loss > 1) then
        total.lossStr = total.loss .. " " .. PVPLOG.LOSSES;
    end

    if (total.slashy and total.loss > 0) then
        total.slashy = " / ";
    else
        total.slashy = "";
    end

    return total;
end

function PvPLogGetGuildTotals(guild)
    if (not initialized) then
        PvPLogInitialize();
    end

    local total = { };
    local gfound = false;
    if (PvPLogData[realm][player].guilds and
        table.getn(PvPLogData[realm][player].guilds) > 0) then
        table.foreach(PvPLogData[realm][player].guilds,
            function(guildname,tname)
                if(guildname == guild) then
                    total.wins = tname.wins;
                    total.loss = tname.loss;
                    gfound = true;
                    return true;
                end
            end
        );
    end
    if (not gfound) then
        total.wins = 0;
        total.loss = 0;
    end

    total.winsStr = "";
    total.lossStr = "";
    total.slashy  = true;

    if (total.wins == 1) then
        total.winsStr = "1 " .. PVPLOG.WIN;
    elseif (total.wins > 1) then
        total.winsStr = total.wins .. " " .. PVPLOG.WINS;
    else
        total.slashy = false;
    end

    if (total.loss == 1) then
        total.lossStr = "1 ".. PVPLOG.LOSS;
    elseif (total.loss > 1) then
        total.lossStr = total.loss .. " " .. PVPLOG.LOSSES;
    end

    if (total.slashy and total.loss > 0) then
        total.slashy = " / ";
    else
        total.slashy = "";
    end

    return total;
end

function PvPLogGetStats()
    local stats = { };
    stats.totalWins = 0;
    stats.totalWinAvgLevelDiff = 0;
    stats.totalLoss = 0;
    stats.totalLossAvgLevelDiff = 0;
    stats.pvpWins = 0;
    stats.pvpWinAvgLevelDiff = 0;
    stats.pvpLoss = 0;
    stats.pvpLossAvgLevelDiff = 0;
    stats.duelWins = 0;
    stats.duelWinAvgLevelDiff = 0;
    stats.duelLoss = 0;
    stats.duelLossAvgLevelDiff = 0;

    table.foreach(PurgeLogData[realm][player].battles,
        function(target,v1)
            if (not v1.lvlDiff) then
                v1.lvlDiff = 0;
            end
            if (v1.enemy == 1) then
                if (v1.win == 1) then
                    stats.pvpWinAvgLevelDiff = 
                        stats.pvpWinAvgLevelDiff + v1.lvlDiff;
                    stats.pvpWins = stats.pvpWins + 1;
                    stats.totalWins = stats.totalWins + 1;
                    stats.totalWinAvgLevelDiff = 
                        stats.totalWinAvgLevelDiff + v1.lvlDiff;
                else
                    stats.pvpLossAvgLevelDiff = 
                        stats.pvpLossAvgLevelDiff + v1.lvlDiff;
                    stats.pvpLoss = stats.pvpLoss + 1;
                    stats.totalLoss = stats.totalLoss + 1;
                    stats.totalLossAvgLevelDiff = 
                        stats.totalLossAvgLevelDiff + v1.lvlDiff;
                end
            else
                if (v1.win == 1) then
                    stats.duelWinAvgLevelDiff = 
                        stats.duelWinAvgLevelDiff + v1.lvlDiff;
                    stats.duelWins = stats.duelWins + 1;
                    stats.totalWins = stats.totalWins + 1;
                    stats.totalWinAvgLevelDiff = 
                        stats.totalWinAvgLevelDiff + v1.lvlDiff;
                else
                    stats.duelLossAvgLevelDiff = 
                        stats.duelLossAvgLevelDiff + v1.lvlDiff;
                    stats.duelLoss = stats.duelLoss + 1;
                    stats.totalLoss = stats.totalLoss + 1;
                    stats.totalLossAvgLevelDiff = 
                        stats.totalLossAvgLevelDiff + v1.lvlDiff;
                end
            end
        end
    );

    if (stats.totalWins > 0) then
        stats.totalWinAvgLevelDiff = stats.totalWinAvgLevelDiff / stats.totalWins;
    end
    if (stats.totalLoss > 0) then
        stats.totalLossAvgLevelDiff = stats.totalLossAvgLevelDiff / stats.totalLoss;
    end
    if (stats.pvpWins > 0) then
        stats.pvpWinAvgLevelDiff = stats.pvpWinAvgLevelDiff / stats.pvpWins;
    end
    if (stats.pvpLoss > 0) then
        stats.pvpLossAvgLevelDiff = stats.pvpLossAvgLevelDiff / stats.pvpLoss;
    end
    if (stats.duelWins > 0) then
        stats.duelWinAvgLevelDiff = stats.duelWinAvgLevelDiff / stats.duelWins;
    end
    if (stats.duelLoss > 0) then
        stats.duelLossAvgLevelDiff = stats.duelLossAvgLevelDiff / stats.duelLoss;
    end

    return stats;
end

function PvPLogInBG()
    bg_found = false;
    for i=1, MAX_BATTLEFIELD_QUEUES do
        bg_status, bg_mapName, bg_instanceId = GetBattlefieldStatus(i);
        if (bg_status == "active" ) then
            bg_found = true;
            return true;
        end
    end
    return false;
end

function PvPLogRecord(vname, vlevel, vrace, vclass, vguild, venemy, win, vrank, vrealm)
    local ZoneName = GetZoneText();
    local SubZone = GetSubZoneText();
    -- Check Battlefield status
    PvPLogInBG();

    -- Check for conditions under which we do not record data
--    PvPLogDebugMsg('bg_found = '..tostring(bg_found)..', recordBG = '..tostring(PvPLogData[realm][player].recordBG));
--    PvPLogDebugMsg('venemy = '..tostring(venemy)..', recordDuel = '..tostring(PvPLogData[realm][player].recordDuel));
    if ((bg_found and not PvPLogData[realm][player].recordBG) or
      (venemy == 0 and not PvPLogData[realm][player].recordDuel)) then
        PvPLogDebugMsg('Do not record conditions met');
        return;
    end

    -- deal with vlevel being negative 1 when 
    -- they are dlevel levels or more greater
    local level = 0;
    local leveltext = "";
    if (vlevel == -1) then
        level = plevel + dlevel; 
        leveltext = "+";
        if (level >= mlevel) then
            level = mlevel;
            leveltext = "";
        end
    elseif (vlevel) then
        level = vlevel; 
    end
    leveltext = tostring(level)..leveltext;

    -- check to see if we've encountered this person before
    if(not PvPLogData[realm][player].battles[vname]) then
        PvPLogData[realm][player].battles[vname] = { };
        PvPLogData[realm][player].battles[vname].wins = 0;
        PvPLogData[realm][player].battles[vname].loss = 0;
        PvPLogData[realm][player].battles[vname].class = vclass;
        PvPLogData[realm][player].battles[vname].race = vrace;
        PvPLogData[realm][player].battles[vname].enemy = venemy;
        PvPLogData[realm][player].battles[vname].realm = vrealm;
    end
    -- update zone and guild as they could change with every new encounter.
    PvPLogData[realm][player].battles[vname].zone = ZoneName;
    PvPLogData[realm][player].battles[vname].guild = vguild;

    if (not vguild) then
        vguild = "";
    end

    if (PvPLogData[realm][player].guilds == nil) then
        PvPLogData[realm][player].guilds = { };
    end

    if(table.getn(PvPLogData[realm][player].guilds) == 0 or
      not PvPLogData[realm][player].guilds[vguild]) then
        PvPLogData[realm][player].guilds[vguild] = { };
        PvPLogData[realm][player].guilds[vguild].wins = 0;
        PvPLogData[realm][player].guilds[vguild].loss = 0;
    end

    -- prepare data for printing out
    if (PurgeLogData[realm][player].PurgeCounter == nil) then
        PurgeLogData[realm][player].PurgeCounter = 5000;
    end

    local PurgeCounter = PurgeLogData[realm][player].PurgeCounter;
    if (PurgeLogData[realm][player].battles[PurgeCounter] == nil) then
        PurgeLogData[realm][player].battles[PurgeCounter] = { };
        PurgeLogData[realm][player].battles[PurgeCounter].name = vname;
        PurgeLogData[realm][player].battles[PurgeCounter].race = vrace;
        PurgeLogData[realm][player].battles[PurgeCounter].class = vclass;
        PurgeLogData[realm][player].battles[PurgeCounter].enemy = venemy;
        PurgeLogData[realm][player].battles[PurgeCounter].realm = vrealm;
    end 
    PurgeLogData[realm][player].battles[PurgeCounter].guild = vguild;
    PurgeLogData[realm][player].battles[PurgeCounter].win = win;
    PurgeLogData[realm][player].battles[PurgeCounter].lvlDiff = level - UnitLevel("player");
    PurgeLogData[realm][player].battles[PurgeCounter].zone = ZoneName;
    PurgeLogData[realm][player].battles[PurgeCounter].subzone = SubZone;
    PurgeLogData[realm][player].battles[PurgeCounter].rank = vrank;
    PurgeLogData[realm][player].battles[PurgeCounter].honor = 0; -- obsolete
    if (bg_found) then
        PurgeLogData[realm][player].battles[PurgeCounter].bg = 1;
    else
        PurgeLogData[realm][player].battles[PurgeCounter].bg = 0;
    end
    PurgeLogData[realm][player].battles[PurgeCounter].date = date();
    PurgeLogData[realm][player].battles[PurgeCounter].time = time();
    PurgeCounter = PurgeCounter + 1;
    PurgeLogData[realm][player].PurgeCounter = PurgeCounter;

    local x, y = GetPlayerMapPosition("player");
    if ((x == 0) and (y == 0)) then
        SetMapToCurrentZone();
        x, y = GetPlayerMapPosition("player");
    end    
    x = math.floor(x*100);
    y = math.floor(y*100);

    local notifyMsg = "";
    local notifySystem = nil;
    if (win == 1) then
        PvPLogData[realm][player].battles[vname].wins = 
            PvPLogData[realm][player].battles[vname].wins + 1; 
        PvPLogData[realm][player].guilds[vguild].wins = 
            PvPLogData[realm][player].guilds[vguild].wins + 1;

        notifyMsg = PvPLogData[realm][player].notifyKillText;
        notifySystem = PvPLogData[realm][player].notifyKill;
    else
        PvPLogData[realm][player].battles[vname].loss = 
            PvPLogData[realm][player].battles[vname].loss + 1;
        PvPLogData[realm][player].guilds[vguild].loss = 
            PvPLogData[realm][player].guilds[vguild].loss + 1;

        notifyMsg = PvPLogData[realm][player].notifyDeathText;
        notifySystem = PvPLogData[realm][player].notifyDeath;
    end

    -- Check for conditions under which we do not notify
--    PvPLogDebugMsg('bg_found = '..tostring(bg_found)..', notifyBG = '..tostring(PvPLogData[realm][player].notifyBG));
--    PvPLogDebugMsg('venemy = '..tostring(venemy)..', notifyDuel = '..tostring(PvPLogData[realm][player].notifyDuel));
    if ((bg_found and not PvPLogData[realm][player].notifyBG) or
      (venemy == 0 and not PvPLogData[realm][player].notifyDuel)) then
        PvPLogDebugMsg('Do not notify conditions met');
        return;
    end

    notifyMsg = string.gsub( notifyMsg, "%%n", vname );
    if( leveltext ) then
        notifyMsg = string.gsub( notifyMsg, "%%l", leveltext );
    else
        notifyMsg = string.gsub( notifyMsg, "%%l", "" );
    end
    if( vclass ) then
        notifyMsg = string.gsub( notifyMsg, "%%c", vclass );
    else
        notifyMsg = string.gsub( notifyMsg, "%%c", "" );
    end
    if( vrace ) then
        notifyMsg = string.gsub( notifyMsg, "%%r", vrace );
    else
        notifyMsg = string.gsub( notifyMsg, "%%r", "" );
    end
    if( vguild ) then
        notifyMsg = string.gsub( notifyMsg, "%%g", vguild );
    else
        notifyMsg = string.gsub( notifyMsg, "%%g", "" );
    end
    if( vrank ) then
        notifyMsg = string.gsub( notifyMsg, "%%t", vrank );
    else
        notifyMsg = string.gsub( notifyMsg, "%%t", "" );
    end
    notifyMsg = string.gsub( notifyMsg, "%%x", x );
    notifyMsg = string.gsub( notifyMsg, "%%y", y );
    notifyMsg = string.gsub( notifyMsg, "%%z", ZoneName );
    notifyMsg = string.gsub( notifyMsg, "%%w", SubZone );
    notifyMsg = string.gsub( notifyMsg, " %(%)", "" );
    notifyMsg = string.gsub( notifyMsg, " %<%>", "" );

    PvPLogDebugAdd(notifyMsg);
    if (notifySystem) then
        for notifyChan in string.gmatch(notifySystem, "%w+") do
            if( venemy and notifyChan == PVPLOG.SELF) then
                PvPLogChatMsg(notifyMsg);
            elseif( venemy and
              ((notifyChan == PVPLOG.PARTY and GetNumPartyMembers() > 0) or 
              (notifyChan == PVPLOG.GUILD and GetGuildInfo("player") )  or 
              (notifyChan == PVPLOG.SAY )  or 
              (notifyChan == PVPLOG.RAID  and GetNumRaidMembers() > 0)) ) then
                if (notifyChan == PVPLOG.RAID and bg_found) then
                    notifyChan = PVPLOG.BG;
                end
                PvPLogSendChatMessage(notifyMsg, notifyChan);
            elseif( venemy and notifyChan ~= PVPLOG.NONE and notifyChan ~= PVPLOG.SELF and
              notifyChan ~= PVPLOG.PARTY and notifyChan ~= PVPLOG.GUILD and 
              notifyChan ~= PVPLOG.SAY and notifyChan ~= PVPLOG.RAID and notifyChan ~= PVPLOG.BG) then
                PvPLogSendMessageOnChannel(notifyMsg, notifyChan);
            end
        end
    end
end

function PvPLogKeepPurge(value)
    if (tonumber(value)) then
        -- PvPLogDebugMsg('value = '..tostring(value)..', PurgeCounter = '..tostring(PurgeLogData[realm][player].PurgeCounter));
        local keep = PurgeLogData[realm][player].PurgeCounter - tonumber(value);
        -- PvPLogDebugMsg('keep = '..tostring(keep));
        if (keep > 5000) then
            table.foreach(PurgeLogData[realm][player].battles, function( counter, v2 )
                if (counter < keep) then
                    -- PvPLogDebugMsg('counter = '..tostring(counter));
                    PurgeLogData[realm][player].battles[counter] = nil;
                end               
            end);
        end
    end
end

function PvPLogSetEnabled(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].enabled = false;
        PvPLogChatMsgCyan("PvPLog " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].enabled = true;
        PvPLogChatMsgCyan("PvPLog " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSetDisplay(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].display = false;
        PvPLogChatMsgCyan("PvPLog Floating Display " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].display = true;
        PvPLogChatMsgCyan("PvPLog Floating Display " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSetDing(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].ding = false;
        PvPLogChatMsgCyan("PvPLog Ding Sound " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].ding = true;
        PvPLogChatMsgCyan("PvPLog Ding Sound " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSetMouseover(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].mouseover = false;
        PvPLogChatMsgCyan("PvPLog Mouseover Effects " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].mouseover = true;
        PvPLogChatMsgCyan("PvPLog Mouseover Effects " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSetRecordBG(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].recordBG = false;
        PvPLogChatMsgCyan("PvPLog Record in Battlegrounds " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].recordBG = true;
        PvPLogChatMsgCyan("PvPLog Record in Battlegrounds " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSetNotifyBG(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].notifyBG = false;
        PvPLogChatMsgCyan("PvPLog Notify in Battlegrounds " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].notifyBG = true;
        PvPLogChatMsgCyan("PvPLog Notify in Battlegrounds " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSetRecordDuel(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].recordDuel = false;
        PvPLogChatMsgCyan("PvPLog Record Duels " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].recordDuel = true;
        PvPLogChatMsgCyan("PvPLog Record Duels " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSetNotifyDuel(toggle)
    toggle = string.lower(toggle);
    if (toggle == "off") then
        PvPLogData[realm][player].notifyDuel = false;
        PvPLogChatMsgCyan("PvPLog Notify Duels " .. ORANGE .. PVPLOG.OFF);
    else
        PvPLogData[realm][player].notifyDuel = true;
        PvPLogChatMsgCyan("PvPLog Notify Duels " .. ORANGE .. PVPLOG.ON);
    end        
end

function PvPLogSlashHandler(msg)
    -- initialize if we're not for some reason
    if (not initialized) then
      PvPLogInitialize();
    end

    local firsti, lasti, command, value = string.find (msg, "(%w+) \"(.*)\"");
    if (command == nil) then
        firsti, lasti, command, value = string.find (msg, "(%w+) (%w+)");
    end
    if (command == nil) then
        firsti, lasti, command = string.find(msg, "(%w+)");
    end    
    if (command ~= nil) then
        command = string.lower(command);
    end

    -- respond to commands
    if (command == nil) then
        PvPLogDisplayUsage();
    elseif (command == "debug") then
        if (value == "on") then
            debug_flag = true;
        elseif (value == "off") then
            debug_flag = false;
        elseif (value == "save") then
            PvPLogDebugSave = { };
            for i,v in ipairs(PvPLogDebug) do
                table.insert(PvPLogDebugSave,v);
            end
        elseif (value == "clear") then
            PvPLogDebug = { };
        else
            PvPLogDebugMsg("debug_flag = "..tostring(debug_flag));
        end
    elseif (command == "comm") then
        if (value == "on") then
            debug_comm = true;
        elseif (value == "off") then
            debug_comm = false;
        else
            PvPLogDebugMsg("debug_comm = "..tostring(debug_comm));
        end
    elseif (command == "notify") then
        PvPLogSendMessageOnChannel("PvPLog test", value);
    elseif (command == "ignore") then
        if (value == "on") then
            debug_ignore = true;
        elseif (value == "off") then
            debug_ignore = false;
            ignoreList = { };
            ignoreRecords = { };
        elseif (value == "clear") then
            ignoreList = { };
            ignoreRecords = { };
        else
            PvPLogDebugMsg("debug_ignore = "..tostring(debug_ignore));
        end
    elseif (command == "target") then
        if (value == "clear") then
            targetList = { };
            targetRecords = { };
        end
    elseif (command == "event1") then
        if (value == "on") then
            debug_event1 = true;
        elseif (value == "off") then
            debug_event1 = false;
        else
            PvPLogDebugMsg("debug_event1 = "..tostring(debug_event1));
        end
    elseif (command == "event2") then
        if (value == "on") then
            debug_event2 = true;
        elseif (value == "off") then
            debug_event2 = false;
        else
            PvPLogDebugMsg("debug_event2 = "..tostring(debug_event2));
        end
    elseif (command == "combat") then
        if (value == "on") then
            debug_combat = true;
        elseif (value == "off") then
            debug_combat = false;
        else
            PvPLogDebugMsg("debug_combat = "..tostring(debug_combat));
        end
    elseif (command == "pve") then
        if (value == "on") then
            debug_pve = true;
            debug_ignore = false;
            ignoreList = { };
            ignoreRecords = { };
        elseif (value == "off") then
            debug_pve = false;
        else
            PvPLogDebugMsg("debug_pve = "..tostring(debug_pve));
            PvPLogDebugMsg("debug_ignore = "..tostring(debug_ignore));
        end
    elseif (command == "ui") then
        if (value == "on") then
            debug_ui = true;
        elseif (value == "off") then
            debug_ui = false;
        else
            PvPLogDebugMsg("debug_ui = "..tostring(debug_ui));
        end
    elseif (command == "ttm") then
        if (value == "on") then
            debug_ttm = true;
        elseif (value == "off") then
            debug_ttm = false;
        else
            PvPLogDebugMsg("debug_ttm = "..tostring(debug_ttm));
        end
    elseif (command == "ptc") then
        if (value == "on") then
            debug_ptc = true;
        elseif (value == "off") then
            debug_ptc = false;
        else
            PvPLogDebugMsg("debug_ptc = "..tostring(debug_ptc));
        end
    elseif (command == "vars") then
        if (softPL) then
            PvPLogDebugMsg("softPL = TRUE");
        else
            PvPLogDebugMsg("softPL = FALSE");
        end
        PvPLogDebugMsg("targetList = {"..table.concat(targetList,", ").."}");
        s = "";
        for i in pairs(targetRecords) do
            s = s..", "..i;
        end
        s = string.sub(s,3);
        PvPLogDebugMsg("targetRecords = {"..s.."}");
        PvPLogDebugMsg("ignoreList = {"..table.concat(ignoreList,", ").."}");
        s = "";
        for i in pairs(ignoreRecords) do
            s = s..", "..i;
        end
        s = string.sub(s,3);
        PvPLogDebugMsg("ignoreRecords = {"..s.."}");
        PvPLogDebugMsg("recentDamager = {"..table.concat(recentDamager,", ").."}");
        PvPLogDebugMsg("recentDamaged = {"..table.concat(recentDamaged,", ").."}");
        if (isDuel) then
            PvPLogDebugMsg("isDuel = TRUE");
        else
            PvPLogDebugMsg("isDuel = FALSE");
        end
    elseif (command == PVPLOG.KEEP) then
            PvPLogKeepPurge(value);
    elseif (command == PVPLOG.RESET) then
        if (value == PVPLOG.CONFIRM) then
            PvPLogInitPvP();
            PvPLogInitPurge();
            PvPLogChatMsgCyan("PvPLog " .. MAGENTA .. PVPLOG.RESET .. " " .. CYAN .. PVPLOG.COMP);
        end
    elseif (command == PVPLOG.NOTIFYKILL) then
        if (value ~= nil) then
            PvPLogData[realm][player].notifyKill = value;
            PvPLogFloatMsg(CYAN .. "PvPLog: " .. WHITE .. PVPLOG.NOTIFYKILL .. 
                CYAN .. PVPLOG.TO .. FIRE .. value);
        else
            PvPLogDisplayUsage();
        end
    elseif (command == PVPLOG.NOTIFYKILLTEXT) then
        if (value ~= nil) then
            PvPLogData[realm][player].notifyKillText = value;
            PvPLogFloatMsg(CYAN .. "PvPLog: " .. WHITE .. PVPLOG.NOTIFYKILLTEXT .. 
                CYAN .. PVPLOG.TO .. FIRE .. value);
        else
            PvPLogDisplayUsage();
        end
    elseif (command == PVPLOG.NOTIFYDEATH) then
        if (value ~= nil) then
            PvPLogData[realm][player].notifyDeath = value;
            PvPLogFloatMsg(CYAN .. "PvPLog: " .. WHITE .. PVPLOG.NOTIFYDEATH .. 
                CYAN .. PVPLOG.TO .. FIRE .. value);
        else
            PvPLogDisplayUsage();
        end
    elseif (command == PVPLOG.NOTIFYDEATHTEXT) then
        if (value ~= nil) then
            PvPLogData[realm][player].notifyDeathText = value;
            PvPLogFloatMsg(CYAN .. "PvPLog: " .. WHITE .. PVPLOG.NOTIFYDEATHTEXT .. 
                CYAN .. PVPLOG.TO .. FIRE .. value);
        else
            PvPLogDisplayUsage();
        end
    elseif (command == PVPLOG.ENABLE) then
        PvPLogSetEnabled("on");
    elseif (command == PVPLOG.DISABLE) then
        PvPLogSetEnabled("off");
    elseif (command == PVPLOG.VER) then
        PvPLogChatMsgCyan("PvPLog "..VER..": " .. WHITE .. PVPLOG.VER_NUM);
    elseif (command == PVPLOG.VEN) then
        PvPLogChatMsgCyan("PvPLog "..VEN..": " .. WHITE .. PVPLOG.VENDOR);
    elseif (command == PVPLOG.ST) then
        PvPLogPrintStats();
    elseif (command == PVPLOG.NOSPAM) then
        PvPLogSetDisplay("off");
        PvPLogSetDing("off");
        PvPLogSetMouseover("off");
    elseif (command == string.lower(PVPLOG.UI_PVP)) then
        PvPLogStatsFrame:Hide();
        PVPLOG.STATS_TYPE = PVPLOG.UI_PVP;
        PvPLogStatsFrame:Show();
    elseif (command == string.lower(PVPLOG.DUEL)) then
        PvPLogStatsFrame:Hide();
        PVPLOG.STATS_TYPE = PVPLOG.DUEL;
        PvPLogStatsFrame:Show();
    elseif (command == string.lower(PVPLOG.RECENT)) then
        PvPLogStatsFrame:Hide();
        PVPLOG.STATS_TYPE = PVPLOG.RECENT;
        PvPLogStatsFrame:Show();
    elseif (command == PVPLOG.UI_CONFIG) then
        PvPLogConfigShow();
    else
        PvPLogDisplayUsage();
    end
end

function PvPLogDisplayUsage()
    local text;

    text = CYAN .. PVPLOG.USAGE .. ":\n  /pl <";
    if (PvPLogData[realm][player].enabled) then
        text = text .. WHITE .. PVPLOG.ENABLE .. CYAN .. " | " .. PVPLOG.DISABLE .. ">";
    else
        text = text .. PVPLOG.ENABLE.." | " .. WHITE .. PVPLOG.DISABLE .. CYAN .. ">";
    end
    PvPLogChatMsg(text);

    PvPLogChatMsgPl(PVPLOG.RESET .. " " .. PVPLOG.CONFIRM);
    PvPLogChatMsgPl(PVPLOG.ST);
    PvPLogChatMsgPl(PVPLOG.DMG);

    text = PVPLOG.NOTIFYKILL.." <";
    if (PvPLogData[realm][player].notifyKill == PVPLOG.NONE) then
        text = text .. WHITE .. PVPLOG.NONE .. CYAN;
    else
        text = text .. PVPLOG.NONE;
    end
    text = text .." | ";
    if (PvPLogData[realm][player].notifyKill == PVPLOG.SELF) then
        text = text .. WHITE .. PVPLOG.SELF .. CYAN;
    else
        text = text .. PVPLOG.SELF;
    end
    text = text .." | ";
    if (PvPLogData[realm][player].notifyKill == PVPLOG.PARTY) then
        text = text .. WHITE .. PVPLOG.PARTY .. CYAN;
    else
        text = text .. PVPLOG.PARTY;
    end
    text = text .." | ";
    if (PvPLogData[realm][player].notifyKill == PVPLOG.GUILD) then
        text = text .. WHITE .. PVPLOG.GUILD .. CYAN;
    else
        text = text .. PVPLOG.GUILD;
    end
    
    if (PvPLogData[realm][player].notifyKill == PVPLOG.SAY) then
        text = text .. WHITE .. PVPLOG.SAY .. CYAN;
    else
        text = text .. PVPLOG.SAY;
    end
    
    text = text .." | ";
    if (PvPLogData[realm][player].notifyKill == PVPLOG.RAID) then
        text = text .. WHITE .. PVPLOG.RAID .. CYAN;
    else
        text = text .. PVPLOG.RAID;
    end
    if (PvPLogData[realm][player].notifyKill ~= PVPLOG.NONE and
        PvPLogData[realm][player].notifyKill ~= PVPLOG.SELF and
        PvPLogData[realm][player].notifyKill ~= PVPLOG.PARTY and
        PvPLogData[realm][player].notifyKill ~= PVPLOG.GUILD and
        PvPLogData[realm][player].notifyKill ~= PVPLOG.RAID) then
        text = text .." | " .. WHITE .. PvPLogData[realm][player].notifyKill .. CYAN .. ">";
    else
        text = text .. ">";
    end
    PvPLogChatMsgPl(text);

    text = PVPLOG.NOTIFYKILLTEXT.." <";
    text = text .. WHITE .. PvPLogData[realm][player].notifyKillText .. CYAN .. ">";
    PvPLogChatMsgPl(text);

    text = PVPLOG.NOTIFYDEATH.." <";
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.NONE) then
        text = text .. WHITE .. PVPLOG.NONE .. CYAN;
    else
        text = text .. PVPLOG.NONE;
    end
    text = text .." | ";
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.SELF) then
        text = text .. WHITE .. PVPLOG.SELF .. CYAN;
    else
        text = text .. PVPLOG.SELF;
    end
    text = text .." | ";
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.PARTY) then
        text = text .. WHITE .. PVPLOG.PARTY .. CYAN;
    else
        text = text .. PVPLOG.PARTY;
    end
    text = text .." | ";
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.GUILD) then
        text = text .. WHITE .. PVPLOG.GUILD .. CYAN;
    else
        text = text .. PVPLOG.GUILD;
    end
    text = text .." | ";
    if (PvPLogData[realm][player].notifyDeath == PVPLOG.RAID) then
        text = text .. WHITE .. PVPLOG.RAID .. CYAN;
    else
        text = text .. PVPLOG.RAID;
    end
    if (PvPLogData[realm][player].notifyDeath ~= PVPLOG.NONE and
        PvPLogData[realm][player].notifyDeath ~= PVPLOG.SELF and
        PvPLogData[realm][player].notifyDeath ~= PVPLOG.PARTY and
        PvPLogData[realm][player].notifyDeath ~= PVPLOG.GUILD and
        PvPLogData[realm][player].notifyDeath ~= PVPLOG.RAID) then
        text = text .. " | " .. WHITE .. PvPLogData[realm][player].notifyDeath .. CYAN .. ">";
    else
        text = text .. ">";
    end
    PvPLogChatMsgPl(text);

    text = PVPLOG.NOTIFYDEATHTEXT.." <";
    text = text .. WHITE .. PvPLogData[realm][player].notifyDeathText .. CYAN .. ">";
    PvPLogChatMsgPl(text);

    PvPLogChatMsgPl(PVPLOG.NOSPAM);
    PvPLogChatMsgPl(PVPLOG.VER);
    PvPLogChatMsgPl(PVPLOG.VEN);

    PvPLogChatMsgPl(string.lower(PVPLOG.UI_PVP));
    PvPLogChatMsgPl(string.lower(PVPLOG.DUEL));
    PvPLogChatMsgPl(PVPLOG.UI_CONFIG);
    PvPLogChatMsgPl(PVPLOG.KEEP);
end

function PvPLogChatMsgPl(msg)
    PvPLogChatMsgCyan("  /pl " .. msg);
end

function PvPLogChatMsgCyan(msg)
    PvPLogChatMsg(CYAN .. msg);
end

--
--  Functions which send notify messages to a specified channel.
--    Debugging messages are under the control of the 
--    "/pvplog comm on" and "/pvplog comm off" commands.
--
function PvPLogSendChatMessage(message, channel)
    if (chan == PVPLOG.PARTY) then chan = "PARTY"; end
    if (chan == PVPLOG.GUILD) then chan = "GUILD"; end
    if (chan == PVPLOG.RAID) then chan = "RAID"; end
    if (chan == PVPLOG.SAY) then chan = "SAY"; end
    if (chan == PVPLOG.BG) then chan = "BATTLEGROUND"; end
    PvPLogDebugComm('PvPLogSendChatMessage("' .. message .. '", "' .. channel .. '")');
    SendChatMessage(message, channel);
end

function PvPLogSendMessageOnChannel(message, channel)
    local number = 0;
    number = PvPLogGetChannelNumber(channel);
    PvPLogDebugComm('PvPLogSendMessageOnChannel("' .. message .. '", "' .. channel .. '", ' .. number ..')');
    if (not number or number == 0) then
        PvPLogJoinChannel(channel);
        queuedMessage = message;
        queuedChannel = channel;
        notifyQueued = true;
    else
        SendChatMessage(message, "CHANNEL", nil, tostring(number));
    end
end

function PvPLogGetChannelNumber(channel)
    PvPLogDebugComm('PvPLogGetChannelNumber("' .. channel .. '")');
    local number = 0;
    if (string.len(channel) == 1 and channel >= "1" and channel <= "9") then
        number = channel;
    else
        number = GetChannelName(channel);
    end
    PvPLogDebugComm('channelNum: ' .. tostring(number));
    return number;
end

function PvPLogJoinChannel(channel)
    PvPLogDebugComm('PvPLogJoinChannel("' .. channel .. '")');
    local number = 0;
    JoinChannelByName(channel, nil, DEFAULT_CHAT_FRAME:GetID());
    ChatFrame_AddChannel(DEFAULT_CHAT_FRAME, channel);
    number = GetChannelName(channel);
    PvPLogDebugComm('channelNum: ' .. tostring(number));
    return number;
end
