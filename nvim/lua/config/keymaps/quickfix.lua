-- `:colder`/`:cnewer`/`setqflist()` don't fire the events Trouble refreshes on.
local function refresh_trouble()
    if package.loaded["trouble"] then
        require("trouble").refresh({ mode = "qflist" })
    end
end

-- Step through the quickfix stack, e.g. back to the list before narrowing it.
local function stack(cmd)
    return function()
        local ok, err = pcall(vim.api.nvim_command, cmd .. " " .. vim.v.count1)
        if not ok then
            local msg = tostring(err)
            vim.notify(msg:match("E%d+:.*") or msg, vim.log.levels.WARN)
            return
        end
        refresh_trouble()
    end
end

vim.keymap.set("n", "<leader>lo", stack("colder"), { desc = "[O]lder quickfix list" })
vim.keymap.set("n", "<leader>ln", stack("cnewer"), { desc = "[N]ewer quickfix list" })

-- Substitute the word under the cursor in every quickfix entry, confirming each
-- match. Leaves the cursor where the replacement goes. `e` keeps `:cdo` going
-- when an earlier entry on the same line already replaced the match.
vim.keymap.set("n", "<leader>lr", function()
    local word = vim.fn.escape(vim.fn.expand("<cword>"), [[/\]])
    local tail = "/gce | update"
    local cmd = ":cdo s/\\<" .. word .. "\\>/" .. tail
    vim.api.nvim_feedkeys(cmd .. string.rep(vim.keycode("<Left>"), #tail), "n", false)
end, { desc = "[R]eplace word in quickfix entries" })

vim.keymap.set("n", "<leader>lc", function()
    vim.fn.setqflist({}, "f")
    refresh_trouble()
end, { desc = "[C]lear quickfix lists" })
