return {
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      require("mini.files").setup()
    end,
    keys = {
      {
        "<leader>F",
        function()
          MiniFiles.open(vim.fn.expand("%:h"))
        end,
        desc = "Files in Buffer cwd",
      },
    },
  },
}
