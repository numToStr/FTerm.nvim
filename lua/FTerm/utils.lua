local U = {}

---@alias Command string|string[]

---@class Dimensions - Every field inside the dimensions should be b/w `0` to `1`
---@field height number: Height of the floating window (default: `0.8`)
---@field width number: Width of the floating window (default: `0.8`)
---@field x number: X-Axis of the floating window (default: `0.5`)
---@field y number: Y-Axis of the floating window (default: `0.5`)
---@field col number: Specify the exact col for opening the window. See `:h nvim_open_win` for details. If provided, this will mean the `x` option is ignored.
---@field row number: Specify the exact row for opening the window. See `:h nvim_open_win` for details. If provided, this will mean the `y` option is ignored.

---@class Config
---@field ft string: Filetype of the terminal buffer (default: `FTerm`)
---@field cmd Command: Command to run inside the terminal (default: `os.getenv('SHELL'`))
---@field border string: Border type for the floating window. See `:h nvim_open_win` (default: `single`)
---@field auto_close boolean: Close the terminal as soon as command exits (default: `true`)
---@field anchor string: Where to anchor the floating terminal to. See `:h nvim_open_win` (default: `NW`)
---@field hl string: Highlight group for the terminal buffer (default: `true`)
---@field blend number: Transparency of the floating window (default: `true`)
---@field on_exit function: Callback invoked when the terminal exits (default: `nil`)
---@field on_stdout function: Callback invoked when the terminal emits stdout data (default: `nil`)
---@field on_stderr function: Callback invoked when the terminal emits stderr data (default: `nil`)
---@field dimensions Dimensions: Dimensions of the floating window

---@type Config
U.defaults = {
    ft = 'FTerm',
    cmd = os.getenv('SHELL'),
    border = 'single',
    auto_close = true,
    hl = 'Normal',
    blend = 0,
    anchor = 'NW',
    dimensions = {
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
        col = nil,
        row = nil,
    },
}

---Create terminal dimension relative to the viewport
---@param opts Dimensions
---@return table
function U.get_dimension(opts)
    -- get lines and columns
    local cl = vim.o.columns
    local ln = vim.o.lines

    -- calculate our floating window size
    local width = math.ceil(cl * opts.width)
    local height = math.ceil(ln * opts.height - 4)

    -- and its starting position
    local col = opts.col or math.ceil((cl - width) * opts.x)
    local row = opts.row or math.ceil((ln - height) * opts.y - 1)

    return {
        width = width,
        height = height,
        col = col,
        row = row,
    }
end

---Check whether the window is valid
---@param win number Window ID
---@return boolean
function U.is_win_valid(win)
    return win and vim.api.nvim_win_is_valid(win)
end

---Check whether the buffer is valid
---@param buf number Buffer ID
---@return boolean
function U.is_buf_valid(buf)
    return buf and vim.api.nvim_buf_is_loaded(buf)
end

---Creates a valid command from user's input
---@param cmd Command
---@return string
function U.build_cmd(cmd)
    return type(cmd) == 'table' and table.concat(cmd, ' ') or cmd
end

return U
