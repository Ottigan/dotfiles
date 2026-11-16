-- Scroll an open LSP hover/signature window, otherwise fall back to the key,
-- centered in normal mode only: in insert mode the keys delete text and a
-- trailing `zz` would be typed into the buffer.
local function lsp_scroll_or(delta, key)
    if require("noice.lsp").scroll(delta) then
        return
    end

    return vim.fn.mode() == "n" and key .. "zz" or key
end

return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        "rcarriga/nvim-notify",
    },
    opts = {
        lsp = {
            -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
            },
            -- LSP Progress is handled by Lualine
            progress = { enabled = false },
            signature = { auto_open = { throttle = 150 } },
        },
        commands = {
            history = { view = "popup" },
            all = { view = "popup" },
        },
        presets = {
            long_message_to_split = true,
            lsp_doc_border = true,
        },
        views = {
            cmdline_popup = {
                position = {
                    row = 10,
                    col = "50%",
                },
                size = {
                    width = 60,
                    height = "auto",
                },
            },
        },
        routes = {
            {
                -- Shutting a language server down on idle (see lsp.lua) makes
                -- `tsc` exit non-zero, which Neovim reports as a crash. Drop only
                -- the warnings that land right after a deliberate stop, so a
                -- server that really does fall over is still reported.
                opts = { skip = true },
                filter = {
                    event = "notify",
                    find = "quit with exit code",
                    cond = function()
                        local at = vim.g.lsp_idle_stopped_at
                        return at ~= nil and (vim.uv.now() - at) < 1000
                    end,
                },
            },
            {
                opts = { skip = true },
                filter = {
                    any = {
                        { event = "msg_show", find = "Not a valid PNG file" },
                        { event = "msg_show", find = "fewer lines" },
                        { event = "msg_show", find = "more lines" },
                        { event = "msg_show", kind = "search_count" },
                    },
                },
            },
        },
    },
    keys = {
        {
            "<leader>na",
            function()
                require("noice").cmd("all")
            end,
            desc = "[A]ll messages",
        },
        {
            "<leader>nn",
            function()
                require("noice").cmd("history")
            end,
            desc = "Message history",
        },
        {
            "<leader>nl",
            function()
                require("noice").cmd("last")
            end,
            desc = "[L]ast message",
        },
        {
            "<leader>sn",
            function()
                require("noice").cmd("snacks")
            end,
            desc = "[N]otifications",
        },
        {
            "<c-u>",
            function()
                return lsp_scroll_or(-4, "<c-u>")
            end,
            silent = true,
            expr = true,
            mode = { "n", "i" },
            desc = "Scroll up",
        },
        {
            "<c-d>",
            function()
                return lsp_scroll_or(4, "<c-d>")
            end,
            silent = true,
            expr = true,
            mode = { "n", "i" },
            desc = "Scroll down",
        },
    },
}
