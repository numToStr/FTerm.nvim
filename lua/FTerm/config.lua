local U = {}

local O = {
    -- Run the default shell in the terminal
    cmd = os.getenv('SHELL'),
    -- Neovim's native `nvim_open_win` border config
    border = 'single',
    -- Kill the terminal buffer as soon as shell exists
    close_on_kill = true,
    -- Dimensions are treated as percentage
    dimensions = {
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5,
    },
}

function U.create_config(opts)
    if not opts then
        return O
    end

    return {
        cmd = opts.cmd or O.cmd,
        dimensions = opts.dimensions and vim.tbl_extend('keep', opts.dimensions, O.dimensions) or O.dimensions,
        border = opts.border or O.border,
        -- Also treat `nil` as false
        close_on_kill = opts.close_on_kill and O.close_on_kill or false,
    }
end

function U.to_hex(str)
    return str:gsub('.', function(c)
        return string.format('%02X', string.byte(c))
    end)
end

return U
