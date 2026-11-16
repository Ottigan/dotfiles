vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Alternate [b]uffer" })
vim.keymap.set("n", "<leader>bd", function()
    if vim.bo.filetype == "neotest-summary" then
        require("neotest").summary.close()
    else
        Snacks.bufdelete()
    end
end, { desc = "[d]elete" })
vim.keymap.set("n", "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", { desc = "Delete others" })
vim.keymap.set("n", "<leader>bh", "<cmd>BufferLineCloseLeft<cr>", { desc = "Delete left" })
vim.keymap.set("n", "<leader>bl", "<cmd>BufferLineCloseRight<cr>", { desc = "Delete right" })
