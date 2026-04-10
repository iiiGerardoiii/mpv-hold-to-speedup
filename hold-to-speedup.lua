-- This script changes playback speed to 2x while the spacebar or LMB is held for 0.5 seconds
-- and reverts it to normal speed when the spacebar is released. If released earlier,
-- it toggles pause/play as default behavior.

local speed_multiplier = 2.0
local hold_threshold = 0.5
local is_speeding = false
local timer = nil
local pre_hold_speed = 1.0 -- Variable to store your original speed

local function speed_on()
    is_speeding = true
    -- Capture the speed EXACTLY as it is before we change it
    pre_hold_speed = mp.get_property_number("speed")

    mp.set_property("speed", speed_multiplier)
    mp.set_osd_ass(0, 0, "▶▶ " .. speed_multiplier .. "x faster")
end

local function speed_off()
    -- Revert to the captured speed instead of a hardcoded 1.0
    mp.set_property("speed", pre_hold_speed)
    -- Clear persistent ASS text
    mp.set_osd_ass(0, 0, "")
    -- Force OSD to refresh/clear
    is_speeding = false
    mp.osd_message("", 0)
    mp.osd_message("▶", 1)
end

-- Logic for Spacebar (includes Pause)
local function handle_space(event)
    if event.event == "down" then
        timer = mp.add_timeout(hold_threshold, speed_on)
    elseif event.event == "up" then
        if timer then timer:kill(); timer = nil end
        if is_speeding then speed_off() else mp.command("cycle pause") end
    end
end

-- Logic for Left Click (Speed only)
local function handle_click(event)
    if event.event == "down" then
        timer = mp.add_timeout(hold_threshold, speed_on)
    elseif event.event == "up" then
        if timer then timer:kill(); timer = nil end
        if is_speeding then speed_off() end
    end
end

mp.add_forced_key_binding("space", "speed_space", handle_space, {complex = true})
mp.add_forced_key_binding("MBTN_LEFT", "speed_click", handle_click, {complex = true})
