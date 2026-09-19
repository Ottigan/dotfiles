local function setup_filetypes()
    vim.filetype.add({
        extension = {
            pcss = "scss",
        },
    })
end

local function setup_diagnostics()
    -- Diagnostic configuration.
    vim.diagnostic.config({
        status = {
            format = {
                [vim.diagnostic.severity.ERROR] = MiniIcons.get("lsp", "ERROR"),
                [vim.diagnostic.severity.WARN] = MiniIcons.get("lsp", "WARN"),
                [vim.diagnostic.severity.INFO] = MiniIcons.get("lsp", "INFO"),
                [vim.diagnostic.severity.HINT] = MiniIcons.get("lsp", "HINT"),
            },
        },
        virtual_text = {
            prefix = "",
            spacing = 2,
            format = function(diagnostic)
                -- Use shorter, nicer names for some sources:
                local special_sources = {
                    ["Lua Diagnostics."] = "lua",
                    ["Lua Syntax Check."] = "lua",
                }

                local message = MiniIcons.get("lsp", vim.diagnostic.severity[diagnostic.severity])
                if diagnostic.source then
                    message = string.format("%s %s", message, special_sources[diagnostic.source] or diagnostic.source)
                end
                if diagnostic.code then
                    message = string.format("%s[%s]", message, diagnostic.code)
                end

                return message .. " "
            end,
        },
        float = {
            source = "if_many",
            -- Show severity icons as prefixes.
            prefix = function(diag)
                local level = vim.diagnostic.severity[diag.severity]
                local prefix = string.format(" %s ", MiniIcons.get("lsp", level))
                return prefix, "Diagnostic" .. level:gsub("^%l", string.upper)
            end,
        },
        -- Disable signs in the gutter.
        signs = false,
    })
end

local function setup_lsp_keymaps()
    local FzfLua = require("fzf-lua")

    local keymaps = {
        {
            keys = "gra",
            callback = vim.lsp.buf.code_action,
            desc = "Goto Code [A]ction",
            mode = { "n", "x" },
        },
        { keys = "gri", callback = FzfLua.lsp_implementations, desc = "Goto [I]mplementation" },
        { keys = "grn", callback = vim.lsp.buf.rename, desc = "Re[n]ame" },
        { keys = "grr", callback = FzfLua.lsp_references, desc = "Goto [R]eferences" },
        { keys = "grt", callback = FzfLua.lsp_typedefs, desc = "Goto [T]ype Definition" },
        { keys = "grx", callback = vim.lsp.codelens.run, desc = "Code Lens E[x]ecute" },
        { keys = "grd", callback = FzfLua.lsp_definitions, desc = "Goto [D]efinition" },
        { keys = "grD", callback = vim.lsp.buf.declaration, desc = "Goto [D]eclaration" },
        { keys = "gO", callback = FzfLua.lsp_document_symbols, desc = "Document Symbols" },
        { keys = "gW", callback = FzfLua.lsp_live_workspace_symbols, desc = "Workspace Symbols" },
    }

    for _, mapping in ipairs(keymaps) do
        vim.keymap.set(mapping.mode or "n", mapping.keys, mapping.callback, {
            desc = "LSP: " .. mapping.desc,
        })
    end
end

local function setup_servers()
    local servers = {
        tsc = {
            cmd = { "tsc", "--lsp", "--stdio" },
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
        },
        eslint = {
            cmd = { "vscode-eslint-language-server", "--stdio" },
            filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
            root_markers = {
                ".eslintrc",
                ".eslintrc.js",
                ".eslintrc.json",
                "eslint.config.js",
                "eslint.config.cjs",
                "eslint.config.mjs",
            },
            settings = {
                validate = "on",
                packageManager = vim.NIL,
                useESLintClass = false,
                experimental = { useFlatConfig = true },
                codeActionOnSave = { enable = false, mode = "all" },
                format = false,
                quiet = false,
                onIgnoredFiles = "off",
                options = {},
                rulesCustomizations = {},
                run = "onSave",
                problems = { shortenToSingleLine = false },
                nodePath = "",
                workingDirectory = { mode = "location" },
                codeAction = {
                    disableRuleComment = { enable = true, location = "separateLine" },
                    showDocumentation = { enable = true },
                },
            },
            before_init = function(params, config)
                -- Set the workspace folder setting for correct search of tsconfig.json files etc.
                config.settings.workspaceFolder = {
                    uri = params.rootPath,
                    name = vim.fn.fnamemodify(params.rootPath, ":t"),
                }
            end,
            ---@type table<string, lsp.Handler>
            handlers = {
                ["eslint/openDoc"] = function(_, params)
                    vim.ui.open(params.url)
                    return {}
                end,
                ["eslint/probeFailed"] = function()
                    vim.notify("LSP[eslint]: Probe failed.", vim.log.levels.WARN)
                    return {}
                end,
                ["eslint/noLibrary"] = function()
                    vim.notify("LSP[eslint]: Unable to load ESLint library.", vim.log.levels.WARN)
                    return {}
                end,
            },
        },
        gopls = {
            cmd = { "gopls" },
            root_markers = { "go.mod" },
            filetypes = { "go", "gomod" },
            settings = {
                gopls = {
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                },
            },
        },
        rust_analyzer = {
            cmd = { "rust-analyzer" },
            filetypes = { "rust" },
            root_markers = { "Cargo.toml", "rust-project.json", ".git" },
            before_init = function(_, config)
                -- rust-analyzer only ever looks for a Cargo.toml or a
                -- rust-project.json under the workspace root, and gives up with
                -- "failed to find any projects" on a .rs file that belongs to
                -- neither. Naming the file as a linked project is what makes it
                -- analyse a standalone script; linkedProjects takes a plain .rs
                -- path for exactly this case, and has to arrive as a setting
                -- rather than an init option to be picked up. Cargo cannot check
                -- a file outside a project, so that pass goes with it.
                if not config.root_dir then
                    local settings = config.settings["rust-analyzer"]
                    settings.linkedProjects = { vim.api.nvim_buf_get_name(0) }
                    settings.checkOnSave = false
                end
            end,
            settings = {
                ["rust-analyzer"] = {
                    cargo = { allFeatures = true },
                    check = { command = "clippy" },
                    inlayHints = {
                        bindingModeHints = { enable = true },
                        closureReturnTypeHints = { enable = "always" },
                        lifetimeElisionHints = { enable = "always", useParameterNames = true },
                        parameterHints = { enable = true },
                        typeHints = { enable = true },
                    },
                    procMacro = { enable = true },
                },
            },
        },
        lua_ls = {
            -- Command and arguments to start the server.
            cmd = { "lua-language-server" },
            -- Filetypes to automatically attach to.
            filetypes = { "lua" },
            -- Sets the "workspace" to the directory where any of these files is found.
            -- Files that share a root directory will reuse the LSP server connection.
            -- Nested lists indicate equal priority, see |vim.lsp.Config|.
            root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
            -- Specific settings to send to the server. The schema is server-defined.
            -- Example: https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
            settings = {
                Lua = {
                    -- Using stylua for formatting.
                    format = { enable = false },
                    runtime = {
                        version = "LuaJIT",
                    },
                    workspace = {
                        checkThirdParty = false,
                        library = {
                            vim.env.VIMRUNTIME,
                            "${3rd}/luv/library",
                        },
                    },
                },
            },
        },
        cssls = {
            cmd = { "vscode-css-language-server", "--stdio" },
            filetypes = { "css", "scss", "less" },
            settings = {
                css = { validate = true },
                scss = { validate = true },
                less = { validate = true },
            },
        },
        jsonls = {
            cmd = { "vscode-json-language-server", "--stdio" },
            filetypes = { "json", "jsonc" },
            settings = {
                json = {
                    validate = { enable = true },
                },
            },
            -- Defer the schema catalog lookup until jsonls is actually about to
            -- start (i.e. a json/jsonc buffer was opened), instead of building it
            -- unconditionally every time this file's config runs.
            before_init = function(_, config)
                config.settings.json.schemas = require("schemastore").json.schemas()
            end,
        },
        tailwindcss = {},
        taplo = {},
        templ = {},
        zls = {},
    }

    for name, config in pairs(servers) do
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
    end
end

return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { "b0o/schemastore.nvim", lazy = true },
    },
    config = function()
        setup_filetypes()
        setup_diagnostics()
        setup_lsp_keymaps()
        setup_servers()
    end,
}
