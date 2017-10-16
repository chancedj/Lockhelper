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
        GetQuestResetTime, GetServerTime =                               -- variables 
      GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID,
        GetQuestResetTime, GetServerTime                                 -- blizzard api

local EMISSARY_MAP_ID = 1014;

      
function addon:Lockedout_BuildEmissary( realmName, charNdx )
    local emissaries = {}; -- initialize world boss table;
    local dayCalc = 24 * 60 * 60;
    
    local bounties = GetQuestBountyInfoForMapID( EMISSARY_MAP_ID );

    local test = { };
    
    table.insert( test, "48642" ); -- argussian reach
    table.insert( test, "48641" ); -- armies of the legionfall
    table.insert( test, "48639" ); -- armies of the light
    table.insert( test, "42420" ); -- court of farondis
    table.insert( test, "42233" ); -- highmountain tribes
    table.insert( test, "42170" ); -- the dreamweavers
    table.insert( test, "43179" ); -- kirin tor of dalaran
    table.insert( test, "42421" ); -- the nightfallen
    table.insert( test, "42234" ); -- the valajar   
    table.insert( test, "42422" ); -- the wardens
    ---[[
    for ndx, questId in next, test do
        local timeleft = C_TaskQuest.GetQuestTimeLeftMinutes( questId );
        print( "[" .. ndx .. "] QuestId: " .. questId .. " timeleft: " .. SecondsToTime( timeleft * 60 ) );
        local a = GetQuestLogIndexByID( questId );
        
        print( "|cffffff00|Hquest:" .. questId .. "|h[%%s]|h|r" );
    end
    
    local b = L["booger"];
    --]]
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
