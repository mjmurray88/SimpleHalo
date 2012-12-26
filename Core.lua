--[[
SimpleHalo
Author: Michael Joseph Murray aka Lyte of Lothar(US)
$Revision: 13 $
$Date: 2012-10-26 20:22:31 -0500 (Fri, 26 Oct 2012) $
Project Version: r250
contact: codemaster2010 AT gmail DOT com

Copyright (c) 2012 Michael J. Murray aka Lyte of Lothar(US)
All rights reserved unless otherwise explicitly stated.
]]

if select(2, UnitClass("player")) ~= "PRIEST" then return end

SimpleHalo = LibStub("AceAddon-3.0"):NewAddon("SimpleHalo", "AceConsole-3.0", "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")
local LRC = LibStub("LibRangeCheck-2.0")

function SimpleHalo:OnInitialize()
	local defaults = {
		profile = {
			position = {},
			locked = false,
			scale = 1,
			unit = "target",
			customUnit = "none",
			background = "Blizzard Tooltip",
			border = "Blizzard Tooltip",
			bgColor = {0.65, 0.65, 0.65, 0.65},
			borderColor = {1, 1, 1, 1},
			minusColor = {1, 1, 1, 1},
			plusColor = {1, 1, 1, 1},
			showInRaids = true,
			showInParty = true,
			showSolo = false,
		},
	}
	
	self.db = LibStub("AceDB-3.0"):New("SimpleHaloDB", defaults, "Default")
	self.db.RegisterCallback(self, "OnProfileReset", "Reset")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	
	self:RegisterChatCommand("halo", "OpenConfig", true, true)
	self:RegisterChatCommand("simplehalo", "OpenConfig")
	
	self.indicator = self:CreateIndicator()
	self.hasHalo = false
end

function SimpleHalo:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "LeaveCombat")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "EnterCombat")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", "TalentUpdate")
	self:TalentUpdate()
end

function SimpleHalo:Reset()
	self.indicator:SetHeight(35)
	self.indicator:SetWidth(70)
	
	self.indicator.icon:SetHeight(25)
	self.indicator.icon:SetWidth(25)

	self.indicator.plus:SetHeight(25)
	self.indicator.plus:SetWidth(25)
	
	self.indicator.minus:SetHeight(25)
	self.indicator.minus:SetWidth(25)
	
	self.indicator:ClearAllPoints()
	self.indicator:SetPoint("CENTER", UIParent, "CENTER")
	
	self.indicator:EnableMouse(true)
end

function SimpleHalo:Refresh()
	local db = self.db.profile
	
	self.indicator:SetHeight(35*db.scale)
	self.indicator:SetWidth(70*db.scale)
	
	self.indicator.icon:SetHeight(25*db.scale)
	self.indicator.icon:SetWidth(25*db.scale)

	self.indicator.plus:SetHeight(25*db.scale)
	self.indicator.plus:SetWidth(25*db.scale)
	
	self.indicator.minus:SetHeight(25*db.scale)
	self.indicator.minus:SetWidth(25*db.scale)
	
	self.indicator:ClearAllPoints()
	if db.position.x then
		self.inticator:SetPoint(db.position.point, UIParent, db.position.anchor, db.position.x, db.position.y)
	else
		self.indicator:SetPoint("CENTER", UIParent, "CENTER")
	end
	
	if db.locked then
		self.indicator:EnableMouse(false)
	else
		self.indicator:EnableMouse(true)
	end
end

function SimpleHalo:OpenConfig()
	LoadAddOn("SimpleHalo_Options")
	LibStub("AceConfigDialog-3.0"):Open("SimpleHalo")
end

function SimpleHalo:TalentUpdate()
	local _, _, _, _, selected = GetTalentInfo(18) --Halo is the 18th talent
	
	self.hasHalo = selected
end

function SimpleHalo:EnterCombat()
	local num = GetNumGroupMembers()
	local inRaid = UnitInRaid("player")
	
	if self.hasHalo then
		if (num == 0 and self.db.profile.showSolo)
			or (num > 0 and num <= 5 and (not inRaid) and self.db.profile.showInParty)
			or (inRaid and self.db.profile.showInRaids)
		then
			self.indicator:Show()
		end
	end
end

function SimpleHalo:LeaveCombat()
	--hide the frame to stop range polling
	self.indicator:Hide()
end

local lastUpdate = 0
local function updateRange(frame, elapsed)
	lastUpdate = lastUpdate + elapsed
	if lastUpdate < 0.15 then return end
	
	lastUpdate = 0
	
	local minRange, maxRange = LRC:GetRange(frame.unit)
	
	--This is the same logic used by HaloPro, which the Theorycrafters love
	if (not minRange) or (not maxRange) then
		--no range information
		frame.icon:SetVertexColor(1,1,1)
		frame.minus:Hide()
		frame.plus:Hide()
	elseif maxRange <= 15 then
		--within 15 yards of target
		--too close!
		frame.icon:SetVertexColor(1,0,0)
		frame.minus:Show()
		frame.plus:Hide()
	elseif minRange >= 15 and maxRange <= 20 then
		--between 15 and 20 yards of target
		--slightly too close
		frame.icon:SetVertexColor(1,1,0)
		frame.minus:Show()
		frame.plus:Hide()
	elseif minRange >= 20 and maxRange <= 25 then
		--sweet spot
		frame.icon:SetVertexColor(0,1,0)
		frame.minus:Hide()
		frame.plus:Hide()
	elseif minRange >= 25 and maxRange <=30 then
		--between 25 and 30 yards of target
		--slightly too far
		frame.icon:SetVertexColor(1,1,0)
		frame.minus:Hide()
		frame.plus:Show()
	elseif minRange > 30 then
		--more than 30 yards
		--too far!
		frame.icon:SetVertexColor(1,0,0)
		frame.minus:Hide()
		frame.plus:Show()
	end
end

function SimpleHalo:CreateIndicator()
	local db = self.db.profile
	local f = CreateFrame("FRAME", nil, UIParent)
	
	--size and positon
	f:SetWidth(70*db.scale)
	f:SetHeight(35*db.scale)
	
	if self.db.profile.position.x and self.db.profile.position.y and self.db.profile.position.anchor and self.db.profile.position.point then
		f:ClearAllPoints()
		f:SetPoint(self.db.profile.position.point, UIParent, self.db.profile.position.anchor, self.db.profile.position.x, self.db.profile.position.y)
	else
		f:SetPoint("CENTER", UIParent, "CENTER")
	end
	
	--style the frame
	f:SetBackdrop({
		bgFile = LSM:Fetch('background', self.db.profile.background),
		edgeFile = LSM:Fetch('border', self.db.profile.border),
		tile = false, tileSize = 16, edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 }
	})
	f:SetBackdropColor(unpack(self.db.profile.bgColor))
	f:SetBackdropBorderColor(unpack(self.db.profile.borderColor))
	
	f.icon = f:CreateTexture()
	f.icon:SetTexture([[Interface\AddOns\SimpleHalo\Art\icon.tga]])
	f.icon:SetHeight(25*db.scale)
	f.icon:SetWidth(25*db.scale)
	f.icon:ClearAllPoints()
	f.icon:SetPoint("LEFT", f, "LEFT", 5, 0)
	
	f.minus = f:CreateTexture()
	f.minus:SetTexture([[Interface\AddOns\SimpleHalo\Art\minus.tga]])
	f.minus:SetHeight(25*db.scale)
	f.minus:SetWidth(25*db.scale)
	f.minus:SetVertexColor(unpack(self.db.profile.minusColor))
	f.minus:ClearAllPoints()
	f.minus:SetPoint("RIGHT", f, "RIGHT", -10, 0)
	f.minus:Hide()
	
	f.plus = f:CreateTexture()
	f.plus:SetTexture([[Interface\AddOns\SimpleHalo\Art\plus.tga]])
	f.plus:SetHeight(25*db.scale)
	f.plus:SetWidth(25*db.scale)
	f.plus:SetVertexColor(unpack(self.db.profile.plusColor))
	f.plus:ClearAllPoints()
	f.plus:SetPoint("RIGHT", f, "RIGHT", -10, 0)
	f.plus:Hide()
	
	--setup dragging
	f:SetClampedToScreen(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	if self.db.profile.locked then
		f:EnableMouse(false)
	else
		f:EnableMouse(true)
	end
	
	f:SetScript("OnDragStart", function() f:StartMoving() end )
	f:SetScript("OnDragStop", function ()
		f:StopMovingOrSizing()
		local point, _, anchor, x, y = f:GetPoint()
		SimpleHalo.db.profile.position.x = floor(x)
		SimpleHalo.db.profile.position.y = floor(y)
		SimpleHalo.db.profile.position.anchor = anchor
		SimpleHalo.db.profile.position.point = point
	end)
	
	if self.db.profile.unit ~= "custom" then
		f.unit = self.db.profile.unit
	else
		f.unit = self.db.profile.customUnit
	end
	
	--set our update script
	f:SetScript("OnUpdate", updateRange)
	
	--hide and return
	f:Hide()
	return f
end
