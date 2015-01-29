-----------------------------------------------------------------------------------------------
-- Client Lua Script for AfLogicLoot
-- Copyright (c) NCsoft. All rights reserved
-----------------------------------------------------------------------------------------------
 
require "Window"
 
-----------------------------------------------------------------------------------------------
-- AfLogicLoot Module Definition
-----------------------------------------------------------------------------------------------
local AfLogicLoot = {} 
 
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


-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

function AfLogicLoot:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self 

    -- default settings
	o.settings = {
		decor = {
			quality = ItemQuality.inferior,
			below = LootAction.none,
			above = LootAction.none,
		},
		runes = {
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
		bags = {
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

		-- if the xmlDoc is no longer needed, you should set it to nil
		-- self.xmlDoc = nil
		
		-- Register handlers for events, slash commands and timer, etc.
		-- e.g. Apollo.RegisterEventHandler("KeyDown", "OnKeyDown", self)
		Apollo.RegisterSlashCommand("afloot", "OnAfLogicLootOn", self)

		self.timer = ApolloTimer.Create(15.0, false, "OnTimer", self)

		Apollo.RegisterEventHandler("LootRollUpdate", "OnLootRollUpdate", self)
		self.crbAddon = Apollo.GetAddon("NeedVsGreed")
		
		self.wndMain:FindChild("lbl_version"):SetText(strVersion)
		
		if not self.settings.firstconfigureshown then
			self:OnConfigure()
			self.settings.firstconfigureshown = true
		end
	end
end


-----------------------------------------------------------------------------------------------
-- AfLogicLoot Functions
-----------------------------------------------------------------------------------------------

function AfLogicLoot:OnAfLogicLootOn(strCommand, strParam)
	local item = Item.GetDataFromId(strParam)
	if item ~= nil then
		self:analyze(item)
	else
		self.wndMain:Invoke()
		self:SettingsToGUI()
	end
end


function AfLogicLoot:OnConfigure()
	self.wndMain:Invoke()
	self:SettingsToGUI()
end


function AfLogicLoot:SettingsToGUI()
	self.wndMain:FindChild("frm_decor"):FindChild("frm_quality"):SetRadioSel("decor_quality", self.settings.decor.quality)
	self.wndMain:FindChild("frm_decor"):FindChild("frm_action_below"):SetRadioSel("decor_below", self.settings.decor.below)
	self.wndMain:FindChild("frm_decor"):FindChild("frm_action_above"):SetRadioSel("decor_above", self.settings.decor.above)
	self.wndMain:FindChild("frm_runes"):FindChild("frm_action"):SetRadioSel("runes_all", self.settings.runes.all)
	self.wndMain:FindChild("frm_survivalist"):FindChild("frm_action"):SetRadioSel("survivalist_all", self.settings.survivalist.all)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_quality"):SetRadioSel("equipment_quality", self.settings.equipment.quality)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_action"):SetRadioSel("equipment_below", self.settings.equipment.below - 1)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_action_noneed"):SetRadioSel("equipment_noneed", self.settings.equipment.noneed - 1)
	self.wndMain:FindChild("frm_bags"):FindChild("frm_action"):SetRadioSel("bags_all", self.settings.bags.all)
	self.wndMain:FindChild("frm_amps"):FindChild("frm_action"):SetRadioSel("amps_all", self.settings.amps.all)
	self.wndMain:FindChild("frm_schematics"):FindChild("frm_action"):SetRadioSel("schematics_all", self.settings.schematics.all)
	self.wndMain:FindChild("frm_cloth"):FindChild("frm_action"):SetRadioSel("cloth_all", self.settings.cloth.all)
	self.wndMain:FindChild("frm_dye"):FindChild("frm_action"):SetRadioSel("dye_all", self.settings.dye.all)
	self.wndMain:FindChild("frm_flux"):FindChild("frm_action"):SetRadioSel("flux_all", self.settings.flux.all)
	self.wndMain:FindChild("frm_prop"):FindChild("frm_action"):SetRadioSel("prop_all", self.settings.prop.all)
end


function AfLogicLoot:GUIToSettings()
	self.settings.decor.quality = self.wndMain:FindChild("frm_decor"):FindChild("frm_quality"):GetRadioSel("decor_quality")
	self.settings.decor.below = self.wndMain:FindChild("frm_decor"):FindChild("frm_action_below"):GetRadioSel("decor_below")
	self.settings.decor.above = self.wndMain:FindChild("frm_decor"):FindChild("frm_action_above"):GetRadioSel("decor_above")
	self.settings.runes.all = self.wndMain:FindChild("frm_runes"):FindChild("frm_action"):GetRadioSel("runes_all")
	self.settings.survivalist.all = self.wndMain:FindChild("frm_survivalist"):FindChild("frm_action"):GetRadioSel("survivalist_all")
	self.settings.equipment.quality = self.wndMain:FindChild("frm_equip"):FindChild("frm_quality"):GetRadioSel("equipment_quality")
	self.settings.equipment.below = self.wndMain:FindChild("frm_equip"):FindChild("frm_action"):GetRadioSel("equipment_below") + 1
	self.settings.equipment.noneed = self.wndMain:FindChild("frm_equip"):FindChild("frm_action_noneed"):GetRadioSel("equipment_noneed") + 1
	self.settings.bags.all = self.wndMain:FindChild("frm_bags"):FindChild("frm_action"):GetRadioSel("bags_all")
	self.settings.amps.all = self.wndMain:FindChild("frm_amps"):FindChild("frm_action"):GetRadioSel("amps_all")
	self.settings.schematics.all = self.wndMain:FindChild("frm_schematics"):FindChild("frm_action"):GetRadioSel("schematics_all")
	self.settings.cloth.all = self.wndMain:FindChild("frm_cloth"):FindChild("frm_action"):GetRadioSel("cloth_all")
	self.settings.dye.all = self.wndMain:FindChild("frm_dye"):FindChild("frm_action"):GetRadioSel("dye_all")
	self.settings.flux.all = self.wndMain:FindChild("frm_flux"):FindChild("frm_action"):GetRadioSel("flux_all")
	self.settings.prop.all = self.wndMain:FindChild("frm_prop"):FindChild("frm_action"):GetRadioSel("prop_all")
end


function AfLogicLoot:OnSave(eType)
	-- really account-based? sounds reasonable at the moment
	if eType == GameLib.CodeEnumAddonSaveLevel.Account then
		local tSavedData = {}
		tSavedData.settings = self.settings
		return tSavedData		
	end
	return
end


function AfLogicLoot:OnRestore(eType, tSavedData)
	if eType == GameLib.CodeEnumAddonSaveLevel.Account then
		if tSavedData.settings ~= nil then
			-- replacing single values to not overwrite new default values by not existing values
			if tSavedData.settings.firstconfigureshown ~= nil then self.settings.firstconfigureshown = tSavedData.settings.firstconfigureshown end
			if tSavedData.settings.decor ~= nil then
				if tSavedData.settings.decor.quality ~= nil then self.settings.decor.quality = tSavedData.settings.decor.quality end
				if tSavedData.settings.decor.below ~= nil then self.settings.decor.below = tSavedData.settings.decor.below end
				if tSavedData.settings.decor.above ~= nil then self.settings.decor.above = tSavedData.settings.decor.above end
			end
			if tSavedData.settings.runes ~= nil then
				if tSavedData.settings.runes.all ~= nil then self.settings.runes.all = tSavedData.settings.runes.all end
			end
			if tSavedData.settings.survivalist ~= nil then
				if tSavedData.settings.survivalist.all ~= nil then self.settings.survivalist.all = tSavedData.settings.survivalist.all end
			end
			if tSavedData.settings.equipment ~= nil then
				if tSavedData.settings.equipment.quality ~= nil then self.settings.equipment.quality = tSavedData.settings.equipment.quality end
				if tSavedData.settings.equipment.below ~= nil then self.settings.equipment.below = tSavedData.settings.equipment.below end
				if tSavedData.settings.equipment.noneed ~= nil then self.settings.equipment.noneed = tSavedData.settings.equipment.noneed end
			end
			if tSavedData.settings.bags ~= nil then
				if tSavedData.settings.bags.all ~= nil then self.settings.bags.all = tSavedData.settings.bags.all end
			end
			if tSavedData.settings.amps ~= nil then
				if tSavedData.settings.amps.all ~= nil then self.settings.amps.all = tSavedData.settings.amps.all end
			end
			if tSavedData.settings.schematics ~= nil then
				if tSavedData.settings.schematics.all ~= nil then self.settings.schematics.all = tSavedData.settings.schematics.all end
			end
			if tSavedData.settings.cloth ~= nil then
				if tSavedData.settings.cloth.all ~= nil then self.settings.cloth.all = tSavedData.settings.cloth.all end
			end
			if tSavedData.settings.dye ~= nil then
				if tSavedData.settings.dye.all ~= nil then self.settings.dye.all = tSavedData.settings.dye.all end
			end
			if tSavedData.settings.flux ~= nil then
				if tSavedData.settings.flux.all ~= nil then self.settings.flux.all = tSavedData.settings.flux.all end
			end
			if tSavedData.settings.prop ~= nil then
				if tSavedData.settings.prop.all ~= nil then self.settings.prop.all = tSavedData.settings.prop.all end
			end
		end
		self:log(tostring(self.settings.firstconfigureshown))
	end
end


function AfLogicLoot:OnLootRollUpdate()
	for _, LootListEntry in pairs(GameLib.GetLootRolls()) do
		self:CheckForAutoAction(LootListEntry)
	end
end


function AfLogicLoot:CheckForAutoAction(LootListEntry)
	local item = LootListEntry.itemDrop
	local lootid = LootListEntry.nLootId
	
	local category = item:GetItemCategory()
	local family = item:GetItemFamily()
	local quality = toItemQuality[item:GetItemQuality()]
	local itype = item:GetItemType()
	
	-- Decor
	if (itype == 155) then
		if quality <= self.settings.decor.quality then
			self:DoLootAction(lootid, self.settings.decor.below)
			return
		else
			self:DoLootAction(lootid, self.settings.decor.above)
			return
		end
	end
	
	-- Runes and Fragments
	--  signs                rune fragments
	if (category == 120) or (itype == 359) then
		self:DoLootAction(lootid, self.settings.runes.all)
		return
	end
		
	-- Survivalist
	if (category == 110) then
		self:DoLootAction(lootid, self.settings.survivalist.all)
		return
	end
	
	-- Cloth
	if (category == 113) then
		self:DoLootAction(lootid, self.settings.cloth.all)
		return
	end
	
	-- Dye
	--  dye collection    dye
	if (itype == 349) or (itype == 332) then
		self:DoLootAction(lootid, self.settings.dye.all)
		return
	end
		
	-- Flux
	if (itype == 465) then
		self:DoLootAction(lootid, self.settings.flux.all)
		return
	end
	
	-- Proprietary Material
	if (category == 128) then
		self:DoLootAction(lootid, self.settings.prop.all)
		return
	end
	
	-- Bags
	if (itype == 134) then
		self:DoLootAction(lootid, self.settings.bags.all)
		return
	end
	
	-- AMPs and Schematics
	if (family == 32) or (familiy == 19) then
		local tItemDI = item:GetDetailedInfo().tPrimary
		local bNeed = false
		
		if (tItemDI.arSpells and tItemDI.arClassRequirement and tItemDI.arClassRequirement.bRequirementMet) or (tItemDI.arTradeskillReqs and tItemDI.arTradeskillReqs[1].bCanLearn) then		
			bNeed = true
			-- ignore level requirement? yes, i thing it's better.
			if (tItemDI.arSpells and tItemDI.arSpells[1].strFailure) or (tItemDI.arTradeskillReqs and tItemDI.arTradeskillReqs[1].bIsKnown) then
	            bNeed = false
	        end
		end
		
		if bNeed then
			self:DoLootAction(lootid, LootAction.need)
		else
			if (family == 32) then
				self:DoLootAction(lootid, self.settings.amps.all)
			else
				self:DoLootAction(lootid, self.settings.schematics.all)
			end
		end
		
		return
	end
	
	-- Equipment
	if not GameLib.IsNeedRollAllowed(lootid) then
		self:DoLootAction(lootid, self.settings.equipment.noneed)
		return
	else
		if item:IsEquippable() then
			if quality <= self.settings.equipment.quality then
				self:DoLootAction(lootid, self.settings.equipment.below)
			end
			return
		end
	end
	
	-- Not categorized now: analyze it
	self:analyze(item)
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
	self:log("ITEM: "..item:GetItemId().." "..item:GetName())
	self:log("CAT: "..item:GetItemCategory().." "..item:GetItemCategoryName())
	self:log("FAM: "..item:GetItemFamily().." "..item:GetItemFamilyName())
	self:log("TYP: "..item:GetItemType().." "..item:GetItemTypeName())
	self:log("---")
end


function AfLogicLoot:OnTimer()
end


function AfLogicLoot:log(strMeldung)
	if strMeldung == nil then strMeldung = "nil" end
	ChatSystemLib.PostOnChannel(ChatSystemLib.ChatChannel_System, strMeldung, "afLogicLoot")
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


-----------------------------------------------------------------------------------------------
-- AfLogicLoot Instance
-----------------------------------------------------------------------------------------------
local AfLogicLootInst = AfLogicLoot:new()
AfLogicLootInst:Init()
