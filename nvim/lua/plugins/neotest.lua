local jest_config_files = {
    "jest.config.ts",
    "jest.config.js",
    "jest.config.cjs",
    "jest.config.mjs",
}

local jest_lockfiles = {
    "pnpm-lock.yaml",
    "yarn.lock",
    "bun.lock",
}

local jest_commands = {
    ["pnpm-lock.yaml"] = "pnpm jest",
    ["yarn.lock"] = "yarn jest",
    ["bun.lock"] = "bun jest",
}

local function current_dir()
    local cwd = vim.uv.cwd()
    if not cwd then
        error("Failed to determine current working directory for neotest-jest")
    end

    return vim.fs.normalize(cwd)
end

local function parent_dir(path)
    return vim.fs.normalize(vim.fs.dirname(path))
end

local function find_file_upward(names, start, stop)
    local dir = vim.fs.normalize(start)
    local root = vim.fs.normalize(stop)

    while dir do
        -- Check for the presence of any of the specified files in the current directory
        for _, name in ipairs(names) do
            local candidate = dir .. "/" .. name
            if vim.uv.fs_stat(candidate) ~= nil then
                return candidate
            end
        end

        -- Stop if we've reached the root directory
        if dir == root then
            break
        end

        -- Move up to the parent directory
        dir = parent_dir(dir)
        if not dir then
            break
        end
    end

    return nil
end

local function jest_cmd(path)
    local root = current_dir()
    local start = parent_dir(path)
    local lockfile = find_file_upward(jest_lockfiles, start, root)

    if lockfile then
        return jest_commands[vim.fs.basename(lockfile)]
    end

    return "npx jest"
end

-- neotest parses test files in a child `nvim --embed --headless -n -u NONE`. It
-- copies the treesitter parsers over to the child's runtimepath, but `-u NONE`
-- means no plugin is ever sourced there, so nvim-treesitter's filetype ->
-- parser registrations are missing and the child falls back to the filetype as
-- the parser name. That is fine wherever the two match (`typescript`), and
-- fails wherever they do not: a `*.spec.tsx` file is `typescriptreact`, whose
-- parser is `tsx`, so discovery dies with
-- `No parser for language "typescriptreact"` before jest is ever invoked.
--
-- Mirror this instance's registrations into the child, taking them from the
-- installed parsers rather than a hardcoded list so they cannot drift.
local function child_language_registrations()
    local registrations = {}

    for _, path in ipairs(vim.api.nvim_get_runtime_file("parser/*", true)) do
        local lang = vim.fn.fnamemodify(path, ":t:r")
        local filetypes = vim.treesitter.language.get_filetypes(lang)

        -- `get_filetypes` always returns the parser name itself; anything beyond
        -- that is a filetype the child would otherwise fail to resolve
        if #filetypes > 1 then
            registrations[lang] = filetypes
        end
    end

    return registrations
end

--- Consumer that teaches neotest's parsing child process the filetype ->
--- treesitter parser mappings this instance has.
---@type neotest.Consumer
local function child_filetypes(client)
    -- `starting` fires just after the child is spawned and long before anything
    -- is parsed, since discovery is off and parsing is driven by the keymaps
    client.listeners.starting = function()
        local subprocess = require("neotest.lib").subprocess

        if not subprocess.enabled() then
            return
        end

        for lang, filetypes in pairs(child_language_registrations()) do
            subprocess.call("vim.treesitter.language.register", { lang, filetypes })
        end
    end

    return {}
end

local function kill_test_output()
    local id = vim.api.nvim_get_current_buf()
    local buf = vim.bo[id]

    if buf.filetype == "neotest-output" then
        vim.api.nvim_buf_delete(id, { force = true })
    end
end

return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "nvim-neotest/neotest-jest",
        "nvim-neotest/neotest-go",
        "marilari88/neotest-vitest",
    },
    config = function()
        local js_clients_jest = require("neotest-jest")
        local neotest = require("neotest")

        --- @diagnostic disable: duplicate-set-field
        js_clients_jest.root = function()
            return current_dir()
        end

        ---@diagnostic disable: missing-fields
        neotest.setup({
            consumers = {
                child_filetypes = child_filetypes,
            },
            projects = {
                ["~/Documents/js-clients"] = {
                    discovery = { concurrent = 0, enabled = false },
                    adapters = {
                        js_clients_jest({
                            jestCommand = jest_cmd,
                            jestConfigFile = function(file)
                                local root = current_dir()
                                local start = parent_dir(file)
                                local config = find_file_upward(jest_config_files, start, root)
                                return config
                            end,
                        }),
                    },
                },
            },
            status = { enabled = true, virtual_text = true, signs = true },
            output = { enabled = true, open_on_run = true },
            discovery = { concurrent = 0, enabled = false },
            adapters = {
                require("neotest-vitest"),
                require("neotest-jest"),
                require("neotest-go"),
            },
        })
    end,
    keys = {
        {
            "<leader>tn",
            function()
                require("neotest").run.run()
            end,
            desc = "[N]earest",
        },
        {
            "<leader>tf",
            function()
                require("neotest").run.run(vim.fn.expand("%"))
            end,
            desc = "[F]ile",
        },
        {
            "<leader>to",
            function()
                require("neotest").output.open({ enter = true })
            end,
            desc = "[O]utput",
        },
        {
            "<leader>ts",
            function()
                kill_test_output()
                require("neotest").summary.toggle()
            end,
            desc = "[S]ummary",
        },
        {
            "<leader>tp",
            function()
                kill_test_output()
                require("neotest").output_panel.toggle()
            end,
            desc = "[P]anel",
        },
        {
            "<leader>tc",
            function()
                require("neotest").output_panel.clear()
            end,
            desc = "[C]lear",
        },
        {
            "<leader>tl",
            function()
                require("neotest").run.run_last()
            end,
            desc = "[L]ast",
        },
        {
            "<leader>td",
            function()
                require("neotest").run.run({ strategy = "dap", suite = false })
            end,
            desc = "[D]ebug",
        },
    },
}
