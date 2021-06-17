<h1 align='center'>FTerm.nvim</h1>

<h4 align='center'>🔥 No-nonsense floating terminal plugin for neovim written in lua 🔥</h4>

![FTerm](https://user-images.githubusercontent.com/24727447/113905276-999bc580-97f0-11eb-9c01-347de0ff53c9.png "FTerm floating in the wind")

### Requirements

-   Neovim Nightly (0.5)

### Install

-   With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    "numtostr/FTerm.nvim",
    config = function()
        require("FTerm").setup()
    end
}
```

-   With [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'numtostr/FTerm.nvim'

" Somewhere after plug#end()

lua require('FTerm').setup()
```

### Functions

-   `require('FTerm').setup()` - To configure the terminal window.

-   `require('FTerm').open()` - To open the terminal

-   `require('FTerm').close()` - To close the terminal

    > Actually this closes the floating window not the actual terminal buffer

-   `require('FTerm').toggle()` - To toggle the terminal

### Configuration

Options can be provided when calling `setup()`.

-   `cmd`: Command to run inside the terminal. (default: `os.getenv('SHELL')`)

> NOTE: This is not meant for edit in the default terminal. See [custom terminal](#custom-terminal) section for use case.

-   `dimensions`: Object containing the terminal window dimensions.

    The value for each field should be between `0` and `1`

    -   `height` - Height of the terminal window (default: `0.8`)
    -   `width` - Width of the terminal window (default: `0.8`)
    -   `x` - X axis of the terminal window (default: `0.5`)
    -   `y` - Y axis of the terminal window (default: `0.5`)

-   `border`: Neovim's native window border (default: `single`). See `:h nvim_open_win` for more configuration options.

### Setup

```lua

require'FTerm'.setup({
    dimensions  = {
        height = 0.8,
        width = 0.8,
        x = 0.5,
        y = 0.5
    },
    border = 'single' -- or 'double'
})

-- Keybinding
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>', opts)
map('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', opts)
```

### Custom Terminal

By default `FTerm` only creates and manage one terminal instance but you can create your terminal by using the underlying terminal function and overriding the default command.

Below are some examples:

-   Running [gitui](https://github.com/extrawurst/gitui)

```lua
local term = require("FTerm.terminal")

local gitui = term:new():setup({
    cmd = "gitui",
    dimensions = {
        height = 0.9,
        width = 0.9
    }
})

 -- Use this to toggle gitui in a floating terminal
function _G.__fterm_gitui()
    gitui:toggle()
end
```

Screenshot

![gitui](https://user-images.githubusercontent.com/24727447/115375538-8541ca80-a1eb-11eb-90aa-b81803e591dc.png "gitui in a floating terminal")

-   Running [bpytop](https://github.com/aristocratos/bpytop)

```lua
local term = require("FTerm.terminal")

local top = term:new():setup({
    cmd = "bpytop"
})

 -- Use this to toggle bpytop in a floating terminal
function _G.__fterm_top()
    top:toggle()
end
```

Screenshot

![bpytop](https://user-images.githubusercontent.com/24727447/115376384-47917180-a1ec-11eb-9717-8dbf21465428.png "bpytop in floating terminal")

### Credits

[vim-floaterm](https://github.com/voldikss/vim-floaterm) for the inspiration
