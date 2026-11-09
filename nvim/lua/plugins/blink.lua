return {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "saghen/blink.lib",
        -- optional: provides snippets for the snippet source
        "rafamadriz/friendly-snippets",
    },

    build = function()
        -- build the fuzzy matcher, wait up to 60 seconds
        -- you can use `gb` in `:Lazy` to rebuild the plugin as needed
        require("blink.cmp").build():wait(60000)
    end,

    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
        -- "default" (recommended) for mappings similar to built-in completions (C-y to accept)
        -- "super-tab" for mappings similar to vscode (tab to accept)
        -- "enter" for enter to accept
        -- "none" for no mappings
        --
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            preset = "super-tab",
            ["<cr>"] = { "snippet_forward", "fallback" },
            ["S-<cr>"] = { "snippet_backward", "fallback" },
        },

        appearance = {
            nerd_font_variant = "mono",
        },

        -- (Default) Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = false } },
        signature = { enabled = false },

        -- (Default) list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, due to `opts_extend`
        sources = {
            default = { "lazydev", "lsp", "path", "snippets", "buffer" },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    -- make lazydev completions top priority (see `:h blink.cmp`)
                    score_offset = 100,
                },
            },
        },

        -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
        -- You may use a lua implementation instead by using `implementation = "lua"`
        -- See the fuzzy documentation for more information
        fuzzy = {
            implementation = "rust",
            sorts = {
                "exact", -- Exact matches first
                "score", -- Primary sort: by fuzzy matching score
                "sort_text", -- Secondary sort: by sortText field if scores are equal
                "label", -- Tertiary sort: by label if still tied
            },
        },
    },
}
