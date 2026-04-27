if not vim.g.neovide then return {} end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    options = {
      opt = {
        guifont = "JetBrainsMono Nerd Font:h16",
      },
      g = {
        neovide_floating_shadow = false,
        neovide_floating_corner_radius = 0.0,
        neovide_floating_blur_amount_x = 0.0,
        neovide_floating_blur_amount_y = 0.0,
      },
    },
    mappings = {
      -- Cmd+V paste in all modes
      n = {
        ["<D-v>"] = { '"+P', desc = "Paste from clipboard" },
      },
      v = {
        ["<D-v>"] = { '"+P', desc = "Paste from clipboard" },
      },
      i = {
        ["<D-v>"] = { '<C-r>+', desc = "Paste from clipboard" },
      },
      c = {
        ["<D-v>"] = { '<C-r>+', desc = "Paste from clipboard" },
      },
      t = {
        ["<D-v>"] = { '<C-\\><C-n>"+pi', desc = "Paste from clipboard" },
      },
    },
  },
}
