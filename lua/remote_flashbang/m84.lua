local config = require("remote_flashbang.config")
local network = require("remote_flashbang.network")
local debugPrint = require("remote_flashbang.debug")

local grenade = {}
function grenade.pullPin()
    local checkGap = 4000
    local counter = 0
    local deployIfFlashed = coroutine.create(function()
        while true do
            coroutine.yield()
            counter = counter + 1
            network.getFlash(function(messages, err)
                if err then
                    print("Couldn't obtain flashes from server")
                else
                    for _, v in pairs(messages) do
                        -- deploy(v)[TODO] call lia function
                    end
                end
            end)
        end
    end)

    local function restartCoroutine()
        if coroutine.status(deployIfFlashed) ~= "running" then
            debugPrint(counter, false)
            coroutine.resume(deployIfFlashed)
        end
    end

    local peakingTimer = vim.loop.new_timer()
    if peakingTimer ~= nil then
        peakingTimer:start(0, checkGap, restartCoroutine)
    end

    vim.api.nvim_create_autocmd("FocusLost", {
        desc = "Disable https requests in the background",
        group = vim.api.nvim_create_augroup("remote_flashbang.nvim", { clear = true }),
        callback = function()
            if peakingTimer ~= nil then
                debugPrint("Not checking anymore", true)
                peakingTimer:stop()
            end
        end,
    })
    vim.api.nvim_create_autocmd("FocusGained", {
        desc = "Re-enable https requests on focus",
        group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
        callback = function()
            if peakingTimer ~= nil then
                debugPrint("checking again", true)
                peakingTimer:start(0, checkGap, restartCoroutine)
            end
        end,
    })
end

return grenade
