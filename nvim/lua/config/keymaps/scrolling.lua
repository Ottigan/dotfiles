-- Center screen when jumping
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "}", "}zz", { desc = "Next paragraph (centered)" })
vim.keymap.set("n", "{", "{zz", { desc = "Previous paragraph (centered)" })
