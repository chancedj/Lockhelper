--[[
    This file handles emissary tracking
--]]
local addonName, _ = ...;

-- libraries
local addon = LibStub( "AceAddon-3.0" ):GetAddon( addonName );
local L     = LibStub( "AceLocale-3.0" ):GetLocale( addonName, false );

-- Upvalues
local next = -- variables
      next   -- lua functions

-- cache blizzard function/globals
local UnitClass, GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID, GetSpellCooldown
        , GetQuestObjectiveInfo, GetServerTime, GetTime, GetTalentTreeIDsByClassID, GetTalentTreeInfoForID, GetLFGDungeonRewards  =                       -- variables 
      UnitClass, GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID, GetSpellCooldown
        , GetQuestObjectiveInfo, GetServerTime, GetTime, C_Garrison.GetTalentTreeIDsByClassID, C_Garrison.GetTalentTreeInfoForID, GetLFGDungeonRewards    -- blizzard api

local BOSS_KILL_TEXT = "|T" .. READY_CHECK_READY_TEXTURE .. ":0|t";

local EVENTS_TO_TRACK = {
    -- brewfest
    [372] = {},
    -- feast of winter veil
    [141] = {},
    -- hallows end
    [324] = {},
    -- love is in the air
    [335] = {},
    -- midsummer fire festival
    [341] = {},
    -- noblegarden
    [181] = {},
    -- pilgrims bounty
    [404] = {},

    -- recurring (monthly) events
    -- darkmoon faire
    [479] = {},
}

function addon:Lockedout_GetCommingEvents()
    local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
    C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);

    local currentTime = GetServerTime();
    local endTime = currentTime + (2 * 7 * 24 * 60 * 60);
    local events = {};

    for offset = 0, 1 do    
        local monthInfo = C_Calendar.GetMonthInfo( 0 );

        for day = 1, monthInfo.numDays do
            local eventCount = C_Calendar.GetNumDayEvents( 0, day );
            for eventNum = 1, eventCount do
                local eventInfo = C_Calendar.GetDayEvent( 0, day, eventNum);
                local etTbl = eventInfo.endTime;
                local eventStartTime = time( { year=etTbl.year, month=etTbl.month, day=etTbl.monthDay } );

                if( EVENTS_TO_TRACK[ eventInfo.eventID ] ) and ( events[ eventInfo.eventID ] == nil ) and ( eventStartTime >= currentTime) and ( eventStartTime <= endTime ) then
                    events[ eventInfo.eventID ] = {
                        startTime = eventInfo.startTime,
                        endTime   = eventInfo.endTime,
                        title     = eventInfo.title
                    };
                    print( "[", currentCalendarTime.month + offset, "/", day, " | ", eventInfo.eventID, " == ", eventInfo.title );
                end
            end
        end
        C_Calendar.SetMonth( 1 );
    end

    C_Calendar.SetAbsMonth(currentCalendarTime.month, currentCalendarTime.year);
    return events;
end

local function getCurrentEvents()
    return { {} };
end

function addon:Lockedout_BuildHolidayEventQuests( )
    local holidayEvents = {}; -- initialize weekly quest table;

    self:Lockedout_GetCommingEvents();

    for _, currentEventID in next, getCurrentEvents() do
        local eventQuestIDs = EVENTS_TO_TRACK[ currentEventID];
        if( eventQuestIDs ) then
            for _, questID in next, eventQuestIDs do
            end
        end
    end

    --[[
    local calculatedResetDate = addon:getWeeklyLockoutDate();
    for abbr, questData in next, QUEST_LIBRARY do
        local resetDate, completed, displayText = questData:checkStatus();

        local indivQuestData = nil;
        if( completed ) then
            indivQuestData = {};
            indivQuestData.name = questData.name;
            indivQuestData.displayText = displayText;
            indivQuestData.resetDate = resetDate;
        end

        weeklyQuests[ abbr ] = indivQuestData;
        if( questData.copyAccountWide ) then
            -- blingtron is account bound, so we copy across the accounts
            for realmName, characters in next, LockoutDb do
                for charNdx, charData in next, characters do
                    charData.weeklyQuests = charData.weeklyQuests or {};
                    charData.weeklyQuests[ abbr ] = indivQuestData;
                end
            end
        end
    end -- for bossId, bossData in next, WORLD_BOSS_LIST
    --]]

    addon.playerDb.holidayEvents = holidayEvents;
end -- Lockedout_BuildInstanceLockout()
