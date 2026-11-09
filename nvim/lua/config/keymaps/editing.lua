vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })

-- Better J behavior
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines and keep cursor position" })

-- Move lines up/down
local function position_before(a, b)
    return a[2] < b[2] or (a[2] == b[2] and a[3] <= b[3])
end

local function move_visual_selection(delta)
    local anchor = vim.fn.getpos("v")
    local cursor = vim.fn.getcurpos()
    local start_pos, end_pos = anchor, cursor

    if not position_before(start_pos, end_pos) then
        start_pos, end_pos = end_pos, start_pos
    end

    local start_line = start_pos[2]
    local end_line = end_pos[2]
    local destination = delta > 0 and end_line + delta or start_line + delta - 1
    vim.cmd(string.format("%d,%dmove %d", start_line, end_line, destination))

    start_pos[2] = start_pos[2] + delta
    end_pos[2] = end_pos[2] + delta
    vim.fn.setpos("'<", start_pos)
    vim.fn.setpos("'>", end_pos)
    vim.cmd.normal({ args = { "gv=gv" }, bang = true })
end

vim.keymap.set("n", "<S-C-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
vim.keymap.set("n", "<S-C-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
vim.keymap.set("x", "<S-C-k>", function()
    move_visual_selection(-1)
end, { desc = "Move selection up" })
vim.keymap.set("x", "<S-C-j>", function()
    move_visual_selection(1)
end, { desc = "Move selection down" })

-- Better indenting
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("n", "<", "<cmd> < <cr>", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
vim.keymap.set("n", ">", "<cmd> > <cr>", { desc = "Indent right" })
