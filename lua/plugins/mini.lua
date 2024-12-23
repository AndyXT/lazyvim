return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- load the libraries here
      require("mini.diff").setup()
      require("mini.align").setup()
      require("mini.misc").setup()
      require("mini.extra").setup()
      require("mini.pick").setup()
      require("mini.files").setup()
      require("mini.jump").setup()
      require("mini.jump2d").setup()
      require("mini.bracketed").setup({
        comment = { suffix = 'v'},
      })
    end,
    lazy = true,
  },
}
