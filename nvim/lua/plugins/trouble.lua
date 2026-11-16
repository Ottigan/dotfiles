return {
    "folke/trouble.nvim",
    opts = {
        focus = true,
    },
    cmd = "Trouble",
    init = function()
        -- Show every quickfix/location list in Trouble instead of the native
        -- window, whatever opened it (snacks <C-q>, :copen, :grep, …). The lists
        -- themselves are untouched, so ]q, :cdo and <leader>sq keep working.
        vim.api.nvim_create_autocmd("BufWinEnter", {
            group = vim.api.nvim_create_augroup("TroubleQuickfix", { clear = true }),
            callback = function(ev)
                if vim.bo[ev.buf].buftype ~= "quickfix" then
                    return
                end

                local win = vim.fn.bufwinid(ev.buf)
                local loclist = vim.fn.getwininfo(win)[1].loclist == 1

                vim.schedule(function()
                    if vim.api.nvim_win_is_valid(win) then
                        vim.api.nvim_win_close(win, true)
                    end
                    require("trouble").open({ mode = loclist and "loclist" or "qflist" })
                end)
            end,
        })
    end,
    keys = {
        {
            "<leader>xx",
            "<cmd>Trouble diagnostics toggle<cr>",
            desc = "Global diagnostics",
        },
        {
            "<leader>xX",
            "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
            desc = "Buffer diagnostics",
        },
        {
            "<leader>lq",
            "<cmd>Trouble qflist toggle<cr>",
            desc = "Toggle quickfix",
        },
        {
            "<leader>ll",
            "<cmd>Trouble loclist toggle<cr>",
            desc = "Toggle loclist",
        },
    },
}
