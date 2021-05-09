local lu = require("luaunit")
local yt = require("src/youtube")

TestSanitizeUrl = {}
function TestSanitizeUrl:test_is_not_youtube_url()
    local err, url = yt.sanitize_url('toto')

    lu.assert_not_equals(err, nil)
end

function TestSanitizeUrl:test_is_youtube_dot_com_url()
    local test_url = 'https://www.youtube.com/watch?v=PvKb97LW04A'
    local err, url = yt.sanitize_url(test_url)

    lu.assert_equals(err, nil)
    lu.assert_equals(url, test_url)
end

function TestSanitizeUrl:test_is_youtu_dot_be_url()
    local expected_url = 'https://www.youtube.com/watch?v=PvKb97LW04A'
    local err, url = yt.sanitize_url('https://youtu.be/PvKb97LW04A')

    lu.assert_equals(err, nil)
    lu.assert_equals(url, expected_url)
end

function TestSanitizeUrl:test_is_youtu_dot_be_url_with_time()
    local expected_url = 'https://www.youtube.com/watch?v=PvKb97LW04A'
    local err, url = yt.sanitize_url('https://youtu.be/PvKb97LW04A?t=30')

    lu.assert_equals(err, nil)
    lu.assert_equals(url, expected_url)
end

TestGetAutoplayUrl = {
    no_initial_data_error = {name = "NotFoundError", message = "No ytInitialData in given string"},
    no_autoplay_id_error = {name = "NotFoundError", message = "videoId is not in given object"},
    fake_object = {
        contents = {
            twoColumnWatchNextResults = {
                autoplay = {
                    autoplay = {
                        sets = {
                            {autoplayVideo = {watchEndpoint = {videoId = 'PvKb97LW04A'}}}
                        }
                    }
                }
            }
        }
    }
}
function TestGetAutoplayUrl:test_empty_string_should_throw_error()
    lu.assert_error_msg_equals(self.no_initial_data_error, yt.get_autoplay_url, '', '')
end

function TestGetAutoplayUrl:test_should_throw_error_if_string_not_contain_initial_data()
    lu.assert_error_msg_equals(self.no_initial_data_error, yt.get_autoplay_url, 'foo', '')
end

function TestGetAutoplayUrl:test_should_throw_error_if_autoplay_id_is_not_in_object()
    local parser = function() return {}, nil end
    lu.assert_error_msg_equals(
        self.no_autoplay_id_error,
        yt.get_autoplay_url, 'ytInitialData = {};</script>', parser
    )

end

function TestGetAutoplayUrl:test_ytInitialData_contain_semicolon()
    local argument
    local parser = function(arg)
        argument = arg
        return self.fake_object, nil
    end

    yt.get_autoplay_url('ytInitialData = {;};</script>', parser)
    lu.assert_equals(argument, '{;}')

    yt.get_autoplay_url('ytInitialData = {"foo": {return {"foo": "bar"};};</script><script> };', parser)
    lu.assert_equals(argument, '{"foo": {return {"foo": "bar"};}')
end

function TestGetAutoplayUrl:test_should_return_video_url()
    local parser = function() return self.fake_object, nil end

    lu.assert_equals(
        yt.get_autoplay_url('ytInitialData = {};</script>', parser),
        'https://youtu.be/PvKb97LW04A'
    )
end

os.exit( lu.LuaUnit.run() )
