local U = require("FTerm.utils")
local api = vim.api
local fn = vim.fn
local cmd = api.nvim_command

local Terminal = {}

-- Init
function Terminal:new()
    local state = {
        win = nil,
        buf = nil,
        terminal = nil
    }

    self.__index = self
    return setmetatable(state, self)
end

-- Terminal:setup takes windows configuration ie. dimensions
function Terminal:setup(opts)
    self.config = U.build_config(opts)
end

-- Terminal:store adds the given floating windows and buffer to the list
function Terminal:store(win, buf)
    self.win = win
    self.buf = buf
end

-- Terminal:remember_cursor stores the last cursor position and window
function Terminal:remember_cursor()
    self.last_win = api.nvim_get_current_win()
    self.last_pos = api.nvim_win_get_cursor(self.last_win)
end

-- Terminal:restore_cursor restores the cursor to the last remembered position
function Terminal:restore_cursor()
    if self.last_win and self.last_pos ~= nil then
        api.nvim_set_current_win(self.last_win)
        api.nvim_win_set_cursor(self.last_win, self.last_pos)

        self.last_win = nil
        self.last_pos = nil
    end
end

-- Terminal:win_dim return window dimensions
function Terminal:win_dim()
    -- get dimensions
    local d = self.config.dimensions
    local cl = vim.o.columns
    local ln = vim.o.lines

    -- calculate our floating window size
    local width = math.ceil(cl * d.width)
    local height = math.ceil(ln * d.height - 4)

    -- and its starting position
    local col = math.ceil((cl - width) * d.col)
    local row = math.ceil((ln - height) * d.row - 1)

    return {
        width = width,
        height = height,
        col = col,
        row = row
    }
end

-- Terminal:create_buf creates a scratch buffer for floating window to consume
function Terminal:create_buf()
    -- If previous buffer exists then return it
    local prev = self.buf

    if prev and api.nvim_buf_is_loaded(prev) then
        return prev
    end

    return api.nvim_create_buf(false, true)
end

-- Terminal:create_win creates a new window with a given buffer
function Terminal:create_win(buf, opts)
    local win_handle = api.nvim_open_win(buf, true, opts)

    api.nvim_win_set_option(win_handle, "winhl", "Normal:Normal")

    return win_handle
end

-- Terminal:term opens a terminal inside a buffer
function Terminal:term()
    if not self.buf then
        -- This function fails if the current buffer is modified (all buffer contents are destroyed).
        local pid = fn.termopen(self.config.cmd)

        -- IDK what to do with this now, maybe later we can use it
        self.terminal = pid
    end

    cmd("startinsert")

    function _G.__fterm_close()
        self:close(true)
    end

    -- This fires when someone executes `exit` inside term
    -- So, in this case the buffer should also be removed instead of reusing
    cmd("autocmd! TermClose <buffer> lua __fterm_close()")
end

-- Terminal:open does all the magic of opening terminal
function Terminal:open()
    self:remember_cursor()

    local dim = self:win_dim()

    local buf = self:create_buf()

    local win =
        self:create_win(
        buf,
        {
            border = self.config.border,
            relative = "editor",
            style = "minimal",
            width = dim.width,
            height = dim.height,
            col = dim.col,
            row = dim.row
        }
    )

    self:term()

    -- Need to store the handles after opening the terminal
    self:store(win, buf)
end

-- Terminal:close does all the magic of closing terminal and clearing the buffers/windows
function Terminal:close(force)
    if not self.win then
        return
    end

    if api.nvim_win_is_valid(self.win) then
        api.nvim_win_close(self.win, {})
    end

    self.win = nil

    if force then
        if api.nvim_buf_is_loaded(self.buf) then
            api.nvim_buf_delete(self.buf, {force = true})
        end

        fn.jobstop(self.terminal)

        self.buf = nil
        self.terminal = nil
    end

    self:restore_cursor()
end

-- Terminal:toggle is used to toggle the terminal window
function Terminal:toggle()
    -- If window is stored then it is already opened
    if not self.win then
        self:open()
    else
        self:close()
    end
end

return Terminal
