-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },
  --
  -- -- == Examples of Overriding Plugins ==
  --
  -- -- customize alpha options
  -- {
  --   "goolord/alpha-nvim",
  --   opts = function(_, opts)
  --     -- customize the dashboard header
  --     opts.section.header.val = {
  --       " █████  ███████ ████████ ██████   ██████",
  --       "██   ██ ██         ██    ██   ██ ██    ██",
  --       "███████ ███████    ██    ██████  ██    ██",
  --       "██   ██      ██    ██    ██   ██ ██    ██",
  --       "██   ██ ███████    ██    ██   ██  ██████",
  --       " ",
  --       "    ███    ██ ██    ██ ██ ███    ███",
  --       "    ████   ██ ██    ██ ██ ████  ████",
  --       "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
  --       "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
  --       "    ██   ████   ████   ██ ██      ██",
  --     }
  --     return opts
  --   end,
  -- },

  -- You can disable default plugins as follows:
  -- { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  -- {
  --   "L3MON4D3/LuaSnip",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom luasnip configuration such as filetype extend or custom snippets
  --     local luasnip = require "luasnip"
  --     luasnip.filetype_extend("javascript", { "javascriptreact" })
  --   end,
  -- },

  -- {
  --   "windwp/nvim-autopairs",
  --   config = function(plugin, opts)
  --     require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
  --     -- add more custom autopairs configuration such as custom rules
  --     local npairs = require "nvim-autopairs"
  --     local Rule = require "nvim-autopairs.rule"
  --     local cond = require "nvim-autopairs.conds"
  --     npairs.add_rules(
  --       {
  --         Rule("$", "$", { "tex", "latex" })
  --           -- don't add a pair if the next character is %
  --           :with_pair(cond.not_after_regex "%%")
  --           -- don't add a pair if  the previous character is xxx
  --           :with_pair(
  --             cond.not_before_regex("xxx", 3)
  --           )
  --           -- don't move right when repeat character
  --           :with_move(cond.none())
  --           -- don't delete if the next character is xx
  --           :with_del(cond.not_after_regex "xx")
  --           -- disable adding a newline when you press <cr>
  --           :with_cr(cond.none()),
  --       },
  --       -- disable for .vim files, but it work for another filetypes
  --       Rule("a", "a", "-vim")
  --     )
  --   end,
  -- },
  {
    "cshuaimin/ssr.nvim",
    -- Calling setup is optional.
    config = function()
      require("ssr").setup {
        border = "rounded",
        min_width = 50,
        min_height = 5,
        max_width = 120,
        max_height = 25,
        adjust_window = true,
        keymaps = {
          close = "q",
          next_match = "n",
          prev_match = "N",
          replace_confirm = "<cr>",
          replace_all = "<leader><cr>",
        },
      }
    end,
  },
  {
    "dhananjaylatkar/cscope_maps.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
    },
    opts = {
      prefix = "<leader>C",
      picker = "quickfix", -- "quickfix", "telescope", "fzf-lua" or "mini-pick"
    },
  },
  -- nvim v0.8.0
  {
    -- "kdheepak/lazygit.nvim",
    -- lazy = true,
    -- cmd = {
    --   "LazyGit",
    --   "LazyGitConfig",
    --   "LazyGitCurrentFile",
    --   "LazyGitFilter",
    --   "LazyGitFilterCurrentFile",
    -- },
    -- -- optional for floating window border decoration
    -- dependencies = {
    --   "nvim-lua/plenary.nvim",
    -- },
    -- -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- -- order to load the plugin when the command is run for the first time
    -- keys = {
    --   { "<leader>lg", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    -- },
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    config = true,
  },
  {
    "linrongbin16/gentags.nvim",
    config = function() require("gentags").setup() end,
  },
  { "junegunn/fzf", lazy = true },
  { "junegunn/fzf.vim", lazy = true },
  {
    "vimwiki/vimwiki",
  },
  { "tpope/vim-eunuch" },
  { "tpope/vim-fugitive" },
  { "junegunn/fzf-git.sh", lazy = true },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
    },
  },
  {
    "folke/edgy.nvim",
    ---@module 'edgy'
    ---@param opts Edgy.Config
    opts = function(_, opts)
      for _, pos in ipairs { "top", "bottom", "left", "right" } do
        opts[pos] = opts[pos] or {}
        table.insert(opts[pos], {
          ft = "snacks_terminal",
          size = { height = 0.4 },
          title = "%{b:snacks_terminal.id}: %{b:term_title}",
          filter = function(_buf, win)
            return vim.w[win].snacks_win
              and vim.w[win].snacks_win.position == pos
              and vim.w[win].snacks_win.relative == "editor"
              and not vim.w[win].trouble_preview
          end,
        })
      end
    end,
  },
  {
    "CWood-sdf/cmdTree.nvim",
    lazy = true,
  },
  { "ColinKennedy/cursor-text-objects.nvim" },
  {
    "rktjmp/hotpot.nvim",
    lazy = true,
  },
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      -- 👇 in this section, choose your own keymappings!
      {
        "<leader>-",
        "<cmd>Yazi<cr>",
        desc = "Open yazi at the current file",
      },
      {
        -- Open in the current working directory
        "<leader>cw",
        "<cmd>Yazi cwd<cr>",
        desc = "Open the file manager in nvim's working directory",
      },
      {
        -- NOTE: this requires a version of yazi that includes
        -- https://github.com/sxyazi/yazi/pull/1305 from 2024-07-18
        "<c-up>",
        "<cmd>Yazi toggle<cr>",
        desc = "Resume the last yazi session",
      },
    },
    ---@type YaziConfig
    opts = {
      -- if you want to open yazi instead of netrw, see below for more info
      open_for_directories = false,
      keymaps = {
        show_help = "<f1>",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    config = function() vim.cmd "TSContextDisable" end,
  },
  { "rxi/lume" },
  {
    "luafun/luafun",
    lazy = true,
    event = "VeryLazy",
    opts = {
      rocks = {
        enabled = false,
      },
    },
    build = false,
    config = function() end,
  },
  {
    "tadaa/vimade",
    event = "VeryLazy",
    -- default opts (you can partially set these or configure them however you like)
    opts = {
      -- Recipe can be any of 'default', 'minimalist', 'duo', and 'ripple'
      -- Set animate = true to enable animations on any recipe.
      -- See the docs for other config options.
      recipe = { "default", { animate = false } },
      ncmode = "buffers", -- use 'windows' to fade inactive windows
      fadelevel = 0.4, -- any value between 0 and 1. 0 is hidden and 1 is opaque.
      tint = {
        -- bg = {rgb={0,0,0}, intensity=0.3}, -- adds 30% black to background
        -- fg = {rgb={0,0,255}, intensity=0.3}, -- adds 30% blue to foreground
        -- fg = {rgb={120,120,120}, intensity=1}, -- all text will be gray
        -- sp = {rgb={255,0,0}, intensity=0.5}, -- adds 50% red to special characters
        -- you can also use functions for tint or any value part in the tint object
        -- to create window-specific configurations
        -- see the `Tinting` section of the README for more details.
      },

      -- Changes the real or theoretical background color. basebg can be used to give
      -- transparent terminals accurating dimming.  See the 'Preparing a transparent terminal'
      -- section in the README.md for more info.
      -- basebg = [23,23,23],
      basebg = "",

      -- prevent a window or buffer from being styled. You
      blocklist = {
        default = {
          buf_opts = { buftype = { "prompt", "terminal" } },
          win_config = { relative = true },
          -- buf_name = {'name1','name2', name3'},
          -- buf_vars = { variable = {'match1', 'match2'} },
          -- win_opts = { option = {'match1', 'match2' } },
          -- win_vars = { variable = {'match1', 'match2'} },
        },
        -- any_rule_name1 = {
        --   buf_opts = {}
        -- },
        -- only_behind_float_windows = {
        --   buf_opts = function(win, current)
        --     if (win.win_config.relative == '')
        --       and (current and current.win_config.relative ~= '') then
        --         return false
        --     end
        --     return true
        --   end
        -- },
      },
      -- Link connects windows so that they style or unstyle together.
      -- Properties are matched against the active window. Same format as blocklist above
      link = {},
      groupdiff = true, -- links diffs so that they style together
      groupscrollbind = false, -- link scrollbound windows so that they style together.

      -- enable to bind to FocusGained and FocusLost events. This allows fading inactive
      -- tmux panes.
      enablefocusfading = false,

      -- when nohlcheck is disabled the highlight tree will always be recomputed. You may
      -- want to disable this if you have a plugin that creates dynamic highlights in
      -- inactive windows. 99% of the time you shouldn't need to change this value.
      nohlcheck = true,
    },
  },
  {
    "nvim-telescope/telescope.nvim", -- optional [for picker="telescope"]
    config = function()
      require("telescope").setup {
        extensions = {
          fzf = {},
        },
      }
    end,
  },
  {
    "aaronik/treewalker.nvim",
    opts = {
      highlight = true, -- default is false
    },
    config = function()
      local tw = require "treewalker"
      vim.keymap.set("n", "<C-j>", tw.move_down, { noremap = true })
      vim.keymap.set("n", "<C-k>", tw.move_up, { noremap = true })
      vim.keymap.set("n", "<C-h>", tw.move_out, { noremap = true })
      vim.keymap.set("n", "<C-l>", tw.move_in, { noremap = true })
    end,
  },
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  },
  { "EdenEast/nightfox.nvim" }, -- lazy
}
