local Term = require('FTerm.terminal')

local t = Term:new()

local M = {}

---To create a custom terminal by overriding the default command
---@param cfg table
---@return table
function M:new(cfg)
    return Term:new():setup(cfg)
end

function M.setup(opts)
    t:setup(opts)
end

function M.open()
    t:open()
end

function M.close()
    t:close()
end

function M.toggle()
    t:toggle()
end

function M.run(...)
    t:run(...)
end

return M
