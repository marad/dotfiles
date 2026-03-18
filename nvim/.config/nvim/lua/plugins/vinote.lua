---@type LazySpec
return {
  {
    "marad/vinote",
    name = "vinote",
    lazy = false,
    config = function()
      require("vinote").setup()
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>v", group = "vinote" },
      },
    },
  },
}
