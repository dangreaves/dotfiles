-- source(s)
-- https://github.com/nvim-lua/kickstart.nvim

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

  -- lsp plugins
  use {
    'neovim/nvim-lspconfig',
    requires = {
      -- automatically install servers to stdpath for neovim
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- useful status updates for lsp
      'j-hui/fidget.nvim',
    }
  }

  -- autocompletion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
      'saadparwaiz1/cmp_luasnip'
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

  -- search
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      'nvim-lua/plenary.nvim'
    }
  }

  -- git related plugins
  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'

  use 'lukas-reineke/indent-blankline.nvim'  -- add indentation guides
  use 'numToStr/Comment.nvim' -- "gc" to comment visual regions/lines
  use 'tpope/vim-sleuth' -- detect tabstop and shiftwidth automatically

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

-- case insensitive searching unless /C or capital in search
vim.o.smartcase = true
vim.o.ignorecase = true

-- decrease update time
vim.o.updatetime = 250

-- set colorscheme
vim.o.termguicolors = true
vim.cmd.colorscheme "catppuccin"

-- enable line numbers
vim.wo.number = true

-- enable the sign column to prevent jumping
vim.wo.signcolumn = 'yes'

-- set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

-- decrease the which-key timeout
vim.o.timeoutlen = 500

require("lualine").setup() -- enable status line
require("which-key").setup() -- enable which key
require('telescope').setup() -- enable telescope
require('gitsigns').setup() -- enable gitsigns
require('indent_blankline').setup() -- enable indents
require('Comment').setup() -- enable comments

-- enable file tree
require("nvim-tree").setup({
  view = {
    width = 35,
  }
})

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

-- nvim-cmp supports additional completion capabilities
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- enable lsps
require'lspconfig'.svelte.setup{ capabilities = capabilities }
require'lspconfig'.tsserver.setup{ capabilities = capabilities }

-- show lsp status information
require('fidget').setup()

-- configure autocompletion
local cmp = require 'cmp'
local luasnip = require 'luasnip'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }),
}
