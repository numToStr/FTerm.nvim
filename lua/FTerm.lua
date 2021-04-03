local T = require("FTerm.terminal")

local t = T:new()

local M = {}

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

return M
