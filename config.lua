local _, ns = ... -- namespace
ns.Config = {} -- add config to the namespace
local Config = ns.Config
_G.ScrappinDB = ScrappinDB or {}
Config.color = "ff186aa7" -- blue

---------------------------------------------------
-- UI FUNCTIONS
---------------------------------------------------
do
	--Interface Options
	local panel = CreateFrame("FRAME")
	panel.name = "ScrapButton"
	panel.configbtn = CreateFrame("Button", "ScrapButton_Panel", panel, "OptionsButtonTemplate")
	panel.configbtn:SetText("Config")
	panel.configbtn:SetPoint("CENTER", panel, "TOP", 0, -100)
	panel.configbtn:SetScript("OnClick", function()
		if InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Hide()	
		end
		Config:ToggleScrappinFrame()
	end)
	panel.debugbtn = CreateFrame("Button", "ScrapButton_Panel", panel, "OptionsButtonTemplate")
	panel.debugbtn:SetText("Debug Log")
	panel.debugbtn:SetPoint("CENTER", panel, "TOP", 0, -150)
	panel.debugbtn:SetScript("OnClick", function()
		if InterfaceOptionsFrame:IsShown() then
			InterfaceOptionsFrame:Hide()
		end
		Config:ToggleScrappinDebug()
	end)
	InterfaceOptions_AddCategory(panel)

	--Frame
	_G.ScrappinUI = CreateFrame("Frame", "ScrappinUI_Frame", UIParent, "TranslucentFrameTemplate")
	ScrappinUI:SetSize(600, 300)
	ScrappinUI:SetPoint("CENTER")
	ScrappinUI.title = ScrappinUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ScrappinUI.title:SetPoint("CENTER", ScrappinUI_FrameTopBorder, "CENTER")
	ScrappinUI.title:SetText("Scrap Button Config")
	ScrappinUI:SetMovable(true)
	ScrappinUI:EnableMouse(true)
	ScrappinUI:RegisterForDrag("LeftButton")
	ScrappinUI:SetScript("OnDragStart", ScrappinUI.StartMoving)
	ScrappinUI:SetScript("OnDragStop", ScrappinUI.StopMovingOrSizing)
	tinsert(UISpecialFrames, ScrappinUI:GetName())

	--debug frame
	_G.ScrappinDebug = CreateFrame("Frame", "ScrappinUI_Debug", UIParent, "TranslucentFrameTemplate")
	ScrappinDebug:SetSize(700, 400)
	ScrappinDebug:SetPoint("CENTER")
	ScrappinDebug.title = ScrappinDebug:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ScrappinDebug.title:SetPoint("LEFT", ScrappinUI_Debug, "TOPLEFT", 25, -25)
	ScrappinDebug.title:SetText("ScrapDebug - If a setting is Disabled, the value should be false to be inserted. Not Scrappable/ItemCompare")
	ScrappinDebug.exitbtn = CreateFrame("Button", nil, ScrappinUI_Debug, "UIPanelCloseButton")
	ScrappinDebug.exitbtn:SetPoint("CENTER", ScrappinUI_DebugTopRightCorner, "CENTER", -5, -5)
	ScrappinDebug.exitbtn:SetScript("OnClick", function() Config.ToggleScrappinDebug() end)
	tinsert(UISpecialFrames, ScrappinDebug:GetName())

	--scroll
	local ScrappinDebugScrollArea = CreateFrame("ScrollFrame", "ScrappinDebugScroll", ScrappinUI_Debug, "UIPanelScrollFrameTemplate")
	ScrappinDebugScrollArea:SetPoint("TOPLEFT", ScrappinDebug.title, "BOTTOMLEFT", 8, -8)
	ScrappinDebugScrollArea:SetPoint("BOTTOMRIGHT", ScrappinUI_Debug, "BOTTOMRIGHT", -33, 20)
	
	ScrappinDebug.body = CreateFrame("EditBox", nil, ScrappinUI_Debug)
	ScrappinDebug.body:SetMultiLine(true)
	ScrappinDebug.body:SetMaxLetters(99999)
	ScrappinDebug.body:EnableMouse(false)
	ScrappinDebug.body:SetAutoFocus(false)
	ScrappinDebug.body:SetFontObject(ChatFontNormal)
	--ScrappinDebug.body:SetFont('Fonts\\ARIALN.ttf', 13, 'THINOUTLINE')
	ScrappinDebug.body:SetWidth(1000)
	ScrappinDebug.body:SetHeight(575)
	ScrappinDebug.body:Show()

	ScrappinDebugScrollArea:SetScrollChild(ScrappinDebug.body)

	local ScrappinDebugBackdrop = CreateFrame("Frame", nil, ScrappinUI_Debug)
	ScrappinDebugBackdrop:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 3, right = 3, top = 5, bottom = 3}}
	)
	ScrappinDebugBackdrop:SetBackdropColor(0,0,0,1)
	ScrappinDebugBackdrop:SetPoint("TOPLEFT", ScrappinDebug.title, "BOTTOMLEFT", -5, 0)
	ScrappinDebugBackdrop:SetPoint("BOTTOMRIGHT", ScrappinUI_Debug, "BOTTOMRIGHT", -27, 5)
	
	--Text
	ScrappinUI.dev = ScrappinUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ScrappinUI.dev:SetPoint("CENTER", ScrappinUI_Frame, "BOTTOM", 0, 40)
	ScrappinUI.dev:SetText(string.format("Version: |c%s%s|r", ns.Config.color, GetAddOnMetadata("ScrapButton", "Version")))

	ScrappinUI.bagHeader = ScrappinUI:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	ScrappinUI.bagHeader:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 85, -160)
	ScrappinUI.bagHeader:SetText("Tick to ignore bags:")

	--Exit Button
	ScrappinUI.exitbtn = CreateFrame("Button", "ScrappinUI_CloseButton", ScrappinUI_Frame, "UIPanelCloseButton")
	ScrappinUI.exitbtn:SetPoint("CENTER", ScrappinUI_FrameTopRightCorner, "CENTER", -5, -5)
	ScrappinUI.exitbtn:SetScript("OnClick", function() Config.ToggleScrappinFrame() end)

	--CheckButtons
	--ilvl
	ScrappinUI.checkbtn1 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn1:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -40)
	ScrappinUI.checkbtn1.text:SetText("Don't insert items above Equipped iLvl")
	ScrappinUI.checkbtn1:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Itemlvl = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbtn1.text:GetText() .. tostring(ScrappinDB.CheckButtons.Itemlvl))
	end)

	--bottom
	ScrappinUI.checkbtn2 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn2:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -70)
	ScrappinUI.checkbtn2.text:SetText("Place scrap button at the bottom (/reload)")
	ScrappinUI.checkbtn2:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bottom = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbtn2.text:GetText() .. tostring(ScrappinDB.CheckButtons.Bottom))
	end)

	--itemprint
	ScrappinUI.checkbtn3 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn3:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -100)
	ScrappinUI.checkbtn3.text:SetText("Print items inserted to chat")
	ScrappinUI.checkbtn3:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Itemprint = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbtn3.text:GetText() .. tostring(ScrappinDB.CheckButtons.Itemprint))
	end)

	--BoE
	ScrappinUI.checkbtn4 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn4:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -130)
	ScrappinUI.checkbtn4.text:SetText("Ignore Bind-on-Equipped items")
	ScrappinUI.checkbtn4:SetScript("OnClick", function(self)
		PlaySound(856)
		ScrappinDB.CheckButtons.boe = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbtn4.text:GetText()..tostring(ScrappinDB.CheckButtons.boe))
	end)

	--SpecificILvL
	ScrappinUI.editbox = CreateFrame("EditBox", nil, ScrappinUI_Frame, "InputBoxTemplate")
	ScrappinUI.editbox:SetWidth(40)
	ScrappinUI.editbox:SetHeight(40)
	ScrappinUI.editbox:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 540, -40)
	ScrappinUI.editbox:SetAutoFocus(false)
	ScrappinUI.editbox:SetNumeric(true)
	ScrappinUI.editbox:SetMaxLetters(3)

	ScrappinUI.editbox:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)

	ScrappinUI.editbox:SetScript("OnEditFocusLost", function(self)
		self:ClearFocus()
		ScrappinDB.specificilvlbox = self:GetNumber()
	end)

	ScrappinUI.editbox:SetScript("OnEnable", function(self)
		self:SetText(ScrappinDB.specificilvlbox)
	end)

	ScrappinUI.editbox:SetScript("OnDisable", function(self)
		self:SetText(" ")
	end)

	ScrappinUI.checkbtn5 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn5:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 340, -40)
	ScrappinUI.checkbtn5.text:SetText("Ignore items above item level:")
	ScrappinUI.checkbtn5:SetScript("OnClick", function(self)
		PlaySound(856)
		if self:GetChecked() then
			ScrappinUI.editbox:Enable()
		else
			ScrappinUI.editbox:Disable()
		end
		ScrappinDB.CheckButtons.specificilvl = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbtn5.text:GetText()..tostring(ScrappinDB.CheckButtons.specificilvl))
	end)

	--Equipment sets
	ScrappinUI.checkbtn6 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn6:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 340, -70)
	ScrappinUI.checkbtn6.text:SetText("Ignore items in equipment sets")
	ScrappinUI.checkbtn6:SetScript("OnClick", function(self)
		PlaySound(856)
		ScrappinDB.CheckButtons.equipmentsets = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbtn6.text:GetText() .. tostring(ScrappinDB.CheckButtons.equipmentsets))
	end)

	--Azerite Item
	ScrappinUI.checkbtn7 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbtn7:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 340, -100)
	ScrappinUI.checkbtn7.text:SetText("Ignore Azerite Items")
	ScrappinUI.checkbtn7:SetScript("OnClick", function(self)
		PlaySound(856)
		ScrappinDB.CheckButtons.azerite = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbtn7.text:GetText() .. tostring(ScrappinDB.CheckButtons.azerite))		
	end)

	-- Bags
	ScrappinUI.checkbag0 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag0:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -190)
	ScrappinUI.checkbag0.text:SetText("Backpack")
	ScrappinUI.checkbag0:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[0] = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbag0.text:GetText() .. tostring(ScrappinDB.CheckButtons.Bag[0]))
	end)

	ScrappinUI.checkbag1 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag1:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -220)
	ScrappinUI.checkbag1.text:SetText("Bag 1")
	ScrappinUI.checkbag1:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[1] = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbag1.text:GetText() .. tostring(ScrappinDB.CheckButtons.Bag[1]))
	end)

	ScrappinUI.checkbag2 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag2:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 40, -250)
	ScrappinUI.checkbag2.text:SetText("Bag 2")
	ScrappinUI.checkbag2:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[2] = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbag2.text:GetText() .. tostring(ScrappinDB.CheckButtons.Bag[2]))
	end)

	ScrappinUI.checkbag3 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag3:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 160, -190)
	ScrappinUI.checkbag3.text:SetText("Bag 3")
	ScrappinUI.checkbag3:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[3] = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbag3.text:GetText() .. tostring(ScrappinDB.CheckButtons.Bag[3]))
	end)

	ScrappinUI.checkbag4 = CreateFrame("CheckButton", nil, ScrappinUI_Frame, "UICheckButtonTemplate")
	ScrappinUI.checkbag4:SetPoint("CENTER", ScrappinUI_Frame, "TOPLEFT", 160, -220)
	ScrappinUI.checkbag4.text:SetText("Bag 4")
	ScrappinUI.checkbag4:SetScript("OnClick", function(self) 
		PlaySound(856)
		ScrappinDB.CheckButtons.Bag[4] = self:GetChecked()
		DebugLog("CUSTOM", ScrappinUI.checkbag4.text:GetText() .. tostring(ScrappinDB.CheckButtons.Bag[4]))
	end)

	ScrappinDebug:Hide()
	ScrappinUI:Hide()
end

function Config:UpdateCheckButtonStates()
	ScrappinUI.checkbtn1:SetChecked(ScrappinDB.CheckButtons.Itemlvl)
	ScrappinUI.checkbtn2:SetChecked(ScrappinDB.CheckButtons.Bottom)
	ScrappinUI.checkbtn3:SetChecked(ScrappinDB.CheckButtons.Itemprint)
	ScrappinUI.checkbtn4:SetChecked(ScrappinDB.CheckButtons.boe)
	ScrappinUI.checkbtn5:SetChecked(ScrappinDB.CheckButtons.specificilvl)
	ScrappinUI.checkbtn6:SetChecked(ScrappinDB.CheckButtons.equipmentsets)
	ScrappinUI.checkbtn7:SetChecked(ScrappinDB.CheckButtons.azerite)
	ScrappinUI.checkbag0:SetChecked(ScrappinDB.CheckButtons.Bag[0])
	ScrappinUI.checkbag1:SetChecked(ScrappinDB.CheckButtons.Bag[1])
	ScrappinUI.checkbag2:SetChecked(ScrappinDB.CheckButtons.Bag[2])
	ScrappinUI.checkbag3:SetChecked(ScrappinDB.CheckButtons.Bag[3])
	ScrappinUI.checkbag4:SetChecked(ScrappinDB.CheckButtons.Bag[4])

	if ScrappinDB.CheckButtons.specificilvl then
		ScrappinUI.editbox:Enable()
	else
		ScrappinUI.editbox:Disable()
	end
end

function Config:ToggleScrappinFrame()
	ScrappinUI:SetShown(not ScrappinUI:IsShown())
end

function Config:ToggleScrappinDebug()
	ScrappinDebug:SetShown(not ScrappinDebug:IsShown())
end