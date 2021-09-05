<h1 align='center'>FTerm.nvim</h1>

<h4 align='center'>🔥 No-nonsense floating terminal plugin for neovim 🔥</h4>

![FTerm](https://user-images.githubusercontent.com/24727447/113905276-999bc580-97f0-11eb-9c01-347de0ff53c9.png "FTerm floating in the wind")

### Requirements

-   Neovim 0.5

### Install

-   With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use "numtostr/FTerm.nvim"
```

-   With [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'numtostr/FTerm.nvim'
```

### Setup (optional)

`FTerm` default terminal has sane defaults. If you want to use the default configuration then you don't have to do anything but you can override the default configuration by calling `setup()`.

```lua

require'FTerm'.setup({
    border = 'double',
    dimensions  = {
        height = 0.9,
        width = 0.9,
    },
})

-- Example keybindings
local map = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }

map('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>', opts)
map('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', opts)
```

#### Configuration

Following options can be provided when calling `setup({options})`. Below is the default configuration:

```lua
{
    -- Command to run inside the terminal
    cmd = os.getenv('SHELL'),

    -- Neovim's native window border. See `:h nvim_open_win` for more configuration options.
    border = 'single',

    -- Close the terminal as soon as shell/command exits.
    -- Disabling this will mimic the native terminal behaviour.
    auto_close = true,

    -- Object containing the terminal window dimensions.
    -- The value for each field should be between `0` and `1`
    dimensions = {
        height = 0.8, -- Height of the terminal window
        width = 0.8, -- Width of the terminal window
        x = 0.5 -- X axis of the terminal window
        y = 0.5 -- Y axis of the terminal window
    }
}
```

> NOTE: See [custom terminal](#custom-terminal) section for more use cases.

### Usage

-   `require('FTerm').open()` - To open the terminal

-   `require('FTerm').close()` - To close the terminal

    > Actually this closes the floating window not the actual terminal buffer

-   `require('FTerm').toggle()` - To toggle the terminal

-   `require('FTerm').run(...)` - To run arbitrary command inside the terminal. [Read More](#running-one-off-commands)

### Running one-off commands

There may be a situation when you want to run some commands like `yarn build` or something. You can do that by using the `run` method which will open the terminal and run the provided command. Keep in mind that after the command finishes/exits, the terminal won't close automatically. You have to close that manually, if you want to or you can reuse the terminal.

```lua
local fterm = require('FTerm')

-- Setup with the default config
fterm.setup()

-- Now use `run` method
function _G.yarn_build()
    fterm.run('yarn build\n')
end

-- Or you can do this
vim.cmd('command! YarnBuild lua require("FTerm").run("yarn build\n")')
```

### Custom Terminal

By default `FTerm` only creates and manage one terminal instance but you can create your terminal by using the `FTerm:new()` function and overriding the default command.

Below are some examples:

-   Running [gitui](https://github.com/extrawurst/gitui)

```lua
local fterm = require("FTerm")

local gitui = fterm:new({
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
local fterm = require("FTerm")

local top = fterm:new({ cmd = "bpytop" })

 -- Use this to toggle bpytop in a floating terminal
function _G.__fterm_top()
    top:toggle()
end
```

Screenshot

![bpytop](https://user-images.githubusercontent.com/24727447/115376384-47917180-a1ec-11eb-9717-8dbf21465428.png "bpytop in floating terminal")

### Credits

[vim-floaterm](https://github.com/voldikss/vim-floaterm) for the inspiration
