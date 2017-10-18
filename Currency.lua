--[[
    This file is to deal with the code to generate the lockout table/vector and
    to handle the refresh of data and deletion of stale data
--]]
local addonName, _ = ...;

-- libraries
local addon = LibStub( "AceAddon-3.0" ):GetAddon( addonName );
local L     = LibStub( "AceLocale-3.0" ):GetLocale( addonName, false );

-- Upvalues
local next, strfmt =            -- variables
      next, string.format       -- lua functions

-- cache blizzard function/globals
local GetCurrencyListSize, GetCurrencyListInfo, GetCurrencyInfo, IsQuestFlaggedCompleted =    -- variables
      GetCurrencyListSize, GetCurrencyListInfo, GetCurrencyInfo, IsQuestFlaggedCompleted      -- blizzard api

local function getCurrencyName( self )
    local name = GetCurrencyInfo(self.currencyID);
    
    return name;
end

---[[
local BONUS_ROLL_QUESTID = {
    [ "Seal of Broken Fate" ] = {
        [1] = {
            43892,  -- order resources
            43893,  -- order resources
            43894,  -- order resources
            43895,  -- gold
            43896,  -- gold
            43897,  -- gold
            47851,  -- marks of honor
            47864,  -- marks of honor
            47865,  -- marks of honor
            43510,  -- class hall
            47040,  -- broken shore
            47045,  -- broken shore
            47054   -- broken shore

        }
    }
}
--]]

local shortMap = {
    [1] =
        {
            limit = 1e9, -- billions
            fmt = "%.1fb"
        },
    [2] =
        {
            limit = 1e6, -- millions
            fmt = "%.1fm"
        },
    [3] =
        {
            limit = 1e3, -- thousands
            fmt = "%.1fk"
        }
}

function addon:shortenAmount( amount )
    local result = amount

    if( self.config.profile.currency.display == "short" ) then
        for _, map in next, shortMap do
            if( amount > map.limit ) then
                return strfmt( map.fmt, amount / map.limit );
            end
        end
    end
    
    return result;
end

function addon:Lockedout_BuildCurrencyList( realmName, charNdx )
    local currency = {}; -- initialize currency table;

    local currencyListSize = GetCurrencyListSize();
    local calculatedResetDate = addon:getWeeklyLockoutDate();
    for index=1, currencyListSize do
        local name, isHeader, _, isUnused, _, count, icon, maximum = GetCurrencyListInfo( index );

        if( not isHeader ) and ( not isUnused ) then
            currency[ name ] = {}
            currency[ name ].icon = "|T" .. icon .. ":0|t";
            currency[ name ].count = count;
            currency[ name ].maximum = maximum;

            local questList = BONUS_ROLL_QUESTID[ name ];
            local bonus = nil;
            if( questList ~= nil ) then
                bonus = {};
                for _, questGroup in next, questList do
                    local bonusCompleted = 0;
                    for _, questId in next, questGroup do
                        if( IsQuestFlaggedCompleted( questId ) ) then
                            bonusCompleted = bonusCompleted + 1;
                        end
                    end

                    bonus[ #bonus + 1 ] = bonusCompleted;
                end
            end
            currency[ name ].bonus = bonus;
        end
    end

    LockoutDb[ realmName ][ charNdx ].currency = currency;
end -- Lockedout_BuildInstanceLockout()
