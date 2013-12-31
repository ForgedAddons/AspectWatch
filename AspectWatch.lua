local config = {
	use_custom_frame = false, -- set to "true" to use custom message frame
	font_size = 16, -- msbt and custon frame font size
	sound = true,
	
	accept_hawk = true,
	accept_fox = true,
	accept_cheetah = true,
	accept_pack = true,
	accept_wild = true,
}

if select(2, UnitClass("player")) ~= "HUNTER" then
	return DisableAddOn("AspectWatch")
end

local message_frame = false
local function create_message_frame()
	if message_frame then return end
	message_frame = CreateFrame("MessageFrame", "aspect_watch_message_frame", UIParent)
	message_frame:SetWidth(512)
	message_frame:SetHeight(80)
	
	message_frame:SetPoint("CENTER", 0, -20)
	message_frame:SetScale(1)
	message_frame:SetInsertMode("TOP")
	message_frame:SetFrameStrata("HIGH")
	message_frame:SetToplevel(true)
	message_frame:SetFont("Fonts\\FRIZQT__.TTF", config.font_size, "OUTLINE")
	message_frame:Show()
	message_frame:SetFadeDuration(0)
	message_frame:SetTimeVisible(1)

end

local ASPECT = {
	HAWK        = GetSpellInfo(13165),
	FOX         = GetSpellInfo(82661),
	CHEETAH     = GetSpellInfo(5118),
	PACK        = GetSpellInfo(13159),
	WILD        = GetSpellInfo(20043),
}

local last_timestamp = 0
local function _AspectWatchSpamPreventer()
	local newtime = time()
	if (newtime - last_timestamp) < 2 then return true end
	last_timestamp = newtime
	return false
end

local function sct(tx, r, g, b, sticky)
	if config.sound then
		PlaySoundFile("Sound\\interface\\RaidWarning.wav");
	end
	if config.use_custom_frame then
			if message_frame == false then create_message_frame() end
			message_frame:AddMessage(tx, r, g, b, 1, 1);
	elseif _G.MikSBT then
		MikSBT.DisplayMessage(tx, MikSBT.DISPLAYTYPE_NOTIFICATION, sticky, r * 255, g * 255, b * 255, config.font_size)
	elseif _G.SCT then	
		local sct_color = {}
		sct_color.r, sct_color.g, sct_color.b = r, g, b
		SCT:DisplayCustomEvent(tx, sct_color, sticky, SCT.MSG, nil, nil)
	elseif _G.Parrot then
		Parrot:ShowMessage(tx, "Notification", sticky, r, g, b, nil, nil, nil, nil)
	elseif not(not SHOW_COMBAT_TEXT or tostring(SHOW_COMBAT_TEXT) == "0") then
		if tostring(SHOW_COMBAT_TEXT) ~= "0" then
			CombatText_AddMessage(tx, CombatText_StandardScroll, r, g, b, sticky and "crit" or nil, false)
		else
			UIErrorsFrame:AddMessage(tx, r, g, b, 1, UIERRORS_HOLD_TIME)
		end
	end
end

local function AspectCheck()
	if UnitIsDeadOrGhost("player") or IsMounted() or UnitInVehicle("player") or _AspectWatchSpamPreventer() or UnitLevel("player") < 10 then return end
	
	if (config.accept_hawk and UnitBuff("player", ASPECT.HAWK) == ASPECT.HAWK)
		or (config.accept_fox and UnitBuff("player", ASPECT.FOX) == ASPECT.FOX)
		or (config.accept_cheetah and UnitBuff("player", ASPECT.CHEETAH) == ASPECT.CHEETAH)
		or (config.accept_pack and UnitBuff("player", ASPECT.PACK) == ASPECT.PACK)
		or (config.accept_wild and UnitBuff("player", ASPECT.WILD) == ASPECT.WILD) then
		return
	else
		sct("! Aspect !", 1, 0.5, 0.5, true) 
	end
end

local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(self, event, ...) AspectCheck() end)
