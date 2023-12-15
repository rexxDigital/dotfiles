-------------------------------------------------------------------------------
-- Options
-------------------------------------------------------------------------------
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.smartindent = true
vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.laststatus = 3
vim.opt.cmdheight = 0
vim.opt.numberwidth = 4
vim.opt.signcolumn = "yes"
vim.opt.relativenumber = true
vim.opt.clipboard = { 'unnamed', 'unnamedplus' }
vim.opt.guicursor = ""

vim.opt.termguicolors = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = " "
vim.g.maplocalleader = ";"
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
vim.keymap.set("n", "<leader>gg", vim.cmd.LazyGit)
vim.keymap.set("n", "<leader>sv", '<Cmd>vsplit<CR>')
vim.keymap.set("n", "<leader>sh", '<Cmd>split<CR>')
vim.keymap.set("n", "<C-p>", '<Cmd>bp<CR>')
vim.keymap.set("n", "<C-n>", '<Cmd>bn<CR>')

require("lazy").setup({
  { "folke/which-key.nvim", lazy = true },
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",

 -- {
   -- "rose-pine/neovim",
   -- as = "rose-pine",
   -- lazy = false,
   -- priority = 1000,
   -- config = function()
   --   require("rose-pine").setup({dark_variant = 'moon'})
   --   vim.cmd([[colorscheme rose-pine]])

   --   vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
   --   vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
   -- end,
  --},
  {
    "ayu-theme/ayu-vim",
    config = function()
      vim.cmd([[colorscheme ayu]])
      vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    end,
  },

  {
    "nvim-telescope/telescope.nvim", tag = "0.1.3",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "vim", "vimdoc", "javascript", "typescript", "c", "lua", "rust", "go" },
	      sync_install = false,
	      auto_install = true,
	      highlight = {
	        enable = true,
	        additional_vim_regex_highlighting = false,
        },
      }
    end
  },

  {
    "mbbill/undotree"
  },

  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("telescope").load_extension("lazygit")
    end,
  },

  {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    dependencies = {
      -- LSP Support
      {'neovim/nvim-lspconfig'},             -- Required
      {'williamboman/mason.nvim'},           -- Optional
      {'williamboman/mason-lspconfig.nvim'}, -- Optional

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},     -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},     -- Required
    }
  },

  { "freddiehaddad/feline.nvim",
    config = function()
      require("feline").setup()
    end,
  },

  { "mhartington/formatter.nvim" },
})

local lsp = require("lsp-zero")

lsp.preset("recommended")
lsp.ensure_installed({
  "tsserver",
  "eslint",
  "gopls",
  "clangd",
  "svelte",
  "tailwindcss",
  "lua_ls",
  "rust_analyzer"
})

local cmp = require("cmp")
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
  ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
  ["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
  ["<C-Enter>"] = cmp.mapping.confirm(cmp_select),
  ["<C-Space>"] = cmp.mapping.complete(),
})

lsp.set_preferences({
  sign_icons = { }
})

lsp.on_attach(function(client, bufnr)
  local opts = { buffer = bufnr, remap = false }

  vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
  vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
  vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
  vim.keymap.set("n", "<leader>vd", function() vim.lsp.buf.open_float() end, opts)
  vim.keymap.set("n", "[d", function() vim.lsp.buf.goto_next() end, opts)
  vim.keymap.set("n", "]d", function() vim.lsp.buf.goto_prev() end, opts)
  vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
  vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
  vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
  vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
end)

lsp.setup()

require("formatter").setup(
  {
    logging = true,
    filetype = {
      go = {
        function()
          return {
            exe = "gofmt",
            args = {vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      typescriptreact = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      typescript = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
        -- linter
        -- function()
        --   return {
        --     exe = "eslint",
        --     args = {
        --       "--stdin-filename",
        --       vim.api.nvim_buf_get_name(0),
        --       "--fix",
        --       "--cache"
        --     },
        --     stdin = false
        --   }
        -- end
      },
      javascript = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      javascriptreact = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      json = {
        -- prettier
        function()
          return {
            exe = "prettier",
            args = {"--stdin-filepath", vim.api.nvim_buf_get_name(0)},
            stdin = true
          }
        end
      },
      lua = {
        -- luafmt
        function()
          return {
            exe = "luafmt",
            args = {"--indent-count", 2, "--stdin"},
            stdin = true
          }
        end
      },
      c = {
        function()
          return {
            exe = "clang-format",
            stdin = true
          }
        end
      }
    }
  }
)

vim.keymap.set('n', 'F', '<Cmd>Format<CR>')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>ps', function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
