local U = require('FTerm.utils')

local A = vim.api
local fn = vim.fn
local cmd = A.nvim_command

---@class Term
---@field config Config
local Term = {}

-- Init
function Term:new()
    local state = {
        win = nil,
        buf = nil,
        terminal = nil,
        tjob_id = nil,
        config = U.defaults,
    }

    return setmetatable(state, { __index = self })
end

-- Terminal:setup overrides the terminal windows configuration ie. dimensions
function Term:setup(cfg)
    if not cfg then
        return vim.notify('FTerm: setup() is optional. Please remove it!', vim.log.levels.WARN)
    end

    self.config = vim.tbl_deep_extend('force', self.config, cfg)
    self.config.cmd = U.build_cmd(self.config.cmd)

    return self
end

-- Terminal:store adds the given floating windows and buffer to the list
function Term:store(win, buf)
    self.win = win
    self.buf = buf

    return self
end

-- Terminal:remember_cursor stores the last cursor position and window
function Term:remember_cursor()
    self.last_win = A.nvim_get_current_win()
    self.prev_win = fn.winnr('#')
    self.last_pos = A.nvim_win_get_cursor(self.last_win)

    return self
end

-- Terminal:restore_cursor restores the cursor to the last remembered position
function Term:restore_cursor()
    if self.last_win and self.last_pos ~= nil then
        if self.prev_win > 0 then
            cmd('silent! ' .. self.prev_win .. 'wincmd w')
        end

        A.nvim_set_current_win(self.last_win)
        A.nvim_win_set_cursor(self.last_win, self.last_pos)

        self.last_win = nil
        self.prev_win = nil
        self.last_pos = nil
    end

    return self
end

-- Terminal:create_buf creates a scratch buffer for floating window to consume
function Term:create_buf()
    -- If previous buffer exists then return it
    local prev = self.buf

    if U.is_buf_valid(prev) then
        return prev
    end

    local buf = A.nvim_create_buf(false, true)

    -- this ensures filetype is set to Fterm on first run
    A.nvim_buf_set_option(buf, 'filetype', self.config.ft)

    return buf
end

-- Terminal:create_win creates a new window with a given buffer
function Term:create_win(buf)
    local cfg = self.config

    local dim = U.get_dimension(cfg.dimensions)

    local win = A.nvim_open_win(buf, true, {
        border = cfg.border,
        relative = 'editor',
        style = 'minimal',
        width = dim.width,
        height = dim.height,
        col = dim.col,
        row = dim.row,
    })

    A.nvim_win_set_option(win, 'winhl', 'Normal:' .. cfg.hl)
    A.nvim_win_set_option(win, 'winblend', cfg.blend)

    return win
end

function Term:handle_exit(...)
    if self.config.auto_close then
        self:close(true)
    end
    if self.config.on_exit then
        self.config.on_exit(...)
    end
end

-- Terminal:term opens a terminal inside a buffer
function Term:open_term()
    -- NOTE: we are storing window and buffer after opening terminal bcz of this `self.buf` will be `nil` initially
    if not U.is_buf_valid(self.buf) then
        -- This function fails if the current buffer is modified (all buffer contents are destroyed).
        self.terminal = fn.termopen(self.config.cmd, {
            on_stdout = self.config.on_stdout,
            on_stderr = self.config.on_stderr,
            on_exit = function(...)
                self:handle_exit(...)
            end,
        })

        -- Explanation behind the `b.terminal_job_id`
        -- https://github.com/numToStr/FTerm.nvim/pull/27/files#r674020429
        self.tjob_id = vim.b.terminal_job_id
    end

    -- This prevents the filetype being changed to term instead of fterm when closing the floating window
    A.nvim_buf_set_option(self.buf, 'filetype', self.config.ft)

    cmd('startinsert')

    return self
end

-- Terminal:open does all the magic of opening terminal
function Term:open()
    -- Move to existing window if the window already exists
    if U.is_win_valid(self.win) then
        return A.nvim_set_current_win(self.win)
    end

    -- Create new window and terminal if it doesn't exist
    self:remember_cursor()

    local buf = self:create_buf()
    local win = self:create_win(buf)

    self:open_term()

    -- Need to store the handles after opening the terminal
    self:store(win, buf)

    return self
end

-- Terminal:close does all the magic of closing terminal and clearing the buffers/windows
function Term:close(force)
    if not self.win then
        return
    end

    if U.is_win_valid(self.win) then
        A.nvim_win_close(self.win, {})
    end

    self.win = nil

    if force then
        if U.is_buf_valid(self.buf) then
            A.nvim_buf_delete(self.buf, { force = true })
        end

        fn.jobstop(self.terminal)

        self.buf = nil
        self.terminal = nil
        self.tjob_id = nil
    end

    self:restore_cursor()

    return self
end

-- Terminal:toggle is used to toggle the terminal window
function Term:toggle()
    -- If window is stored and valid then it is already opened, then close it
    if U.is_win_valid(self.win) then
        self:close()
    else
        self:open()
    end

    return self
end

-- Terminal:run is used to (open and) run commands to terminal window
function Term:run(command)
    self:open()

    local c = U.build_cmd(command)
    A.nvim_chan_send(self.tjob_id, c .. A.nvim_replace_termcodes('<CR>', true, true, true))

    return self
end

return Term
