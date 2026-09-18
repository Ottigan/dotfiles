-- Navigation for Obsidian-style wikilinks: `[[Note]]`, `[[Note|Alias]]`,
-- `[[Note#Heading]]`, `[[Note#^block-id]]` and `[[Folder/Note]]`.
--
-- Obsidian links by *shortest unique path*, so `[[Hiragana]]` is a valid link
-- to `Japanese/Hiragana.md`. That rules out plain `gf`, which only resolves
-- literal paths — the target has to be searched for by basename across the
-- vault instead.
local M = {}

-- `.obsidian` marks the vault root; without it there is no vault to search and
-- following a link is meaningless, so callers fall back to builtin `gf`.
local function vault_root(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return nil
    end

    return vim.fs.root(name, ".obsidian")
end

-- Returns the `[[...]]` body the cursor sits inside, or nil. Scans every link
-- on the line rather than the first one, so lines with several links work.
local function link_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    local init = 1

    while true do
        local start, finish, body = line:find("%[%[(.-)%]%]", init)
        if not start then
            return nil
        end

        if col >= start and col <= finish then
            return body
        end

        init = finish + 1
    end
end

-- `[[target#anchor|alias]]` — the alias is display-only, the anchor is a
-- heading or, when prefixed with `^`, a block id.
local function parse(body)
    local link = vim.split(body, "|", { plain = true })[1]
    local target, anchor = link:match("^(.-)#(.*)$")

    target = vim.trim(target or link)
    anchor = anchor and vim.trim(anchor) or nil

    if target == "" then
        return nil, anchor
    end

    return target, anchor
end

local function candidates(root, target)
    -- A link that spells out a path is unambiguous; take it as written.
    if target:find("/", 1, true) then
        local path = vim.fs.joinpath(root, target)
        if vim.uv.fs_stat(path) then
            return { path }
        end
    end

    return vim.fs.find(vim.fs.basename(target), {
        path = root,
        type = "file",
        limit = math.huge,
    })
end

-- Headings are matched case-insensitively on their text, ignoring the `#`
-- markers, which is how Obsidian resolves them.
local function jump_to_anchor(anchor)
    local block = anchor:match("^%^(.+)$")
    local pattern

    if block then
        pattern = [[\V\^]] .. vim.fn.escape(block, [[\]]) .. [[\s\*\$]]
    else
        pattern = [[\c\v^#+\s*]] .. vim.fn.escape(anchor, [[\/]]) .. [[\s*$]]
    end

    local found = vim.fn.search(pattern, "w")
    if found == 0 then
        vim.notify("No anchor: " .. anchor, vim.log.levels.WARN)
        return
    end

    vim.cmd("normal! zz")
end

local function open(path, anchor)
    -- Attachments (images, PDFs) are linked the same way but have no business
    -- being loaded into a buffer.
    if not path:match("%.md$") then
        vim.ui.open(path)
        return
    end

    vim.cmd.edit(vim.fn.fnameescape(path))

    if anchor then
        jump_to_anchor(anchor)
    end
end

-- Unresolved links are how notes get written in Obsidian, so offer to create
-- the file rather than just reporting it missing. New notes land next to the
-- linking note unless the link named a folder.
local function create(root, target, anchor)
    if not target:match("%.%w+$") then
        target = target .. ".md"
    end

    local path
    if target:find("/", 1, true) then
        path = vim.fs.joinpath(root, target)
    else
        path = vim.fs.joinpath(vim.fs.dirname(vim.api.nvim_buf_get_name(0)), target)
    end

    local choice = vim.fn.confirm("Create " .. vim.fs.relpath(root, path) .. "?", "&Yes\n&No", 2)
    if choice ~= 1 then
        return
    end

    vim.fn.mkdir(vim.fs.dirname(path), "p")
    open(path, anchor)
end

--- Follow the wikilink under the cursor.
--- @return boolean handled `false` when the cursor is not on a resolvable link,
--- letting the caller fall back to its default mapping.
function M.follow()
    local body = link_under_cursor()
    if not body then
        return false
    end

    local root = vault_root(0)
    if not root then
        return false
    end

    local target, anchor = parse(body)

    -- `[[#Heading]]` links within the current note.
    if not target then
        if anchor then
            jump_to_anchor(anchor)
        end
        return true
    end

    local matches = candidates(root, target)
    if not target:match("%.%w+$") then
        vim.list_extend(matches, candidates(root, target .. ".md"))
    end

    if #matches == 0 then
        create(root, target, anchor)
    elseif #matches == 1 then
        open(matches[1], anchor)
    else
        vim.ui.select(matches, {
            prompt = "Wikilink: " .. target,
            format_item = function(item)
                return vim.fs.relpath(root, item) or item
            end,
        }, function(choice)
            if choice then
                open(choice, anchor)
            end
        end)
    end

    return true
end

return M
