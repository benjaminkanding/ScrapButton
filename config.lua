---------------------------------------------------
-- SETUP
-- TODO:
-- cleanup
-- fix itemlevel thing or remove it
---------------------------------------------------
local _, ns		= ... -- namespace
ns.Config		= {} -- add config to the namespace
local Config	= ns.Config
_G.ScrappinDB	= ScrappinDB or {}
Config.color	= "ff186aa7" -- blue

---------------------------------------------------
-- UI FUNCTIONS
---------------------------------------------------
--global function create UI
do
	--Frame
	_G.ScrappinUI = CreateFrame("Frame", "ScrappinUI_Frame", UIParent, "TranslucentFrameTemplate")
	ScrappinUI:SetSize(600, 300)
	ScrappinUI:SetPoint("CENTER")
	ScrappinUI.title = ScrappinUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ScrappinUI.title:SetPoint("CENTER", ScrappinUI_FrameTopBorder, "CENTER")
	ScrappinUI.title:SetText("Scrappin Config")
	ScrappinUI:SetMovable(true)
	ScrappinUI:EnableMouse(true)
	ScrappinUI:RegisterForDrag("LeftButton")
	ScrappinUI:SetScript("OnDragStart", ScrappinUI.StartMoving)
	ScrappinUI:SetScript("OnDragStop", ScrappinUI.StopMovingOrSizing)

	--Text
	ScrappinUI.dev = ScrappinUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ScrappinUI.dev:SetPoint("CENTER", ScrappinUI_Frame, "BOTTOM", 0, 40)
	ScrappinUI.dev:SetText(string.format("Version: |c%s%s|r - more filters coming soon.", ns.Config.color, GetAddOnMetadata("Scrappin", "Version")))

	ScrappinUI.bagHeader = ScrappinUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ScrappinUI.bagHeader:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 85, -130)
	ScrappinUI.bagHeader:SetText("Tick to ignore bags:")

	--Buttons
	ScrappinUI.exitbtn = CreateFrame("Button", "ScrappinUI_CloseButton", ScrappinUI_Frame, "UIPanelCloseButton")
	ScrappinUI.exitbtn:SetPoint("CENTER", ScrappinUI_FrameTopRightCorner, "CENTER", -5, -5)
	ScrappinUI.exitbtn:SetScript("OnClick", function() Config.ToggleScrappinFrame() end)

	ScrappinUI.debugbtn = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.debugbtn:SetPoint("CENTER", ScrappinUI_Frame, "BOTTOMRIGHT", -100, 40)
	ScrappinUI.debugbtn.text:SetText("Debug mode")
	ScrappinUI.debugbtn:SetScript("OnClick", function(self)
		PlaySound(856)
		ScrappinDB.CheckButtons.Debug = self:GetChecked()
		DebugPrint("debugbtn value is now: " .. tostring(ScrappinDB.CheckButtons.Debug))

	end)

	ScrappinUI.checkbtn1 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn1:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -40)
	ScrappinUI.checkbtn1.text:SetText("Don't insert items above equipped ilvl (*)")
	ScrappinUI.checkbtn1:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Itemlvl = self:GetChecked()
		DebugPrint("btn1 value is now: " .. tostring(ScrappinDB.CheckButtons.Itemlvl))
	end)

	ScrappinUI.checkbtn2 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn2:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -70)
	ScrappinUI.checkbtn2.text:SetText("Place scrap button at the bottom (/reload)")
	ScrappinUI.checkbtn2:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bottom = self:GetChecked()
		DebugPrint("btn2 value is now: " .. tostring(ScrappinDB.CheckButtons.Bottom))
	end)

	ScrappinUI.checkbtn3 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn3:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -100)
	ScrappinUI.checkbtn3.text:SetText("Print items inserted to chat")
	ScrappinUI.checkbtn3:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Itemprint = self:GetChecked()
		DebugPrint("btn3 value is now: " .. tostring(ScrappinDB.CheckButtons.Itemprint))
	end)

	-- bags
	ScrappinUI.checkbag0 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag0:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -160)
	ScrappinUI.checkbag0.text:SetText("Backpack")
	ScrappinUI.checkbag0:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[0] = self:GetChecked()
		DebugPrint("bag0 value is now: " .. tostring(ScrappinDB.CheckButtons.Bag[0]))
	end)

	ScrappinUI.checkbag1 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag1:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -190)
	ScrappinUI.checkbag1.text:SetText("Bag 1")
	ScrappinUI.checkbag1:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[1] = self:GetChecked()
		DebugPrint("bag1 value is now: " .. tostring(ScrappinDB.CheckButtons.Bag[1]))
	end)

	ScrappinUI.checkbag2 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag2:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -220)
	ScrappinUI.checkbag2.text:SetText("Bag 2")
	ScrappinUI.checkbag2:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[2] = self:GetChecked()
		DebugPrint("bag2 value is now: " .. tostring(ScrappinDB.CheckButtons.Bag[2]))
	end)

	ScrappinUI.checkbag3 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag3:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 160, -160)
	ScrappinUI.checkbag3.text:SetText("Bag 3")
	ScrappinUI.checkbag3:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[3] = self:GetChecked()
		DebugPrint("bag3 value is now: " .. tostring(ScrappinDB.CheckButtons.Bag[3]))
	end)

	ScrappinUI.checkbag4 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag4:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 160, -190)
	ScrappinUI.checkbag4.text:SetText("Bag 4")
	ScrappinUI.checkbag4:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[4] = self:GetChecked()
		DebugPrint("bag4 value is now: " .. tostring(ScrappinDB.CheckButtons.Bag[4]))
	end)

	ScrappinUI:Hide()
end

function Config:UpdateCheckButtonStates()
	ScrappinUI.checkbtn1:SetChecked(ScrappinDB.CheckButtons.Itemlvl)
	ScrappinUI.checkbtn2:SetChecked(ScrappinDB.CheckButtons.Bottom)
	ScrappinUI.checkbtn3:SetChecked(ScrappinDB.CheckButtons.Itemprint)
	ScrappinUI.debugbtn:SetChecked(ScrappinDB.CheckButtons.Debug)
	ScrappinUI.checkbag0:SetChecked(ScrappinDB.CheckButtons.Bag[0])
	ScrappinUI.checkbag1:SetChecked(ScrappinDB.CheckButtons.Bag[1])
	ScrappinUI.checkbag2:SetChecked(ScrappinDB.CheckButtons.Bag[2])
	ScrappinUI.checkbag3:SetChecked(ScrappinDB.CheckButtons.Bag[3])
	ScrappinUI.checkbag4:SetChecked(ScrappinDB.CheckButtons.Bag[4])
end

--possibly updatesVariables call function to avoid /reload?
-- if checkbtn1 == true then
--	set variables/callfunctions
--

function Config:ToggleScrappinFrame()
	ScrappinUI:SetShown(not ScrappinUI:IsShown())
end