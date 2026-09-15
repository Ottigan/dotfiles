return {
    -- In-buffer rendering: headings, tables, code blocks, checkboxes and callouts
    -- are drawn with extmarks, so the buffer stays editable text. Inline images
    -- and LaTeX are handled separately by `snacks.image`.
    {
        "MeanderingProgrammer/render-markdown.nvim",
        -- The treesitter config already installs the `markdown` parsers and starts
        -- treesitter for the filetype; `mini.icons` is picked up as the icon provider.
        dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" },
        ft = { "markdown" },
        ---@module 'render-markdown'
        ---@type render.md.UserConfig
        opts = {},
        keys = {
            {
                "<leader>mt",
                "<cmd>RenderMarkdown buf_toggle<cr>",
                ft = "markdown",
                desc = "[T]oggle in-buffer render",
            },
        },
    },

    -- Browser preview for what the in-buffer renderer can't draw: mermaid
    -- diagrams, KaTeX, and the real HTML output. Pure Lua server, so unlike
    -- the node- and deno-based previewers there is no runtime to install.
    {
        "brianhuster/live-preview.nvim",
        dependencies = { "ibhagwan/fzf-lua" },
        cmd = "LivePreview",
        keys = {
            { "<leader>mp", "<cmd>LivePreview start<cr>", desc = "[P]review in browser" },
            { "<leader>mf", "<cmd>LivePreview pick<cr>", desc = "Preview picked [F]ile" },
            { "<leader>mc", "<cmd>LivePreview close<cr>", desc = "[C]lose preview server" },
        },
        config = function()
            -- No `setup()`; the plugin reads its config from this module.
            require("livepreview.config").set({
                -- Keyed by the enum *value* in `livepreview.config.pickers`.
                picker = "fzf-lua",
            })
        end,
    },
}
