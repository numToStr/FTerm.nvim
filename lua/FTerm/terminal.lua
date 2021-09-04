local utils = require('FTerm.utils')

local api = vim.api
local fn = vim.fn
local cmd = api.nvim_command

local Terminal = {
    au_close = {},
    au_resize = {},
}

-- Init
function Terminal:new()
    local state = {
        win = nil,
        buf = nil,
        terminal = nil,
        tjob_id = nil,
    }

    self.__index = self
    return setmetatable(state, self)
end

-- Terminal:setup takes windows configuration ie. dimensions
function Terminal:setup(cfg)
    self.config = utils.build_config(cfg)

    -- Give every terminal instance their own key
    -- by converting the given cmd into a hex string
    -- This is to be used with autocmd
    self.au_key = utils.to_hex(self.config.cmd)

    self:win_dim()

    -- Need to setup different autocmd for different terminal instances
    -- Otherwise autocmd will be overriden by other terminal aka custom terminal
    Terminal.au_resize[self.au_key] = function()
        self:win_dim()
    end

    cmd("autocmd VimResized * lua require('FTerm.terminal').au_resize['" .. self.au_key .. "']()")

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

-- Terminal:win_dim return window dimensions
function Terminal:win_dim()
    self.dims = utils.build_dimensions(self.config.dimensions)

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
    local dim = self.dims

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
            -- Need to setup different TermClose autocmd for different terminal instances
            -- Otherwise this will be overriden by other terminal aka custom terminal
            Terminal.au_close[self.au_key] = function()
                self:close(true)
            end

            -- This fires when someone executes `exit` inside term
            -- So, in this case the buffer should also be removed instead of reusing
            cmd("autocmd! TermClose <buffer> lua require('FTerm.terminal').au_close['" .. self.au_key .. "']()")
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
