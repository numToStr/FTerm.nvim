<h1 align='center'>FTerm.nvim</h1>
<p align="center"><sup>🔥 No-nonsense floating terminal plugin for neovim 🔥</sup></p>

![FTerm](https://user-images.githubusercontent.com/24727447/135801811-9e2787eb-e241-4ece-bfcf-6c79a90e6e97.png "Hello from fterm :)")

### 🚀 Installation

- With [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use "numToStr/FTerm.nvim"
```

- With [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'numToStr/FTerm.nvim'
```

<a id="setup"></a>

### ⚒️ Setup (optional)

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
vim.keymap.set('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')
```

#### Configuration

Following options can be provided when calling [`setup()`](#setup). Below is the **default** configuration:

```lua
{
    -- Filetype of the terminal buffer
    ft = 'FTerm',

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

### 🔥 Usage

- Opening the terminal

```lua
require('FTerm').open()

-- or create a vim command
vim.api.nvim_add_user_command('FTermOpen', require('FTerm').open, { bang = true })
```

- Closing the terminal

> This will close the terminal window but preserves the actual terminal session

```lua
require('FTerm').close()

-- or create a vim command
vim.api.nvim_add_user_command('FTermClose', require('FTerm').close, { bang = true })
```

- Exiting the terminal

> Unlike closing, this will remove the terminal session

```lua
require('FTerm').exit()

-- or create a vim command
vim.api.nvim_add_user_command('FTermExit', require('FTerm').exit, { bang = true })
```

- Toggling the terminal

```lua
require('FTerm').toggle()

-- or create a vim command
vim.api.nvim_add_user_command('FTermToggle', require('FTerm').toggle, { bang = true })
```

- Running commands

If you want to run some commands, you can do that by using the `run` method. This method uses the default terminal and doesn't override the default command (which is usually your shell). Because of this when the command finishes/exits, the terminal won't close automatically.

```lua
-- run() can take `string` or `table` just like `cmd` config
require('FTerm').run('man ls') -- with string
require('FTerm').run({'yarn', 'build'})
require('FTerm').run({'node', vim.api.nvim_get_current_buf()})

-- Or you can do this
vim.api.nvim_add_user_command('ManLs', function()
    require('FTerm').run('man ls')
end, { bang = true })

vim.api.nvim_add_user_command('YarnBuild', function()
    require('FTerm').run({'yarn', 'build'})
end, { bang = true })
```

<a id="scratch-terminal"></a>

### ⚡ Scratch Terminal

You can also create scratch terminal for ephemeral processes like build commands. Scratch terminal will be created when you can invoke it and will be destroyed when the command exits. You can use the `scratch({config})` method to create it which takes [same options](#configuration) as `setup()`. This uses [custom terminal](#custom-terminal) under the hood.

```lua
require('FTerm').scratch({ cmd = 'yarn build' })
require('FTerm').scratch({ cmd = {'cargo', 'build', '--target', os.getenv('RUST_TARGET')} })

-- Scratch terminals are awesome because you can do this
vim.api.nvim_add_user_command('YarnBuild', function()
    require('FTerm').scratch({ cmd = {'yarn', 'build'} })
end, { bang = true })

vim.api.nvim_add_user_command('CargoBuild', function()
    require('FTerm').scratch({ cmd = {'cargo', 'build', '--target', os.getenv("RUST_TARGET")} })
end, { bang = true })
```

<a id="custom-terminal"></a>

### ✨ Custom Terminal

By default `FTerm` only creates and manage one terminal instance but you can create your terminal by using the `FTerm:new()` function and overriding the default command. This is useful if you want a separate terminal and the command you want to run is a long-running process. If not, see [scratch terminal](#scratch-terminal).

Below are some examples:

- Running [gitui](https://github.com/extrawurst/gitui)

```lua
local fterm = require("FTerm")

local gitui = fterm:new({
    ft = 'fterm_gitui', -- You can also override the default filetype, if you want
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

![gitui](https://user-images.githubusercontent.com/24727447/135801936-3519cd12-7924-4838-83d8-7c9fe6725f71.png "gitui w/ fterm")

- Running [btop](https://github.com/aristocratos/btop)

```lua
local fterm = require("FTerm")

local btop = fterm:new({
    ft = 'fterm_btop',
    cmd = "btop"
})

 -- Use this to toggle btop in a floating terminal
function _G.__fterm_btop()
    btop:toggle()
end
```

Screenshot

![btop](https://user-images.githubusercontent.com/24727447/135802042-afe83ad0-e044-4ba6-bd19-0a75fdeff441.png "btop w/ fterm")

### 💐 Credits

- [vim-floaterm](https://github.com/voldikss/vim-floaterm) for the inspiration
