--- This module is a part of mpv_youtube_autoplay plugin for mpv
--
-- This plugin look for the current full path of the current playing video
-- and if current video is youtube video, simply add the next autoplay video
-- by fetching info from youtube.com

local mp = require("mp")

local http = require("http")
local yt = require("youtube")

function is_in_playlist(filename)
    local playlist_count = tonumber(mp.get_property("playlist-count"))

    for i = 0, playlist_count - 1 do
        if filename == mp.get_property("playlist/" .. i .. "/filename") then
            return true
        end
    end

    return false
end

function is_last_element_in_playlist()
    local current_position = tonumber(mp.get_property("playlist-playing-pos"))
    if current_position < 0 then return false end


    local playlist_count = tonumber(mp.get_property("playlist-count"))
    return current_position == (playlist_count - 1)
end

function on_playlist_playing_pos_change()
    -- Do nothing if current playing video is not the last element in playlist
    if not is_last_element_in_playlist() then return end

    local err, current_url = yt.sanitize_url(mp.get_property("path") or '')
    if err ~= nil then return end

    local next_url = yt.get_autoplay_url(http.get(current_url))
    if is_in_playlist(next_url) then
        mp.msg.info(next_url .. " already in playlist, nothing to do.")
        return
    end

    mp.commandv("loadfile", next_url, "append-play")
    mp.osd_message(next_url .. " as been added to playlist", 5)
end

mp.observe_property("playlist-playing-pos", "string", on_playlist_playing_pos_change)
