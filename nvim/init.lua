-- install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
local is_bootstrap = false
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  is_bootstrap = true
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

-- install plugins
require('packer').startup(function(use)
  -- package manager
  use 'wbthomason/packer.nvim'

  -- catppuccin theme
  use "catppuccin/nvim"

  -- shows a popup after commands with possible key bindings
  use "folke/which-key.nvim"

  -- LSP plugins
  use {
    'neovim/nvim-lspconfig',
    requires = {
      -- automatically install LSPs to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- useful status updates for LSP
      'j-hui/fidget.nvim',
    }
  }

  -- file tree
  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons'
    }
  }

  -- file tabs
  use {
    'romgrk/barbar.nvim',
    requires = {
      'nvim-tree/nvim-web-devicons'
    }
  }

  -- status line
  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      'nvim-tree/nvim-web-devicons'
    }
  }

  -- highlight, edit, and navigate code
  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  }

  -- additional text objects via treesitter
  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    after = 'nvim-treesitter',
  }

  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    }
  }

  -- sync plugins on initial install
  if is_bootstrap then
    require('packer').sync()
  end
end)

-- halt lua execution if packer is installing
if is_bootstrap then
  print '=================================='
  print '    Plugins are being installed'
  print '    Wait until Packer completes,'
  print '       then restart nvim'
  print '=================================='
  return
end

-- disable built in file browser
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- enable line numbers
vim.wo.number = true

-- case insensitive searching unless /C or capital in search
vim.opt.smartcase = true
vim.opt.ignorecase = true

-- set colorscheme
vim.opt.termguicolors = true
vim.cmd.colorscheme "catppuccin"

-- enable file tree
require("nvim-tree").setup()

-- enable status line
require("lualine").setup()

-- enable which key
require("which-key").setup()

-- enable telescope
require('telescope').setup()

-- close file tree if last window
vim.api.nvim_create_autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and require("nvim-tree.utils").is_nvim_tree_buf() then
      vim.cmd "quit"
    end
  end
})

-- enable treesitter
require('nvim-treesitter.configs').setup {
  ensure_installed = { 'lua', 'typescript', 'help', 'svelte', 'javascript' },
  highlight = { enable = true }
}

-- enable mason
require("mason").setup()

-- enable the following language servers
local servers = { 'tsserver', 'svelte' }

-- ensure the servers above are installed
require('mason-lspconfig').setup {
  ensure_installed = servers,
}

-- enable lsps
require'lspconfig'.svelte.setup{}
require'lspconfig'.tsserver.setup{}

-- show lsp status information
require('fidget').setup()
