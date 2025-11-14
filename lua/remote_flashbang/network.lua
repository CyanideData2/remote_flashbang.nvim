local config = require("remote_flashbang.config")
local debugPrint = require("remote_flashbang.debug")

local Network = {}

local counter = 0
function Network.getFlash(callback)
    counter = counter + 1
    vim.system({
        "curl",
        config.options.endpoint .. "/get_unread?username=" .. config.options.username,
    }, {}, function(result)
        if result.code ~= 0 then
            callback(nil, "Error: getFlash couldn't get messages")
            return
        end

        local success, data = pcall(vim.json.decode, result.stdout)
        if not success then
            callback(nil, "Error: Failed to parse JSON")
            return
        end

        callback(data.messages, nil)
    end)
end

function Network.sendFlash(receiver, message)
    local function urlEncode(str)
        str = string.gsub(str, "([^%w%.%- ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
        return str
    end
    local betterRequest = vim.system({
        "curl",
        config.options.endpoint
        .. "/send?sender="
        .. config.options.username
        .. "&receiver="
        .. receiver
        .. "&message="
        .. urlEncode(message),
    }, {}, function(obj)
        print(obj.stdout)
    end)
end

---@class user
---@field username string
---@field displayname string
---@field active boolean

---@return user[]
function Network.getUsers(callback)
    local url = config.options.endpoint .. "/get_users_active"
    vim.system({ "curl", url }, {}, function(result)
        if result.code ~= 0 then
            callback(nil, "Error: getUsers couldn't get messages")
            return
        end

        local success, data = pcall(vim.json.decode, result.stdout)
        if not success then
            callback(nil, "Error: Failed to parse JSON")
            return
        end

        callback(data.users, nil)
    end)
end

function Network.register()
    local betterRequest = vim.system({
        "curl",
        config.options.endpoint
        .. "/register?username="
        .. config.options.username
        .. "&displayname="
        .. config.options.displayname,
    })
end

return Network
