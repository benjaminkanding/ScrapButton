---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns		= ... -- namespace
ns.Core			= {} -- add the core to the namespace
local Core		= ns.Core

---------------------------------------------------
-- HELPER FUNCTIONS
---------------------------------------------------
local function IsBagBlacklisted(int)
	return ScrappinDB.CheckButtons.Bag[int]
end

local function ItemPrint(text)
	if (ScrappinDB.CheckButtons.Itemprint) then
		print(string.format("|c%sScrap:|r: Inserting %s", ns.Config.color, text))
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

local function ItemLvlLessThanEquipped(equipped, item)
	if (not ScrappinDB.CheckButtons.Itemlvl) then
		return true
	end

	local itemlvl = nil
	local PLH_ITEM_LEVEL_PATTERN = _G.ITEM_LEVEL:gsub('%%d', '(%%d+)')
	if item ~= nil then
		tooltip = tooltip or CreateEmptyTooltip()
		tooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
		tooltip:ClearLines()
		tooltip:SetHyperlink(item)
		local t = tooltip.leftside[2]:GetText()
		if t ~= nil then
			itemlvl = t:match(PLH_ITEM_LEVEL_PATTERN)
		end
		if itemlvl == nil then
			t = tooltip.leftside[3]:GetText()
			if t ~= nil then
				itemlvl = t:match(PLH_ITEM_LEVEL_PATTERN)
			end
		end
		tooltip:Hide()
		
		if itemlvl == nil then
			itemlvl = select(4, GetItemInfo(item))
		end
	end
	
	if itemlvl == nil then
		itemlvl = 0
	end

	itemlvl = tonumber(itemlvl)

	DebugPrint("Comparing that " .. tostring(itemlvl) .. " is less than " .. tostring(equipped) .. " = " .. tostring(itemlvl < equipped))
	return itemlvl < equipped
end


---------------------------------------------------
-- SCRAPPING FUNCTIONS
-- free reuse with credit :o)
---------------------------------------------------
local function IsScrappable(itemString)
	local tooltipReader = tooltipReader or CreateEmptyTooltip()
	tooltipReader:SetOwner(WorldFrame, "ANCHOR_NONE")
	tooltipReader:ClearLines()

	if (itemString ~= nil) then
		tooltipReader:SetHyperlink(itemString)
		DebugPrint(itemString .. " has lines: " .. tooltipReader:NumLines())
		for i = tooltipReader:NumLines(), 1, -1 do
			local line = tooltipReader.leftside[i]:GetText()
			if (line ~= nil) then
				if line == "Cannot be Scrapped" then
					return false
				elseif line == "Scrappable" then
					return true
				end
			end
		end

		tooltipReader:Hide()
	end
end

local function InsertScrapItems()
	local _, equipped = GetAverageItemLevel()
	for bag = 0, 4 do
		if (not IsBagBlacklisted(bag)) then
			for slot = 1, GetContainerNumSlots(bag) do
				local item = GetContainerItemLink(bag, slot)
				if (item ~= nil) then
					if (IsScrappable(item) and ItemLvlLessThanEquipped(equipped, item)) then
						ItemPrint(item)
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

	local scrapCooldown = CreateFrame("Cooldown", "scrapButtonAntiSpam", scrapButton, "CooldownFrameTemplate")
	scrapCooldown:SetAllPoints() -- sized exactly same as scrapButton

	scrapButton:SetScript("OnClick", function() 
		local duration = scrapCooldown:GetCooldownDuration()

		if duration ~= 0 then return end

		if (UnitCastingInfo("player") ~= nil) then
			print(string.format("|c%sScrap|r: You cannot insert items while actively scrapping, cancel your cast to refill.", ns.Config.color))
			return
		end

		scrapCooldown:SetCooldown(GetTime(), 1)
		if (C_ScrappingMachineUI.HasScrappableItems()) then
			C_ScrappingMachineUI.RemoveAllScrapItems()
			print(string.format("|c%sScrap|r: Refilling..", ns.Config.color))
			InsertScrapItems()
			PlaySound(73919) -- UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
			return
		end

		PlaySound(73919) -- UI_PROFESSIONS_NEW_RECIPE_LEARNED_TOAST
		InsertScrapItems()
	end)
end
