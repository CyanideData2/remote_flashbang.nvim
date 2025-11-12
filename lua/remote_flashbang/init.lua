local config = require("remote_flashbang.config")
local network = require("remote_flashbang.network")
local api = require("remote_flashbang.api")
local grenade = require("remote_flashbang.m84")

local Remote_flashbang = {}

function Remote_flashbang.setup(opts)
    config.setup(opts)
    network.register()
    api.setup()
    grenade.pullPin()
end

return Remote_flashbang
