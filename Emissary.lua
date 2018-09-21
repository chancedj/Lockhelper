--[[
    This file handles emissary tracking
--]]
local addonName, _ = ...;

-- libraries
local addon = LibStub( "AceAddon-3.0" ):GetAddon( addonName );
local L     = LibStub( "AceLocale-3.0" ):GetLocale( addonName, false );

-- Upvalues
local next, mfloor =    -- variables
      next, math.floor  -- lua functions

-- cache blizzard function/globals
local GetQuestObjectiveInfo, GetQuestTimeLeftMinutes, C_GetFactionParagonInfo, C_IsFactionParagon =                                    -- variables 
      GetQuestObjectiveInfo, C_TaskQuest.GetQuestTimeLeftMinutes, C_Reputation.GetFactionParagonInfo, C_Reputation.IsFactionParagon    -- blizzard api

local EMISSARY_MAP_ID = 1014;
local OLD_EMISSARY_LIST = {
    { questID = "48642", numRequired=4 }, -- argussian reach
    { questID = "48641", numRequired=4 }, -- armies of the legionfall
    { questID = "48639", numRequired=4 }, -- armies of the light
    { questID = "42420", numRequired=4 }, -- court of farondis
    { questID = "42233", numRequired=4 }, -- highmountain tribes
    { questID = "42170", numRequired=4 }, -- the dreamweavers
    { questID = "43179", numRequired=3 }, -- kirin tor of dalaran
    { questID = "42421", numRequired=4 }, -- the nightfallen
    { questID = "42234", numRequired=4 }, -- the valajar   
    { questID = "42422", numRequired=4 }  -- the wardens
}

local EMISSARY_LIST = {
    [ "6" ] = {
        { questID = "48642", numRequired=4, factionId=0 }, -- argussian reach
        { questID = "48641", numRequired=4, factionId=0 }, -- armies of the legionfall
        { questID = "48639", numRequired=4, factionId=0 }, -- armies of the light
        { questID = "42420", numRequired=4, factionId=0 }, -- court of farondis
        { questID = "42233", numRequired=4, factionId=0 }, -- highmountain tribes
        { questID = "42170", numRequired=4, factionId=0 }, -- the dreamweavers
        { questID = "43179", numRequired=3, factionId=0 }, -- kirin tor of dalaran
        { questID = "42421", numRequired=4, factionId=0 }, -- the nightfallen
        { questID = "42234", numRequired=4, factionId=0 }, -- the valajar   
        { questID = "42422", numRequired=4, factionId=0 }  -- the wardens
    },
    [ "7" ] = {
        { questID = "50604", numRequired=3, factionId=0 }, -- Tortollan Seekers
        { questID = "50562", numRequired=4, factionId=0 }, -- Champions of Azeroth 
        { questID = "50599", numRequired=4, factionId=0 }, -- Proudmoore Admiralty 
        { questID = "50600", numRequired=4, factionId=0 }, -- Order of Embers
        { questID = "50601", numRequired=4, factionId=0 }, -- Storm's Wake
        { questID = "50605", numRequired=4, factionId=0 }, -- Alliance War Effort
        { questID = "50598", numRequired=4, factionId=0 }, -- Zandalari Empire
        { questID = "50603", numRequired=4, factionId=0 }, -- Voldunai
        { questID = "50602", numRequired=4, factionId=0 }, -- Talanji's Expedition 
        { questID = "50606", numRequired=4, factionId=0 }  -- Horde War Effort 
    }
}

local function copyEmissaryData( from, to )
    to.name       = from.name;
    to.required   = from.fullfilled; -- set required to fulfilled.  we're only copying DONE data - so fulfilled and required need to be equal.
    to.fullfilled = from.fullfilled;
    to.resetDate  = from.resetDate;
end

function addon:Lockedout_BuildEmissary( realmName, charNdx )
    local emissaries = LockoutDb[ realmName ][ charNdx ].emissaries or {}; -- initialize world boss table;
    local dayCalc = 24 * 60 * 60;
    local dailyResetDate = addon:getDailyLockoutDate();
    
    for expLevel, emExpansionList in next, EMISSARY_LIST do
        for _, emData in next, emExpansionList do
            ---[[
            local questID = emData.questID;
            local timeleft = GetQuestTimeLeftMinutes( questID );
            local _, _, finished, numFulfilled, numRequired = GetQuestObjectiveInfo( questID, 1, false );
            local currentValue, threshold, _, hasRewardPending = C_GetFactionParagonInfo( emData.factionId );

            if( timeleft ~= nil ) and ( timeleft > 0 ) and ( numRequired ~= nil ) then
                local day = mfloor( timeleft * 60 / dayCalc );
                local emissaryData = emissaries[ questID ] or {};
                
                emissaryData.active       = true;
                emissaryData.fullfilled   = numFulfilled or 0;
                emissaryData.required     = numRequired or 0;
                emissaryData.isComplete   = finished and IsQuestFlaggedCompleted( questID );
                emissaryData.resetDate    = dailyResetDate + (day * dayCalc);
                emissaryData.paragonReady = currentValue and hasRewardPending;
                emissaryData.expLevel     = expLevel;
                
                self:debug( "In Process: ", questID );
                emissaries[ questID ] = emissaryData;
            elseif( IsQuestFlaggedCompleted( questID ) ) then
                local emissaryData = emissaries[ questID ] or {};
                local resetDate = emissaryData.resetDate or dailyResetDate;
                
                if( timeleft ~= nil) and (timeleft > 0 ) then
                    local day = mfloor( timeleft * 60 / dayCalc );
                    resetDate = dailyResetDate + (day * dayCalc)
                end
                
                emissaryData.active     = true;
                emissaryData.fullfilled = emData.numRequired;
                emissaryData.required   = emData.numRequired;
                emissaryData.isComplete = true;
                emissaryData.resetDate  = resetDate;
                emissaryData.paragonReady = currentValue and hasRewardPending;
                emissaryData.expLevel     = expLevel;
                
                self:debug( "Completed: resetDate: ", emissaryData.resetDate, "timeleft: ", timeleft, " - ", questID );
                emissaries[ questID ] = emissaryData;
            else
                emissaries[ questID ] = nil;
            end
            --]]
        end
    end

    -- fix nil error on char rebuild
    LockoutDb[ realmName ][ charNdx ].emissaries = emissaries;
    for realmName, charDataList in next, LockoutDb do
        for charNdx, charData in next, charDataList do
            local charEmissaries = charData.emissaries;
            
            for questID, emissaryData in next, emissaries do
                if( charEmissaries[ questID ] ~= nil ) then
                    if( charEmissaries[ questID ].resetDate < emissaries[ questID ].resetDate ) then
                        self:debug( "updating: ", realmName, " - ", charData.charName );
                        charEmissaries[ questID ].resetDate = emissaries[ questID ].resetDate;
                        charEmissaries[ questID ].active    = emissaries[ questID ].active;
                        charEmissaries[ questID ].expLevel  = emissaries[ questID ].expLevel;
                    elseif( charEmissaries[ questID ].resetDate > emissaries[ questID ].resetDate ) then
                        self:debug( "using: ", realmName, " - ", charData.charName );
                        emissaries[ questID ].resetDate = charEmissaries[ questID ].resetDate;
                        emissaries[ questID ].active    = charEmissaries[ questID ].active;
                        emissaries[ questID ].expLevel  = charEmissaries[ questID ].expLevel;
                    end
                end
            end
        end
    end
    
    -- last update since we may have updated
    LockoutDb[ realmName ][ charNdx ].emissaries = emissaries;
end -- Lockedout_BuildEmissary()
