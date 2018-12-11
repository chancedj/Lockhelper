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

--[[
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
--]]
--[[
	first key is the expansion level that the emissary applies to
	second key is the questid that the emissary ties to
--]]
local EMISSARY_LIST = {
    [ "6" ] = {
        [ "48642" ] = { numRequired=4, factionId=2170, appliesTo="B" }, -- argussian reach
        [ "48641" ] = { numRequired=4, factionId=2045, appliesTo="B" }, -- armies of the legionfall
        [ "48639" ] = { numRequired=4, factionId=2165, appliesTo="B" }, -- armies of the light
        [ "42420" ] = { numRequired=4, factionId=1900, appliesTo="B" }, -- court of farondis
        [ "42233" ] = { numRequired=4, factionId=1828, appliesTo="B" }, -- highmountain tribes
        [ "42170" ] = { numRequired=4, factionId=1883, appliesTo="B" }, -- the dreamweavers
        [ "43179" ] = { numRequired=3, factionId=1090, appliesTo="B" }, -- kirin tor of dalaran
        [ "42421" ] = { numRequired=4, factionId=1859, appliesTo="B" }, -- the nightfallen
        [ "42234" ] = { numRequired=4, factionId=1948, appliesTo="B" }, -- the valajar   
        [ "42422" ] = { numRequired=4, factionId=1894, appliesTo="B" }  -- the wardens
    },
    [ "7" ] = {
        [ "50604" ] = { numRequired=3, factionId=2163, appliesTo="B" }, -- Tortollan Seekers (neutral)
        [ "50562" ] = { numRequired=4, factionId=2164, appliesTo="B" }, -- Champions of Azeroth (neutral)
        [ "50599" ] = { numRequired=4, factionId=2160, appliesTo="A" }, -- Proudmoore Admiralty (alliance)
        [ "50600" ] = { numRequired=4, factionId=2161, appliesTo="A" }, -- Order of Embers (alliance)
        [ "50601" ] = { numRequired=4, factionId=2162, appliesTo="A" }, -- Storm's Wake (alliance)
        [ "50605" ] = { numRequired=4, factionId=2159, appliesTo="A" }, -- Alliance War Effort (alliance)
        [ "50598" ] = { numRequired=4, factionId=2103, appliesTo="H" }, -- Zandalari Empire (horde)
        [ "50603" ] = { numRequired=4, factionId=2158, appliesTo="H" }, -- Voldunai (horde)
        [ "50602" ] = { numRequired=4, factionId=2156, appliesTo="H" }, -- Talanji's Expedition (horde)
        [ "50606" ] = { numRequired=4, factionId=2157, appliesTo="H" }  -- Horde War Effort (horde)
    }
}

--[[
local EMISSARY_LIST = {
    [ "6" ] = {
        { questID = "48642", numRequired=4, factionId=2170, appliesTo="B" }, -- argussian reach
        { questID = "48641", numRequired=4, factionId=2045, appliesTo="B" }, -- armies of the legionfall
        { questID = "48639", numRequired=4, factionId=2165, appliesTo="B" }, -- armies of the light
        { questID = "42420", numRequired=4, factionId=1900, appliesTo="B" }, -- court of farondis
        { questID = "42233", numRequired=4, factionId=1828, appliesTo="B" }, -- highmountain tribes
        { questID = "42170", numRequired=4, factionId=1883, appliesTo="B" }, -- the dreamweavers
        { questID = "43179", numRequired=3, factionId=1090, appliesTo="B" }, -- kirin tor of dalaran
        { questID = "42421", numRequired=4, factionId=1859, appliesTo="B" }, -- the nightfallen
        { questID = "42234", numRequired=4, factionId=1948, appliesTo="B" }, -- the valajar   
        { questID = "42422", numRequired=4, factionId=1894, appliesTo="B" }  -- the wardens
    },
    [ "7" ] = {
        { questID = "50604", numRequired=3, factionId=2163, appliesTo="B" }, -- Tortollan Seekers (neutral)
        { questID = "50562", numRequired=4, factionId=2164, appliesTo="B" }, -- Champions of Azeroth (neutral)
        { questID = "50599", numRequired=4, factionId=2160, appliesTo="A" }, -- Proudmoore Admiralty (alliance)
        { questID = "50600", numRequired=4, factionId=2161, appliesTo="A" }, -- Order of Embers (alliance)
        { questID = "50601", numRequired=4, factionId=2162, appliesTo="A" }, -- Storm's Wake (alliance)
        { questID = "50605", numRequired=4, factionId=2159, appliesTo="A" }, -- Alliance War Effort (alliance)
        { questID = "50598", numRequired=4, factionId=2103, appliesTo="H" }, -- Zandalari Empire (horde)
        { questID = "50603", numRequired=4, factionId=2158, appliesTo="H" }, -- Voldunai (horde)
        { questID = "50602", numRequired=4, factionId=2156, appliesTo="H" }, -- Talanji's Expedition (horde)
        { questID = "50606", numRequired=4, factionId=2157, appliesTo="H" }  -- Horde War Effort (horde)
    }
}
--]]

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
        for questID, emData in next, emExpansionList do
            ---[[
            --local questID = emData.questID;
            local timeleft = GetQuestTimeLeftMinutes( questID );
            local _, _, finished, numFulfilled, numRequired = GetQuestObjectiveInfo( questID, 1, false );
            local factionParagonEnabled = C_IsFactionParagon( emData.factionId );
            local currentValue, threshold, _, hasRewardPending = C_GetFactionParagonInfo( emData.factionId );

            self:debug( 'factionId: ', emData.factionId, ' ',  currentValue, '/', threshold, ' Reward Pending: ', factionParagonEnabled and hasRewardPending );
            
            local emissaryData = emissaries[ questID ] or {};

            if( timeleft ~= nil ) and ( timeleft > 0 ) and ( numRequired ~= nil ) then
                local day = mfloor( timeleft * 60 / dayCalc );
                
                emissaryData.active       = true;
                emissaryData.fullfilled   = numFulfilled or 0;
                emissaryData.required     = numRequired or 0;
                emissaryData.isComplete   = finished and IsQuestFlaggedCompleted( questID );
                emissaryData.resetDate    = dailyResetDate + (day * dayCalc);
                emissaryData.paragonReady = factionParagonEnabled and hasRewardPending;
                emissaryData.expLevel     = expLevel;
                
                self:debug( "In Process: ", questID );
            elseif( IsQuestFlaggedCompleted( questID ) ) then
                local resetDate = emissaryData.resetDate or dailyResetDate;
                
                if( timeleft ~= nil) and (timeleft > 0 ) then
                    local day = mfloor( timeleft * 60 / dayCalc );
                    resetDate = dailyResetDate + (day * dayCalc)
                end
                
                emissaryData.active     	= true;
                emissaryData.fullfilled 	= emData.numRequired;
                emissaryData.required   	= emData.numRequired;
                emissaryData.isComplete 	= true;
                emissaryData.resetDate  	= resetDate;
                emissaryData.paragonReady 	= factionParagonEnabled and hasRewardPending;
                emissaryData.expLevel     	= expLevel;
                
                self:debug( "Completed: resetDate: ", emissaryData.resetDate, "timeleft: ", timeleft, " - ", questID );
            elseif( factionParagonEnabled and hasRewardPending ) then
                emissaryData.active     	= false;
                emissaryData.fullfilled 	= 0;
                emissaryData.required   	= 0;
                emissaryData.isComplete 	= false;
                emissaryData.resetDate  	= -1;
                emissaryData.paragonReady 	= factionParagonEnabled and hasRewardPending;
                emissaryData.expLevel     	= expLevel;
                
                self:debug( "Paragon found: ", questID );
        	else
                emissaryData = nil;
            end
            --]]
            emissaries[ questID ] = emissaryData;
        end
    end

    -- fix nil error on char rebuild
    LockoutDb[ realmName ][ charNdx ].emissaries = emissaries;
    for realmName, charDataList in next, LockoutDb do
        for charNdx, charData in next, charDataList do
            local charEmissaries = charData.emissaries;
            
            for questID, emissaryData in next, emissaries do
                if( charEmissaries[ questID ] ~= nil ) then
                	local charEmissaryData = charEmissaries[ questID ];
                	if( charEmissaryData.resetData ) and (charEmissaryData.resetData == -1) then
                		--- skip - paragon is tracking only for current char, so don't copy!;
                    elseif( charEmissaryData.resetDate < emissaries[ questID ].resetDate ) then
                        self:debug( "updating: ", realmName, " - ", charData.charName );
                        charEmissaryData.resetDate = emissaries[ questID ].resetDate;
                        charEmissaryData.active    = emissaries[ questID ].active;
                        charEmissaryData.expLevel  = emissaries[ questID ].expLevel;
                    elseif( charEmissaryData.resetDate > emissaries[ questID ].resetDate ) then
                        self:debug( "using: ", realmName, " - ", charData.charName );
                        emissaries[ questID ].resetDate = charEmissaryData.resetDate;
                        emissaries[ questID ].active    = charEmissaryData.active;
                        emissaries[ questID ].expLevel  = charEmissaryData.expLevel;
                    end
                end
            end
        end
    end
    
    -- last update since we may have updated
    LockoutDb[ realmName ][ charNdx ].emissaries = emissaries;
end -- Lockedout_BuildEmissary()
