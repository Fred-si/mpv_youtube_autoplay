# Fresh paint
This is an mpv plugin for autoplay video from youtube.

This plugin automatically append the next autoplay video to the mpv playlist

## Installation
- Go to your mpv scripts directory `cd $HOME/.config/mpv/scripts` by default
- Clone the repository
  `git clone https://github.com/Fred-si/mpv_youtube_autoplay.git`
  or `git clone git@github.com:Fred-si/mpv_youtube_autoplay.git`

## Usage
nothing to do

## Setup dev environment
The project come with unit test based on LuaUnit library for test the youtube
adapter, for install it simply use `make setup` for init luarocks project and
install dev dependencies.

Use `make test` for launch test suite.

For remove luarocks files use `make teardown`.


