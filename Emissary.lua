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
local GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID,
        GetQuestResetTime, SecondsToTime, GetServerTime =                               -- variables 
      GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID,
        GetQuestResetTime, SecondsToTime, GetServerTime                                 -- blizzard api

local EMISSARY_MAP_ID = 1014;
      
function addon:Lockedout_BuildEmissary( realmName, charNdx )
    local emissaries = {}; -- initialize world boss table;
    local dayCalc = 24 * 60 * 60;
    
    local bounties = GetQuestBountyInfoForMapID( EMISSARY_MAP_ID );

    for i = 1, #bounties do
        local questId = bounties[ i ].questID;
        
        local _, _, finished, numFulfilled, numRequired = GetQuestObjectiveInfo( questId, 1, false )
        local title = GetQuestLogTitle( GetQuestLogIndexByID( questId ) );
        
        local emissary = {
            name = title,
            fullfilled = numFulfilled,
            required = numRequired,
            isComplete = finished,
            icon = "|T" .. bounties[ i ].icon .. ":0|t",
            resetDate = GetServerTime() + GetQuestResetTime() + ((i - 1) * dayCalc);
        };
        
        emissaries[ #emissaries + 1 ] = emissary;
    end -- for i = 1, #bounties do
    
    LockoutDb[ realmName ][ charNdx ].emissaries = emissaries;
end -- Lockedout_BuildEmissary()
