local group = vim.api.nvim_create_augroup("Config", { clear = true })

-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
        vim.highlight.on_yank()
    end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
    group = group,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        local line = mark[1]
        local ft = vim.bo.filetype

        if
            line > 0
            and line <= lcount
            and vim.fn.index({ "commit", "gitrebase", "xxd" }, ft) == -1
            and not vim.o.diff
        then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Disable line numbers in terminal
vim.api.nvim_create_autocmd("TermOpen", {
    group = group,
    callback = function()
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false
        vim.opt_local.signcolumn = "no"
    end,
})

-- Auto-resize splits when window is resized
vim.api.nvim_create_autocmd("VimResized", {
    group = group,
    callback = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Re-render images when re-entering an already-open image buffer.
-- Snacks.image caches placement state and skips re-rendering when nothing has
-- changed, but the terminal clears graphics on buffer switch. Forcing a fresh
-- attach resets that cache so the image is always re-transmitted.
-- Scoped via FileType -> buffer-local BufEnter so this never runs on the
-- global BufEnter path for every other buffer switch. Registration is
-- deferred with vim.schedule so it lands after the buffer's own initial
-- BufEnter (fired synchronously as part of the same FileType chain on first
-- open) — otherwise this would double-attach on the very first open, racing
-- Snacks' own initial render.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "image",
    callback = function(ev)
        vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(ev.buf) then
                return
            end

            vim.api.nvim_create_autocmd("BufEnter", {
                group = group,
                buffer = ev.buf,
                callback = function()
                    Snacks.image.buf.attach(ev.buf)
                end,
            })
        end)
    end,
})

-- Automatically close buffers that no longer exist on disk
vim.api.nvim_create_autocmd("User", {
    pattern = "MiniGitUpdated",
    callback = function(ev)
        local buffers = require("config.buffers")

        -- Check if a branch change actually occurred
        local new_branch = vim.b[ev.buf].minigit_summary

        if not new_branch then
            return
        end

        if new_branch.head_name == vim.g.last_known_branch then
            return
        end

        vim.g.last_known_branch = new_branch.head_name

        for _, bufnr in ipairs(buffers.list()) do
            local bufname = vim.api.nvim_buf_get_name(bufnr)
            local path = vim.fn.fnamemodify(bufname, ":p")

            -- Delete buffer if it no longer exists on disk (e.g. due to git checkout)
            if not path or not vim.uv.fs_stat(path) then
                buffers.delete(bufnr)
            end
        end
    end,
})

-- Follow Obsidian wikilinks in markdown. Buffer-local so `gf` keeps its
-- builtin meaning everywhere else, and falls through to it when the cursor
-- isn't on a `[[link]]` or the file isn't inside a vault.
vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(ev)
        local wikilink = require("config.wikilink")

        vim.keymap.set("n", "gf", function()
            if not wikilink.follow() then
                vim.cmd("normal! gf")
            end
        end, { buffer = ev.buf, desc = "Follow wikilink or file under cursor" })

        vim.keymap.set("n", "<cr>", wikilink.follow, {
            buffer = ev.buf,
            desc = "Follow wikilink under cursor",
        })
    end,
})
