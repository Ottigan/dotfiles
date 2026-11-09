return {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = { "ConformInfo" },
    keys = {
        {
            "<leader>f",
            function()
                require("conform").format({ async = true, lsp_format = "fallback" })
            end,
            mode = { "n", "v" },
            desc = "[F]ormat buffer",
        },
        {
            "<leader>F",
            function()
                vim.g.disable_autoformat = not vim.g.disable_autoformat
                vim.notify(
                    "Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"),
                    vim.log.levels.INFO
                )
            end,
            desc = "Toggle [F]ormat on Save",
        },
    },
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
        formatters = {
            prettierd = {
                command = "prettierd",
                args = { "--stdin-filepath", "$FILENAME" },
                stdin = true,
            },
        },
        formatters_by_ft = {
            -- No external formatter: ESLint fixes come from the `eslint` language
            -- server (its `format` setting, see lsp.lua) through the LSP fallback
            -- below. `name` keeps `tsc` from formatting these filetypes too.
            javascript = { name = "eslint" },
            typescript = { name = "eslint" },
            javascriptreact = { name = "eslint" },
            typescriptreact = { name = "eslint" },
            markdown = { "prettierd" },
            scss = { "stylelint" },
            yaml = { "prettierd" },
            toml = { "taplo" },
            lua = { "stylua" },
            zsh = { "shfmt" },
        },
        format_on_save = function()
            if vim.g.disable_autoformat then
                return
            end

            return { timeout_ms = 2000, lsp_format = "fallback" }
        end,
    },
}
