local config = require("flashbang.config")

function dump(o)
    if type(o) == "table" then
        local s = "{ "
        for k, v in pairs(o) do
            if type(k) ~= "number" then
                k = '"' .. k .. '"'
            end
            s = s .. "[" .. k .. "] = " .. dump(v) .. ","
        end
        return s .. "} "
    else
        return tostring(o)
    end
end

return function(message, shouldPrint)
    if shouldPrint ~= nil then
        if shouldPrint then
            print(dump(message))
        end
    else
        if config.options.debug then
            print(dump(message))
        end
    end
end
