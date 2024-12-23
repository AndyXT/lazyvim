return {
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
}
