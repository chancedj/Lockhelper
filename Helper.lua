--[[
    This file is for overall helper functions that are to be used addon wide.
--]]
local addonName, _ = ...;

-- libraries
local addon = LibStub( "AceAddon-3.0" ):GetAddon( addonName );
local L     = LibStub( "AceLocale-3.0" ):GetLocale( addonName, false );

-- cache lua functions
local print, type =                                -- variables
      print, type                                  -- lua functions

-- cache blizzard function/globals
local GetCurrentRegion, GetServerTime, GetQuestResetTime, RAID_CLASS_COLORS =                        -- variables
      GetCurrentRegion, GetServerTime, GetQuestResetTime, CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS; -- blizzard global table

function addon:colorizeString( className, value )
    if( className == nil ) then return value; end

    local sStart, sTail, classColor = "|c", "|r", RAID_CLASS_COLORS[ className ].colorStr;

    return sStart .. classColor .. value .. sTail;
end -- addon:colorizeString

function addon:destroyDb()
    if( LockoutDb == nil ) then return; end

    local _, charData = next( LockoutDb );
    if( charData == nil ) then LockoutDb = nil; return; end

    local key = next( charData );
    -- if the char ndx is not a number, we have the old style so destroy db
    if( type( key ) ~= "number" ) then LockoutDb = nil; end;
end -- destroyDb

-- tues for US, Wed for rest?
local MapRegionReset = {
    [1] = 3, -- US
    [2] = 5, -- KR
    [3] = 4, -- EU
    [4] = 5, -- TW
    [5] = 5  -- CN
}

local weekdayRemap = {
    [3] = {
        [1] = 1,
        [2] = 0,
        [3] = 6,
        [4] = 5,
        [5] = 4,
        [6] = 3,
        [7] = 2,
    },
    [4] = {
        [1] = 2,
        [2] = 1,
        [3] = 0,
        [4] = 6,
        [5] = 5,
        [6] = 4,
        [7] = 3,
    },
    [5] = {
        [1] = 3,
        [2] = 2,
        [3] = 1,
        [4] = 0,
        [5] = 6,
        [6] = 5,
        [7] = 4,
    },
}

function addon:getDailyLockoutDate()
    return GetServerTime() + GetQuestResetTime();
end

function addon:getWeeklyLockoutDate()
    local secondsInDay      = 24 * 60 * 60;
    local serverResetDay    = MapRegionReset[ GetCurrentRegion() ];
    local daysLefToReset    = weekdayRemap[ serverResetDay ][ date( "*t", currentServerTime ).wday ];

    local currentServerTime = GetServerTime();
    local weeklyResetTime   = addon:getDailyLockoutDate();

    -- handle reset on day of reset (before vs after server reset)
    if( daysLefToReset == 6 ) then
        -- if they are diff, we've passed server reset time.  so push it a week.
        if( date("%x", weeklyResetTime) ~= date("%x", currentServerTime) ) then
            weeklyResetTime = weeklyResetTime + (daysLefToReset * secondsInDay);
        end
    else
        weeklyResetTime = weeklyResetTime + (daysLefToReset * secondsInDay);
    end

    return weeklyResetTime
end
