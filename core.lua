---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ... -- namespace
ns.Core	= {} -- add the core to the namespace
local Core = ns.Core
local itemLocation = itemLocation or ItemLocation:CreateEmpty()
local Locale = GetLocale()
local L_Scrappable = {
	enGB = "Scrappable",
	enUS = "Scrappable",
	deDE = "Verschrottbar",
	frFR = "Recyclable",
	esES = "Aprovechable",
	itIT = "Riciclabile",
	ptBR = "Sucateável",
	ruRU = "Можно утилизировать",
}

local L_BoE = {
	enGB = "Binds when Equipped",
	enUS = "Binds when Equipped",
	deDE = "Seelengebunden wenn ausgrerüstet",
	frFR = "Lié quand équipé",
	esES = "Se liga al equiparlo",
	itIT = "Si vincola all'equipagiamento",
	ptBR = "Vincula-se quando equipado",
	ruRU = "Становится персональным при надевании",
}

---------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------
local function IsBagBlacklisted(n)
	return ScrappinDB.CheckButtons.Bag[n]
end

local function ItemPrint(text, ...)
	if ScrappinDB.CheckButtons.Itemprint then
		print(string.format("|c%sScrap:|r: Inserting %s (%s)", ns.Config.color, text, ...))
	end
end

local function PositionScrapButton(self)
	if ScrappinDB.CheckButtons.Bottom then
		self:ClearAllPoints()
		self:SetPoint("CENTER", ScrappingMachineFrame, "BOTTOM", 0, 42)
	else
		self:ClearAllPoints()
		self:SetPoint("CENTER", ScrappingMachineFrame, "TOP", 0, -45)
	end
end

local function CreateEmptyTooltip()
    local tip = CreateFrame("GameTooltip")
	local leftside = {}
	local rightside = {}
	local L, R
	-- 50 is max tooltip length atm (might need change)
	for i = 1, 50 do
		L, R = tip:CreateFontString(), tip:CreateFontString()
		L:SetFontObject(GameFontNormal)
		R:SetFontObject(GameFontNormal)
		tip:AddFontStrings(L, R)
		leftside[i] = L
		rightside[i] = R
	end
	tip.leftside = leftside
	tip.rightside = rightside
	return tip
end

local function ItemLvlComparison(equipped, itemlvl)
	if not ScrappinDB.CheckButtons.Itemlvl and not ScrappinDB.CheckButtons.specificilvl then
		return true
	end
	
	local ItemLvlLessThanEquip, ItemLvlLessThanSpecific = false, false
	if itemlvl and equipped then
		ItemLvlLessThanEquip = itemlvl < equipped
		DebugLog("CUSTOM", " > Compared ["..tostring(itemlvl).."] < ["..tostring(equipped).."] = "..tostring(ItemLvlLessThanEquip))
	end
	if itemlvl and ScrappinDB.specificilvlbox then
		ItemLvlLessThanSpecific = itemlvl < tonumber(ScrappinDB.specificilvlbox)
		DebugLog("CUSTOM", " > Compared ["..tostring(itemlvl).."] < ["..tostring(ScrappinDB.specificilvlbox).."] = "..tostring(ItemLvlLessThanSpecific))
	end

	--returns
	if ScrappinDB.CheckButtons.Itemlvl and ScrappinDB.CheckButtons.specificilvl then
		if ItemLvlLessThanEquip and ItemLvlLessThanSpecific then
			return true
		else
			return false
		end
	elseif ScrappinDB.CheckButtons.Itemlvl then
		return ItemLvlLessThanEquip
	elseif ScrappinDB.CheckButtons.specificilvl then
		return ItemLvlLessThanSpecific
	end
end

local function IsPartOfEquipmentSet(bag, slot)
	if ScrappinDB.CheckButtons.equipmentsets then
		local isInSet, _ = GetContainerItemEquipmentSetInfo(bag, slot)
		return isInSet
	end

	return false
end

local function IsAzeriteItem(itemLocation)
	if ScrappinDB.CheckButtons.azerite then
		local isAzerite = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)
		return isAzerite
	end

	return false
end

local function IsCorruptedItem(itemLocation)
	if ScrappinDB.CheckButtons.corrupted then
		local isCorrupted = C_Item.IsItemCorrupted(itemLocation)
		return isCorrupted
	end

	return false
end

---------------------------------------------------
-- SCRAPPING FUNCTIONS
---------------------------------------------------
local function ReadTooltip(itemString)
	tooltipReader:Hide()
	tooltipReader:ClearLines()
	tooltipReader:SetOwner(WorldFrame, "ANCHOR_NONE")
	local scrappable = false
	local boe = false

	if itemString then
		tooltipReader:SetHyperlink(itemString)
		for i = tooltipReader:NumLines(), 1, -1 do
			local line = tooltipReader.leftside[i]:GetText()
			if line and line == L_Scrappable[Locale] then
				scrappable = true
				break
			end
		end

		if ScrappinDB.CheckButtons.boe then
			local boe = false
			for i = 2, 4 do
				local t = tooltipReader.leftside[i]:GetText()
				if t and t == L_BoE[Locale] then
					boe = true
					break
				end
			end
			return scrappable, boe
		end
	end
	
	return scrappable, false
end

local function ShouldInsert(item, bag, slot, equipped)
	local scrappable, boe = ReadTooltip(item)
	itemLocation:SetBagAndSlot(bag, slot)	

	if scrappable then
		local azerite_item = IsAzeriteItem(itemLocation)
		local corrupted_item = IsCorruptedItem(itemLocation)
		local itemlvl, _, _ = GetDetailedItemLevelInfo(item) or 0
		local part_of_set = IsPartOfEquipmentSet(bag, slot)
		local itemCompare = ItemLvlComparison(equipped, itemlvl)
		if (scrappable and itemCompare and not boe and not part_of_set and not azerite_item and not corrupted_item) then
			ItemPrint(item, itemlvl)
			return true
		else
			DebugLogItem(item, scrappable, itemCompare, boe, part_of_set, azerite_item, corrupted_item)
		end
	else
		DebugLogItem(item, scrappable)
	end

	return false
end

local function InsertScrapItems()
	local _, avgEquipped, _ = GetAverageItemLevel()
	DebugLogClear()
	DebugLog("SETTINGS", nil)
	for bag = 0, 4 do
		if not IsBagBlacklisted(bag) then
			for slot = 1, GetContainerNumSlots(bag) do
				local item = GetContainerItemLink(bag, slot)
				if item and strsub(item, 13, 16) == "item" then
					if ShouldInsert(item, bag, slot, avgEquipped) then
						UseContainerItem(bag, slot)
					end
				elseif item then
					DebugLog("CUSTOM", item.." invalid prefix: "..strsub(item, 13, 16))
				end
			end
		else
			DebugLog("CUSTOM", "Not iterating through bag "..bag.." as it is ignored.")
		end
	end
end

function Core:CreateScrapButton()
	local loaded = IsAddOnLoaded("Blizzard_ScrappingMachineUI")
	if loaded ~= 1 then LoadAddOn("Blizzard_ScrappingMachineUI") end
	local scrapButton = CreateFrame("Button", "moetQOL_ScrapButton", ScrappingMachineFrame, "OptionsButtonTemplate")
	local scrapCooldown = CreateFrame("Cooldown", "scrapButtonAntiSpam", scrapButton)
	PositionScrapButton(scrapButton)
	scrapCooldown:SetAllPoints()
	scrapButton:SetText("Fill")

	tooltipReader = CreateEmptyTooltip()
	
	scrapButton:SetScript("OnClick", function() 
		local duration = scrapCooldown:GetCooldownDuration()
		if duration ~= 0 then return end

		if UnitCastingInfo("player") ~= nil then
			print(string.format("|c%sScrap|r: You cannot insert items while actively scrapping, cancel your cast to refill.", ns.Config.color))
			return
		end

		scrapCooldown:SetCooldown(GetTime(), 1)
		C_ScrappingMachineUI.RemoveAllScrapItems()
		InsertScrapItems()
		PlaySound(115314)
		collectgarbage("collect")
	end)
end
