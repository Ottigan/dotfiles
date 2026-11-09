-- Unload buffers that have sat hidden and unmodified for a while.
--
-- With 'hidden' set, every visited buffer stays loaded for the whole session,
-- each holding a treesitter tree, gitsigns state and an LSP attachment. The
-- last one matters most: a language server only goes idle (see the idle
-- shutdown in plugins/lsp.lua) once no buffer is attached to it, which never
-- happens while old buffers stay loaded.
--
-- Unloading (not deleting) keeps the buffer listed, so bufferline, sessions and
-- marks are unaffected; the file is re-read on the next visit and undo history
-- comes back from 'undofile'.
local M = {}

local INTERVAL_MS = 5 * 60 * 1000
local MAX_IDLE_S = 30 * 60

local timer

--- Unload every listed, loaded buffer that is not shown in any window, has no
--- unsaved changes, is a regular file buffer and was last used `max_idle`
--- seconds ago or earlier.
--- @param max_idle? integer seconds, defaults to 30 minutes
--- @return integer unloaded number of buffers unloaded
function M.sweep(max_idle)
    max_idle = max_idle or MAX_IDLE_S

    local now = os.time()
    local unloaded = 0

    for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1, bufloaded = 1 })) do
        local buf = info.bufnr

        if
            info.hidden == 1
            and info.changed == 0
            and vim.bo[buf].buftype == ""
            and now - info.lastused >= max_idle
            -- Can fail under textlock (e.g. the cmdline window); try next sweep.
            and pcall(vim.api.nvim_buf_delete, buf, { unload = true })
        then
            unloaded = unloaded + 1
        end
    end

    return unloaded
end

local function stop()
    if timer then
        timer:stop()
        timer:close()
        timer = nil
    end
end

function M.setup()
    -- Safe to call again (e.g. after re-sourcing): never leaves a second timer.
    stop()

    timer = assert(vim.uv.new_timer())
    timer:start(
        INTERVAL_MS,
        INTERVAL_MS,
        vim.schedule_wrap(function()
            M.sweep()
        end)
    )

    vim.api.nvim_create_autocmd("VimLeavePre", {
        group = vim.api.nvim_create_augroup("IdleBuffers", { clear = true }),
        callback = stop,
    })
end

return M
