-- Custom open to handle file paths including port
vim.keymap.set("n", "gx", function()
    local line = vim.api.nvim_get_current_line()
    local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1

    for i = cursor_col, 1, -1 do
        local char = line:sub(i, i)
        if char:match("%s") then
            cursor_col = i
            break
        end
    end

    local url = line:sub(cursor_col):match("%S+")

    if not url then
        return
    end

    vim.ui.open(url)
end, { desc = "Open file/URL under cursor" })

-- Finder. :S shell-escapes the path; silent skips the hit-enter prompt.
vim.keymap.set("n", "<leader>od", "<cmd>silent !open -R %:S<cr>", { desc = "Open file directory" })
vim.keymap.set("n", "<leader>of", "<cmd>silent !open %:S<cr>", { desc = "Open file" })
vim.keymap.set("n", "<leader>oc", "<cmd>silent !open .<cr>", { desc = "Open cwd" })
