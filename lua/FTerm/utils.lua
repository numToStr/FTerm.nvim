local U = {}

local O = {
    -- Neovim's native `nvim_open_win` border config
    border = "single",
    -- Dimensions are treated as percentage
    dimensions = {
        height = 0.8,
        width = 0.8,
        row = 0.5,
        col = 0.5
    }
}

function U.build_config(opts)
    if not opts then
        return O
    end

    return {
        dimensions = opts.dimensions and vim.tbl_extend("keep", opts.dimensions, O.dimensions) or O.dimensions,
        border = opts.border or O.border
    }
end

return U
