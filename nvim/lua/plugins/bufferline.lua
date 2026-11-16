-- Pretty bufferline.
return {
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        keys = {
            -- Buffer navigation.
            { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer" },
            { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
            { "<leader>bp", "<cmd>BufferLinePick<cr>", desc = "[P]ick" },
            { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "[C]lose" },
        },
        config = function()
            local bufferline = require("bufferline")

            local function delete(bufnr)
                Snacks.bufdelete({ buf = bufnr, force = true })
            end

            bufferline.setup({
                options = {
                    close_command = delete,
                    right_mouse_command = delete,
                    style_preset = bufferline.style_preset.no_italic,
                    separator_style = { " │", " │" },
                    indicator = { style = "underline" },
                    show_tab_indicators = false,
                    show_buffer_close_icons = false,
                    show_close_icon = false,
                    custom_filter = function(buf)
                        return vim.bo[buf].buftype ~= "terminal"
                    end,
                    diagnostics = "nvim_lsp",
                    diagnostics_indicator = function(count, level)
                        local icon = level:match("error") and MiniIcons.get("lsp", "error")
                            or MiniIcons.get("lsp", "warn")
                        return " " .. icon .. count
                    end,
                },
            })
        end,
    },
}
