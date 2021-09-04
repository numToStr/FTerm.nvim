local utils = require('FTerm.utils')

local api = vim.api
local fn = vim.fn
local cmd = api.nvim_command

local Terminal = {
    au_close = {},
}

-- Init
function Terminal:new()
    local state = {
        win = nil,
        buf = nil,
        terminal = nil,
        tjob_id = nil,
        config = utils.defaults,
    }

    self.__index = self
    return setmetatable(state, self)
end

-- Terminal:setup overrides the terminal windows configuration ie. dimensions
function Terminal:setup(cfg)
    if not cfg then
        return vim.notify('FTerm: setup() is now optional. Please remove it!', vim.log.levels.WARN)
    end

    self.config = vim.tbl_deep_extend('force', self.config, cfg)

    return self
end

-- Terminal:store adds the given floating windows and buffer to the list
function Terminal:store(win, buf)
    self.win = win
    self.buf = buf

    return self
end

-- Terminal:remember_cursor stores the last cursor position and window
function Terminal:remember_cursor()
    self.last_win = api.nvim_get_current_win()
    self.prev_win = fn.winnr('#')
    self.last_pos = api.nvim_win_get_cursor(self.last_win)

    return self
end

-- Terminal:restore_cursor restores the cursor to the last remembered position
function Terminal:restore_cursor()
    if self.last_win and self.last_pos ~= nil then
        if self.prev_win > 0 then
            cmd('silent! ' .. self.prev_win .. 'wincmd w')
        end

        api.nvim_set_current_win(self.last_win)
        api.nvim_win_set_cursor(self.last_win, self.last_pos)

        self.last_win = nil
        self.prev_win = nil
        self.last_pos = nil
    end

    return self
end

-- Terminal:create_buf creates a scratch buffer for floating window to consume
function Terminal:create_buf()
    -- If previous buffer exists then return it
    local prev = self.buf

    if utils.is_buf_valid(prev) then
        return prev
    end

    return api.nvim_create_buf(false, true)
end

-- Terminal:create_win creates a new window with a given buffer
function Terminal:create_win(buf)
    local dim = utils.build_dimensions(self.config.dimensions)

    local win = api.nvim_open_win(buf, true, {
        border = self.config.border,
        relative = 'editor',
        style = 'minimal',
        width = dim.width,
        height = dim.height,
        col = dim.col,
        row = dim.row,
    })

    api.nvim_win_set_option(win, 'winhl', 'Normal:Normal')

    -- Setting filetype in `create_win()` instead of `create_buf()` because window options
    -- such as `winhl`, `winblend` should be available after the window is created.
    api.nvim_buf_set_option(buf, 'filetype', 'FTerm')

    return win
end

-- Terminal:term opens a terminal inside a buffer
function Terminal:term()
    -- NOTE: we are storing window and buffer after opening terminal bcz of this `self.buf` will be `nil` initially
    if not utils.is_buf_valid(self.buf) then
        -- This function fails if the current buffer is modified (all buffer contents are destroyed).
        local pid = fn.termopen(self.config.cmd)

        -- IDK what to do with this now, maybe later we can use it
        self.terminal = pid

        -- Explanation behind the `b.terminal_job_id`
        -- https://github.com/numToStr/FTerm.nvim/pull/27/files#r674020429
        self.tjob_id = vim.b.terminal_job_id

        -- Only close the terminal buffer when `auto_close` is true
        if self.config.auto_close then
            -- Give every terminal instance their own key
            local key = string.format('%p', self.config)

            -- Need to setup different TermClose autocmd for different terminal instances
            -- Otherwise this will be overriden by other terminal aka custom terminal
            Terminal.au_close[key] = function()
                self:close(true)
            end

            -- This fires when someone executes `exit` inside term
            -- So, in this case the buffer should also be removed instead of reusing
            cmd(string.format("autocmd! TermClose <buffer> lua require('FTerm.terminal').au_close['%s']()", key))
        end
    end

    cmd('startinsert')

    return self
end

-- Terminal:open does all the magic of opening terminal
function Terminal:open()
    -- Move to existing window if the window already exists
    if utils.is_win_valid(self.win) then
        return api.nvim_set_current_win(self.win)
    end

    -- Create new window and terminal if it doesn't exist
    self:remember_cursor()

    local buf = self:create_buf()
    local win = self:create_win(buf)

    self:term()

    -- Need to store the handles after opening the terminal
    self:store(win, buf)

    return self
end

-- Terminal:close does all the magic of closing terminal and clearing the buffers/windows
function Terminal:close(force)
    if not self.win then
        return
    end

    if utils.is_win_valid(self.win) then
        api.nvim_win_close(self.win, {})
    end

    self.win = nil

    if force then
        if utils.is_buf_valid(self.buf) then
            api.nvim_buf_delete(self.buf, { force = true })
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
function Terminal:toggle()
    -- If window is stored and valid then it is already opened, then close it
    if utils.is_win_valid(self.win) then
        self:close()
    else
        self:open()
    end

    return self
end

-- Terminal:run is used to (open and) run commands to terminal window
function Terminal:run(command)
    self:open()
    api.nvim_chan_send(self.tjob_id, command)

    return self
end

return Terminal
