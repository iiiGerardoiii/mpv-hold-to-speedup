-- This script changes playback speed to 2x while the spacebar is held for 0.5 seconds
-- and reverts it to normal speed when the spacebar is released. If released earlier,
-- it toggles pause/play as default behavior.

local mp = require 'mp'

-- Variables to track state
local is_space_held = false
local speed_timeout = nil
local pause_triggered = false

-- Function to set playback speed
local function set_speed(speed)
    mp.set_property("speed", speed)
    mp.msg.info("Speed set to " .. speed)
end

-- Function to toggle pause/play
local function toggle_pause()
    local pause = mp.get_property_native("pause")
    mp.set_property_native("pause", not pause)
    mp.msg.info("Toggled pause to " .. tostring(not pause))
end

-- Handle spacebar key events
local function handle_spacebar(kevent)
    if kevent["event"] == "down" then
        if is_space_held then return end -- Prevent duplicate triggers
        is_space_held = true
        pause_triggered = false

        mp.msg.info("Spacebar pressed")

        -- Start a timer to check if the spacebar is held for 0.5 seconds
        speed_timeout = mp.add_timeout(0.5, function()
            if is_space_held then
                set_speed(2.0) -- Set speed to 2x
                mp.osd_message("⏩ 2 times faster ", 3)
                pause_triggered = true -- Prevent pause on release
            end
        end)
    elseif kevent["event"] == "up" then
        if speed_timeout then
            speed_timeout:kill()
            speed_timeout = nil
        end

        mp.msg.info("Spacebar released")

        if is_space_held then
            is_space_held = false

            if pause_triggered then
                set_speed(1.0) -- Reset speed to normal
                mp.osd_message("▶", 3)
            else
                toggle_pause() -- Toggle pause/play if speed wasn’t activated
            end
        end
    end
end

-- Bind the spacebar with a forced key binding
mp.add_forced_key_binding("space", "handle_spacebar", handle_spacebar, {
    repeatable = false,
    complex = true
})
