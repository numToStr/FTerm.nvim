local T = require'FTerm.terminal'

local t = T:new()

local M = {}

function M.open()
    t:open()
end

function M.close()
    t:open()
end

function M.toggle()
    t:toggle()
end

return M
