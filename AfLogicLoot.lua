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
		log = true,
		decor = {
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
		self.wndMain:FindChild("btn_equipment1"):SetCheck(true)
		self:SwitchToTab(1)
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
	self.wndMain:FindChild("chk_log"):SetCheck(self.settings.log)
	self.wndMain:FindChild("frm_decor"):FindChild("frm_quality"):SetRadioSel("decor_quality", self.settings.decor.quality)
	self.wndMain:FindChild("frm_decor"):FindChild("frm_action_below"):SetRadioSel("decor_below", self.settings.decor.below)
	self.wndMain:FindChild("frm_decor"):FindChild("frm_action_above"):SetRadioSel("decor_above", self.settings.decor.above)
	self.wndMain:FindChild("frm_fragments"):FindChild("frm_action"):SetRadioSel("fragments_all", self.settings.fragments.all)
	self.wndMain:FindChild("frm_survivalist"):FindChild("frm_action"):SetRadioSel("survivalist_all", self.settings.survivalist.all)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_quality"):SetRadioSel("equipment_quality", self.settings.equipment.quality)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_action"):SetRadioSel("equipment_below", self.settings.equipment.below - 1)
	self.wndMain:FindChild("frm_equip"):FindChild("frm_action_noneed"):SetRadioSel("equipment_noneed", self.settings.equipment.noneed - 1)
	self.wndMain:FindChild("frm_sigils"):FindChild("frm_quality"):SetRadioSel("sigil_quality", self.settings.sigils.quality)
	self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_below"):SetRadioSel("sigil_below", self.settings.sigils.below)
	self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_above"):SetRadioSel("sigil_above", self.settings.sigils.above)
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_quality"):SetRadioSel("catalyst_quality_my", self.settings.catalysts.my.quality)
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_below"):SetRadioSel("catalyst_my_below", self.settings.catalysts.my.below)
	self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_above"):SetRadioSel("catalyst_my_above", self.settings.catalysts.my.above)
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_quality"):SetRadioSel("catalyst_quality_other", self.settings.catalysts.other.quality)
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_below"):SetRadioSel("catalyst_other_below", self.settings.catalysts.other.below)
	self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_above"):SetRadioSel("catalyst_other_above", self.settings.catalysts.other.above)
	self.wndMain:FindChild("frm_bags"):FindChild("frm_action"):SetRadioSel("bags_all", self.settings.bags.all)
	self.wndMain:FindChild("frm_amps"):FindChild("frm_action"):SetRadioSel("amps_all", self.settings.amps.all)
	self.wndMain:FindChild("frm_schematics"):FindChild("frm_action"):SetRadioSel("schematics_all", self.settings.schematics.all)
	self.wndMain:FindChild("frm_cloth"):FindChild("frm_action"):SetRadioSel("cloth_all", self.settings.cloth.all)
	self.wndMain:FindChild("frm_dye"):FindChild("frm_action"):SetRadioSel("dye_all", self.settings.dye.all)
	self.wndMain:FindChild("frm_flux"):FindChild("frm_action"):SetRadioSel("flux_all", self.settings.flux.all)
	self.wndMain:FindChild("frm_prop"):FindChild("frm_action"):SetRadioSel("prop_all", self.settings.prop.all)
end


function AfLogicLoot:GUIToSettings()
	self.settings.log = self.wndMain:FindChild("chk_log"):IsChecked()
	self.settings.decor.quality = self.wndMain:FindChild("frm_decor"):FindChild("frm_quality"):GetRadioSel("decor_quality")
	self.settings.decor.below = self.wndMain:FindChild("frm_decor"):FindChild("frm_action_below"):GetRadioSel("decor_below")
	self.settings.decor.above = self.wndMain:FindChild("frm_decor"):FindChild("frm_action_above"):GetRadioSel("decor_above")
	self.settings.fragments.all = self.wndMain:FindChild("frm_fragments"):FindChild("frm_action"):GetRadioSel("fragments_all")
	self.settings.survivalist.all = self.wndMain:FindChild("frm_survivalist"):FindChild("frm_action"):GetRadioSel("survivalist_all")
	self.settings.equipment.quality = self.wndMain:FindChild("frm_equip"):FindChild("frm_quality"):GetRadioSel("equipment_quality")
	self.settings.equipment.below = self.wndMain:FindChild("frm_equip"):FindChild("frm_action"):GetRadioSel("equipment_below") + 1
	self.settings.equipment.noneed = self.wndMain:FindChild("frm_equip"):FindChild("frm_action_noneed"):GetRadioSel("equipment_noneed") + 1
	self.settings.sigils.quality = self.wndMain:FindChild("frm_sigils"):FindChild("frm_quality"):GetRadioSel("sigil_quality")
	self.settings.sigils.below = self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_below"):GetRadioSel("sigil_below")
	self.settings.sigils.above = self.wndMain:FindChild("frm_sigils"):FindChild("frm_action_above"):GetRadioSel("sigil_above")	
	self.settings.catalysts.my.quality = self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_quality"):GetRadioSel("catalyst_quality_my")
	self.settings.catalysts.my.below = self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_below"):GetRadioSel("catalyst_my_below")
	self.settings.catalysts.my.above = self.wndMain:FindChild("frm_catalysts_my"):FindChild("frm_action_above"):GetRadioSel("catalyst_my_above")
	self.settings.catalysts.other.quality = self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_quality"):GetRadioSel("catalyst_quality_other")
	self.settings.catalysts.other.below = self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_below"):GetRadioSel("catalyst_other_below")
	self.settings.catalysts.other.above = self.wndMain:FindChild("frm_catalysts_other"):FindChild("frm_action_above"):GetRadioSel("catalyst_other_above")
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
			if tSavedData.settings.log ~= nil then self.settings.log = tSavedData.settings.log end
			if tSavedData.settings.decor ~= nil then
				if tSavedData.settings.decor.quality ~= nil then self.settings.decor.quality = tSavedData.settings.decor.quality end
				if tSavedData.settings.decor.below ~= nil then self.settings.decor.below = tSavedData.settings.decor.below end
				if tSavedData.settings.decor.above ~= nil then self.settings.decor.above = tSavedData.settings.decor.above end
			end
			if tSavedData.settings.fragments ~= nil then
				if tSavedData.settings.fragments.all ~= nil then self.settings.fragments.all = tSavedData.settings.fragments.all end
			end
			if tSavedData.settings.survivalist ~= nil then
				if tSavedData.settings.survivalist.all ~= nil then self.settings.survivalist.all = tSavedData.settings.survivalist.all end
			end
			if tSavedData.settings.equipment ~= nil then
				if tSavedData.settings.equipment.quality ~= nil then self.settings.equipment.quality = tSavedData.settings.equipment.quality end
				if tSavedData.settings.equipment.below ~= nil then self.settings.equipment.below = tSavedData.settings.equipment.below end
				if tSavedData.settings.equipment.noneed ~= nil then self.settings.equipment.noneed = tSavedData.settings.equipment.noneed end
			end
			if tSavedData.settings.sigils ~= nil then
				if tSavedData.settings.sigils.quality ~= nil then self.settings.sigils.quality = tSavedData.settings.sigils.quality end
				if tSavedData.settings.sigils.below ~= nil then self.settings.sigils.below = tSavedData.settings.sigils.below end
				if tSavedData.settings.sigils.above ~= nil then self.settings.sigils.above = tSavedData.settings.sigils.above end
			end			
			if tSavedData.settings.catalysts ~= nil then
				if tSavedData.settings.catalysts.my ~= nil then
					if tSavedData.settings.catalysts.my.quality ~= nil then self.settings.catalysts.my.quality = tSavedData.settings.catalysts.my.quality end
					if tSavedData.settings.catalysts.my.below ~= nil then self.settings.catalysts.my.below = tSavedData.settings.catalysts.my.below end
					if tSavedData.settings.catalysts.my.above ~= nil then self.settings.catalysts.my.above = tSavedData.settings.catalysts.my.above end
				end						
				if tSavedData.settings.catalysts.other ~= nil then
					if tSavedData.settings.catalysts.other.quality ~= nil then self.settings.catalysts.other.quality = tSavedData.settings.catalysts.other.quality end
					if tSavedData.settings.catalysts.other.below ~= nil then self.settings.catalysts.other.below = tSavedData.settings.catalysts.other.below end
					if tSavedData.settings.catalysts.other.above ~= nil then self.settings.catalysts.other.above = tSavedData.settings.catalysts.other.above end
				end						
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


function AfLogicLoot:PostLootMessage(uItem, iChoice, strCategory)
	if iChoice == LootAction.none then return end
	if not self.settings.log then return end
	
	local strMessage = "Selecting "
	if iChoice == LootAction.need then strMessage = strMessage .. "NEED" end
	if iChoice == LootAction.greed then strMessage = strMessage .. "GREED" end
	strMessage = strMessage .. " "
	if iChoice == LootAction.pass then strMessage = "PASSING " end
	strMessage = strMessage .. "on ".. uItem:GetChatLinkString() .. " from category " .. strCategory
	self:log(strMessage)
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
			self:PostLootMessage(item, self.settings.decor.below, "Decor of and below selected quality")
		else
			self:DoLootAction(lootid, self.settings.decor.above)
			self:PostLootMessage(item, self.settings.decor.above, "Decor above selected quality")
		end
		return
	end
	
	-- Fragments
	if (itype == 359) then
		self:DoLootAction(lootid, self.settings.fragments.all)
		self:PostLootMessage(item, self.settings.fragments.all, "Fragments")
		return
	end

	-- Sigils
	if (category == 120) then
		if quality <= self.settings.sigils.quality then
			self:DoLootAction(lootid, self.settings.sigils.below)
			self:PostLootMessage(item, self.settings.sigils.below, "Sigils of and below selected quality")
		else
			self:DoLootAction(lootid, self.settings.sigils.above)
			self:PostLootMessage(item, self.settings.sigils.above, "Sigils above selected quality")
		end		
		return
	end
		
	-- Survivalist
	if (category == 110) then
		self:DoLootAction(lootid, self.settings.survivalist.all)
		self:PostLootMessage(item, self.settings.survivalist.all, "Survivalist")
		return
	end
	
	-- Cloth
	if (category == 113) then
		self:DoLootAction(lootid, self.settings.cloth.all)
		self:PostLootMessage(item, self.settings.cloth.all, "Cloth")
		return
	end
	
	-- Dye
	--  dye collection    dye
	if (itype == 349) or (itype == 332) then
		self:DoLootAction(lootid, self.settings.dye.all)
		self:PostLootMessage(item, self.settings.dye.all, "Dye")
		return
	end
		
	-- Flux
	if (itype == 465) then
		self:DoLootAction(lootid, self.settings.flux.all)
		self:PostLootMessage(item, self.settings.flux.all, "Runic Flux")
		return
	end
	
	-- Proprietary Material
	if (category == 128) then
		self:DoLootAction(lootid, self.settings.prop.all)
		self:PostLootMessage(item, self.settings.runes.all, "Proprietary Material")
		return
	end
	
	-- Bags
	if (itype == 134) then
		self:DoLootAction(lootid, self.settings.bags.all)
		self:PostLootMessage(item, self.settings.runes.all, "Bags")
		return
	end
	
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
			self:PostLootMessage(item, LootAction.need, "AMP and Schematics you don't already own")
		else
			if (family == 32) then
				self:DoLootAction(lootid, self.settings.amps.all)
				self:PostLootMessage(item, self.settings.amps.all, "AMP")
			else
				self:DoLootAction(lootid, self.settings.schematics.all)
				self:PostLootMessage(item, self.settings.schematics.all, "Schematics")
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
			if quality <= self.settings.catalysts.my.quality then
				self:DoLootAction(lootid, self.settings.catalysts.my.below)
				self:PostLootMessage(item, self.settings.catalysts.my.below, "useful catalysts below selected quality")
			else
				self:DoLootAction(lootid, self.settings.catalysts.my.above)
				self:PostLootMessage(item, self.settings.catalysts.my.above, "useful catalysts above selected quality")
			end		
		else
			if quality <= self.settings.catalysts.other.quality then
				self:DoLootAction(lootid, self.settings.catalysts.other.below)
				self:PostLootMessage(item, self.settings.catalysts.other.below, "other catalysts below selected quality")
			else
				self:DoLootAction(lootid, self.settings.catalysts.other.above)
				self:PostLootMessage(item, self.settings.catalysts.other.above, "other catalysts above selected quality")
			end				
		end
		return
	end
		
	-- Equipment
	--  Armor            Weapon           Gear
	if (family == 1) or (family == 2) or (family == 15) then
		if not GameLib.IsNeedRollAllowed(lootid) then
			self:DoLootAction(lootid, self.settings.equipment.noneed)
			self:PostLootMessage(item, self.settings.equipment.noneed, "Equipment, not needable")
		else
			if item:IsEquippable() then
				if quality <= self.settings.equipment.quality then
					self:DoLootAction(lootid, self.settings.equipment.below)
					self:PostLootMessage(item, self.settings.equipment.below, "Equipment")
				end
			else
				-- does this ever fire?
				self:DoLootAction(lootid, self.settings.equipment.noneed)
				self:PostLootMessage(item, self.settings.equipment.noneed, "Equipment, not wearable")
			end
		end
		return
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


function AfLogicLoot:OnTabSelected(wndHandler, wndControl, eMouseButton)
	local iTab = self.wndMain:GetRadioSel("tabs")
	self:SwitchToTab(iTab)
end


function AfLogicLoot:SwitchToTab(iTab)
	self.wndMain:FindChild("Tab_Equipment1"):Show(iTab == 1)
	self.wndMain:FindChild("Tab_Equipment2"):Show(iTab == 2)
	self.wndMain:FindChild("Tab_Style"):Show(iTab == 3)
	self.wndMain:FindChild("Tab_Crafting"):Show(iTab == 4)
end

-----------------------------------------------------------------------------------------------
-- AfLogicLoot Instance
-----------------------------------------------------------------------------------------------
local AfLogicLootInst = AfLogicLoot:new()
AfLogicLootInst:Init()
