-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
-- local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
-- 
-- if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
--   -- stylua: ignore
--   local result = vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
--   if vim.v.shell_error ~= 0 then
--     -- stylua: ignore
--     vim.api.nvim_echo({ { ("Error cloning lazy.nvim:\n%s\n"):format(result), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
--     vim.fn.getchar()
--     vim.cmd.quit()
--   end
-- end
-- Ensure lazy and hotpot are always installed
local function ensure_installed(plugin, branch)
  local user, repo = string.match(plugin, "(.+)/(.+)")
  local repo_path = vim.fn.stdpath("data") .. "/lazy/" .. repo
  if not (vim.uv or vim.loop).fs_stat(repo_path) then
    vim.notify("Installing " .. plugin .. " " .. branch)
    local repo_url = "https://github.com/" .. plugin .. ".git"
    local out = vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "--branch=" .. branch,
      repo_url,
      repo_path
    })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { "Failed to clone " .. plugin .. ":\n", "ErrorMsg" },
        { out, "WarningMsg" },
        { "\nPress any key to exit..." },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  return repo_path
end
local lazy_path = ensure_installed("folke/lazy.nvim", "stable")
local hotpot_path = ensure_installed("rktjmp/hotpot.nvim", "v0.14.8")
-- As per Lazy's install instructions, but also include hotpot
vim.opt.runtimepath:prepend({hotpot_path, lazy_path})

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require("hotpot")

vim.loader.enable()
require "lazy_setup"
require "polish"

vim.opt.exrc = true

-- Configure Viro

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.viro",
  command = "set filetype=viro",
})

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = "*.viro",
  command = "nnoremap <C-R> :wa<cr>:!viro %<cr>",
})

local pairs = require("nvim-autopairs")
pairs.get_rules("'")[1].not_filetypes = { "viro" }


