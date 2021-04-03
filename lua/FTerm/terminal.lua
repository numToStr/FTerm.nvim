local api = vim.api
local fn = vim.fn
local cmd = api.nvim_command

local Terminal = {}

-- Init
function Terminal:new()
    local x = {
        wins = {},
        bufs = {},
        config = {
            -- Dimensions are treated as percentage
            dimensions = {
                height = 0.8,
                width = 0.8,
                row = 0.5,
                col = 0.5
            },
            border = {
                horizontal = "─",
                vertical = "|",
                topLeft = "┌",
                topRight = "┐",
                bottomRight = "┘",
                bottomLeft = "└"
            }
        }
    }

    self.__index = self
    return setmetatable(x, self)
end

-- Terminal:setup takes windows configuration ie. dimensions
function Terminal:setup(c)
    if not c then
        return
    end

    local cfg = self.config

    c.dimensions = c.dimensions and vim.tbl_extend("keep", c.dimensions, cfg.dimensions) or cfg.dimensions
    c.border = c.border and vim.tbl_extend("keep", c.border, cfg.border) or cfg.border

    self.config = c
end

-- Terminal:store adds the given floating windows and buffer to the list
function Terminal:store(name, win, buf)
    self.wins[name] = win
    self.bufs[name] = buf
end

-- Terminal:remember_cursor stores the last cursor position and window
function Terminal:remember_cursor()
    self.last_win = api.nvim_get_current_win()
    self.last_pos = api.nvim_win_get_cursor(self.last_win)
end

-- Terminal:restore_cursor restores the cursor to the last remembered position
function Terminal:restore_cursor()
    if self.last_win and next(self.last_pos) then
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
function Terminal:create_buf(name, do_border, height, width)
    -- If previous buffer exists then return it
    local prev = self.bufs[name]
    if prev and api.nvim_buf_is_loaded(prev) then
        return prev
    end

    local buf = api.nvim_create_buf(false, true)

    if do_border then
        -- ## Border start ##
        local b = self.config.border
        local h_line = string.rep(b.horizontal, width)
        local border_lines = {b.topLeft .. h_line .. b.topRight}
        local v_border = b.vertical .. string.rep(" ", width) .. b.vertical
        for _ = 1, height do
            table.insert(border_lines, v_border)
        end
        table.insert(border_lines, b.bottomLeft .. h_line .. b.bottomRight)
        -- ## Border end ##

        api.nvim_buf_set_lines(buf, 0, -1, false, border_lines)
    end

    return buf
end

-- Terminal:create_win creates a new window with a given buffer
function Terminal:create_win(buf, opts, do_hl)
    local win_handle = api.nvim_open_win(buf, true, opts)

    if do_hl then
        api.nvim_win_set_option(win_handle, "winhl", "Normal:Normal")
    end

    return win_handle
end

-- Terminal:term opens a terminal inside a buffer
function Terminal:term()
    if vim.tbl_isempty(self.bufs) then
        -- This function fails if the current buffer is modified (all buffer contents are destroyed).
        local pid = fn.termopen(os.getenv("SHELL"))

        -- IDK what to do with this now, maybe later we can use it
        self.terminal = pid
    end

    cmd("startinsert")

    function On_close()
        self:close(true)
    end

    -- This fires when someone executes `exit` inside term
    -- So, in this case the buffer should also be removed instead of reusing
    cmd("autocmd! TermClose <buffer> lua On_close()")
end

-- Terminal:open does all the magic of opening terminal
function Terminal:open()
    self:remember_cursor()

    local dim = self:win_dim()
    local opts = {
        relative = "editor",
        style = "minimal",
        width = dim.width + 2,
        height = dim.height + 2,
        col = dim.col - 1,
        row = dim.row - 1
    }

    local bg_buf = self:create_buf("bg", true, dim.height, dim.width)
    local bg_win = self:create_win(bg_buf, opts, true)

    opts.width = dim.width
    opts.height = dim.height
    opts.col = dim.col
    opts.row = dim.row

    local buf = self:create_buf("fg")
    local win = self:create_win(buf, opts)

    self:term()

    -- Need to store the handles after opening the terminal
    self:store("bg", bg_win, bg_buf)
    self:store("fg", win, buf)
end

-- Terminal:close does all the magic of closing terminal and clearing the buffers/windows
function Terminal:close(force)
    if next(self.wins) == nil then
        return
    end

    for _, win in pairs(self.wins) do
        if api.nvim_win_is_valid(win) then
            api.nvim_win_close(win, {})
        end
    end

    self.wins = {}

    if force then
        for _, buf in pairs(self.bufs) do
            if api.nvim_buf_is_loaded(buf) then
                -- api.nvim_buf_delete(buf, {})
                cmd(buf .. "bd!")
            end
        end

        fn.jobstop(self.terminal)

        self.bufs = {}
        self.terminal = nil
    end

    self:restore_cursor()
end

-- Terminal:toggle is used to toggle the terminal window
function Terminal:toggle()
    if vim.tbl_isempty(self.wins) then
        self:open()
    else
        self:close()
    end
end

return Terminal:new()
