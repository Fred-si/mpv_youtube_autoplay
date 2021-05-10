package = "mpv_youtube_autoplay"
version = "0.1-1"
source = {
   url = "https://github.com/Fred-si/mpv_youtube_autoplay"
}
description = {
   summary = "An mpv plugin that add youtube autoplay next video to playlist",
   homepage = "https://github.com/Fred-si/mpv_youtube_autoplay",
   license = "MIT"
}
build = {
   type = "builtin",
   modules = {
      main = "src/main.lua",
   },
}
dependencies = {
    "luaunit >= 3.4"
}
