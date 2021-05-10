--- This module is a part of mpv_youtube_autoplay plugin for mpv
--
-- This plugin look for the current full path of the current playing video
-- and if current video is youtube video, simply add the next autoplay video
-- by fetching info from youtube.com

local mp = require("mp")

local http = require("http")
local yt = require("youtube")

function on_playlist_pos_change(property_name, position)
    local path = mp.get_property("path")

    local err, current_url = yt.sanitize_url(mp.get_property("path") or '')
    if err ~= nil then return end

    local next_url = yt.get_autoplay_url(http.get(current_url))

    mp.commandv("loadfile", next_url, "append-play")

    local msg = string.format("video %s as been added to playlist", next_url)
    mp.osd_message(msg, 5)
end

mp.observe_property("playlist-playing-pos", "string", on_playlist_pos_change)
