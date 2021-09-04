local u = {}

u.defaults = {
    -- Run the default shell in the terminal
    cmd = os.getenv('SHELL'),
    -- Neovim's native `nvim_open_win` border config
    border = 'single',
    -- Close the terminal as soon as shell/command exits
    auto_close = true,
    -- Dimensions are treated as percentage
    dimensions = {
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
    },
}

function u.build_dimensions(opts)
    -- get lines and columns
    local cl = vim.o.columns
    local ln = vim.o.lines

    -- calculate our floating window size
    local width = math.ceil(cl * opts.width)
    local height = math.ceil(ln * opts.height - 4)

    -- and its starting position
    local col = math.ceil((cl - width) * opts.x)
    local row = math.ceil((ln - height) * opts.y - 1)

    return {
        width = width,
        height = height,
        col = col,
        row = row,
    }
end

function u.is_win_valid(win)
    return win and vim.api.nvim_win_is_valid(win)
end

function u.is_buf_valid(buf)
    return buf and vim.api.nvim_buf_is_loaded(buf)
end

return u
