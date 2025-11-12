local config = {}

--- Flashbang configuration with its default values.
---
---@type table
--- Default values:
---@eval return MiniDoc.afterlines_to_code(MiniDoc.current.eval_section)
config.options = {
    username = "",
    displayname = "",
    endpoint = "",
    defaultMessage = "",
    autoCompleteInactive = false,
    debug = false,
}

---@private
local defaults = vim.deepcopy(config.options)

--- Defaults Flashbang options by merging user provided options with the default plugin values.
---
---@param options table Module config table. See |Flashbang.options|.
---
---@private
function config.defaults(options)
    local newOptions = vim.deepcopy(vim.tbl_deep_extend("keep", options or {}, defaults or {}))

    assert(type(newOptions.duration) == "number", "`duration` must be a number.")

    return newOptions
end

--- Define your flashbang setup.
---
---@param options table Module config table. See |Flashbang.options|.
---
---@usage `require("flashbang").setup()` (add `{}` with your |Flashbang.options| table)
function config.setup(options)
    config.options = config.defaults(options or {})
end

return config
