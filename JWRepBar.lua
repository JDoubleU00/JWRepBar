-- Yes Another XP Bar.

--Config area
local JWBarHeight = 28
local JWBarWidth = 250
local JWBarPoint = {"CENTER", "JWRepBarFrame","CENTER", 0, 0}
local JWBarTexture = "Interface\\TargetingFrame\\UI-StatusBar"
local JWBarFont = [[Fonts\FRIZQT__.TTF]]
--local JWBarFont = [[Interface\addons\JWRepBar\ROADWAY_.ttf]]
local JWBarFontSize = 15
local JWBarFontFlags = "NONE"

--Beyond here be dragons
function comma_value(n)
  return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1,"):gsub(",(%-?)$","%1"):reverse()
end

local function tchelper(first, rest)
  return first:upper()..rest:lower()
end

local JWRepBarFrame = CreateFrame("Frame", "JWRepBarFrame", UIParent)
JWRepBarFrame:SetFrameStrata("HIGH")
JWRepBarFrame:SetHeight(JWBarHeight)
JWRepBarFrame:SetWidth(JWBarWidth)
if IsAddOnLoaded("JWXPBar") then
	JWRepBarFrame:SetPoint("BOTTOM", "JWXPBar", "TOP", 0, 5)
else
	JWRepBarFrame:SetPoint("CENTER", UIPARENT, "CENTER", 0, -275)
end
JWRepBarFrame:EnableMouse(true)
JWRepBarFrame:SetMovable(true)
JWRepBarFrame:SetClampedToScreen(true)

--Create Background and Border
local backdrop = JWRepBarFrame:CreateTexture(nil, "BACKGROUND")
backdrop:SetHeight(JWBarHeight)
backdrop:SetWidth(JWBarWidth)
backdrop:SetPoint(unpack(JWBarPoint))
backdrop:SetTexture(JWBarTexture)
backdrop:SetVertexColor(0.1, 0.1, 0.1)
JWRepBarFrame.backdrop = backdrop

--Rep Bar
local JWRepBar = CreateFrame("StatusBar", "JWRepBar", JWRepBarFrame)
JWRepBar:SetWidth(JWBarWidth)
JWRepBar:SetHeight(JWBarHeight)
JWRepBar:SetPoint(unpack(JWBarPoint))
JWRepBar:SetStatusBarTexture(JWBarTexture)
JWRepBar:GetStatusBarTexture():SetHorizTile(false)
JWRepBarFrame.JWRepBar = JWRepBar

--Create XP Text
local Text = JWRepBar:CreateFontString("JWRepBarText", "OVERLAY")
Text:SetFont(JWBarFont, JWBarFontSize, JWBarFontFlags)
Text:SetPoint("CENTER", JWRepBar, "CENTER",0,1)
Text:SetAlpha(1)

JWRepBarFrame:SetScript("OnMouseDown", function(self, button)
  if button == "LeftButton" and (IsShiftKeyDown()) and not self.isMoving then
   self:StartMoving();
   self.isMoving = true;
  end
end)

JWRepBarFrame:SetScript("OnMouseUp", function(self, button)
  if button == "LeftButton" and (IsShiftKeyDown()) and self.isMoving then
   self:StopMovingOrSizing();
   self.isMoving = false;
  end
end)
	
local function UpdateStatus()
	local JWRepName, JWRepStanding, JWRepMin, JWRepMax, JWRepCur = GetWatchedFactionInfo()
	if JWRepName then
		local JWRepColor = FACTION_BAR_COLORS[JWRepStanding]
		JWRepBar:SetStatusBarColor(JWRepColor.r * 0.8, JWRepColor.g * 0.8, JWRepColor.b * 0.8)
		JWRepBar:SetMinMaxValues(JWRepMin, JWRepMax)
		JWRepBar:SetValue(JWRepCur)
		JWRepName = JWRepName:gsub("(%a)([%w_']*)", tchelper) --Proper case
		Text:SetText(format("%s %s/%s ", JWRepName, comma_value(JWRepCur), comma_value(JWRepMax)))
		return
	end	
end

JWRepBarFrame:RegisterEvent("UPDATE_FACTION")
JWRepBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
JWRepBarFrame:SetScript("OnEvent", UpdateStatus)