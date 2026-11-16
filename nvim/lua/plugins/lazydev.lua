-- lazydev.nvim - Configures lua_ls for editing Neovim config
-- Provides full type signatures for vim.*, vim.api.*, vim.fn.*, etc.
-- https://github.com/folke/lazydev.nvim

return {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
        library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "snacks.nvim", words = { "Snacks" } },
            { path = "nvim-lspconfig", words = { "lspconfig.settings" } }, -- See the configuration section for more details
        },
    },
}
