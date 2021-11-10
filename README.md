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

Following options can be provided when calling `setup({config})`. Below is the default configuration:

```lua
{
    -- Command to run inside the terminal. It could be a `string` or `table`
    cmd = os.getenv('SHELL'),

    -- Neovim's native window border. See `:h nvim_open_win` for more configuration options.
    border = 'single',

    -- Close the terminal as soon as shell/command exits.
    -- Disabling this will mimic the native terminal behaviour.
    auto_close = true,

    -- Highlight group for the terminal. See `:h winhl`
    hl = 'Normal',

    -- Transparency of the floating window. See `:h winblend`
    blend = 0,

    -- Object containing the terminal window dimensions.
    -- The value for each field should be between `0` and `1`
    dimensions = {
        height = 0.8, -- Height of the terminal window
        width = 0.8, -- Width of the terminal window
        x = 0.5 -- X axis of the terminal window
        y = 0.5 -- Y axis of the terminal window
    }

    -- Callback invoked when the terminal exits.
    -- See `:h jobstart-options`
    on_exit = nil,

    -- Callback invoked when the terminal emits stdout data.
    -- See `:h jobstart-options`
    on_stdout = nil,

    -- Callback invoked when the terminal emits stderr data.
    -- See `:h jobstart-options`
    on_stderr = nil,
}
```

### Usage

-   Opening the terminal

```lua
lua require('FTerm').open()

-- or create a vim command
vim.cmd('command! FTermOpen lua require("FTerm").open()')
```

-   Closing the terminal

> This will close the terminal window but preserves the actual terminal session

```lua
lua require('FTerm').close()

-- or create a vim command
vim.cmd('command! FTermClose lua require("FTerm").close()')
```

-   Exiting the terminal

> Unlike closing, this will remove the terminal session

```lua
lua require('FTerm').exit()

-- or create a vim command
vim.cmd('command! FTermExit lua require("FTerm").exit()')
```

-   Toggling the terminal

```lua
lua require('FTerm').toggle()

-- or create a vim command
vim.cmd('command! FTermClose lua require("FTerm").toggle()')
```

-   Running commands

If you want to run some commands, you can do that by using the `run` method. This method uses the default terminal and doesn't override the default command (which is usually your shell). Because of this when the command finishes/exits, the terminal won't close automatically.

> NOTE: There is no need to add `\n` at the end of the command

```lua
-- run() can take `string` or `table` just like `cmd` config
lua require('FTerm').run('man ls') -- with string
lua require('FTerm').run({'yarn', 'build'})
lua require('FTerm').run({'node', vim.api.nvim_get_current_buf()})

-- Or you can do this
vim.cmd('command! ManLs lua require("FTerm").run("man ls")')
vim.cmd('command! YarnBuild lua require("FTerm").run({"yarn", "build"})')
```

### Scratch Terminal

You can also create scratch terminal for ephemeral processes like build commands. Scratch terminal will be created when you can invoke it and will be destroyed when the command exits. You can use the `scratch({config})` method to create it which takes [same options](#configuration) as `setup()`. This uses [custom terminal](#custom-terminal) under the hood.

```lua
lua require('FTerm').scratch({ cmd = 'yarn build' })
lua require('FTerm').scratch({ cmd = {'cargo', 'build', '--target', os.getenv('RUST_TARGET')} })

-- Scratch terminals are awesome because you can do this
vim.cmd('command! YarnBuild lua require("FTerm").scratch({ cmd = "yarn build" })')
vim.cmd('command! CargoBuild lua require("FTerm").scratch({ cmd = {"cargo", "build", "--target", os.getenv("RUST_TARGET")} })')
```

### Custom Terminal

By default `FTerm` only creates and manage one terminal instance but you can create your terminal by using the `FTerm:new()` function and overriding the default command. This is useful if you want a separate terminal and the command you want to run is a long-running process. If not, see [scratch terminal](#scratch-terminal).

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
