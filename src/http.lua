--- This module is a part of mpv_youtube_autoplay plugin for mpv
--
-- This module is a simple wrapper for curl|wget, is require curl or wget that
-- installed in the system.

local CURL_CMD = "curl --silent '%s'"
local WGET_CMD = "wget --quiet -output-document - '%s'"

local get_command
-- Throw error if curl and wget not in PATH
if os.execute('which curl > /dev/null 2>&1') then
    get_command = CURL_CMD
elseif os.execute('which wget > /dev/null 2>&1') then
    get_command = WGET_CMD
else
    error({name = "MissingDependencies", message = "Unable to find curl or wget in $PATH"})
end


--- Return the page at the url
-- @param url the url to get
-- @return the response of get request
local function get(url)
    local curl = io.popen(get_command:format(url))
    local response = curl:read("*a")
    local is_ok, _, exit_code = curl:close()

    if not is_ok then
        error({name = "RequestError", message = "Unable to get youtube page", curl_exit_code = exit_code})
    end

    return response
end

return {get = get}
