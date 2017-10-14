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
      
----[[
local CURRENCY_LIST = {
    [1]     = { currencyID=1,    name=getCurrencyName, expansionLevel=1, show=false }, -- Currency Token Test Token 4
    [2]     = { currencyID=2,    name=getCurrencyName, expansionLevel=1, show=false }, -- Currency Token Test Token 2
    [4]     = { currencyID=4,    name=getCurrencyName, expansionLevel=1, show=false }, -- Currency Token Test Token 5
    [22]    = { currencyID=22,   name=getCurrencyName, expansionLevel=1, show=false }, -- Birmingham Test Item 3
    [42]    = { currencyID=42,   name=getCurrencyName, expansionLevel=2, show=false }, -- Badge of Justice
    [61]    = { currencyID=61,   name=getCurrencyName, expansionLevel=2, show=true }, -- Dalaran Jewelcrafter's Token
    [81]    = { currencyID=81,   name=getCurrencyName, expansionLevel=2, show=true }, -- Epicurean's Award
    [101]   = { currencyID=101,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Heroism
    [102]   = { currencyID=102,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Valor
    [103]   = { currencyID=103,  name=getCurrencyName, expansionLevel=2, show=false }, -- Arena Points
    [104]   = { currencyID=104,  name=getCurrencyName, expansionLevel=2, show=false }, -- Honor Points DEPRECATED
    [121]   = { currencyID=121,  name=getCurrencyName, expansionLevel=2, show=false }, -- Alterac Valley Mark of Honor
    [122]   = { currencyID=122,  name=getCurrencyName, expansionLevel=2, show=false }, -- Arathi Basin Mark of Honor
    [123]   = { currencyID=123,  name=getCurrencyName, expansionLevel=2, show=false }, -- Eye of the Storm Mark of Honor
    [124]   = { currencyID=124,  name=getCurrencyName, expansionLevel=2, show=false }, -- Strand of the Ancients Mark of Honor
    [125]   = { currencyID=125,  name=getCurrencyName, expansionLevel=2, show=false }, -- Warsong Gulch Mark of Honor
    [126]   = { currencyID=126,  name=getCurrencyName, expansionLevel=2, show=false }, -- Wintergrasp Mark of Honor
    [161]   = { currencyID=161,  name=getCurrencyName, expansionLevel=2, show=false }, -- Stone Keeper's Shard
    [181]   = { currencyID=181,  name=getCurrencyName, expansionLevel=2, show=false }, -- Honor Points DEPRECATED2
    [201]   = { currencyID=201,  name=getCurrencyName, expansionLevel=2, show=false }, -- Venture Coin
    [221]   = { currencyID=221,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Conquest
    [241]   = { currencyID=241,  name=getCurrencyName, expansionLevel=2, show=true }, -- Champion's Seal
    [301]   = { currencyID=301,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Triumph
    [321]   = { currencyID=321,  name=getCurrencyName, expansionLevel=2, show=false }, -- Isle of Conquest Mark of Honor
    [341]   = { currencyID=341,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Frost
    [361]   = { currencyID=361,  name=getCurrencyName, expansionLevel=3, show=true }, -- Illustrious Jewelcrafter's Token
    [384]   = { currencyID=384,  name=getCurrencyName, expansionLevel=3, show=false }, -- Dwarf Archaeology Fragment
    [385]   = { currencyID=385,  name=getCurrencyName, expansionLevel=3, show=false }, -- Troll Archaeology Fragment
    [391]   = { currencyID=391,  name=getCurrencyName, expansionLevel=3, show=true }, -- Tol Barad Commendation
    [393]   = { currencyID=393,  name=getCurrencyName, expansionLevel=3, show=false }, -- Fossil Archaeology Fragment
    [394]   = { currencyID=394,  name=getCurrencyName, expansionLevel=3, show=false }, -- Night Elf Archaeology Fragment
    [395]   = { currencyID=395,  name=getCurrencyName, expansionLevel=3, show=true }, -- Justice Points
    [396]   = { currencyID=396,  name=getCurrencyName, expansionLevel=3, show=true }, -- Valor Points
    [397]   = { currencyID=397,  name=getCurrencyName, expansionLevel=3, show=false }, -- Orc Archaeology Fragment
    [398]   = { currencyID=398,  name=getCurrencyName, expansionLevel=3, show=false }, -- Draenei Archaeology Fragment
    [399]   = { currencyID=399,  name=getCurrencyName, expansionLevel=3, show=false }, -- Vrykul Archaeology Fragment
    [400]   = { currencyID=400,  name=getCurrencyName, expansionLevel=3, show=false }, -- Nerubian Archaeology Fragment
    [401]   = { currencyID=401,  name=getCurrencyName, expansionLevel=3, show=false }, -- Tol'vir Archaeology Fragment
    [402]   = { currencyID=402,  name=getCurrencyName, expansionLevel=3, show=true }, -- Ironpaw Token
    [416]   = { currencyID=416,  name=getCurrencyName, expansionLevel=3, show=true }, -- Mark of the World Tree
    [483]   = { currencyID=483,  name=getCurrencyName, expansionLevel=1, show=true }, -- Conquest Arena Meta
    [484]   = { currencyID=484,  name=getCurrencyName, expansionLevel=1, show=true }, -- Conquest Rated BG Meta
    [515]   = { currencyID=515,  name=getCurrencyName, expansionLevel=1, show=true }, -- Darkmoon Prize Ticket
    [614]   = { currencyID=614,  name=getCurrencyName, expansionLevel=3, show=true }, -- Mote of Darkness
    [615]   = { currencyID=615,  name=getCurrencyName, expansionLevel=3, show=true }, -- Essence of Corrupted Deathwing
    [676]   = { currencyID=676,  name=getCurrencyName, expansionLevel=4, show=true }, -- Pandaren Archaeology Fragment
    [677]   = { currencyID=677,  name=getCurrencyName, expansionLevel=4, show=true }, -- Mogu Archaeology Fragment
    [692]   = { currencyID=692,  name=getCurrencyName, expansionLevel=4, show=true }, -- Conquest Random BG Meta
    [697]   = { currencyID=697,  name=getCurrencyName, expansionLevel=4, show=true }, -- Elder Charm of Good Fortune
    [698]   = { currencyID=698,  name=getCurrencyName, expansionLevel=4, show=true }, -- Zen Jewelcrafter's Token
    [738]   = { currencyID=738,  name=getCurrencyName, expansionLevel=4, show=true }, -- Lesser Charm of Good Fortune
    [752]   = { currencyID=752,  name=getCurrencyName, expansionLevel=4, show=true }, -- Mogu Rune of Fate
    [754]   = { currencyID=754,  name=getCurrencyName, expansionLevel=4, show=true }, -- Mantid Archaeology Fragment
    [776]   = { currencyID=776,  name=getCurrencyName, expansionLevel=4, show=true }, -- Warforged Seal
    [777]   = { currencyID=777,  name=getCurrencyName, expansionLevel=4, show=true }, -- Timeless Coin
    [789]   = { currencyID=789,  name=getCurrencyName, expansionLevel=4, show=true }, -- Bloody Coin
    [810]   = { currencyID=810,  name=getCurrencyName, expansionLevel=5, show=false }, -- Black Iron Fragment
    [821]   = { currencyID=821,  name=getCurrencyName, expansionLevel=5, show=false }, -- Draenor Clans Archaeology Fragment
    [823]   = { currencyID=823,  name=getCurrencyName, expansionLevel=5, show=true }, -- Apexis Crystal
    [824]   = { currencyID=824,  name=getCurrencyName, expansionLevel=5, show=true }, -- Garrison Resources
    [828]   = { currencyID=828,  name=getCurrencyName, expansionLevel=5, show=false }, -- Ogre Archaeology Fragment
    [829]   = { currencyID=829,  name=getCurrencyName, expansionLevel=5, show=false }, -- Arakkoa Archaeology Fragment
    [830]   = { currencyID=830,  name=getCurrencyName, expansionLevel=5, show=false }, -- n/a
    [897]   = { currencyID=897,  name=getCurrencyName, expansionLevel=5, show=false }, -- UNUSED
    [910]   = { currencyID=910,  name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Alchemy
    [944]   = { currencyID=944,  name=getCurrencyName, expansionLevel=5, show=true }, -- Artifact Fragment
    [980]   = { currencyID=980,  name=getCurrencyName, expansionLevel=5, show=true }, -- Dingy Iron Coins
    [994]   = { currencyID=994,  name=getCurrencyName, expansionLevel=5, show=true }, -- Seal of Tempered Fate
    [999]   = { currencyID=999,  name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Tailoring
    [1008]  = { currencyID=1008, name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Jewelcrafting
    [1017]  = { currencyID=1017, name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Leatherworking
    [1020]  = { currencyID=1020, name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Blacksmithing
    [1101]  = { currencyID=1101, name=getCurrencyName, expansionLevel=5, show=true }, -- Oil
    [1129]  = { currencyID=1129, name=getCurrencyName, expansionLevel=5, show=true }, -- Seal of Inevitable Fate
    [1149]  = { currencyID=1149, name=getCurrencyName, expansionLevel=6, show=true }, -- Sightless Eye
    [1154]  = { currencyID=1154, name=getCurrencyName, expansionLevel=6, show=true }, -- Shadowy Coins
    [1155]  = { currencyID=1155, name=getCurrencyName, expansionLevel=6, show=true }, -- Ancient Mana
    [1166]  = { currencyID=1166, name=getCurrencyName, expansionLevel=6, show=true }, -- Timewarped Badge
    [1171]  = { currencyID=1171, name=getCurrencyName, expansionLevel=6, show=false }, -- Artifact Knowledge
    [1172]  = { currencyID=1172, name=getCurrencyName, expansionLevel=6, show=false }, -- Highborne Archaeology Fragment
    [1173]  = { currencyID=1173, name=getCurrencyName, expansionLevel=6, show=false }, -- Highmountain Tauren Archaeology Fragment
    [1174]  = { currencyID=1174, name=getCurrencyName, expansionLevel=6, show=false }, -- Demonic Archaeology Fragment
    [1191]  = { currencyID=1191, name=getCurrencyName, expansionLevel=5, show=false }, -- Valor
    [1220]  = { currencyID=1220, name=getCurrencyName, expansionLevel=6, show=true }, -- Order Resources
    [1226]  = { currencyID=1226, name=getCurrencyName, expansionLevel=6, show=true }, -- Nethershard
    [1268]  = { currencyID=1268, name=getCurrencyName, expansionLevel=6, show=true }, -- Timeworn Artifact
    [1273]  = { currencyID=1273, name=getCurrencyName, expansionLevel=6, show=true }, -- Seal of Broken Fate
    [1275]  = { currencyID=1275, name=getCurrencyName, expansionLevel=6, show=true }, -- Curious Coin
    [1299]  = { currencyID=1299, name=getCurrencyName, expansionLevel=6, show=true }, -- Brawler's Gold
    [1314]  = { currencyID=1314, name=getCurrencyName, expansionLevel=6, show=true }, -- Lingering Soul Fragment
    [1324]  = { currencyID=1324, name=getCurrencyName, expansionLevel=6, show=false }, -- Horde Qiraji Commendation
    [1325]  = { currencyID=1325, name=getCurrencyName, expansionLevel=6, show=false }, -- Alliance Qiraji Commendation
    [1342]  = { currencyID=1342, name=getCurrencyName, expansionLevel=6, show=true }, -- Legionfall War Supplies
    [1347]  = { currencyID=1347, name=getCurrencyName, expansionLevel=6, show=false }, -- Legionfall Building - Personal Tracker - Mage Tower (Hidden)
    [1349]  = { currencyID=1349, name=getCurrencyName, expansionLevel=6, show=false }, -- Legionfall Building - Personal Tracker - Command Tower (Hidden)
    [1350]  = { currencyID=1350, name=getCurrencyName, expansionLevel=6, show=false }, -- Legionfall Building - Personal Tracker - Nether Tower (Hidden)
    [1355]  = { currencyID=1355, name=getCurrencyName, expansionLevel=6, show=true }, -- Felessence
    [1356]  = { currencyID=1356, name=getCurrencyName, expansionLevel=6, show=true }, -- Echoes of Battle
    [1357]  = { currencyID=1357, name=getCurrencyName, expansionLevel=6, show=true }, -- Echoes of Domination
    [1379]  = { currencyID=1379, name=getCurrencyName, expansionLevel=6, show=true }, -- Trial of Style Token
    [1416]  = { currencyID=1416, name=getCurrencyName, expansionLevel=6, show=true }, -- Coins of Air
    [1501]  = { currencyID=1501, name=getCurrencyName, expansionLevel=6, show=true }, -- Writhing Essence
    [1506]  = { currencyID=1506, name=getCurrencyName, expansionLevel=6, show=false }, -- Argus Waystone
    [1508]  = { currencyID=1508, name=getCurrencyName, expansionLevel=6, show=true }  -- Veiled Argunite
}
--]]

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
