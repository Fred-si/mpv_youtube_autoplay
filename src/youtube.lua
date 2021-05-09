--- This module is a part of mpv_youtube_autoplay plugin for mpv
--
-- This module is an adapter for query youtube autoplay next video by
-- parsing youtube html page of youtube video.
--
-- This module provide 2 functions:
--      sanitize_url take video url and return "err, url"
--      get_autoplay_url take the html page of youtube video and return next video url
--
-- The method get_autoplay_url work by find "ytInitialData" javascript object in
-- html page and use the mpv json parser for extract the next video id.

local YOUTUBE_DOMAINS = {"www.youtube.com", "youtu.be"}

-- This is the path of the next autoplay video in ytInitialData javascript
-- object contained in html page
local VIDEO_ID_PATH = {
    'contents',
    'twoColumnWatchNextResults',
    'autoplay',
    'autoplay',
    'sets',
    1,
    'autoplayVideo',
    'watchEndpoint',
    'videoId'
}

--- Return true if given string start with a valid youtube domain
-- @param url string
-- @return bool
local function is_youtube(url)
    for _, domain in ipairs(YOUTUBE_DOMAINS) do
        local pattern = "^https://" .. domain .. "/"
        if url:find(pattern) then
            return true
        end
    end

    return false
end

--- Return youtube url that can be passed to curl
-- @param url
-- @return error message or nil
-- @return the sanatized url
local function sanitize_url(url)
    if not is_youtube(url) then
        return 'Not youtube url', ''
    end

    if url:match('youtu.be') then
        local video_id = url:gmatch('youtu.be/([^?]+)')()
        return nil, 'https://www.youtube.com/watch?v=' .. video_id
    end

    return nil, url
end

--- Get the ytInitialData table in html page
-- @param html_page a string that contain a youtube video html page
-- @param json_parser the json parser to use
-- @return table
local function get_initial_data(html_page, json_parser)
    local initial_data = string.gmatch(html_page, 'ytInitialData = ({.*});</script>')()

    if not initial_data then
        error({name = "NotFoundError", message = "No ytInitialData in given string"})
    end

    local parsed, err = json_parser(initial_data)
    if err ~= nil then
        error(err)
    end

    return parsed

end

--- Get the video id of next autoplay video by following the VIDEO_ID_PATH path
-- @param initial_data table
-- @return string the video id
local function extract_video_id(initial_data)
    local ret = initial_data
    for _, property_name in ipairs(VIDEO_ID_PATH) do
        ret = ret[property_name]
    end

    return ret
end

--- Get the next video from youtube html video page
-- @param html_page a string that contain youtube video html page
-- @param json_parser OPTIONAL the json parser to use
-- @return the url of autoplay next video
local function get_autoplay_url(html_page, json_parser)
    -- mp module is not available in LuaUnit test, we need to stub it
    local json_parser = json_parser or require("mp.utils").parse_json

    local initial_data = get_initial_data(html_page, json_parser)
    local ok, video_id = pcall(extract_video_id, initial_data)
    if not ok then
        error({name = "NotFoundError", message = "videoId is not in given object"})
    end

    return 'https://youtu.be/' .. video_id
end

return {
    sanitize_url = sanitize_url,
    get_autoplay_url = get_autoplay_url,
}

