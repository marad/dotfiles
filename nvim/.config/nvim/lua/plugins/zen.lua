---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    zen = {
      win = {
        -- Override height to match the actual editor area.
        -- Zen mode's get_main() uses vim.o.lines which includes
        -- statusline/tabline/cmdline, but floating windows with
        -- relative="editor" can only cover the editor area.
        -- Setting height to a large number lets snacks.win clamp
        -- it to the actual available space.
        height = 9999,
        row = 0,
      },
    },
  },
}
