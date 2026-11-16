-- Every picker goes through fzf-lua: searching, LSP lists and `vim.ui.select`.

-- ripgrep only skips binary files it finds while walking directories. Files
-- passed by name are searched anyway and reported as "binary file matches".
-- Same test ripgrep uses: a NUL byte near the start.
local function is_binary(path)
    local fd = vim.uv.fs_open(path, "r", 438)
    if not fd then
        return true
    end
    local chunk = vim.uv.fs_read(fd, 8192, 0) or ""
    vim.uv.fs_close(fd)
    return chunk:find("\0", 1, true) ~= nil
end

-- Live grep restricted to the (text) files in the quickfix list. Like fzf-lua's
-- own `lgrep_quickfix`, minus the binary files.
local function grep_quickfix()
    local files, seen = {}, {}
    for _, entry in ipairs(vim.fn.getqflist()) do
        local name = entry.bufnr > 0 and vim.api.nvim_buf_get_name(entry.bufnr) or ""
        if name ~= "" and not seen[name] then
            seen[name] = true
            if not is_binary(name) then
                files[#files + 1] = name
            end
        end
    end

    -- Empty `search_paths` would grep the whole cwd instead.
    if #files == 0 then
        vim.notify("Quickfix list has no text files", vim.log.levels.INFO)
        return
    end

    require("fzf-lua").live_grep({ prompt = "Quickfix Files> ", search_paths = files })
end

local function package_grep()
    local root = vim.fs.root(0, { "package.json" }) or vim.fn.getcwd()
    require("fzf-lua").live_grep({ cwd = root })
end

-- Sends entries to a new quickfix list. `copen = ""` below keeps fzf-lua from
-- opening a window.
local function send_to_qflist(selected, opts)
    require("fzf-lua").actions.file_sel_to_qf(selected, opts)
    -- `setqflist()` doesn't fire the events an open Trouble view refreshes on.
    if package.loaded["trouble"] then
        require("trouble").refresh({ mode = "qflist" })
    end
    vim.notify(("Sent %d items to quickfix"):format(#selected))
end

return {
    "ibhagwan/fzf-lua",
    -- Load at startup: setup() replaces `vim.ui.select` (styled by `ui_select`
    -- below), which code actions and other prompts rely on.
    lazy = false,
    keys = {
        { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "[H]elp" },
        { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "[K]eymaps" },
        { "<leader>sf", "<cmd>FzfLua files<cr>", desc = "[F]iles" },
        { "<leader>sq", grep_quickfix, desc = "[Q]uickfix files grep" },
        -- Filter the entries; ctrl-q in the picker turns the result into a new list.
        { "<leader>sQ", "<cmd>FzfLua quickfix<cr>", desc = "[Q]uickfix entries" },
        { "<leader>sL", "<cmd>FzfLua loclist<cr>", desc = "[L]ocation list entries" },
        { "<leader>sb", "<cmd>FzfLua builtin<cr>", desc = "[B]uiltin" },
        { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "[G]rep" },
        { "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "[D]iagnostics" },
        { "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "[R]esume" },
        { "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "[C]ommands" },
        { "<leader><leader>", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
        { "<leader>sv", "<cmd>FzfLua nvim_options<cr>", desc = "[V]im" },
        { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "[W]ord" },
        { "<leader>sw", "<cmd>FzfLua grep_visual<cr>", mode = "x", desc = "[W]ord" },
        { "<leader>so", "<cmd>FzfLua oldfiles<cr>", desc = "[O]ld Files" },
        { "<leader>/", "<cmd>FzfLua blines<cr>", desc = "Grep Buffer" },
        { "<leader>sp", package_grep, desc = "[P]ackage grep" },
    },
    ---@module "fzf-lua"
    ---@type fzf-lua.Config|{}
    ---@diagnostic disable: missing-fields
    opts = {
        defaults = {
            file_icons = "mini",
            copen = "", -- disable auto-open
            lopen = "", -- disable auto-open
        },
        ---@type fzf-lua.config.Colorschemes
        fzf_colors = {
            true, -- inherit fzf colors that aren't specified below from
            ["pointer"] = { "fg", "Exception" },
        },
        -- `true` keeps fzf-lua's defaults; these tables replace them otherwise.
        keymap = {
            fzf = {
                true,
                -- fzf-lua binds these to half-page scrolling; restore the emacs
                -- cursor motions fzf (and the shell) use.
                ["ctrl-b"] = "backward-char",
                ["ctrl-f"] = "forward-char",
            },
        },
        actions = {
            files = {
                true,
                -- ctrl-q: every filtered entry; alt-q: just the selected ones.
                ["ctrl-q"] = { fn = send_to_qflist, prefix = "select-all" },
                ["alt-q"] = send_to_qflist,
            },
        },
        ui_select = {
            -- Equal matches keep the list's order (e.g. sessions by recency, or
            -- `2` then `20`, `21`, …) instead of fzf's default shortest-line-first.
            fzf_opts = { ["--tiebreak"] = "index" },
            winopts = {
                height = 0.5,
                width = 0.5,
                preview = {
                    layout = "vertical",
                },
            },
        },
        files = {
            cwd_prompt = false,
            fzf_opts = {
                ["--multi"] = true,
                ["--scheme"] = "path",
            },
        },
    },
}
