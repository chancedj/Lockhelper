--[[
    This file handles emmisary tracking
--]]
local addonName, _ = ...;

-- libraries
local addon = LibStub( "AceAddon-3.0" ):GetAddon( addonName );
local L     = LibStub( "AceLocale-3.0" ):GetLocale( addonName, false );

-- Upvalues
local next = -- variables
      next   -- lua functions

-- cache blizzard function/globals
local GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID,
        GetQuestResetTime, SecondsToTime =                               -- variables 
      GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID,
        GetQuestResetTime, SecondsToTime                                 -- blizzard api

local EMMISARY_MAP_ID = 1014;
      
function addon:Lockedout_BuildEmmisary( realmName, charNdx )
    local emmisaries = {}; -- initialize world boss table;
    local dayCalc = 24 * 60 * 60;
    
    local bounties = GetQuestBountyInfoForMapID( EMMISARY_MAP_ID );

    for i = 1, #bounties do
        local questId = bounties[ i ].questID;
        
        local _, _, finished, numFulfilled, numRequired = GetQuestObjectiveInfo( questId, 1, false )
        local title = GetQuestLogTitle( GetQuestLogIndexByID( questId ) );
        
        local emmisary = {
            name = title,
            fullfilled = numFulfilled,
            required = numRequired,
            isComplete = finished,
            icon = "|T" .. bounties[ i ].icon .. ":0|t",
            resetDate = GetQuestResetTime() + ((i - 1) * dayCalc);
        };
        
        emmisaries[ #emmisaries + 1 ] = emmisary;
    end -- for i = 1, #bounties do
    
    LockoutDb[ realmName ][ charNdx ].emmisaries = emmisaries;
end -- Lockedout_BuildEmmisary()
