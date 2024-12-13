return {
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
}
