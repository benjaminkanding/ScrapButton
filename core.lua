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

local function ItemLvlLessThanEquipped(equipped, itemlvl)
	if (not ScrappinDB.CheckButtons.Itemlvl) then
		return true
	end
	DebugPrint("Comparing that " .. tostring(itemlvl) .. " is less than " .. tostring(equipped) .. " = " .. tostring(equipped < itemlvl))
	return itemlvl < equipped
end

local function ItemPrint(text)
	if (ScrappinDB.CheckButtons.Itemprint) then
		print(string.format("|c%sScrap|r: Inserting %s", ns.Config.color, text))
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

---------------------------------------------------
-- SCRAPPING FUNCTIONS
-- free reuse with credit :o)
---------------------------------------------------
local function IsScrappable(itemString)
	local tooltipReader = CreateFrame("GameTooltip", "moetQOL_TooltipReader", nil, "GameToolTipTemplate")
	tooltipReader:SetOwner(WorldFrame, "ANCHOR_NONE")

	-- add check here if you want to blacklist items

	tooltipReader:ClearLines()
	tooltipReader:AddFontStrings(
		tooltipReader:CreateFontString("$parentTextLeft1", nil, "GameTooltipText"),
		tooltipReader:CreateFontString("$parentTextRight1", nil, "GameTooltipText")
	)

	if (itemString ~= nil) then
		tooltipReader:SetHyperlink(itemString)
		if (tooltipReader:NumLines() < 9) then
			for i = tooltipReader:NumLines(), 1, -1 do
				local tooltipText = _G["moetQOL_TooltipReaderTextLeft" .. i]
				local line = tooltipText:GetText()
				if line == "Cannot be Scrapped" then
					return false
				elseif line == "Scrappable" then
					return true
				end
			end
		else
			for i = select("#", tooltipReader:GetRegions()), 1, -1 do
				local region = select(i, tooltipReader:GetRegions())
				if region and region:GetObjectType() == "FontString" and region:GetText() then 
					local line = region:GetText()
					if line == "Cannot be Scrapped" then
						return false
					elseif line == "Scrappable" then
						return true
					end
				end 
			end
		end
	end
end

local function InsertScrapItems()
	local overall, equipped = GetAverageItemLevel()
	for bag = 0, 4 do
		if (not IsBagBlacklisted(bag)) then
			for slot = 1, GetContainerNumSlots(bag) do
				local item = GetContainerItemLink(bag, slot)
				if (item ~= nil) then
					if (IsScrappable(item)) then
						DebugPrint("Inserting " .. item)
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