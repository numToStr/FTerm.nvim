local Term = require('FTerm.terminal')

local M = {}

local t = Term:new()

---Creates a custom terminal
---@param cfg Config
---@return Term
function M:new(cfg)
    return Term:new():setup(cfg)
end

---(Optional) Configure the default terminal
---@param cfg Config
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
---@param cmd Command
function M.run(cmd)
    if not cmd then
        return vim.notify('FTerm: Please provide a command to run', vim.log.levels.ERROR)
    end

    t:run(cmd)
end

---Returns the job id of the terminal if it exists
function M.get_job_id()
  return t.terminal
end

---To create a scratch (use and throw) terminal. Like those good ol' C++ build terminal.
---@param cfg Config
function M.scratch(cfg)
    if not cfg then
        return vim.notify('FTerm: Please provide configuration for scratch terminal', vim.log.levels.ERROR)
    end

    cfg.auto_close = false

    M:new(cfg):open()
end

return M
