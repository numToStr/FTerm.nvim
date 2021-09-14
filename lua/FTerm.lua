local Term = require('FTerm.terminal')

local t = Term:new()

local M = {}

---To create a custom terminal by overriding the default command
---@param cfg table
---@return table
function M:new(cfg)
    return Term:new():setup(cfg)
end

---(optional) Configure the default terminal
---@param cfg table
function M.setup(cfg)
    t:setup(cfg)
end

---Opens the default terminal
function M.open()
    t:open()
end

---Closes the default terminal window but preserves the actual terminal session
function M.close()
    t:close()
end

---Exits the terminal session
function M.exit()
    t:close(true)
end

---Toggles the default terminal
function M.toggle()
    t:toggle()
end

---Run a arbitrary command inside the default terminal
---@param cmd string
function M.run(cmd)
    t:run(cmd)
end

---To create a scratch (use and throw) terminal. Like those good ol' C++ build terminal.
---@param cfg table
function M.scratch(cfg)
    if not cfg then
        return vim.notify('FTerm: Please provide configuration for scratch terminal', vim.log.levels.ERROR)
    end

    cfg.auto_close = false

    M:new(cfg):open()
end

return M
