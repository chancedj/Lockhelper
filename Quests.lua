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
        , GetTalentTreeIDsByClassID, GetTalentTreeInfoForID =                       -- variables 
      UnitClass, GetQuestBountyInfoForMapID, GetQuestLogTitle, GetQuestLogIndexByID, GetSpellCooldown
        , C_Garrison.GetTalentTreeIDsByClassID, C_Garrison.GetTalentTreeInfoForID   -- blizzard api

local BOSS_KILL_TEXT = "|T" .. READY_CHECK_READY_TEXTURE .. ":0|t";
local function checkBlingtron( self )
    for _, questId in next, self.checkIds do
        if ( IsQuestFlaggedCompleted( questId ) ) then
            local resetDate;
            if( self.resetForm == "daily" ) then
                resetDate = addon:getDailyLockoutDate();
            else
                resetDate = addon:getWeeklyLockoutDate();
            end
            
            return resetDate, true, BOSS_KILL_TEXT;
        end
    end
    
    return 0, false, nil;
end

local function checkInstantQuests( self )
    -- not working, disable for now.
    return 0, false, nil;

    local _, _, classType = UnitClass( "player" );
    local talentTreeIDs = GetTalentTreeIDsByClassID(LE_GARRISON_TYPE_7_0, classType)
    
    if( talentTreeIDs ) then
        local _, treeID = next(talentTreeIDs);
        local _, _, tree = GetTalentTreeInfoForID( treeID );
        
        for ndx, data in next, tree do
            if( data.selected ) then
                for _, spellId in next, self.checkIds do
                    if( data.perkSpellID == spellId ) then
                        local start, duration, enabled = GetSpellCooldown( spellId );
                        
                        -- when enabled == 1, it's not ready, meaning it's on cooldown
                        if( start > 0 ) and ( enabled == 1 ) then
                            return GetServerTime() + (GetTime() - start) + duration, true, BOSS_KILL_TEXT;
                        end
                        
                        break;
                    end
                end
            end
        end
    end
    
    return 0, false, nil;
end

local QUEST_LIBRARY = {
    ["blingtron"] = {name="Blingtron", checkIds={40753,34774,31752}, resetForm="daily", checkStatus=checkBlingtron, copyAccountWide=true },
    ["instantquest"] = {name="Instant Complete", checkIds={219540,221597,221557}, resetForm="custom", checkStatus=checkInstantQuests, copyAccountWide=false }
};

function addon:Lockedout_BuildWeeklyQuests( realmName, charNdx )
    local weeklyQuests = {}; -- initialize weekly quest table;

    local calculatedResetDate = addon:getWeeklyLockoutDate();
    for abbr, questData in next, QUEST_LIBRARY do
        local resetDate, completed, displayText = questData:checkStatus();

        if( completed ) then
            local indivQuestData = {};
            indivQuestData.name = questData.name;
            indivQuestData.displayText = displayText;
            indivQuestData.resetDate = resetDate;

            weeklyQuests[ questData.name ] = indivQuestData;
            if( questData.copyAccountWide ) then
                -- blingtron is account bound, so we copy across the accounts
                for realmName, characters in next, LockoutDb do
                    for charNdx, charData in next, characters do
                        charData.weeklyQuests = charData.weeklyQuests or {};
                        charData.weeklyQuests[ questData.name ] = indivQuestData;
                    end
                end
            end
        end
    end -- for bossId, bossData in next, WORLD_BOSS_LIST
 
    LockoutDb[ realmName ][ charNdx ].weeklyQuests = weeklyQuests;
end -- Lockedout_BuildInstanceLockout()
