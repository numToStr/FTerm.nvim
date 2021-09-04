local t = require('FTerm.terminal'):new()

local M = {}

function M.setup(opts)
    return t:setup(opts)
end

function M.open()
    return t:open()
end

function M.close()
    return t:close()
end

function M.toggle()
    return t:toggle()
end

function M.run(...)
    return t:run(...)
end

return M
