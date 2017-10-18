--[[
    This file is to deal with the code to generate the lockout table/vector and
    to handle the refresh of data and deletion of stale data
--]]
local addonName, _ = ...;

-- libraries
local addon = LibStub( "AceAddon-3.0" ):NewAddon( addonName, "AceConsole-3.0", "AceEvent-3.0" );
local L     = LibStub( "AceLocale-3.0" ):GetLocale( addonName, false );

-- cache lua functions
local InterfaceOptionsFrame_OpenToCategory, GetMacroIcons =    -- variables
      InterfaceOptionsFrame_OpenToCategory, GetMacroIcons      -- lua functions
      
----[[
local CURRENCY_LIST = {
    { currencyID=1,    name=getCurrencyName, expansionLevel=1, show=false }, -- Currency Token Test Token 4
    { currencyID=2,    name=getCurrencyName, expansionLevel=1, show=false }, -- Currency Token Test Token 2
    { currencyID=4,    name=getCurrencyName, expansionLevel=1, show=false }, -- Currency Token Test Token 5
    { currencyID=22,   name=getCurrencyName, expansionLevel=1, show=false }, -- Birmingham Test Item 3
    { currencyID=42,   name=getCurrencyName, expansionLevel=2, show=false }, -- Badge of Justice
    { currencyID=61,   name=getCurrencyName, expansionLevel=2, show=true }, -- Dalaran Jewelcrafter's Token
    { currencyID=81,   name=getCurrencyName, expansionLevel=2, show=true }, -- Epicurean's Award
    { currencyID=101,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Heroism
    { currencyID=102,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Valor
    { currencyID=103,  name=getCurrencyName, expansionLevel=2, show=false }, -- Arena Points
    { currencyID=104,  name=getCurrencyName, expansionLevel=2, show=false }, -- Honor Points DEPRECATED
    { currencyID=121,  name=getCurrencyName, expansionLevel=2, show=false }, -- Alterac Valley Mark of Honor
    { currencyID=122,  name=getCurrencyName, expansionLevel=2, show=false }, -- Arathi Basin Mark of Honor
    { currencyID=123,  name=getCurrencyName, expansionLevel=2, show=false }, -- Eye of the Storm Mark of Honor
    { currencyID=124,  name=getCurrencyName, expansionLevel=2, show=false }, -- Strand of the Ancients Mark of Honor
    { currencyID=125,  name=getCurrencyName, expansionLevel=2, show=false }, -- Warsong Gulch Mark of Honor
    { currencyID=126,  name=getCurrencyName, expansionLevel=2, show=false }, -- Wintergrasp Mark of Honor
    { currencyID=161,  name=getCurrencyName, expansionLevel=2, show=false }, -- Stone Keeper's Shard
    { currencyID=181,  name=getCurrencyName, expansionLevel=2, show=false }, -- Honor Points DEPRECATED2
    { currencyID=201,  name=getCurrencyName, expansionLevel=2, show=false }, -- Venture Coin
    { currencyID=221,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Conquest
    { currencyID=241,  name=getCurrencyName, expansionLevel=2, show=true }, -- Champion's Seal
    { currencyID=301,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Triumph
    { currencyID=321,  name=getCurrencyName, expansionLevel=2, show=false }, -- Isle of Conquest Mark of Honor
    { currencyID=341,  name=getCurrencyName, expansionLevel=2, show=false }, -- Emblem of Frost
    { currencyID=361,  name=getCurrencyName, expansionLevel=3, show=true }, -- Illustrious Jewelcrafter's Token
    { currencyID=384,  name=getCurrencyName, expansionLevel=3, show=false }, -- Dwarf Archaeology Fragment
    { currencyID=385,  name=getCurrencyName, expansionLevel=3, show=false }, -- Troll Archaeology Fragment
    { currencyID=391,  name=getCurrencyName, expansionLevel=3, show=true }, -- Tol Barad Commendation
    { currencyID=393,  name=getCurrencyName, expansionLevel=3, show=false }, -- Fossil Archaeology Fragment
    { currencyID=394,  name=getCurrencyName, expansionLevel=3, show=false }, -- Night Elf Archaeology Fragment
    { currencyID=395,  name=getCurrencyName, expansionLevel=3, show=true }, -- Justice Points
    { currencyID=396,  name=getCurrencyName, expansionLevel=3, show=true }, -- Valor Points
    { currencyID=397,  name=getCurrencyName, expansionLevel=3, show=false }, -- Orc Archaeology Fragment
    { currencyID=398,  name=getCurrencyName, expansionLevel=3, show=false }, -- Draenei Archaeology Fragment
    { currencyID=399,  name=getCurrencyName, expansionLevel=3, show=false }, -- Vrykul Archaeology Fragment
    { currencyID=400,  name=getCurrencyName, expansionLevel=3, show=false }, -- Nerubian Archaeology Fragment
    { currencyID=401,  name=getCurrencyName, expansionLevel=3, show=false }, -- Tol'vir Archaeology Fragment
    { currencyID=402,  name=getCurrencyName, expansionLevel=3, show=true }, -- Ironpaw Token
    { currencyID=416,  name=getCurrencyName, expansionLevel=3, show=true }, -- Mark of the World Tree
    { currencyID=483,  name=getCurrencyName, expansionLevel=1, show=true }, -- Conquest Arena Meta
    { currencyID=484,  name=getCurrencyName, expansionLevel=1, show=true }, -- Conquest Rated BG Meta
    { currencyID=515,  name=getCurrencyName, expansionLevel=1, show=true }, -- Darkmoon Prize Ticket
    { currencyID=614,  name=getCurrencyName, expansionLevel=3, show=true }, -- Mote of Darkness
    { currencyID=615,  name=getCurrencyName, expansionLevel=3, show=true }, -- Essence of Corrupted Deathwing
    { currencyID=676,  name=getCurrencyName, expansionLevel=4, show=true }, -- Pandaren Archaeology Fragment
    { currencyID=677,  name=getCurrencyName, expansionLevel=4, show=true }, -- Mogu Archaeology Fragment
    { currencyID=692,  name=getCurrencyName, expansionLevel=4, show=true }, -- Conquest Random BG Meta
    { currencyID=697,  name=getCurrencyName, expansionLevel=4, show=true }, -- Elder Charm of Good Fortune
    { currencyID=698,  name=getCurrencyName, expansionLevel=4, show=true }, -- Zen Jewelcrafter's Token
    { currencyID=738,  name=getCurrencyName, expansionLevel=4, show=true }, -- Lesser Charm of Good Fortune
    { currencyID=752,  name=getCurrencyName, expansionLevel=4, show=true }, -- Mogu Rune of Fate
    { currencyID=754,  name=getCurrencyName, expansionLevel=4, show=true }, -- Mantid Archaeology Fragment
    { currencyID=776,  name=getCurrencyName, expansionLevel=4, show=true }, -- Warforged Seal
    { currencyID=777,  name=getCurrencyName, expansionLevel=4, show=true }, -- Timeless Coin
    { currencyID=789,  name=getCurrencyName, expansionLevel=4, show=true }, -- Bloody Coin
    { currencyID=810,  name=getCurrencyName, expansionLevel=5, show=false }, -- Black Iron Fragment
    { currencyID=821,  name=getCurrencyName, expansionLevel=5, show=false }, -- Draenor Clans Archaeology Fragment
    { currencyID=823,  name=getCurrencyName, expansionLevel=5, show=true }, -- Apexis Crystal
    { currencyID=824,  name=getCurrencyName, expansionLevel=5, show=true }, -- Garrison Resources
    { currencyID=828,  name=getCurrencyName, expansionLevel=5, show=false }, -- Ogre Archaeology Fragment
    { currencyID=829,  name=getCurrencyName, expansionLevel=5, show=false }, -- Arakkoa Archaeology Fragment
    { currencyID=830,  name=getCurrencyName, expansionLevel=5, show=false }, -- n/a
    { currencyID=897,  name=getCurrencyName, expansionLevel=5, show=false }, -- UNUSED
    { currencyID=910,  name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Alchemy
    { currencyID=944,  name=getCurrencyName, expansionLevel=5, show=true }, -- Artifact Fragment
    { currencyID=980,  name=getCurrencyName, expansionLevel=5, show=true }, -- Dingy Iron Coins
    { currencyID=994,  name=getCurrencyName, expansionLevel=5, show=true }, -- Seal of Tempered Fate
    { currencyID=999,  name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Tailoring
    { currencyID=1008, name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Jewelcrafting
    { currencyID=1017, name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Leatherworking
    { currencyID=1020, name=getCurrencyName, expansionLevel=5, show=false }, -- Secret of Draenor Blacksmithing
    { currencyID=1101, name=getCurrencyName, expansionLevel=5, show=true }, -- Oil
    { currencyID=1129, name=getCurrencyName, expansionLevel=5, show=true }, -- Seal of Inevitable Fate
    { currencyID=1149, name=getCurrencyName, expansionLevel=6, show=true }, -- Sightless Eye
    { currencyID=1154, name=getCurrencyName, expansionLevel=6, show=true }, -- Shadowy Coins
    { currencyID=1155, name=getCurrencyName, expansionLevel=6, show=true }, -- Ancient Mana
    { currencyID=1166, name=getCurrencyName, expansionLevel=6, show=true }, -- Timewarped Badge
    { currencyID=1171, name=getCurrencyName, expansionLevel=6, show=false }, -- Artifact Knowledge
    { currencyID=1172, name=getCurrencyName, expansionLevel=6, show=false }, -- Highborne Archaeology Fragment
    { currencyID=1173, name=getCurrencyName, expansionLevel=6, show=false }, -- Highmountain Tauren Archaeology Fragment
    { currencyID=1174, name=getCurrencyName, expansionLevel=6, show=false }, -- Demonic Archaeology Fragment
    { currencyID=1191, name=getCurrencyName, expansionLevel=5, show=false }, -- Valor
    { currencyID=1220, name=getCurrencyName, expansionLevel=6, show=true }, -- Order Resources
    { currencyID=1226, name=getCurrencyName, expansionLevel=6, show=true }, -- Nethershard
    { currencyID=1268, name=getCurrencyName, expansionLevel=6, show=true }, -- Timeworn Artifact
    { currencyID=1273, name=getCurrencyName, expansionLevel=6, show=true }, -- Seal of Broken Fate
    { currencyID=1275, name=getCurrencyName, expansionLevel=6, show=true }, -- Curious Coin
    { currencyID=1299, name=getCurrencyName, expansionLevel=6, show=true }, -- Brawler's Gold
    { currencyID=1314, name=getCurrencyName, expansionLevel=6, show=true }, -- Lingering Soul Fragment
    { currencyID=1324, name=getCurrencyName, expansionLevel=6, show=false }, -- Horde Qiraji Commendation
    { currencyID=1325, name=getCurrencyName, expansionLevel=6, show=false }, -- Alliance Qiraji Commendation
    { currencyID=1342, name=getCurrencyName, expansionLevel=6, show=true }, -- Legionfall War Supplies
    { currencyID=1347, name=getCurrencyName, expansionLevel=6, show=false }, -- Legionfall Building - Personal Tracker - Mage Tower (Hidden)
    { currencyID=1349, name=getCurrencyName, expansionLevel=6, show=false }, -- Legionfall Building - Personal Tracker - Command Tower (Hidden)
    { currencyID=1350, name=getCurrencyName, expansionLevel=6, show=false }, -- Legionfall Building - Personal Tracker - Nether Tower (Hidden)
    { currencyID=1355, name=getCurrencyName, expansionLevel=6, show=true }, -- Felessence
    { currencyID=1356, name=getCurrencyName, expansionLevel=6, show=true }, -- Echoes of Battle
    { currencyID=1357, name=getCurrencyName, expansionLevel=6, show=true }, -- Echoes of Domination
    { currencyID=1379, name=getCurrencyName, expansionLevel=6, show=true }, -- Trial of Style Token
    { currencyID=1416, name=getCurrencyName, expansionLevel=6, show=true }, -- Coins of Air
    { currencyID=1501, name=getCurrencyName, expansionLevel=6, show=true }, -- Writhing Essence
    { currencyID=1506, name=getCurrencyName, expansionLevel=6, show=false }, -- Argus Waystone
    { currencyID=1508, name=getCurrencyName, expansionLevel=6, show=true }  -- Veiled Argunite
}
--]]

function addon:getConfigOptions()
    --[[
    local iconList = GetMacroIcons( nil );

    local iconDb = {};
    for ndx, textureId in next, iconList do
        iconDb[ textureId ] = "|T" .. textureId .. ":0|t"
    end
    --]]
    
    local currencyOptions = {
                                ["short"] = "Short",
                                ["long"] = "Long"
                            };
    
    local configOptions = {
		type = "group",
		name = addonName,
		args = {
			--[[
			enableAddon = {
			  order = 1,
			  name = L["Enable"],
			  desc = L["Enables / disables the addon"],
			  type = "toggle",
			  set = function(info,val) self.config.global.enabled = val; end,
			  get = function(info) return self.config.global.enabled end
			},
			--]]
			generalHeader={
			  order = 10,
			  name = L["General Options"],
			  type = "header",
			},
			currentRealmOnly = {
			  order = 11,
			  name = L["Current Realm"],
			  desc = L["Show characters from current realm only"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.general.currentRealm = val; end,
			  get = function(info) return self.config.profile.general.currentRealm end
			},
            showRealmHeader = {
			  order = 12,
			  name = L["Show Realm"],
			  desc = L["Show the realm header"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.general.showRealmHeader = val; end,
			  get = function(info) return self.config.profile.general.showRealmHeader end
			},
			showMinimapIcon = {
			  order = 13,
			  name = L["Hide Icon"],
			  desc = L["Show Minimap Icon"],
			  type = "toggle",
			  set = function(info,val)
                        self.config.profile.minimap.hide = val;
                        if( self.config.profile.minimap.hide ) then
                            self.icon:Hide( addonName );
                        else
                            self.icon:Show( addonName );
                        end
                    end,
			  get = function(info) return self.config.profile.minimap.hide end
			},
            --[[
            minimapIconList = {
                order = 13,
                name = "Choose Icon",
                desc = "Choose icon for addon",
                type = "select",
                values = iconList
            },
            --]]
			dungeonHeader={
			  order = 20,
			  name = L["Instance Options"],
			  type = "header",
			},
			dungeonShow = {
			  order = 21,
			  name = L["Show"],
			  desc = L["Show dungeon information"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.dungeon.show = val; end,
			  get = function(info) return self.config.profile.dungeon.show end
			},
			raidHeader={
			  order = 30,
			  name = L["Raid Options"],
			  type = "header",
			},
			raidShow = {
			  order = 31,
			  name = L["Show"],
			  desc = L["Show raid information"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.raid.show = val; end,
			  get = function(info) return self.config.profile.raid.show end
			},
			worldBossHeader={
			  order = 40,
			  name = L["World Boss Options"],
			  type = "header",
			},
			worldBossShow = {
			  order = 41,
			  name = L["Show"],
			  desc = L["Show world boss information"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.worldBoss.show = val; end,
			  get = function(info) return self.config.profile.worldBoss.show end
			},
            worldBossOnlyDead = {
              order = 42,
              name = L["Show when dead"],
              desc = L["Show in list only when killed"],
              type = "toggle",
			  set = function(info,val) self.config.profile.worldBoss.showKilledOnly = val; end,
			  get = function(info) return self.config.profile.worldBoss.showKilledOnly end
            },
            emissaryHeader={
			  order = 50,
			  name = L["Emissary Options"],
			  type = "header",
            },
            emissaryShow = {
			  order = 51,
			  name = L["Show"],
			  desc = L["Show Emissary Information"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.emissary.show = val; end,
			  get = function(info) return self.config.profile.emissary.show end
            },
            weeklyQuestHeader={
			  order = 60,
			  name = L["Repeatable Quest Options"],
			  type = "header",
            },
            weeklyQuestShow = {
			  order = 61,
			  name = L["Show"],
			  desc = L["Show repeatable quest information"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.weeklyQuest.show = val; end,
			  get = function(info) return self.config.profile.weeklyQuest.show end
            },
			currencyHeader={
			  order = 100,
			  name = L["Currency Options"],
			  type = "header",
			},
			currencyShow = {
			  order = 101,
			  name = L["Show"],
			  desc = L["Show currency information"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.currency.show = val; end,
			  get = function(info) return self.config.profile.currency.show end
			},
			currencyShorten = {
			  order = 102,
			  name = L["Currency Display"],
			  desc = L["Configures currency display"],
			  type = "select",
              style = "dropdown",
              values = currencyOptions,
			  set = function(info,val) self.config.profile.currency.display = val; end,
			  get = function(info) return self.config.profile.currency.display end
			}
		}
	};
	
	return configOptions;
end

function addon:getDefaultOptions()
	local defaultOptions = {
		global = {
			enabled = true
		},
		profile = {
			minimap = {
				hide = false
			},
			general = {
				currentRealm = false,
                showRealmHeader = true
			},
			dungeon = {
				show = true
			},
			raid = {
				show = true
			},
			worldBoss = {
				show = true,
                showKilledOnly = true
			},
			currency = {
				show = true,
                display = "long"
			},
            emissary = {
                show = true
            },
            weeklyQuest = {
                show = true
            }
		}
	}
	
	return defaultOptions;
end

function addon:OnInitialize()
    local LockedoutMo = LibStub( "LibDataBroker-1.1" ):NewDataObject( "Locked Out", {
        type = "data source",
        text = L[ "Locked Out" ],
        icon = "Interface\\Icons\\Inv_misc_key_10",
        OnClick = function( frame, button ) self:OpenConfigDialog( button ) end,
        OnEnter = function( frame ) self:ShowInfo( frame ) end,
    } ); -- local LockedoutMo

	local defaultOptions = self:getDefaultOptions();
    self.config = LibStub( "AceDB-3.0" ):New( "LockedOutConfig", defaultOptions, true );
    self.config:RegisterDefaults( defaultOptions );

    self.icon = LibStub( "LibDBIcon-1.0" );
    self.icon:Register(addonName, LockedoutMo, self.config.profile.minimap)

    self.optionFrameName = addonName .. "OptionPanel"
    LibStub( "AceConfigRegistry-3.0" ):RegisterOptionsTable( self.optionFrameName, self:getConfigOptions() );
    self.optionFrame = LibStub( "AceConfigDialog-3.0" ):AddToBlizOptions( self.optionFrameName, addonName );
    self.optionFrame.default = function() self:ResetDefaults() end;
	self:RegisterChatCommand( "lo", "ChatCommand" );
	self:RegisterChatCommand( "lockedout", "ChatCommand" );

    -- events
    self:RegisterEvent( "PLAYER_ENTERING_WORLD", "FullCharacterRefresh" );
    self:RegisterEvent( "BOSS_KILL", "FullCharacterRefresh" );
    self:RegisterEvent( "UNIT_QUEST_LOG_CHANGED", "FullCharacterRefresh" );
end

function addon:ChatCommand()
	self:OpenConfigDialog();
end

function addon:ResetDefaults()
    -- reset database here.
    self.config:ResetProfile();
    LibStub("AceConfigRegistry-3.0"):NotifyChange( self.optionFrameName );
end

function addon:OpenConfigDialog( button )
	if( button == nil) or ( button == "RightButton" ) then
		-- this command is buggy, open it twice to fix the bug.
		InterfaceOptionsFrame_OpenToCategory( self.optionFrame ); -- #1
		InterfaceOptionsFrame_OpenToCategory( self.optionFrame ); -- #2
	end
    
    --[[ this helps to build the currency table
    for ndx=1, 2000 do
        local name = GetCurrencyInfo( ndx );
        
        if( name ~= nil ) and ( name ~= "" ) then
            print( "{ [" .. ndx .. "] = { currencyID=" .. ndx .. ", getName=function() return '' end, expansionLevel=1 } }, -- " .. name );
        end
    end
    --]]
end

function addon:FullCharacterRefresh()
    self:Lockedout_GetCurrentCharData();
end
