--[[
SimpleHalo_Options - LoD option module for SimpleHalo
Author: Michael Joseph Murray aka Lyte of Lothar(US)
$Revision: 12 $
$Date: 2012-10-26 18:39:07 -0500 (Fri, 26 Oct 2012) $
Project Version: @project-version@
contact: codemaster2010 AT gmail DOT com

Copyright (c) 2012 Michael J. Murray aka Lyte of Lothar(US)
All rights reserved unless otherwise explicitly stated.
]]

local L = LibStub("AceLocale-3.0"):GetLocale("SimpleHalo")
local LSM = LibStub("LibSharedMedia-3.0")
local halo = LibStub("AceAddon-3.0"):GetAddon("SimpleHalo")

local opts = {
	type = 'group',
	args = {
		display = {
			type = 'group',
			name = L["Display"],
			args = {
				configMode = {
					type = 'toggle',
					name = L["Configuration Mode"],
					desc = L["Force the indicator to display for configuration purposes."],
					get = function() return configMode end,
					set = function()
						configMode = not configMode
						
						if configMode then
							halo.indicator:Show()
						else
							halo.indicator:Hide()
						end
					end,
					order = 1,
				},
				locked = {
					type = 'toggle',
					name = L["Lock Frame"],
					desc = L["Lock the frame to prevent movement."],
					get = function() return halo.db.profile.locked end,
					set = function() halo.db.profile.locked = not halo.db.profile.locked end,
					order = 2,
				},
				showRaid = {
					type = 'toggle',
					name = L["Show In Raid"],
					desc = L["Show the indicator when you enter combat in a raid group."],
					get = function() return halo.db.profile.showInRaids end,
					set = function() halo.db.profile.showInRaids = not halo.db.profile.showInRaids end,
					order = 3,
				},
				showParty = {
					type = 'toggle',
					name = L["Show In Party"],
					desc = L["Show the indicator when you enter combat in a five-man party."],
					get = function() return halo.db.profile.showInParty end,
					set = function() halo.db.profile.showInParty = not halo.db.profile.showInParty end,
					order = 4,
				},
				showSolo = {
					type = 'toggle',
					name = L["Show Solo"],
					desc = L["Show the indicator when you enter combat while solo."],
					get = function() return halo.db.profile.showSolo end,
					set = function() halo.db.profile.showSolo = not halo.db.profile.showSolo end,
					order = 5,
				},
				header2 = {
					type = 'header',
					order = 100,
					name = L["Display"],
				},
				scale = {
					type = 'range',
					name = L["Scale"],
					desc = L["Scale the frame to make it smaller or larger."],
					get = function() return halo.db.profile.scale end,
					set = function(_, v)
						halo.db.profile.scale = v
						halo.indicator:SetHeight(50*v)
						halo.indicator:SetWidth(100*v)
						
						halo.indicator.icon:SetHeight(25*v)
						halo.indicator.icon:SetWidth(25*v)

						halo.indicator.text:SetHeight(25*v)
						halo.indicator.text:SetWidth(25*v)
					end,
					min = 0.5,
					max = 2.5,
					step = 0.01,
					order = 103,
				},
				background = {
					type = 'select',
					name = L["Background"],
					desc = L["Select the background of the indicator frame."],
					get = function() return halo.db.profile.background end,
					set = function(_, v)
						halo.db.profile.background = v
						
						halo.indicator:SetBackdrop({
							bgFile = LSM:Fetch('background', halo.db.profile.background),
							edgeFile = LSM:Fetch('border', halo.db.profile.border),
							tile = false, tileSize = 16, edgeSize = 16,
							insets = { left = 5, right = 5, top = 5, bottom = 5 }
						})
					end,
					dialogControl = 'LSM30_Background',
					values = AceGUIWidgetLSMlists.background,
					order = 104,
				},
				backgroundColor = {
					type = 'color',
					name = L["Background Color"],
					desc = L["Select the color for the background of the indicator frame."],
					get = function() return unpack(halo.db.profile.bgColor) end,
					set = function(_, r, g, b, a)
						halo.db.profile.bgColor[1] = r
						halo.db.profile.bgColor[2] = g
						halo.db.profile.bgColor[3] = b
						halo.db.profile.bgColor[4] = a
						
						halo.indicator:SetBackdropColor(r, g, b, a)
					end,
					hasAlpha = true,
					order = 105,
				},
				border = {
					type = 'select',
					name = L["Border"],
					desc = L["Select the border of the indicator frame."],
					get = function() return halo.db.profile.border end,
					set = function(_, v)
						halo.db.profile.border = v
						
						halo.indicator:SetBackdrop({
							bgFile = LSM:Fetch('background', halo.db.profile.background),
							edgeFile = LSM:Fetch('border', halo.db.profile.border),
							tile = false, tileSize = 16, edgeSize = 16,
							insets = { left = 5, right = 5, top = 5, bottom = 5 }
						})
					end,
					dialogControl = 'LSM30_Border',
					values = AceGUIWidgetLSMlists.border,
					order = 106,
				},
				borderColor = {
					type = 'color',
					name = L["Border Color"],
					desc = L["Select the color for the border of the indicator frame."],
					get = function() return unpack(halo.db.profile.borderColor) end,
					set = function(_, r, g, b, a)
						halo.db.profile.borderColor[1] = r
						halo.db.profile.borderColor[2] = g
						halo.db.profile.borderColor[3] = b
						halo.db.profile.borderColor[4] = a
						
						halo.indicator:SetBackdropBorderColor(r, g, b, a)
					end,
					hasAlpha = true,
					order = 107,
				},
				plusColor = {
					type = 'color',
					name = L["Plus Color"],
					desc = L["Set the color of the 'plus' indicator (range is too far)."],
					get = function() return unpack(halo.db.profile.plusColor) end,
					set = function(_, r, g, b, a)
						halo.db.profile.plusColor[1] = r
						halo.db.profile.plusColor[2] = g
						halo.db.profile.plusColor[3] = b
						halo.db.profile.plusColor[4] = a
						
						halo.indicator.plus:SetVertexColor(r, g, b, a)
					end,
					hasAlpha = true,
					order = 108,
				},
				minusColor = {
					type = 'color',
					name = L["Minus Color"],
					desc = L["Set the color of the 'minus' indicator (range is too close)."],
					get = function() return unpack(halo.db.profile.minusColor) end,
					set = function(_, r, g, b, a)
						halo.db.profile.minusColor[1] = r
						halo.db.profile.minusColor[2] = g
						halo.db.profile.minusColor[3] = b
						halo.db.profile.minusColor[4] = a
						
						halo.indicator.minus:SetVertexColor(r, g, b, a)
					end,
					hasAlpha = true,
					order = 109,
				},
				unitGroup = {
					type = 'group',
					name = L["Watch Unit"],
					args = {
						unitText = {
							type = 'description',
							order = 1,
							name = L["Unit_HelpText"],
						},
						header1 = {
							type = 'header',
							order = 2,
							name = L["Watch Unit"],
						},
						unit = {
							type = 'select',
							name = L["Unit to Watch"],
							desc = L["Choose the unit to check for proper Halo range. Target is recommended."],
							get = function() return halo.db.profile.unit end,
							set = function(_, v)
								halo.db.profile.unit = v
								if v == "custom" then
									halo.indicator.unit = halo.db.profile.customUnit
								else
									halo.indicator.unit = v
								end
							end,
							values = {
								target = L["Target"],
								targettarget = L["Target's target"],
								boss1 = L["Boss Frame One"],
								boss2 = L["Boss Frame Two"],
								boss3 = L["Boss Frame Three"],
								boss4 = L["Boss Frame Four"],
								boss5 = L["Boss Frame Five"],
								focus = L["Focus"],
								focustarget = L["Focus' Target"],
								custom = L["Custom Unit"],
							},
							order = 3,
						},
						customUnitText = {
							type = 'description',
							order = 4,
							name = L["customUnit_helpText"],
							hidden = function()
								if halo.db.profile.unit ~= 'custom' then return true else return false end
							end,
						},
						customUnit = {
							type = 'input',
							name = L["Custom Unit"],
							desc = L["Specify a custom UnitID to check for Halo range. For advanced users only!"],
							get = function() return halo.db.profile.customUnit end,
							set = function(_, v)
								halo.db.profile.customUnit = v
								halo.indicator.unit = v
							end,
							hidden = function()
								if halo.db.profile.unit ~= 'custom' then return true else return false end
							end,
							order = 5,
						},
					},
				},
			},
		},
	},
}

opts.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(halo.db)
LibStub("AceConfig-3.0"):RegisterOptionsTable("SimpleHalo", opts)
LibStub("AceConfigDialog-3.0"):SetDefaultSize("SimpleHalo", 500, 600)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("SimpleHalo", "SimpleHalo")
