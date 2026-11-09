return {
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            preview_config = {
                border = "rounded",
                style = "minimal",
                row = -1,
                col = 1,
            },
            signs = {
                add = { text = "+" },
                change = { text = "~" },
                delete = { text = "_" },
                topdelete = { text = "‾" },
                changedelete = { text = "~" },
            },
            on_attach = function(bufnr)
                local gitsigns = require("gitsigns")

                local function map(mode, l, r, opts)
                    opts = opts or {}
                    opts.buffer = bufnr
                    vim.keymap.set(mode, l, r, opts)
                end

                -- Navigation
                map("n", "]c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "]c", bang = true })
                    else
                        gitsigns.nav_hunk("next")
                    end
                end, { desc = "Jump to next git [c]hange" })

                map("n", "[c", function()
                    if vim.wo.diff then
                        vim.cmd.normal({ "[c", bang = true })
                    else
                        gitsigns.nav_hunk("prev")
                    end
                end, { desc = "Jump to previous git [c]hange" })

                -- Actions
                -- visual mode
                map("v", "<leader>gs", function()
                    gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "[S]tage hunk" })
                map("v", "<leader>gr", function()
                    gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
                end, { desc = "[R]eset hunk" })
                -- normal mode
                map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "[S]tage hunk" })
                map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "[R]eset hunk" })
                map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "[S]tage buffer" })
                map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "[R]eset buffer" })
                map("n", "<leader>gp", gitsigns.preview_hunk_inline, { desc = "[P]review hunk" })
                map("n", "<leader>gb", gitsigns.blame_line, { desc = "[B]lame line" })
                map("n", "<leader>gB", gitsigns.blame, { desc = "Blame [f]ile" })
            end,
        },
        config = function(_, opts)
            local gitsigns = require("gitsigns")

            gitsigns.setup(opts)

            local deleted_preview = require("gitsigns.deleted_preview")
            local place_inline_preview_lines = deleted_preview.place_inline_preview_lines

            -- Override the default `place_inline_preview_lines` to disable the left column, which is not needed for deleted lines and can cause issues with certain color schemes.
            ---@diagnostic disable-next-line: duplicate-set-field
            deleted_preview.place_inline_preview_lines = function(bufnr, ns, hunk, staged, preview_opts)
                preview_opts = vim.tbl_extend("force", preview_opts or {}, { leftcol = false })
                return place_inline_preview_lines(bufnr, ns, hunk, staged, preview_opts)
            end
        end,
    },

    {
        "linrongbin16/gitlinker.nvim",
        cmd = { "GitLink" },
        keys = {
            { "<leader>cu", "<cmd>GitLink<cr>", mode = { "n", "v" }, desc = "Copy upstream URL" },
            { "<leader>ou", "<cmd>GitLink!<cr>", mode = { "n", "v" }, desc = "Open upstream URL" },
        },
        opts = {
            router = {
                browse = {
                    ["^gitlab%.evolution%.com"] = "https://gitlab.evolution.com/"
                        .. "{_A.ORG}/"
                        .. "{_A.REPO}/blob/"
                        .. "{_A.REV}/"
                        .. "{_A.FILE}"
                        .. "#L{_A.LSTART}"
                        .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
                },
                blame = {
                    ["^gitlab%.evolution%.com"] = "https://gitlab.evolution.com/"
                        .. "{_A.ORG}/"
                        .. "{_A.REPO}/blame/"
                        .. "{_A.REV}/"
                        .. "{_A.FILE}"
                        .. "#L{_A.LSTART}"
                        .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
                },
                default_branch = {
                    ["^gitlab%.evolution%.com"] = "https://gitlab.evolution.com/"
                        .. "{_A.ORG}/"
                        .. "{_A.REPO}/blob/"
                        .. "{_A.DEFAULT_BRANCH}/"
                        .. "{_A.FILE}"
                        .. "#L{_A.LSTART}"
                        .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
                },
                current_branch = {
                    ["^gitlab%.evolution%.com"] = "https://gitlab.evolution.com/"
                        .. "{_A.ORG}/"
                        .. "{_A.REPO}/blob/"
                        .. "{_A.CURRENT_BRANCH}/"
                        .. "{_A.FILE}"
                        .. "#L{_A.LSTART}"
                        .. "{(_A.LEND > _A.LSTART and ('-L' .. _A.LEND) or '')}",
                },
            },
        },
    },
}
