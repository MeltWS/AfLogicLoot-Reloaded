-----------------------------------------------------------------------------------------------
-- Client Lua Script for AfLogicLoot
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
require "Unit"
require "GameLib"
require "GroupLib"
require "GuildLib"
require "ChatSystemLib"
 
-----------------------------------------------------------------------------------------------
-- AfLogicLoot Module Definition
-----------------------------------------------------------------------------------------------
local AfLogicLoot = {} 
local L = Apollo.GetPackage("Gemini:Locale-1.0").tPackage:GetLocale("AfLogicLoot", true)
 
-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------

local strVersion = "Version: @project-version@"

local LootAction = {
	need = 1,
	greed = 2,
	pass = 3,
	none = 4,
}

local ItemQuality = {
	inferior = 1,
	average = 2,
	good = 3,
	excellent = 4,
	superb = 5,
	legendary = 6,
	artifact = 7,
}

local toItemQuality = {
	[Item.CodeEnumItemQuality.Inferior] = 1,
	[Item.CodeEnumItemQuality.Average] = 2,
	[Item.CodeEnumItemQuality.Good] = 3,
	[Item.CodeEnumItemQuality.Excellent] = 4,
	[Item.CodeEnumItemQuality.Superb] = 5,
	[Item.CodeEnumItemQuality.Legendary] = 6,
	[Item.CodeEnumItemQuality.Artifact] = 7,
}

local tProfileSelect = {
	ini = {
		group = {
			[0] = 1,
			[1] = 2,
			[2] = 3,
			[3] = 4,
			[4] = 5,
		},
		raid = 6,
	},
	world = {
		group = 7,
		raid = 8,
	}
}

local tProfileSelectToString = {
	[1] = "group in instance, no randoms",
	[2] = "group in instance, one random",
	[3] = "group in instance, two randoms",
	[4] = "group in instance, three randoms",
	[5] = "group in instance, four randoms",
	[6] = "raid in instance",
	[7] = "group in open world",
	[8] = "raid in open world",
}

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

function AfLogicLoot:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- default settings for new installation, will be overwritten otherwise
	o.settings = {
		log = true,
		hudlog = true,
		scenelog = false,
		active = true,
		profiles = 1,
		lastprofile = 1,
		activeprofile = 1,
		automaticprofiles = false,
		profileselector = {
			[tProfileSelect.ini.group[0]] = 2,
			[tProfileSelect.ini.group[1]] = 2,
			[tProfileSelect.ini.group[2]] = 2,
			[tProfileSelect.ini.group[3]] = 2,
			[tProfileSelect.ini.group[4]] = 2,
			[tProfileSelect.ini.raid] = 2,
			[tProfileSelect.world.group] = 2,
			[tProfileSelect.world.raid] = 2,
		},
		profileselectorprofile = {
			[tProfileSelect.ini.group[0]] = 1,
			[tProfileSelect.ini.group[1]] = 1,
			[tProfileSelect.ini.group[2]] = 1,
			[tProfileSelect.ini.group[3]] = 1,
			[tProfileSelect.ini.group[4]] = 1,
			[tProfileSelect.ini.raid] = 1,
			[tProfileSelect.world.group] = 1,
			[tProfileSelect.world.raid] = 1,
		},		
	}
	
	o.defaultprofile = {
		decor = {
			quality = ItemQuality.inferior,
			below = LootAction.none,
			above = LootAction.none,
		},
		fabkits = {
			quality = ItemQuality.inferior,
			below = LootAction.none,
			above = LootAction.none,
		},
		fragments = {
			all = LootAction.none,
		},
		survivalist = {
			all = LootAction.none,
		},
		equipment = {
			quality = ItemQuality.good,
			below = LootAction.none,
			noneed = LootAction.none,
		},
		sigils = {
			quality = ItemQuality.good,
			below = LootAction.none,
			above = LootAction.none,
		},
		catalysts = {
			my = {
				quality = ItemQuality.good,
				below = LootAction.none,
				above = LootAction.none,
			},
			other = {
				quality = ItemQuality.good,
				below = LootAction.none,
				above = LootAction.none,			
			},
		},
		bags = {
			all = LootAction.none,
		},
		scanbot = {
			all = LootAction.none,
		},
		amps = {
			all = LootAction.none,
		},
		schematics = {
			all = LootAction.none,
		},
		cloth = {
			all = LootAction.none,
		},
		dye = {
			all = LootAction.none,
		},
		flux = {
			all = LootAction.none,
		},
		prop = {
			all = LootAction.none,
		},
	}
	
	o.profiles = {
		[1] = {
			name = L["default_profile"],
			settings = self:CopyTable(o.defaultprofile)
		}
	}
	
	o.scene = 0
	
	o.hudqueue = {}
	o.hudid = 0
	o.hudlast = 0
	o.hudcounter = 0
	o.debug = false
	o.guild = {}
	
    return o
end


function AfLogicLoot:Init()
	local bHasConfigureFunction = true
	local strConfigureButtonText = "afLogicLoot"
	local tDependencies = {
		-- "UnitOrPackageName",
	}
    Apollo.RegisterAddon(self, bHasConfigureFunction, strConfigureButtonText, tDependencies)
end
 

-----------------------------------------------------------------------------------------------
-- AfLogicLoot OnLoad
-----------------------------------------------------------------------------------------------

function AfLogicLoot:OnLoad()
    -- load our form file
	self.xmlDoc = XmlDoc.CreateFromFile("AfLogicLoot.xml")
	self.xmlDoc:RegisterCallback("OnDocLoaded", self)
	Apollo.LoadSprites("AfLogicLootSprites.xml", "AfLogicLootSprites")
end


-----------------------------------------------------------------------------------------------
-- AfLogicLoot OnDocLoaded
-----------------------------------------------------------------------------------------------

function AfLogicLoot:OnDocLoaded()

	if self.xmlDoc ~= nil and self.xmlDoc:IsLoaded() then
	    self.wndMain = Apollo.LoadForm(self.xmlDoc, "AfLogicLootForm", nil, self)
		if self.wndMain == nil then
			Apollo.AddAddonErrorText(self, "Could not load the main window for some reason.")
			return
		end
		
	    self.wndMain:Show(false, true)
		
		self.wndHud = Apollo.LoadForm(self.xmlDoc, "frm_hud", nil, self)
		self.wndHud:Show(false, true)

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("afloot", "OnAfLogicLootOn", self)

		self.timer = ApolloTimer.Create(15.0, false, "OnTimer", self)
		self.hudtimer = ApolloTimer.Create(1.0, true, "OnHudLogTimer", self)
		self.hudtimer:Stop()
		self.guildtimer = ApolloTimer.Create(30.0, false, "DelayedGuildCheck", self)
		
		Apollo.RegisterEventHandler("LootRollUpdate", "OnLootRollUpdate", self)

		Apollo.RegisterEventHandler("Group_Add",         "ChoseProfile",        self)
		Apollo.RegisterEventHandler("Group_Left",        "ChoseProfile",        self)
		Apollo.RegisterEventHandler("Group_Updated",     "ChoseProfile",        self)
		Apollo.RegisterEventHandler("Group_Join",        "ChoseProfile",        self)
		Apollo.RegisterEventHandler("Group_Remove",      "ChoseProfile",        self)
				
		Apollo.RegisterEventHandler("ChangeWorld",       "ChoseProfile",        self)

		
		Apollo.RegisterEventHandler("GuildRoster",       "UpdateGuildList", self)
	    Apollo.RegisterEventHandler("GuildMemberChange", "UpdateGuildListSource", self)
				
		self.crbAddon = Apollo.GetAddon("NeedVsGreed")
		
		self.wndMain:FindChild("lbl_version"):SetText(strVersion)
		
		if not self.settings.firstconfigureshown then
			self:OnConfigure()
			self.settings.firstconfigureshown = true
		end
		self.wndMain:FindChild("btn_equipment1"):SetCheck(true)
		self:SwitchToTab(1)
		
		local i
		for i = 1, 8, 1 do
			self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("btn_set_profile"..i):SetData(i)
		end
		
		local uMe = GameLib.GetPlayerUnit()
		if uMe then
			self.guild = uMe:GetGuildName()
		end
		
		self:LocalizeWindow()
		
	end
end


-----------------------------------------------------------------------------------------------
-- AfLogicLoot Functions
-----------------------------------------------------------------------------------------------

function AfLogicLoot:RecursiveTranslation(wndItem)
	for idx, wndChild in pairs(wndItem:GetChildren()) do
		if wndChild:GetName() == "chk_inferior" then wndChild:SetText(L["inferior"]) end
		if wndChild:GetName() == "chk_average" then wndChild:SetText(L["average"]) end
		if wndChild:GetName() == "chk_good" then wndChild:SetText(L["good"]) end
		if wndChild:GetName() == "chk_excellent" then wndChild:SetText(L["excellent"]) end
		if wndChild:GetName() == "chk_superb" then wndChild:SetText(L["superb"]) end
		if wndChild:GetName() == "chk_legendary" then wndChild:SetText(L["legendary"]) end
		if wndChild:GetName() == "chk_artifact" then wndChild:SetText(L["artifact"]) end
		if wndChild:GetName() == "chk_need" then wndChild:SetText(L["need"]) end
		if wndChild:GetName() == "chk_greed" then wndChild:SetText(L["greed"]) end
		if wndChild:GetName() == "chk_pass" then wndChild:SetText(L["pass"]) end
		if wndChild:GetName() == "chk_no_action" then wndChild:SetText(L["no_action"]) end
		if wndChild:GetName() == "lbl_caption_quality" then wndChild:SetText(L["quality_below"]) end
		if wndChild:GetName() == "lbl_caption_action" then wndChild:SetText(L["action"]) end
		if wndChild:GetName() == "lbl_caption_selected" then wndChild:SetText(L["selected"]) end
		if wndChild:GetName() == "lbl_caption_otherwise" then wndChild:SetText(L["otherwise"]) end
		if wndChild:GetName() == "radio_off" then wndChild:SetText(L["profile_turn_off"]) end
		if wndChild:GetName() == "radio_use_profile" then wndChild:SetText(L["profile_use_profile"]) end
		self:RecursiveTranslation(wndChild)
	end
end


function AfLogicLoot:LocalizeWindow()
	local i
	
	self.wndMain:FindChild("btn_equipment1"):SetText(L["equipment1"])
	self.wndMain:FindChild("btn_equipment1"):SetText(L["equipment1"])
	self.wndMain:FindChild("btn_style"):SetText(L["style"])
	self.wndMain:FindChild("btn_crafting"):SetText(L["crafting"])
	self.wndMain:FindChild("btn_profiles"):SetText(L["profiles"])
	
	self.wndMain:FindChild("chk_log"):SetText(L["chk_log"])
	
	self:RecursiveTranslation(self.wndMain)
	
	self.wndMain:FindChild("chk_excellent_major"):SetText(L["excellent_major"])
	self.wndMain:FindChild("chk_superb_eldan"):SetText(L["superb_eldan"])
	self.wndMain:FindChild("lbl_caption_no_need"):SetText(L["no_need"])
	
	self.wndMain:FindChild("frm_equip"):FindChild("lbl_category_headline"):SetText(L["equipment_headline"])
	self.wndMain:FindChild("frm_equip"):FindChild("lbl_category_headline"):SetTooltip(L["equipment_headline_tooltip"])
	self.wndMain:FindChild("frm_equip"):FindChild("lbl_caption_action"):SetTooltip(L["equipment_action_tooltip"])
	self.wndMain:FindChild("frm_equip"):FindChild("lbl_caption_no_need"):SetTooltip(L["equipment_no_need_tooltip"])
	
	self.wndMain:FindChild("frm_sigils"):FindChild("lbl_category_headline"):SetText(L["sigils_headline"])
	self.wndMain:FindChild("frm_sigils"):FindChild("lbl_category_headline"):SetTooltip(L["sigils_headline_tooltip"])
	self.wndMain:FindChild("frm_sigils"):FindChild("lbl_caption_selected"):SetTooltip(L["sigils_selected_tooltip"])
	self.wndMain:FindChild("frm_sigils"):FindChild("lbl_caption_otherwise"):SetTooltip(L["sigils_otherwise_tooltip"])

	self.wndMain:FindChild("frm_fragments"):FindChild("lbl_category_headline"):SetText(L["fragments_headline"])
	self.wndMain:FindChild("frm_fragments"):FindChild("lbl_category_headline"):SetTooltip(L["fragments_headline_tooltip"])
	
	self.wndMain:FindChild("frm_flux"):FindChild("lbl_category_headline"):SetText(L["flux_headline"])
	self.wndMain:FindChild("frm_flux"):FindChild("lbl_category_headline"):SetTooltip(L["flux_headline_tooltip"])

	self.wndMain:FindChild("frm_prop"):FindChild("lbl_category_headline"):SetText(L["prop_headline"])
	self.wndMain:FindChild("frm_prop"):FindChild("lbl_category_headline"):SetTooltip(L["prop_headline_tooltip"])

	self.wndMain:FindChild("frm_amps"):FindChild("lbl_category_headline"):SetText(L["amps_headline"])
	self.wndMain:FindChild("frm_amps"):FindChild("lbl_category_headline"):SetTooltip(L["amps_headline_tooltip"])

	self.wndMain:FindChild("frm_bags"):FindChild("lbl_category_headline"):SetText(L["bags_headline"])
	self.wndMain:FindChild("frm_bags"):FindChild("lbl_category_headline"):SetTooltip(L["bags_headline_tooltip"])

	self.wndMain:FindChild("frm_scanbot"):FindChild("lbl_category_headline"):SetText(L["scanbot_headline"])
	self.wndMain:FindChild("frm_scanbot"):FindChild("lbl_category_headline"):SetTooltip(L["scanbot_headline_tooltip"])

	self.wndMain:FindChild("frm_decor"):FindChild("lbl_category_headline"):SetText(L["decor_headline"])
	self.wndMain:FindChild("frm_decor"):FindChild("lbl_category_headline"):SetTooltip(L["decor_headline_tooltip"])
	self.wndMain:FindChild("frm_decor"):FindChild("lbl_caption_selected"):SetTooltip(L["decor_selected_tooltip"])
	self.wndMain:FindChild("frm_decor"):FindChild("lbl_caption_otherwise"):SetTooltip(L["decor_otherwise_tooltip"])
	
	self.wndMain:FindChild("frm_fabkits"):FindChild("lbl_category_headline"):SetText(L["fabkits_headline"])
	self.wndMain:FindChild("frm_fabkits"):FindChild("lbl_category_headline"):SetTooltip(L["fabkits_headline_tooltip"])
	self.wndMain:FindChild("frm_fabkits"):FindChild("lbl_caption_selected"):SetTooltip(L["fabkits_selected_tooltip"])
	self.wndMain:FindChild("frm_fabkits"):FindChild("lbl_caption_otherwise"):SetTooltip(L["fabkits_otherwise_tooltip"])
	
	self.wndMain:FindChild("frm_dye"):FindChild("lbl_category_headline"):SetText(L["dye_headline"])
	self.wndMain:FindChild("frm_dye"):FindChild("lbl_category_headline"):SetTooltip(L["dye_headline_tooltip"])
	
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("lbl_category_headline"):SetText(L["catalysts_my_headline"])
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("lbl_category_headline"):SetTooltip(L["catalysts_my_headline_tooltip"])
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("lbl_caption_selected"):SetTooltip(L["catalysts_my_selected_tooltip"])
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("lbl_caption_otherwise"):SetTooltip(L["catalysts_my_otherwise_tooltip"])
	
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("lbl_category_headline"):SetText(L["catalysts_other_headline"])
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("lbl_category_headline"):SetTooltip(L["catalysts_other_headline_tooltip"])
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("lbl_caption_selected"):SetTooltip(L["catalysts_other_selected_tooltip"])
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("lbl_caption_otherwise"):SetTooltip(L["catalysts_other_otherwise_tooltip"])
	
	self.wndMain:FindChild("frm_schematics"):FindChild("lbl_category_headline"):SetText(L["schematics_headline"])
	self.wndMain:FindChild("frm_schematics"):FindChild("lbl_category_headline"):SetTooltip(L["schematics_headline_tooltip"])
	
	self.wndMain:FindChild("frm_survivalist"):FindChild("lbl_category_headline"):SetText(L["survivalist_headline"])
	self.wndMain:FindChild("frm_survivalist"):FindChild("lbl_category_headline"):SetTooltip(L["survivalist_headline_tooltip"])
	
	self.wndMain:FindChild("frm_cloth"):FindChild("lbl_category_headline"):SetText(L["cloth_headline"])
	self.wndMain:FindChild("frm_cloth"):FindChild("lbl_category_headline"):SetTooltip(L["cloth_headline_tooltip"])
	
	self.wndMain:FindChild("frm_profile_manager"):FindChild("lbl_category_headline"):SetText(L["profile_management"])
	self.wndMain:FindChild("frm_profile_manager"):FindChild("lbl_title_name"):SetText(L["profile_title"])
	self.wndMain:FindChild("frm_profile_manager"):FindChild("btn_add"):SetText(L["profile_add"])
	self.wndMain:FindChild("frm_profile_manager"):FindChild("lbl_explanation"):SetText(L["profile_explanation"])
	
	for i = 1, 8, 1 do
		self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("btn_set_profile"..i):SetTooltip(L["profile_select_that"])
	end

	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_category_headline"):SetText(L["profile_automatic_headline"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_category_headline"):SetTooltip(L["profile_automatic_headline_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_ini_group"):SetText(L["profile_ini_group"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_zero"):SetText(L["profile_group_zero"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_one"):SetText(L["profile_group_one"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_two"):SetText(L["profile_group_two"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_three"):SetText(L["profile_group_three"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_four"):SetText(L["profile_group_four"])
	
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_ini_raid"):SetText(L["profile_ini_raid"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group"):SetText(L["profile_group"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_raid"):SetText(L["profile_raid"])
	
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("chk_automatic_profiles"):SetText(L["profile_automatic"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("chk_hudlog"):SetText(L["profile_hudlog"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("chk_log_scene"):SetText(L["profile_log_scene"])	
	
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_ini_group"):SetTooltip(L["profile_ini_group_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_zero"):SetTooltip(L["profile_group_zero_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_one"):SetTooltip(L["profile_group_one_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_two"):SetTooltip(L["profile_group_two_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_three"):SetTooltip(L["profile_group_three_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group_four"):SetTooltip(L["profile_group_four_tt"])
	
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_ini_raid"):SetTooltip(L["profile_ini_raid_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_group"):SetTooltip(L["profile_group_tt"])
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_raid"):SetTooltip(L["profile_raid_tt"])
end


function AfLogicLoot:OnAfLogicLootOn(strCommand, strParam)
	local item = Item.GetDataFromId(strParam)
	if item ~= nil then
		self:analyze(item)
	elseif strParam == "on" then
		self:SetStatus(true)
	elseif strParam == "off" then
		self:SetStatus(false)
	elseif strParam == "toggle" then
		self:SetStatus(not self.settings.active)
	elseif strParam == "debug" then
		self.debug = (self.debug == false)
		self:log("debug: "..tostring(self.debug))
	else
		self.wndMain:Invoke()
		self:SettingsToGUI()
	end
end


function AfLogicLoot:DelayedGuildCheck()
	for _,guild in ipairs(GuildLib.GetGuilds()) do
	    	guild:RequestMembers()
  	end
end


function AfLogicLoot:UpdateGuildListSource(uGuild)
	uGuild:RequestMembers()
end


function AfLogicLoot:UpdateGuildList(uGuild, roster)
	if (uGuild:GetType() == GuildLib.GuildType_Guild) then
		self.guild = {}
		for key, value in pairs(roster) do
			self.guild[value.strName] = true
		end
	end
end


function AfLogicLoot:OnConfigure()
	self.wndMain:Invoke()
	self:SettingsToGUI()
end


function AfLogicLoot:ChoseProfile()
	if not self.settings.automaticprofiles then return end
	if not GroupLib.InGroup() then return end
	local result = 0
	if GroupLib.InInstance() then
		if GroupLib.InRaid() then
			result = tProfileSelect.ini.raid
		else
			local iRandoms = 0
			local nMembers = GroupLib.GetMemberCount()
			for idx = 1, nMembers, 1 do
				if not self.guild[GroupLib.GetGroupMember(idx).strCharacterName] then
					iRandoms = iRandoms + 1
				end
			end
			result = tProfileSelect.ini.group[iRandoms]
		end
	else
		if GroupLib.InRaid() then
			result = tProfileSelect.world.raid
		else
			result = tProfileSelect.world.group
		end
	end
	if self.scene ~= result then
		if result == nil then return end	
		local bChanged = false
		self.scene = result
		if self.settings.scenelog then
			self:log("Scene switched to "..tProfileSelectToString[result])
			if self.settings.hudlog then
				self:HudLog("Scene switched to "..tProfileSelectToString[result])
			end
		end
		
		if self.settings.profileselector[result] == 1 then
			if self.settings.active then
				self:SetStatus(false)
				bChanged = true
			end
		else
			if not self.settings.active then
				self:SetStatus(true)
				bChanged = true
			end
		end
		
		if self.settings.activeprofile ~= self.settings.profileselectorprofile[result] then
			self:log(L["msg_switch_profile"]..": "..self.profiles[self.settings.profileselectorprofile[result]].name)
			if self.settings.hudlog then
				self:HudLog(L["msg_switch_profile"]..": "..self.profiles[self.settings.profileselectorprofile[result]].name)
			end
			self.settings.activeprofile = self.settings.profileselectorprofile[result]
			self:LoadProfiles()
			bChanged = true
		end
		
		if bChanged and not self.settings.hudlog then
			-- even if the scene switched, the resulting profile may be the same
			-- this fires only, if the profile or the online status changed
			Sound.PlayFile("./sounds/chatnotify.wav")
		end
	end
end


function AfLogicLoot:RegExSafe(strMessage)
	strMessage = strMessage:gsub("%%", "%%%%")
	strMessage = strMessage:gsub("%^", "%%%^")
	strMessage = strMessage:gsub("%$", "%%%$")
	strMessage = strMessage:gsub("%(", "%%%(")
	strMessage = strMessage:gsub("%)", "%%%)")
	strMessage = strMessage:gsub("%.", "%%%.")
	strMessage = strMessage:gsub("%[", "%%%[")
	strMessage = strMessage:gsub("%]", "%%%]")
	strMessage = strMessage:gsub("%*", "%%%*")
	strMessage = strMessage:gsub("%+", "%%%+")
	strMessage = strMessage:gsub("%-", "%%%-")
	strMessage = strMessage:gsub("%?", "%%%?")	
	return strMessage
end


function AfLogicLoot:SettingsToGUI()
	self.wndMain:FindChild("chk_log"):SetCheck(self.settings.log)
	self.wndMain:FindChild("chk_hudlog"):SetCheck(self.settings.hudlog)
	self.wndMain:FindChild("chk_log_scene"):SetCheck(self.settings.scenelog)
	
	self.wndMain:FindChild("frm_decor"):FindChild("frm_quality"):SetRadioSel("decor_quality", self.profiles[self.settings.activeprofile].settings.decor.quality)
	self.wndMain:FindChild("frm_decor"):FindChild("frm_action_below"):SetRadioSel("decor_below", self.profiles[self.settings.activeprofile].settings.decor.below)
	self.wndMain:FindChild("frm_decor"):FindChild("frm_action_above"):SetRadioSel("decor_above", self.profiles[self.settings.activeprofile].settings.decor.above)
	self.wndMain:FindChild("frm_fabkits"):FindChild("frm_quality"):SetRadioSel("fabkits_quality", self.profiles[self.settings.activeprofile].settings.fabkits.quality)
	self.wndMain:FindChild("frm_fabkits"):FindChild("frm_action_below"):SetRadioSel("fabkits_below", self.profiles[self.settings.activeprofile].settings.fabkits.below)
	self.wndMain:FindChild("frm_fabkits"):FindChild("frm_action_above"):SetRadioSel("fabkits_above", self.profiles[self.settings.activeprofile].settings.fabkits.above)	
	self.wndMain:FindChild("frm_fragments"):FindChild("frm_action"):SetRadioSel("fragments_all", self.profiles[self.settings.activeprofile].settings.fragments.all)
	self.wndMain:FindChild("frm_survivalist"):FindChild("frm_action"):SetRadioSel("survivalist_all", self.profiles[self.settings.activeprofile].settings.survivalist.all)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_quality"):SetRadioSel("equipment_quality", self.profiles[self.settings.activeprofile].settings.equipment.quality)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_action"):SetRadioSel("equipment_below", self.profiles[self.settings.activeprofile].settings.equipment.below - 1)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_action_noneed"):SetRadioSel("equipment_noneed", self.profiles[self.settings.activeprofile].settings.equipment.noneed - 1)
	self.wndMain:FindChild("frm_sigils"):FindChild("frm_quality"):SetRadioSel("sigil_quality", self.profiles[self.settings.activeprofile].settings.sigils.quality)
	self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_below"):SetRadioSel("sigil_below", self.profiles[self.settings.activeprofile].settings.sigils.below)
	self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_above"):SetRadioSel("sigil_above", self.profiles[self.settings.activeprofile].settings.sigils.above)
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_quality"):SetRadioSel("catalyst_quality_my", self.profiles[self.settings.activeprofile].settings.catalysts.my.quality)
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_below"):SetRadioSel("catalyst_my_below", self.profiles[self.settings.activeprofile].settings.catalysts.my.below)
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_above"):SetRadioSel("catalyst_my_above", self.profiles[self.settings.activeprofile].settings.catalysts.my.above)
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_quality"):SetRadioSel("catalyst_quality_other", self.profiles[self.settings.activeprofile].settings.catalysts.other.quality)
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_below"):SetRadioSel("catalyst_other_below", self.profiles[self.settings.activeprofile].settings.catalysts.other.below)
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_above"):SetRadioSel("catalyst_other_above", self.profiles[self.settings.activeprofile].settings.catalysts.other.above)
	self.wndMain:FindChild("frm_bags"):FindChild("frm_action"):SetRadioSel("bags_all", self.profiles[self.settings.activeprofile].settings.bags.all)
	self.wndMain:FindChild("frm_scanbot"):FindChild("frm_action"):SetRadioSel("scanbot_all", self.profiles[self.settings.activeprofile].settings.scanbot.all)
	self.wndMain:FindChild("frm_amps"):FindChild("frm_action"):SetRadioSel("amps_all", self.profiles[self.settings.activeprofile].settings.amps.all)
	self.wndMain:FindChild("frm_schematics"):FindChild("frm_action"):SetRadioSel("schematics_all", self.profiles[self.settings.activeprofile].settings.schematics.all)
	self.wndMain:FindChild("frm_cloth"):FindChild("frm_action"):SetRadioSel("cloth_all", self.profiles[self.settings.activeprofile].settings.cloth.all)
	self.wndMain:FindChild("frm_dye"):FindChild("frm_action"):SetRadioSel("dye_all", self.profiles[self.settings.activeprofile].settings.dye.all)
	self.wndMain:FindChild("frm_flux"):FindChild("frm_action"):SetRadioSel("flux_all", self.profiles[self.settings.activeprofile].settings.flux.all)
	self.wndMain:FindChild("frm_prop"):FindChild("frm_action"):SetRadioSel("prop_all", self.profiles[self.settings.activeprofile].settings.prop.all)
	self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("chk_automatic_profiles"):SetCheck(self.settings.automaticprofiles)
	local wndToggleButton1 = self.wndMain:FindChild("btnToggleButton1")
	local wndToggleButton2 = self.wndMain:FindChild("btnToggleButton2")	
	wndToggleButton1:Show(self.settings.active)
	wndToggleButton2:Show(self.settings.active == false)

	self:RefreshProfileSelectorDisplay()
	self:LoadProfiles()
end


function AfLogicLoot:GUIToSettings()
	self.settings.log = self.wndMain:FindChild("chk_log"):IsChecked()
	self.settings.hudlog = self.wndMain:FindChild("chk_hudlog"):IsChecked()
	self.settings.scenelog = self.wndMain:FindChild("chk_log_scene"):IsChecked()
	
	self.profiles[self.settings.activeprofile].settings.decor.quality = self.wndMain:FindChild("frm_decor"):FindChild("frm_quality"):GetRadioSel("decor_quality")
	self.profiles[self.settings.activeprofile].settings.decor.below = self.wndMain:FindChild("frm_decor"):FindChild("frm_action_below"):GetRadioSel("decor_below")
	self.profiles[self.settings.activeprofile].settings.decor.above = self.wndMain:FindChild("frm_decor"):FindChild("frm_action_above"):GetRadioSel("decor_above")
	self.profiles[self.settings.activeprofile].settings.fabkits.quality = self.wndMain:FindChild("frm_fabkits"):FindChild("frm_quality"):GetRadioSel("fabkits_quality")
	self.profiles[self.settings.activeprofile].settings.fabkits.below = self.wndMain:FindChild("frm_fabkits"):FindChild("frm_action_below"):GetRadioSel("fabkits_below")
	self.profiles[self.settings.activeprofile].settings.fabkits.above = self.wndMain:FindChild("frm_fabkits"):FindChild("frm_action_above"):GetRadioSel("fabkits_above")
	self.profiles[self.settings.activeprofile].settings.fragments.all = self.wndMain:FindChild("frm_fragments"):FindChild("frm_action"):GetRadioSel("fragments_all")
	self.profiles[self.settings.activeprofile].settings.survivalist.all = self.wndMain:FindChild("frm_survivalist"):FindChild("frm_action"):GetRadioSel("survivalist_all")
	self.profiles[self.settings.activeprofile].settings.equipment.quality = self.wndMain:FindChild("frm_equip"):FindChild("frm_quality"):GetRadioSel("equipment_quality")
	self.profiles[self.settings.activeprofile].settings.equipment.below = self.wndMain:FindChild("frm_equip"):FindChild("frm_action"):GetRadioSel("equipment_below") + 1
	self.profiles[self.settings.activeprofile].settings.equipment.noneed = self.wndMain:FindChild("frm_equip"):FindChild("frm_action_noneed"):GetRadioSel("equipment_noneed") + 1
	self.profiles[self.settings.activeprofile].settings.sigils.quality = self.wndMain:FindChild("frm_sigils"):FindChild("frm_quality"):GetRadioSel("sigil_quality")
	self.profiles[self.settings.activeprofile].settings.sigils.below = self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_below"):GetRadioSel("sigil_below")
	self.profiles[self.settings.activeprofile].settings.sigils.above = self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_above"):GetRadioSel("sigil_above")	
	self.profiles[self.settings.activeprofile].settings.catalysts.my.quality = self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_quality"):GetRadioSel("catalyst_quality_my")
	self.profiles[self.settings.activeprofile].settings.catalysts.my.below = self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_below"):GetRadioSel("catalyst_my_below")
	self.profiles[self.settings.activeprofile].settings.catalysts.my.above = self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_above"):GetRadioSel("catalyst_my_above")
	self.profiles[self.settings.activeprofile].settings.catalysts.other.quality = self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_quality"):GetRadioSel("catalyst_quality_other")
	self.profiles[self.settings.activeprofile].settings.catalysts.other.below = self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_below"):GetRadioSel("catalyst_other_below")
	self.profiles[self.settings.activeprofile].settings.catalysts.other.above = self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_above"):GetRadioSel("catalyst_other_above")
	self.profiles[self.settings.activeprofile].settings.bags.all = self.wndMain:FindChild("frm_bags"):FindChild("frm_action"):GetRadioSel("bags_all")
	self.profiles[self.settings.activeprofile].settings.scanbot.all = self.wndMain:FindChild("frm_scanbot"):FindChild("frm_action"):GetRadioSel("scanbot_all")
	self.profiles[self.settings.activeprofile].settings.amps.all = self.wndMain:FindChild("frm_amps"):FindChild("frm_action"):GetRadioSel("amps_all")
	self.profiles[self.settings.activeprofile].settings.schematics.all = self.wndMain:FindChild("frm_schematics"):FindChild("frm_action"):GetRadioSel("schematics_all")
	self.profiles[self.settings.activeprofile].settings.cloth.all = self.wndMain:FindChild("frm_cloth"):FindChild("frm_action"):GetRadioSel("cloth_all")
	self.profiles[self.settings.activeprofile].settings.dye.all = self.wndMain:FindChild("frm_dye"):FindChild("frm_action"):GetRadioSel("dye_all")
	self.profiles[self.settings.activeprofile].settings.flux.all = self.wndMain:FindChild("frm_flux"):FindChild("frm_action"):GetRadioSel("flux_all")
	self.profiles[self.settings.activeprofile].settings.prop.all = self.wndMain:FindChild("frm_prop"):FindChild("frm_action"):GetRadioSel("prop_all")
	self.settings.profileselector[tProfileSelect.ini.group[0]] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("group0")
	self.settings.profileselector[tProfileSelect.ini.group[1]] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("group1")
	self.settings.profileselector[tProfileSelect.ini.group[2]] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("group2")
	self.settings.profileselector[tProfileSelect.ini.group[3]] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("group3")
	self.settings.profileselector[tProfileSelect.ini.group[4]] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("group4")
	self.settings.profileselector[tProfileSelect.ini.raid] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("raid_ini")
	self.settings.profileselector[tProfileSelect.world.group] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("group_world")
	self.settings.profileselector[tProfileSelect.world.raid] = self.wndMain:FindChild("frm_automatic_for_the_people"):GetRadioSel("raid_world")	
	self.settings.automaticprofiles = self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("chk_automatic_profiles"):IsChecked()
end
	
	
function AfLogicLoot:RefreshProfileSelectorDisplay()
	local i
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("group0", self.settings.profileselector[tProfileSelect.ini.group[0]])
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("group1", self.settings.profileselector[tProfileSelect.ini.group[1]])
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("group2", self.settings.profileselector[tProfileSelect.ini.group[2]])
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("group3", self.settings.profileselector[tProfileSelect.ini.group[3]])
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("group4", self.settings.profileselector[tProfileSelect.ini.group[4]])
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("raid_ini", self.settings.profileselector[tProfileSelect.ini.raid])
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("group_world", self.settings.profileselector[tProfileSelect.world.group])
	self.wndMain:FindChild("frm_automatic_for_the_people"):SetRadioSel("raid_world", self.settings.profileselector[tProfileSelect.world.raid])
	for i = 1, 8, 1 do
		self.wndMain:FindChild("frm_automatic_for_the_people"):FindChild("lbl_profile_selector"..i):SetText(self.profiles[self.settings.profileselectorprofile[i]].name)
	end
end


function AfLogicLoot:CheckProfileSelector()
	local i
	for i = 1, 8, 1 do
		if (self.settings.profileselectorprofile[i] == nil) or (self.profiles[self.settings.profileselectorprofile[i]] == nil) then
			self.settings.profileselector[i] = 1
			self.settings.profileselectorprofile[i] = self.settings.activeprofile
		end
	end
end


function AfLogicLoot:CopyTable(obj, seen)
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[self:CopyTable(k, s)] = self:CopyTable(v, s) end
	return res
end


function AfLogicLoot:OnSave(eType)
	-- really account-based? sounds reasonable at the moment
	if eType == GameLib.CodeEnumAddonSaveLevel.Account then
		local tSavedData = {}
		tSavedData.settings = self.settings
		tSavedData.profiles = self.profiles
		return tSavedData		
	end
	return
end


function AfLogicLoot:OnRestore(eType, tSavedData)
	if eType == GameLib.CodeEnumAddonSaveLevel.Account then
	
		if tSavedData.settings ~= nil then
			-- replacing single values to not overwrite new default values by not existing values
			if tSavedData.settings.firstconfigureshown ~= nil then self.settings.firstconfigureshown = tSavedData.settings.firstconfigureshown end
			if tSavedData.settings.log ~= nil then self.settings.log = tSavedData.settings.log end
			if tSavedData.settings.hudlog ~= nil then self.settings.hudlog = tSavedData.settings.hudlog end
			if tSavedData.settings.scenelog ~= nil then self.settings.scenelog = tSavedData.settings.scenelog end
			if tSavedData.settings.automaticprofiles ~= nil then self.settings.automaticprofiles = tSavedData.settings.automaticprofiles end
			if tSavedData.settings.active ~= nil then self.settings.active = tSavedData.settings.active end
			if tSavedData.settings.activeprofile ~= nil then 
				self.settings.activeprofile = tSavedData.settings.activeprofile
			else
				self.settings.activeprofile = 1
			end
			if tSavedData.settings.profileselector ~= nil then
				if tSavedData.settings.profileselector[tProfileSelect.ini.group[0]] ~= nil then self.settings.profileselector[tProfileSelect.ini.group[0]] = tSavedData.settings.profileselector[tProfileSelect.ini.group[0]] end
				if tSavedData.settings.profileselector[tProfileSelect.ini.group[1]] ~= nil then self.settings.profileselector[tProfileSelect.ini.group[1]] = tSavedData.settings.profileselector[tProfileSelect.ini.group[1]] end
				if tSavedData.settings.profileselector[tProfileSelect.ini.group[2]] ~= nil then self.settings.profileselector[tProfileSelect.ini.group[2]] = tSavedData.settings.profileselector[tProfileSelect.ini.group[2]] end
				if tSavedData.settings.profileselector[tProfileSelect.ini.group[3]] ~= nil then self.settings.profileselector[tProfileSelect.ini.group[3]] = tSavedData.settings.profileselector[tProfileSelect.ini.group[3]] end
				if tSavedData.settings.profileselector[tProfileSelect.ini.group[4]] ~= nil then self.settings.profileselector[tProfileSelect.ini.group[4]] = tSavedData.settings.profileselector[tProfileSelect.ini.group[4]] end
				if tSavedData.settings.profileselector[tProfileSelect.ini.raid]     ~= nil then self.settings.profileselector[tProfileSelect.ini.raid]     = tSavedData.settings.profileselector[tProfileSelect.ini.raid]     end
				if tSavedData.settings.profileselector[tProfileSelect.world.group]  ~= nil then self.settings.profileselector[tProfileSelect.world.group]  = tSavedData.settings.profileselector[tProfileSelect.world.group]  end
				if tSavedData.settings.profileselector[tProfileSelect.world.raid]   ~= nil then self.settings.profileselector[tProfileSelect.world.raid]   = tSavedData.settings.profileselector[tProfileSelect.world.raid]   end
			end

			if tSavedData.settings.profileselectorprofile ~= nil then
				self.settings.profileselectorprofile = tSavedData.settings.profileselectorprofile 
			end						
			
		end
		
		if tSavedData.profiles ~= nil then
		
			-- check if profile 1 has been deleted (forced creation at init)
			if tSavedData.profiles[1] == nil then self.profiles[1] = nil end
		
			for idx, profile in pairs(tSavedData.profiles) do
			
				-- Restore profiles and replace non existing values with default values
				self.profiles[idx] = {
					name = profile.name,
					settings = {},
				}
				self.profiles[idx].settings =  self:CopyTable(self.defaultprofile)
			
				if profile.settings ~= nil then
					-- replacing single values to not overwrite new default values by not existing values
					if profile.settings.fabkits ~= nil then
						if profile.settings.fabkits.quality ~= nil then self.profiles[idx].settings.fabkits.quality = profile.settings.fabkits.quality end
						if profile.settings.fabkits.below ~= nil then self.profiles[idx].settings.fabkits.below = profile.settings.fabkits.below end
						if profile.settings.fabkits.above ~= nil then self.profiles[idx].settings.fabkits.above = profile.settings.fabkits.above end
					end
					if profile.settings.decor ~= nil then
						if profile.settings.decor.quality ~= nil then self.profiles[idx].settings.decor.quality = profile.settings.decor.quality end
						if profile.settings.decor.below ~= nil then self.profiles[idx].settings.decor.below = profile.settings.decor.below end
						if profile.settings.decor.above ~= nil then self.profiles[idx].settings.decor.above = profile.settings.decor.above end
					end
					if profile.settings.fragments ~= nil then
						if profile.settings.fragments.all ~= nil then self.profiles[idx].settings.fragments.all = profile.settings.fragments.all end
					end
					if profile.settings.survivalist ~= nil then
						if profile.settings.survivalist.all ~= nil then self.profiles[idx].settings.survivalist.all = profile.settings.survivalist.all end
					end
					if profile.settings.equipment ~= nil then
					
						if profile.settings.equipment.quality ~= nil then self.profiles[idx].settings.equipment.quality = profile.settings.equipment.quality end
						if profile.settings.equipment.below ~= nil then self.profiles[idx].settings.equipment.below = profile.settings.equipment.below end
						if profile.settings.equipment.noneed ~= nil then self.profiles[idx].settings.equipment.noneed = profile.settings.equipment.noneed end
					end
					if profile.settings.sigils ~= nil then
						if profile.settings.sigils.quality ~= nil then self.profiles[idx].settings.sigils.quality = profile.settings.sigils.quality end
						if profile.settings.sigils.below ~= nil then self.profiles[idx].settings.sigils.below = profile.settings.sigils.below end
						if profile.settings.sigils.above ~= nil then self.profiles[idx].settings.sigils.above = profile.settings.sigils.above end
					end			
					if profile.settings.catalysts ~= nil then
						if profile.settings.catalysts.my ~= nil then
							if profile.settings.catalysts.my.quality ~= nil then self.profiles[idx].settings.catalysts.my.quality = profile.settings.catalysts.my.quality end
							if profile.settings.catalysts.my.below ~= nil then self.profiles[idx].settings.catalysts.my.below = profile.settings.catalysts.my.below end
							if profile.settings.catalysts.my.above ~= nil then self.profiles[idx].settings.catalysts.my.above = profile.settings.catalysts.my.above end
						end						
						if profile.settings.catalysts.other ~= nil then
							if profile.settings.catalysts.other.quality ~= nil then self.profiles[idx].settings.catalysts.other.quality = profile.settings.catalysts.other.quality end
							if profile.settings.catalysts.other.below ~= nil then self.profiles[idx].settings.catalysts.other.below = profile.settings.catalysts.other.below end
							if profile.settings.catalysts.other.above ~= nil then self.profiles[idx].settings.catalysts.other.above = profile.settings.catalysts.other.above end
						end						
					end
					if profile.settings.bags ~= nil then
						if profile.settings.bags.all ~= nil then self.profiles[idx].settings.bags.all = profile.settings.bags.all end
					end
					if profile.settings.scanbot ~= nil then
						if profile.settings.scanbot.all ~= nil then self.profiles[idx].settings.scanbot.all = profile.settings.scanbot.all end
					end
					if profile.settings.amps ~= nil then
						if profile.settings.amps.all ~= nil then self.profiles[idx].settings.amps.all = profile.settings.amps.all end
					end
					if profile.settings.schematics ~= nil then
						if profile.settings.schematics.all ~= nil then self.profiles[idx].settings.schematics.all = profile.settings.schematics.all end
					end
					if profile.settings.cloth ~= nil then
						if profile.settings.cloth.all ~= nil then self.profiles[idx].settings.cloth.all = profile.settings.cloth.all end
					end
					if profile.settings.dye ~= nil then
						if profile.settings.dye.all ~= nil then self.profiles[idx].settings.dye.all = profile.settings.dye.all end
					end
					if profile.settings.flux ~= nil then
						if profile.settings.flux.all ~= nil then self.profiles[idx].settings.flux.all = profile.settings.flux.all end
					end
					if profile.settings.prop ~= nil then
						if profile.settings.prop.all ~= nil then self.profiles[idx].settings.prop.all = profile.settings.prop.all end
					end
				end
						
				self.settings.profiles = self.settings.profiles + 1
				if idx > self.settings.lastprofile then
					self.settings.lastprofile = idx
				end
			end
		end
		
		
		if (tSavedData.settings == nil) or (tSavedData.settings.profiles == nil) then
			-- no profiles existing: first run or updated from old version
			-- can only be old version, because OnRestore isn't called at first start, because nothing gets loaded!
			-- create default profile in both cases
			self.profiles[1] = {
				name = L["default_profile"],
				settings = self:CopyTable(self.defaultprofile),
			}
			self.settings.profiles = 1
			self.settings.activeprofile = 1
			self.settings.lastprofile = 1
			
			local i
			for i = 1, 8, 1 do
				self.settings.profileselector[i] = 2
				self.settings.profileselectorprofile[i] = 1
			end
		
			-- check for existing values from old version and overwrite new profile with these values
			-- OLD ONES
			-- no need to expand
			if tSavedData.settings ~= nil then
				if tSavedData.settings.fabkits ~= nil then
					if tSavedData.settings.fabkits.quality ~= nil then self.profiles[1].settings.fabkits.quality = tSavedData.settings.fabkits.quality end
					if tSavedData.settings.fabkits.below ~= nil then self.profiles[1].settings.fabkits.below = tSavedData.settings.fabkits.below end
					if tSavedData.settings.fabkits.above ~= nil then self.profiles[1].settings.fabkits.above = tSavedData.settings.fabkits.above end
				end
				if tSavedData.settings.decor ~= nil then
					if tSavedData.settings.decor.quality ~= nil then self.profiles[1].settings.decor.quality = tSavedData.settings.decor.quality end
					if tSavedData.settings.decor.below ~= nil then self.profiles[1].settings.decor.below = tSavedData.settings.decor.below end
					if tSavedData.settings.decor.above ~= nil then self.profiles[1].settings.decor.above = tSavedData.settings.decor.above end
				end
				if tSavedData.settings.fragments ~= nil then
					if tSavedData.settings.fragments.all ~= nil then self.profiles[1].settings.fragments.all = tSavedData.settings.fragments.all end
				end
				if tSavedData.settings.survivalist ~= nil then
					if tSavedData.settings.survivalist.all ~= nil then self.profiles[1].settings.survivalist.all = tSavedData.settings.survivalist.all end
				end
				if tSavedData.settings.equipment ~= nil then
					if tSavedData.settings.equipment.quality ~= nil then self.profiles[1].settings.equipment.quality = tSavedData.settings.equipment.quality end
					if tSavedData.settings.equipment.below ~= nil then self.profiles[1].settings.equipment.below = tSavedData.settings.equipment.below end
					if tSavedData.settings.equipment.noneed ~= nil then self.profiles[1].settings.equipment.noneed = tSavedData.settings.equipment.noneed end
				end
				if tSavedData.settings.sigils ~= nil then
					if tSavedData.settings.sigils.quality ~= nil then self.profiles[1].settings.sigils.quality = tSavedData.settings.sigils.quality end
					if tSavedData.settings.sigils.below ~= nil then self.profiles[1].settings.sigils.below = tSavedData.settings.sigils.below end
					if tSavedData.settings.sigils.above ~= nil then self.profiles[1].settings.sigils.above = tSavedData.settings.sigils.above end
				end			
				if tSavedData.settings.catalysts ~= nil then
					if tSavedData.settings.catalysts.my ~= nil then
						if tSavedData.settings.catalysts.my.quality ~= nil then self.profiles[1].settings.catalysts.my.quality = tSavedData.settings.catalysts.my.quality end
						if tSavedData.settings.catalysts.my.below ~= nil then self.profiles[1].settings.catalysts.my.below = tSavedData.settings.catalysts.my.below end
						if tSavedData.settings.catalysts.my.above ~= nil then self.profiles[1].settings.catalysts.my.above = tSavedData.settings.catalysts.my.above end
					end						
					if tSavedData.settings.catalysts.other ~= nil then
						if tSavedData.settings.catalysts.other.quality ~= nil then self.profiles[1].settings.catalysts.other.quality = tSavedData.settings.catalysts.other.quality end
						if tSavedData.settings.catalysts.other.below ~= nil then self.profiles[1].settings.catalysts.other.below = tSavedData.settings.catalysts.other.below end
						if tSavedData.settings.catalysts.other.above ~= nil then self.profiles[1].settings.catalysts.other.above = tSavedData.settings.catalysts.other.above end
					end						
				end
				if tSavedData.settings.bags ~= nil then
					if tSavedData.settings.bags.all ~= nil then self.profiles[1].settings.bags.all = tSavedData.settings.bags.all end
				end
				if tSavedData.settings.amps ~= nil then
					if tSavedData.settings.amps.all ~= nil then self.profiles[1].settings.amps.all = tSavedData.settings.amps.all end
				end
				if tSavedData.settings.schematics ~= nil then
					if tSavedData.settings.schematics.all ~= nil then self.profiles[1].settings.schematics.all = tSavedData.settings.schematics.all end
				end
				if tSavedData.settings.cloth ~= nil then
					if tSavedData.settings.cloth.all ~= nil then self.profiles[1].settings.cloth.all = tSavedData.settings.cloth.all end
				end
				if tSavedData.settings.dye ~= nil then
					if tSavedData.settings.dye.all ~= nil then self.profiles[1].settings.dye.all = tSavedData.settings.dye.all end
				end
				if tSavedData.settings.flux ~= nil then
					if tSavedData.settings.flux.all ~= nil then self.profiles[1].settings.flux.all = tSavedData.settings.flux.all end
				end
				if tSavedData.settings.prop ~= nil then
					if tSavedData.settings.prop.all ~= nil then self.profiles[1].settings.prop.all = tSavedData.settings.prop.all end
				end
			end
					
		end
	
		self:CheckProfileSelector()
	end
end


function AfLogicLoot:OnLootRollUpdate()
	if not self.settings.active then return end
	for _, LootListEntry in pairs(GameLib.GetLootRolls()) do
		self:CheckForAutoAction(LootListEntry)
	end
end


function AfLogicLoot:PostLootMessage(uItem, iChoice, strCategory)
	if iChoice == LootAction.none then return end
	if not self.settings.log then return end
	
	local strMessage = L["msg_action_log_sentence"]
	
	if iChoice == LootAction.need then strMessage = strMessage:gsub("%[ACTION%]", L["msg_action_log_sentence_need"]) end
	if iChoice == LootAction.greed then strMessage = strMessage:gsub("%[ACTION%]", L["msg_action_log_sentence_greed"]) end
	if iChoice == LootAction.pass then strMessage = strMessage:gsub("%[ACTION%]", L["msg_action_log_sentence_pass"]) end
	strMessage = strMessage:gsub("%[ITEM%]", uItem:GetChatLinkString())
	strMessage = strMessage:gsub("%[CATEGORY%]", strCategory)
	self:log(strMessage)
end


function AfLogicLoot:CheckForAutoAction(LootListEntry)
	local item = LootListEntry.itemDrop
	local lootid = LootListEntry.nLootId
	
	local category = item:GetItemCategory()
	local family = item:GetItemFamily()
	local quality = toItemQuality[item:GetItemQuality()]
	local itype = item:GetItemType()
	local itemid = item:GetItemId()
	
	-- Decor
	if (itype == 155) then
		if quality <= self.profiles[self.settings.activeprofile].settings.decor.quality then
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.decor.below)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.decor.below, L["decor_headline"]..", "..L["msg_action_log_sentence_quality_below"])
		else
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.decor.above)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.decor.above, L["decor_headline"]..", "..L["msg_action_log_sentence_quality_above"])
		end
		return
	end

	-- Fabkits
	if (itype == 164) then
		if quality <= self.profiles[self.settings.activeprofile].settings.fabkits.quality then
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.fabkits.below)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.fabkits.below, L["fabkits_headline"]..", "..L["msg_action_log_sentence_quality_below"])
		else
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.fabkits.above)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.fabkits.above, L["fabkits_headline"]..", "..L["msg_action_log_sentence_quality_above"])
		end
		return
	end	
		
	-- Fragments
	if (itype == 359) then
		self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.fragments.all)
		self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.fragments.all, L["fragments_headline"])
		return
	end

	-- Sigils
	if (category == 120) then
		if quality <= self.profiles[self.settings.activeprofile].settings.sigils.quality then
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.sigils.below)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.sigils.below, L["sigils_headline"]..", "..L["msg_action_log_sentence_quality_below"])
		else
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.sigils.above)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.sigils.above, L["sigils_headline"]..", "..L["msg_action_log_sentence_quality_above"])
		end		
		return
	end
		
	-- Survivalist
	if (category == 110) then
		self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.survivalist.all)
		self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.survivalist.all, L["survivalist_headline"])
		return
	end
	
	-- Cloth
	if (category == 113) then
		self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.cloth.all)
		self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.cloth.all, L["cloth_headline"])
		return
	end
	
	-- Dye
	--  dye collection    dye               dye loot bag
	if (itype == 349) or (itype == 332) or (itype == 450) then
		self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.dye.all)
		self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.dye.all, L["dye_headline"])
		return
	end
		
	-- Flux
	if (itype == 465) then
		self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.flux.all)
		self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.flux.all, L["flux_headline"])
		return
	end
	
	-- Proprietary Material
	if (category == 128) then
		self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.prop.all)
		self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.prop.all, L["prop_headline"])
		return
	end
	
	-- Bags
	if (itype == 134) then
		self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.bags.all)
		self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.bags.all, L["bags_headline"])
		return
	end
	
	-- Scanbot Vanity
	local vanityid = 0
	local vanity = {
		31452, -- Aviator Goggles
		31455, -- Exhaust
		31446, -- Fez
		31454, -- Beer Hat
		31449, -- Pirate Hat
		31456, -- Bow
		31457, -- Brain Tank
		31451, -- Chua Ears
		31450, -- Miner Hat
		31447, -- Tesla
		31448, -- TV Antenna
		31445, -- Satellite Dish
		31453, -- Aurin Ears
	}
	for _,vanityid in pairs(vanity) do
		if itemid == vanityid then
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.scanbot.all)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.scanbot.all, L["scanbot_headline"])
			return
		end
	end
	vanity = nil
	
	-- AMPs and Schematics
	if (family == 32) or (familiy == 19) then
		local tItemDI = item:GetDetailedInfo().tPrimary
		local bNeed = false
		
		if (tItemDI.arSpells and tItemDI.arClassRequirement and tItemDI.arClassRequirement.bRequirementMet) or (tItemDI.arTradeskillReqs and tItemDI.arTradeskillReqs[1].bCanLearn) then		
			bNeed = true
			-- ignore level requirement? yes, i think it's better.
			if (tItemDI.arSpells and tItemDI.arSpells[1].strFailure) or (tItemDI.arTradeskillReqs and tItemDI.arTradeskillReqs[1].bIsKnown) then
	            bNeed = false
	        end
		end
		if bNeed then
			self:DoLootAction(lootid, LootAction.need)
			self:PostLootMessage(item, LootAction.need, L["useful_amps_schematics"])
		else
			if (family == 32) then
				self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.amps.all)
				self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.amps.all, L["amps_headline"])
			else
				self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.schematics.all)
				self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.schematics.all, L["schematics_headline"])
			end
		end
		
		return
	end
	
	-- Catalysts (Technologist == Augmentor)
	--  Architect         Technologist      Cook
	if (itype == 320) or (itype == 321) or (itype == 322) then
		local tTradeskills = CraftingLib.GetKnownTradeskills()
		local bCouldUse = false
		for _, tVal in pairs(tTradeskills) do
			if (((tVal.eId == CraftingLib.CodeEnumTradeskill.Architect) and (itype == 320)) or
			    ((tVal.eId == CraftingLib.CodeEnumTradeskill.Augmentor) and (itype == 321)) or 
			    ((tVal.eId == CraftingLib.CodeEnumTradeskill.Cooking)   and (itype == 322))) then
				bCouldUse = true
			end
		end
		if bCouldUse then
			if quality <= self.profiles[self.settings.activeprofile].settings.catalysts.my.quality then
				self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.catalysts.my.below)
				self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.catalysts.my.below, L["catalysts_my_headline"]..", "..L["msg_action_log_sentence_quality_below"])
			else
				self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.catalysts.my.above)
				self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.catalysts.my.above, L["catalysts_my_headline"]..", "..L["msg_action_log_sentence_quality_above"])
			end		
		else
			if quality <= self.profiles[self.settings.activeprofile].settings.catalysts.other.quality then
				self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.catalysts.other.below)
				self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.catalysts.other.below, L["catalysts_other_headline"]..", "..L["msg_action_log_sentence_quality_below"])
			else
				self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.catalysts.other.above)
				self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.catalysts.other.above, L["catalysts_other_headline"]..", "..L["msg_action_log_sentence_quality_above"])
			end				
		end
		return
	end
		
	-- Equipment
	--  Armor            Weapon           Gear
	if (family == 1) or (family == 2) or (family == 15) then
		if not GameLib.IsNeedRollAllowed(lootid) then
			self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.equipment.noneed)
			self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.equipment.noneed, L["equipment_headline"]..", "..L["equipment_not_wearable"])
		else
			if item:IsEquippable() then
				if quality <= self.profiles[self.settings.activeprofile].settings.equipment.quality then
					self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.equipment.below)
					self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.equipment.below, L["equipment_headline"]..", "..L["msg_action_log_sentence_quality_below"])
				end
			else
				-- does this ever fire?
				self:DoLootAction(lootid, self.profiles[self.settings.activeprofile].settings.equipment.noneed)
				self:PostLootMessage(item, self.profiles[self.settings.activeprofile].settings.equipment.noneed, L["equipment_headline"]..", "..L["equipment_not_wearable"])
			end
		end
		return
	end
	
	-- Not categorized now: analyze it
	-- self:analyze(item)
end


function AfLogicLoot:DoLootAction(LootID, action)
	if action == LootAction.need then
		GameLib.RollOnLoot(LootID, true)
	elseif action == LootAction.greed then
		GameLib.RollOnLoot(LootID, false)
	elseif action == LootAction.pass then
		GameLib.PassOnLoot(LootID)
	end
	if action == LootAction.none then return end
	self:CloseOrgLootWindow(LootID)
end


function AfLogicLoot:CloseOrgLootWindow(LootID)
	if self.crbAddon ~= nil then
		local crbWindow = self.crbAddon.wndMain
		if not crbWindow then return end
		if crbWindow:GetData() == LootID then
			crbWindow:Close()
		end
	end
end


function AfLogicLoot:analyze(item)
	self:log("ITM: "..item:GetItemId().." "..item:GetName())
	self:log("CAT: "..item:GetItemCategory().." "..item:GetItemCategoryName())
	self:log("FAM: "..item:GetItemFamily().." "..item:GetItemFamilyName())
	self:log("TYP: "..item:GetItemType().." "..item:GetItemTypeName())
	self:log("---")
end


function AfLogicLoot:OnTimer()
	self:ChoseProfile()
end


function AfLogicLoot:log(strMeldung)
	if strMeldung == nil then strMeldung = "nil" end
	ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_System, strMeldung, "afLogicLoot")
end


function AfLogicLoot:SetStatus(bActive)
	local wndToggleButton1 = self.wndMain:FindChild("btnToggleButton1")
	local wndToggleButton2 = self.wndMain:FindChild("btnToggleButton2")
	self.settings.active = bActive
	wndToggleButton1:Show(bActive)
	wndToggleButton2:Show(bActive == false)
	if bActive then
		self:log(L["msg_activated"])
	else
		self:log(L["msg_deactivated"])
	end
end


function AfLogicLoot:AddProfile()
	local wndInput = self.wndMain:FindChild("txt_profile_name")
	local strName = wndInput:GetText()
	if strName:len() == 0 then
		self:log(L["msg_error_name_missing"])
		return
	end
	
	self.settings.lastprofile = self.settings.lastprofile + 1
	self.profiles[self.settings.lastprofile] = {
		name = strName,
		settings = self:CopyTable(self.defaultprofile),
	}
	self.settings.profiles = self.settings.profiles + 1
	self.settings.activeprofile = self.settings.lastprofile
	self:GUIToSettings()
	self:LoadProfiles()
	wndInput:SetText("")
end


function AfLogicLoot:LoadProfiles()
	local wndContainer = self.wndMain:FindChild("frm_profiles")
	local wndPopupContainer = self.wndMain:FindChild("frm_profiles_dropup")
	
	wndContainer:DestroyChildren()
	wndPopupContainer:DestroyChildren()
	
	for idx, tProfile in pairs(self.profiles) do
		-- Profile deletion
		local wndEntry = Apollo.LoadForm(self.xmlDoc, "frm_entry_profiles", wndContainer, self)
		wndEntry:FindChild("lbl_entry_name"):SetText(tProfile.name)
		wndEntry:FindChild("btn_delete"):SetData(idx)
		wndEntry:FindChild("btn_delete"):SetTooltip(L["profile_delete"])
		-- Profile selector
		local wndEntry = Apollo.LoadForm(self.xmlDoc, "frm_entry_single_profile", wndPopupContainer, self)
		local wndButton = wndEntry:FindChild("btn_entry")
		wndButton:SetText(tProfile.name)
		wndButton:SetData(idx)
	end
		
	wndContainer:ArrangeChildrenVert()
	wndPopupContainer:ArrangeChildrenVert()	
	
	self.wndMain:FindChild("frm_combobox_selector"):FindChild("btn_text"):SetText(self.profiles[self.settings.activeprofile].name)
end


function AfLogicLoot:HudLog(strMessage)
	self.hudlast = self.hudlast + 1
	self.hudqueue[self.hudlast] = strMessage
	if not self.wndHud:IsVisible() then
		self:NextHudLog()
	end
	return
end


function AfLogicLoot:OnHudLogTimer()
	self.hudcounter = self.hudcounter - 1
	if self.hudcounter <= 0 then
		self:NextHudLog()
	end
end


function AfLogicLoot:NextHudLog()
	if self.hudid == self.hudlast then
		self.wndHud:Show(false)
		self.hudtimer:Stop()
		return
	end
	self.hudid = self.hudid + 1
	self.wndHud:SetText(self.hudqueue[self.hudid])
	self.wndHud:ToFront()
	if self.wndHud:IsVisible() then
		self.hudcounter = 5
	else
		self.hudcounter = 15
	end
	self.wndHud:Show(true)
	self.hudtimer:Start()
	Sound.PlayFile("./sounds/chatnotify.wav")
end


-----------------------------------------------------------------------------------------------
-- AfLogicLootForm Functions
-----------------------------------------------------------------------------------------------

function AfLogicLoot:OnOK()
	self:GUIToSettings()
	self.wndMain:Close()
end


function AfLogicLoot:OnCancel()
	self.wndMain:Close()
end


function AfLogicLoot:OnTabSelected(wndHandler, wndControl, eMouseButton)
	local iTab = self.wndMain:GetRadioSel("tabs")
	self:SwitchToTab(iTab)
end


function AfLogicLoot:SwitchToTab(iTab)
	self.wndMain:FindChild("Tab_Equipment1"):Show(iTab == 1)
	self.wndMain:FindChild("Tab_Equipment2"):Show(iTab == 2)
	self.wndMain:FindChild("Tab_Style"):Show(iTab == 3)
	self.wndMain:FindChild("Tab_Crafting"):Show(iTab == 4)
	self.wndMain:FindChild("Tab_Profiles"):Show(iTab == 5)
end


function AfLogicLoot:ToggleStatus(wndHandler, wndControl, eMouseButton)
	self:SetStatus(not self.settings.active)
end


function AfLogicLoot:OnAddProfile(wndHandler, wndControl, eMouseButton)
	self:AddProfile()
end


function AfLogicLoot:OnProfileCombobox(wndHandler, wndControl, eMouseButton)
	local wndComboboxPopup = self.wndMain:FindChild("frm_combobox_popup")
	wndComboboxPopup:Show(wndComboboxPopup:IsShown() == false)
end


function AfLogicLoot:OnAssignProfile(wndHandler, wndControl, eMouseButton)
	local iProfile = wndControl:GetData()
	self.settings.profileselectorprofile[iProfile] = self.settings.activeprofile
	self.settings.profileselector[iProfile] = 2
	self:RefreshProfileSelectorDisplay()
end


---------------------------------------------------------------------------------------------------
-- frm_entry_single_profile Functions
---------------------------------------------------------------------------------------------------

function AfLogicLoot:OnComboboxEntry(wndHandler, wndControl, eMouseButton)
	local wndComboboxPopup = self.wndMain:FindChild("frm_combobox_popup")
	wndComboboxPopup:Show(false)
	self.settings.activeprofile = wndControl:GetData()
	self:SettingsToGUI()
end


---------------------------------------------------------------------------------------------------
-- frm_entry_profiles Functions
---------------------------------------------------------------------------------------------------

function AfLogicLoot:OnDeleteProfile(wndHandler, wndControl, eMouseButton)
	-- wndControl:GetParent():Destroy()
	local iID = wndControl:GetData()
	if iID == self.settings.activeprofile then
		self:log(L["msg_error_no_delete"])
		return
	end
	if self.settings.profiles == 1 then
		-- shouldn't fire and therefore make self.settings.profiles unneccessary - ach ja? komm doch her!
		self:log(L["msg_error_keep_last"])
		return
	end
	self.profiles[iID] = nil
	self.settings.profiles = self.settings.profiles - 1
	self:LoadProfiles()
	self:CheckProfileSelector()
	self:RefreshProfileSelectorDisplay()
end


-----------------------------------------------------------------------------------------------
-- AfLogicLoot Instance
-----------------------------------------------------------------------------------------------
local AfLogicLootInst = AfLogicLoot:new()
AfLogicLootInst:Init()
