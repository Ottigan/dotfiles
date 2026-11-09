-- require("config.ui2").setup() -- INFO: Enable when it is more stable
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.terminal")
require("config.idle_buffers").setup()

local mise_shims = vim.fn.expand("~/.local/share/mise/shims")
if not vim.env.PATH:find(mise_shims, 1, true) then
    vim.env.PATH = mise_shims .. ":" .. vim.env.PATH
end

-- Install Lazy.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        error("Error cloning lazy.nvim:\n" .. out)
    end
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    ui = { border = "rounded" },
    -- Don't bother me when tweaking plugins.
    change_detection = { notify = false },
    -- None of my plugins use luarocks so disable this.
    rocks = { enabled = false },
    performance = {
        rtp = {
            -- Stuff I don't use.
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "rplugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
})
