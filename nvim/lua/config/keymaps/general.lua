vim.keymap.set("n", "'", "`", { desc = "Use backticks for jumping to marks" })

-- Save
vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
vim.keymap.set("n", "<leader>W", "<cmd>wa<cr>", { desc = "Save all files" })

-- Quit
vim.keymap.set("n", "<leader>qq", "<cmd>quit<cr>", { desc = "[Q]uit window" })
vim.keymap.set("n", "<leader>qa", "<cmd>qall<cr>", { desc = "Quit [a]ll" })
vim.keymap.set("n", "<leader>qA", "<cmd>qall!<cr>", { desc = "Quit [a]ll (force)" })

-- Clear highlights on search and close floating windows when pressing <Esc> in normal mode
vim.keymap.set("n", "<Esc>", function()
    -- noice loads on VeryLazy; before that there is nothing to dismiss.
    if package.loaded["noice"] then
        require("noice").cmd("dismiss")
    end
    vim.cmd("nohlsearch")

    local curr = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_config(curr).relative ~= "" then
        vim.api.nvim_win_close(curr, false)
    end
end)
