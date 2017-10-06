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
local GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID,               -- variables 
      GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID                -- blizzard api

local QUEST_LIBRARY = {
    ["blingtron"] = {name="Blingtron", questIds={40753,34774,31752}, resetForm="daily"}
};

local BOSS_KILL_TEXT = "|T" .. READY_CHECK_READY_TEXTURE .. ":0|t";
function addon:Lockedout_BuildWeeklyQuests( realmName, charNdx )
    local weeklyQuests = {}; -- initialize weekly quest table;

    local calculatedResetDate = addon:getWeeklyLockoutDate();
    for abbr, questData in next, QUEST_LIBRARY do
        for _, questId in next, questData.questIds do
            if ( IsQuestFlaggedCompleted( questId ) ) then
                weeklyQuests[ questData.name ] = {}
                weeklyQuests[ questData.name ].name = questData.name;
                weeklyQuests[ questData.name ].displayText = BOSS_KILL_TEXT;
                if( questData.resetForm == "daily" ) then
                    weeklyQuests[ questData.name ].resetDate = addon:getDailyLockoutDate();
                else
                    weeklyQuests[ questData.name ].resetDate = addon:getWeeklyLockoutDate();
                end
                
                break;
            end
        end
    end -- for bossId, bossData in next, WORLD_BOSS_LIST
    
    -- blingtron is account bound, so we copy across the accounts
    for realmName, characters in next, LockoutDb do
        for charNdx, charData in next, characters do
            charData.weeklyQuests = weeklyQuests;
        end
    end
 
    LockoutDb[ realmName ][ charNdx ].weeklyQuests = weeklyQuests;
end -- Lockedout_BuildInstanceLockout()