-- Emacs-style command-line navigation
vim.keymap.set("c", "<C-a>", "<Home>", { desc = "Start of line" })
vim.keymap.set("c", "<C-e>", "<End>", { desc = "End of line" })
vim.keymap.set("c", "<C-b>", "<Left>", { desc = "Back one character" })
vim.keymap.set("c", "<C-f>", "<Right>", { desc = "Forward one character" })
vim.keymap.set("c", "<C-d>", "<Del>", { desc = "Delete character under cursor" })
vim.keymap.set("c", "<C-n>", "<Down>", { desc = "Recall newer command-line" })
vim.keymap.set("c", "<C-p>", "<Up>", { desc = "Recall previous (older) command-line" })
