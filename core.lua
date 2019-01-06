---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ... -- namespace
ns.Core	= {} -- add the core to the namespace
local Core = ns.Core
local itemLocation = itemLocation or ItemLocation:CreateEmpty()

---------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------
local function IsBagBlacklisted(int)
	return ScrappinDB.CheckButtons.Bag[int]
end

local function ItemPrint(text, ...)
	if (ScrappinDB.CheckButtons.Itemprint) then
		print(string.format("|c%sScrap:|r: Inserting %s (%s)", ns.Config.color, text, ...))
	end
end

local function PositionScrapButton(self)
	if (ScrappinDB.CheckButtons.Bottom) then
		self:ClearAllPoints()
		self:SetPoint("CENTER", ScrappingMachineFrame, "BOTTOM", 0, 42)
	else
		self:ClearAllPoints()
		self:SetPoint("CENTER", ScrappingMachineFrame, "TOP", 0, -45)
	end
end

--amazing tooltip function from Personal Loot Helper
local function CreateEmptyTooltip()
    local tip = CreateFrame('GameTooltip')
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
	if (not ScrappinDB.CheckButtons.Itemlvl and not ScrappinDB.CheckButtons.specificilvl) then
		return true
	end
	DebugPrint("Comparing Itemlvl: " .. tostring(itemlvl) .. " equipped: " .. tostring(equipped) .. " specific: " .. tostring(ScrappinDB.specificilvlbox))

	local ItemLvlLessThanEquip, ItemLvlLessThanSpecific = false
	if itemlvl and equipped then
		ItemLvlLessThanEquip = itemlvl < equipped
	end
	if itemlvl and ScrappinDB.specificilvlbox then
		ItemLvlLessThanSpecific = itemlvl < tonumber(ScrappinDB.specificilvlbox)
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


---------------------------------------------------
-- SCRAPPING FUNCTIONS
---------------------------------------------------
local function ReadTooltip(itemString)
	local tooltipReader = tooltipReader or CreateEmptyTooltip()
	tooltipReader:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltipReader:ClearLines()
	local scrappable = false
	local boe = false

	if itemString then
		tooltipReader:SetHyperlink(itemString)
		for i = tooltipReader:NumLines(), 1, -1 do
			local line = tooltipReader.leftside[i]:GetText()
			if line and line == "Scrappable" then
				scrappable = true
				break
			end
		end

		if (ScrappinDB.CheckButtons.boe) then
			local boe = false
			for i = 2, tooltipReader:NumLines() do
				local t = tooltipReader.leftside[i]:GetText()
				if t and t == "Binds when equipped" then
					DebugPrint("Found BoE: " .. itemString)
					boe = true
					break
				end
			end
			return scrappable, boe
		end
	end
	
	return scrappable, false
end

local function InsertScrapItems()
	local _, equipped = GetAverageItemLevel()
	for bag = 0, 4 do
		if not IsBagBlacklisted(bag) then
			for slot = 1, GetContainerNumSlots(bag) do
				local item = GetContainerItemLink(bag, slot)
				if item and strsub(item, 13, 16) == "item" then
					itemLocation:SetBagAndSlot(bag, slot)
					local azerite_item = IsAzeriteItem(itemLocation)
					local scrappable, boe = ReadTooltip(item)
					local itemlvl, _, _ = GetDetailedItemLevelInfo(item) or 0
					local part_of_set = IsPartOfEquipmentSet(bag, slot)
					local itemCompare = ItemLvlComparison(equipped, itemlvl)
					if (scrappable and itemCompare and not boe and not part_of_set and not azerite_item) then
						ItemPrint(item, itemlvl)
						UseContainerItem(bag, slot)
					end
				end
			end
		end
	end
end

function Core:CreateScrapButton()
	LoadAddOn("Blizzard_ScrappingMachineUI")
	local scrapButton = CreateFrame("Button", "moetQOL_ScrapButton", ScrappingMachineFrame, "OptionsButtonTemplate")
	PositionScrapButton(scrapButton)
	scrapButton:SetText("Insert Scrap")
	
	local scrapCooldown = CreateFrame("Cooldown", "scrapButtonAntiSpam", scrapButton)
	scrapCooldown:SetAllPoints()

	scrapButton:SetScript("OnClick", function() 
		local duration = scrapCooldown:GetCooldownDuration()
		if duration ~= 0 then return end

		if (UnitCastingInfo("player") ~= nil) then
			print(string.format("|c%sScrap|r: You cannot insert items while actively scrapping, cancel your cast to refill.", ns.Config.color))
			return
		end

		scrapCooldown:SetCooldown(GetTime(), 1)
		PlaySound(73919) -- UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
		InsertScrapItems()
		collectgarbage()
	end)
end
