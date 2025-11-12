local network = require("flashbang.network")
local config = require("flashbang.config")
local debugPrint = require("flashbang.debug")

local api = {}

---@type user[]
local autocompletion = {
    config.options.username,
}

local function filterCompletion(ArgLead, _, _)
    ---@type string[]
    local completion = {}
    for _, v in pairs(autocompletion) do
        if (v.active or config.options.autoCompleteInactive) and v.username:find(ArgLead) then
            table.insert(completion, v.username)
        end
    end
    return completion
end

local function completionWatcher()
    local userGap = 3000

    local userTimer = vim.loop.new_timer()

    local counter = 0
    local request = coroutine.create(function()
        while true do
            coroutine.yield()
            counter = counter + 1
            debugPrint(counter, false)
            network.getUsers(function(messages, err)
                if err then
                    debugPrint(err, true)
                else
                    autocompletion = messages
                end
            end)
        end
    end)
    local function checkCompletion()
        if userTimer ~= nil then
            userTimer:start(
                userGap,
                0,
                vim.schedule_wrap(function()
                    userTimer:stop()
                    if coroutine.status(request) ~= "running" then
                        coroutine.resume(request)
                    end
                    checkCompletion()
                end)
            )
        end
    end
    coroutine.resume(request)
    checkCompletion()
end

function api.setup()
    vim.api.nvim_create_user_command(
        "Flash", -- string
        function(opts)
            network.sendFlash(opts.args, config.options.defaultMessage)
        end, -- string or Lua function
        {
            nargs = 1,
            complete = filterCompletion,
        }
    )
    vim.api.nvim_create_user_command(
        "FlashMessage", -- string
        function(args)
            vim.ui.input({ prompt = "Message to Target: " }, function(message)
                network.sendFlash(args.args, message)
            end)
        end, -- string or Lua function
        {
            nargs = 1,
            complete = filterCompletion,
        }
    )
    completionWatcher()
end
return api
