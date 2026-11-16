-- Every picker goes through snacks: searching, LSP lists and `vim.ui.select`.
-- This spec extends the main one in snacks.lua; lazy.nvim merges `opts` and `keys`.

local function pick(source, opts)
    return function()
        Snacks.picker[source](opts)
    end
end

-- ripgrep only skips binary files it finds while walking directories. Files
-- passed by name are searched anyway and reported as "binary file matches",
-- which snacks can't parse. Same test ripgrep uses: a NUL byte near the start.
local function is_binary(path)
    local fd = vim.uv.fs_open(path, "r", 438)
    if not fd then
        return true
    end
    local chunk = vim.uv.fs_read(fd, 8192, 0) or ""
    vim.uv.fs_close(fd)
    return chunk:find("\0", 1, true) ~= nil
end

-- Live grep restricted to the (text) files in the quickfix list.
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

    -- An empty `dirs` would grep the whole cwd instead.
    if #files == 0 then
        vim.notify("Quickfix list has no text files", vim.log.levels.INFO)
        return
    end

    Snacks.picker.grep({ title = "Grep Quickfix Files", dirs = files })
end

-- Snacks has no options picker. <cr> toggles a boolean, otherwise edits the value.
local function nvim_options()
    local items = {}
    for name, info in pairs(vim.api.nvim_get_all_options_info()) do
        local value = vim.api.nvim_get_option_value(name, {})
        items[#items + 1] = { text = name, name = name, value = value, type = info.type }
    end
    table.sort(items, function(a, b)
        return a.name < b.name
    end)

    Snacks.picker.pick({
        title = "Options",
        items = items,
        layout = { preset = "select" },
        format = function(item)
            return { { ("%-24s"):format(item.name), "Identifier" }, { vim.inspect(item.value), "String" } }
        end,
        confirm = function(picker, item)
            picker:close()
            if not item then
                return
            end

            if item.type == "boolean" then
                vim.o[item.name] = not item.value
                return
            end

            vim.ui.input({ prompt = item.name .. ": ", default = tostring(item.value) }, function(input)
                if input then
                    vim.o[item.name] = item.type == "number" and tonumber(input) or input
                end
            end)
        end,
    })
end

local function package_grep()
    local root = vim.fs.root(0, { "package.json" }) or vim.fn.getcwd()
    Snacks.picker.grep({ cwd = root })
end

-- Replaces snacks' `qflist` action (<C-q>): sends the selected items (or all of
-- them) to a new quickfix list without opening any window.
local function send_to_qflist(picker)
    picker:close()
    local items = picker:selected()
    if #items == 0 then
        items = picker:items()
    end

    -- Same item -> entry conversion as snacks' own action.
    local entries = {}
    for _, item in ipairs(items) do
        entries[#entries + 1] = {
            filename = Snacks.picker.util.path(item),
            bufnr = item.buf,
            lnum = item.pos and item.pos[1] or 1,
            col = item.pos and item.pos[2] + 1 or 1,
            end_lnum = item.end_pos and item.end_pos[1] or nil,
            end_col = item.end_pos and item.end_pos[2] + 1 or nil,
            text = item.line or item.comment or item.label or item.name or item.detail or item.text,
            pattern = item.search,
            type = ({ "E", "W", "I", "N" })[item.severity],
            valid = true,
        }
    end

    vim.fn.setqflist(entries)
    -- `setqflist()` doesn't fire the events an open Trouble view refreshes on.
    if package.loaded["trouble"] then
        require("trouble").refresh({ mode = "qflist" })
    end
    vim.notify(("Sent %d items to quickfix"):format(#entries))
end

-- <C-u>/<C-d> scroll the preview instead of the list.
local keys = {
    ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
    ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
}

return {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
        picker = {
            ui_select = true,
            actions = { qflist = send_to_qflist },
            sources = {
                -- Substring rather than fuzzy matching, like fzf's --exact.
                files = { matcher = { fuzzy = false } },
            },
            win = {
                input = { keys = keys },
                list = { keys = keys },
            },
        },
    },
    keys = {
        { "<leader>sh", pick("help"), desc = "[H]elp" },
        { "<leader>sk", pick("keymaps"), desc = "[K]eymaps" },
        { "<leader>sf", pick("files"), desc = "[F]iles" },
        { "<leader>sq", grep_quickfix, desc = "[Q]uickfix files grep" },
        -- Filter the entries; <C-q> in the picker turns the result into a new list.
        { "<leader>sQ", pick("qflist"), desc = "[Q]uickfix entries" },
        { "<leader>sL", pick("loclist"), desc = "[L]ocation list entries" },
        { "<leader>sb", pick("pickers"), desc = "[B]uiltin" },
        { "<leader>sg", pick("grep"), desc = "[G]rep" },
        { "<leader>sd", pick("diagnostics"), desc = "[D]iagnostics" },
        { "<leader>sr", pick("resume"), desc = "[R]esume" },
        { "<leader>sc", pick("commands"), desc = "[C]ommands" },
        { "<leader><leader>", pick("buffers"), desc = "Buffers" },
        { "<leader>sv", nvim_options, desc = "[V]im" },
        { "<leader>sw", pick("grep_word"), mode = { "n", "x" }, desc = "[W]ord" },
        { "<leader>so", pick("recent"), desc = "[O]ld Files" },
        { "<leader>/", pick("lines"), desc = "Grep Buffer" },
        { "<leader>sp", package_grep, desc = "[P]ackage grep" },
    },
}
