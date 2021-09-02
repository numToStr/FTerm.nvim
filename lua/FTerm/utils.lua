local u = {}

function u.is_win_valid(win)
    return win and vim.api.nvim_win_is_valid(win)
end

function u.is_buf_valid(buf)
    return buf and vim.api.nvim_buf_is_loaded(buf)
end

return u
