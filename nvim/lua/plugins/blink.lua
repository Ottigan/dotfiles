return {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
        "saghen/blink.lib",
        "rafamadriz/friendly-snippets",
    },

    build = function()
        -- Build the fuzzy matcher, wait up to 60 seconds. `gb` in `:Lazy` rebuilds it.
        require("blink.cmp").build():wait(60000)
    end,

    ---@module "blink.cmp"
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = "super-tab",
            ["<cr>"] = { "snippet_forward", "fallback" },
            ["<S-cr>"] = { "snippet_backward", "fallback" },
        },

        -- Only show the documentation popup when manually triggered
        completion = { documentation = { auto_show = false } },

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
