---------------------------------------------------
-- SETUP
---------------------------------------------------
local _, ns	= ... -- namespace
local shortcut = "/scrap"
local addonVersion = GetAddOnMetadata("ScrapButton", "Version")
local defaultDB = {
	DBversion = 7,
	specificilvlbox = " ",
	CheckButtons = {
		Itemlvl = false,
		Bottom = false,
		Itemprint = false,
		boe = false,
		specificilvl = false,
		equipmentsets = false,
		azerite = false,
		corrupted = false,
		Bag = {
			[0] = false,
			[1] = false,
			[2] = false,
			[3] = false,
			[4] = false,
		},
	}
}

function DebugLog(mode, txt)
	if not mode then return end

	if mode == "CUSTOM" then
		ScrappinDebug.body:Insert(tostring(txt).."\n")
	elseif mode == "SETTINGS" then
		for k, v in pairs(ScrappinDB.CheckButtons) do
			ScrappinDebug.body:Insert("["..tostring(k)..": "..tostring(v).."]\n")
		end
	end	
end

function DebugLogClear()
	ScrappinDebug.body:SetText("")
end

function DebugLogItem(i, s, ic, b, p, a, c)
	if not s then
		ScrappinDebug.body:Insert("Cannot insert "..i.." since it is not Scrappable.\n")
	else
		s, ic, b, p, a, c = tostring(s), tostring(ic), tostring(b), tostring(p), tostring(a), tostring(c)
		ScrappinDebug.body:Insert("Skipping "..i.." with flags: \n")
		ScrappinDebug.body:Insert(" > [Scrappable: "..s.."] [Compare: "..ic.."] [BoE: "..b.."] [Set: "..p.."] [Azerite: "..a.."] [Corrupted: "..c.."]\n")
	end
end

---------------------------------------------------
-- DATABASE FUNCTIONS
---------------------------------------------------
local function CheckDatabaseKeysNil(database, default)
	for key, value in pairs(default) do
		if database[key] == nil then
			database[key] = value
		elseif type(database[key]) == "table" then
			CheckDatabaseKeysNil(database[key], default[key])
		end
	end
end

---------------------------------------------------
-- SLASH COMMANDS
---------------------------------------------------
local commands = {
	["scrap"] = function()
		ns.Config.ToggleScrappinFrame()
	end,

	["reset"] = function()
		ScrappinDB = defaultDB
		print(string.format("|c%sScrapButton|r database has been reset.", ns.Config.color))
		ns.Config.UpdateCheckButtonStates()
	end,

	["debug"] = function()
		ns.Config:ToggleScrappinDebug()
	end,
}

local function HandleSlashCommands(str)
	if #str == 0 then -- player entered /scrap
		commands.scrap()
	end
	-- insert each word into a table and remove any spaces
	local args = {}
	local path = commands

	for _, arg in ipairs({ string.split(' ', str) }) do
		if #arg > 0 then
			table.insert(args, arg) -- args is now a table with each word
		end
	end

	-- iterate through commands until we find the correct one
	for id, arg in ipairs(args) do
		if #arg > 0 then
			arg = arg:lower() -- make the command into lowercase
			if path[arg] then
				if type(path[arg]) == "function" then
					path[arg]()
					-- path[arg](select(id + 1, unpack(args)))
					return
				elseif type(path[arg]) == "table" then
					path = path[arg] -- enter found subtable
				end
			else
				commands.scrap()
				return
			end
		end
	end
end

---------------------------------------------------
-- INIT
---------------------------------------------------
function ns:Init(event, name)
	if name ~= "ScrapButton" then return end

	SLASH_ScrapButton1 = shortcut
	SLASH_ScrapButton2 = "/scrapbutton"
	SlashCmdList.ScrapButton = HandleSlashCommands
	
	ns.Config.SetupFrames()
	CheckDatabaseKeysNil(ScrappinDB, defaultDB)
	ns.Config.UpdateCheckButtonStates()

	ns.Core.CreateScrapButton()
end

local addonloadedFrame = CreateFrame("Frame")
addonloadedFrame:RegisterEvent("ADDON_LOADED")
addonloadedFrame:SetScript("OnEvent", ns.Init)