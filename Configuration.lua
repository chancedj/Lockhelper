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

function addon:getConfigOptions()
    --[[
    local iconList = GetMacroIcons( nil );

    local iconDb = {};
    for ndx, textureId in next, iconList do
        iconDb[ textureId ] = "|T" .. textureId .. ":0|t"
    end
    --]]
    
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
			showMinimapIcon = {
			  order = 12,
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
			currencyHeader={
			  order = 60,
			  name = L["Currency Options"],
			  type = "header",
			},
			currencyShow = {
			  order = 61,
			  name = L["Show"],
			  desc = L["Show currency information"],
			  type = "toggle",
			  set = function(info,val) self.config.profile.currency.show = val; end,
			  get = function(info) return self.config.profile.currency.show end
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
				currentRealm = false
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
				show = true
			},
            emissary = {
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
    
    self:RegisterEvent("PLAYER_ENTERING_WORLD");
    --self:RegisterEvent("PLAYER_ENTERING_WORLD");
    --self:RegisterEvent("PLAYER_ENTERING_WORLD");
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
end

function addon:PLAYER_ENTERING_WORLD()
    self:Lockedout_GetCurrentCharData();
end