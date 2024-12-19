return {
  {
    "nvimdev/lspsaga.nvim",
    -- opts = {},
    config = function()
      require("lspsaga").setup({})
    end,
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- optional
      "nvim-tree/nvim-web-devicons", -- optional
    },
    -- keys = {
    --   { "K", "<cmd>Lspsaga hover_doc<CR>", desc = "Hover" },
    -- },
  },
}
