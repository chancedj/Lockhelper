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
local UnitClass, GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID, GetSpellCooldown, UnitFactionGroup
        , GetQuestObjectiveInfo, GetServerTime, GetTime, GetTalentTreeIDsByClassID, GetTalentTreeInfoForID, GetLFGDungeonRewards  =                       -- variables 
      UnitClass, GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID, GetSpellCooldown, UnitFactionGroup
        , GetQuestObjectiveInfo, GetServerTime, GetTime, C_Garrison.GetTalentTreeIDsByClassID, C_Garrison.GetTalentTreeInfoForID, GetLFGDungeonRewards    -- blizzard api

local BOSS_KILL_TEXT = "|T" .. READY_CHECK_READY_TEXTURE .. ":0|t";

local EVENTS_TO_TRACK = {
    -- brewfest
    [372] = {
        ["All"] = {},
    },
    -- feast of winter veil
    [141] = {
        ["All"] = {},
    },
    -- hallows end
    [324] = {
        ["All"] = {},
    },
    -- love is in the air
    [335] = {
        ["All"] = {},
    },
    -- midsummer fire festival
    [341] = {
        ["All"] = {},
    },
    -- noblegarden
    [181] = {
        ["All"] = {},
    },
    -- pilgrims bounty
    [404] = {
        ["All"] = {},
    },

    -- recurring (monthly) events
    -- darkmoon faire
    [479] = {
        All = {36481,29438,29463,29455,29436,37910,29434},
    },
}

function addon:Lockedout_GetCommingEvents()
    local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
    local currentSetMonth, currentSetYear = currentCalendarTime.month, currentCalendarTime.year;

    local currentTime = GetServerTime();
    local currDp = date( "*t", currentTime );
    local endTime = currentTime + (2 * 7 * 24 * 60 * 60);
    local events = {};

    C_Calendar.SetAbsMonth( currDp.month, currDp.year );
    for offset = 0, 1 do    
        local monthInfo = C_Calendar.GetMonthInfo( 0 );

        for day = 1, monthInfo.numDays do
            local eventCount = C_Calendar.GetNumDayEvents( 0, day );
            for eventNum = 1, eventCount do
                local eventInfo = C_Calendar.GetDayEvent( 0, day, eventNum);
                local etTbl = eventInfo.endTime;
                local eventStartTime = time( { year=etTbl.year, month=etTbl.month, day=etTbl.monthDay } );

                if( EVENTS_TO_TRACK[ eventInfo.eventID ] ) and ( events[ eventInfo.eventID ] == nil ) and ( eventStartTime >= currentTime) and ( eventStartTime <= endTime ) then
                    EVENTS_TO_TRACK[ eventInfo.eventID ].title = eventInfo.title;
                    events[ eventInfo.eventID ] = {
                        startTime = eventInfo.startTime,
                        endTime   = eventInfo.endTime,
                        title     = eventInfo.title
                    };
                    addon:debug( "[", currentCalendarTime.month + offset, "/", day, " | ", eventInfo.eventID, " == ", eventInfo.title );
                end
            end
        end
        C_Calendar.SetMonth( 1 );
    end

    C_Calendar.SetAbsMonth( currentSetMonth, currentSetYear );
    return events;
end

local function addEvent(eventTable, day, eventNum)
    local eventInfo = C_Calendar.GetDayEvent( 0, day, eventNum);
    local etTbl = eventInfo.endTime;
    local eventStartTime = time( { year=etTbl.year, month=etTbl.month, day=etTbl.monthDay } );

    if( EVENTS_TO_TRACK[ eventInfo.eventID ] ) and ( eventTable[ eventInfo.eventID ] == nil ) then
        eventTable[ eventInfo.eventID ] = {
            startTime = eventInfo.startTime,
            endTime   = eventInfo.endTime,
            title     = eventInfo.title
        };
        print( EVENTS_TO_TRACK[ eventInfo.eventID ].title, " => ", eventInfo.eventID, " == ", eventInfo.title );
    end
end

local function getCurrentEvents()
    local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime();
    local currentSetMonth, currentSetYear = currentCalendarTime.month, currentCalendarTime.year;

    local currentTime = GetServerTime();
    local currDp = date( "*t", currentTime );
    local endTime = currentTime + (2 * 7 * 24 * 60 * 60);
    local events = {};

    C_Calendar.SetAbsMonth( currDp.month, currDp.year );
    local monthInfo = C_Calendar.GetMonthInfo( 0 );
    local eventCount = C_Calendar.GetNumDayEvents( 0, currDp.day );
    for eventNum = 1, eventCount do
        addEvent( events, currDp.day, eventNum);
    end

    C_Calendar.SetAbsMonth( currentSetMonth, currentSetYear );
    return events;
end

function addon:Lockedout_BuildHolidayEventQuests( )
    local holidayEvents = {}; -- initialize weekly quest table;

    self:Lockedout_GetCommingEvents();

    local englishFaction = UnitFactionGroup("player")

    for currentEventID, eventTable in next, getCurrentEvents() do
        local charEventData = {};
        local eventData     = EVENTS_TO_TRACK[ currentEventID ];
        local allQuests     = EVENTS_TO_TRACK[ currentEventID ][ "All" ] or {};
        local factionQuests = EVENTS_TO_TRACK[ currentEventID ][ englishFaction ] or {};
        
        allQuests = addon:mergeTable( allQuests, factionQuests );
        for _, questID in next, allQuests do
            charEventData[ questID ] = {
                resetDate = addon:getDailyLockoutDate(),
                displayText = "0/0"
           }

            print( addon:getQuestTitleByID( questID ) );
        end

        holidayEvents[ currentEventID ] = charEventData;
    end

    addon.playerDb.holidayEvents = holidayEvents;
end -- Lockedout_BuildInstanceLockout()
