return {
    "ibhagwan/fzf-lua",
    -- Load at startup: setup() replaces `vim.ui.select` (styled by `ui_select`
    -- below), which code actions and other prompts rely on.
    lazy = false,
    keys = {
        {
            "<leader>sh",
            function()
                require("fzf-lua").help_tags()
            end,
            desc = "[H]elp",
        },
        {
            "<leader>sk",
            function()
                require("fzf-lua").keymaps()
            end,
            desc = "[K]eymaps",
        },
        {
            "<leader>sf",
            function()
                require("fzf-lua").files()
            end,
            desc = "[F]iles",
        },
        {
            "<leader>sq",
            function()
                require("fzf-lua").lgrep_quickfix()
            end,
            desc = "[Q]uickfix",
        },
        {
            "<leader>sb",
            function()
                require("fzf-lua").builtin()
            end,
            desc = "[B]uiltin",
        },
        {
            "<leader>sg",
            function()
                require("fzf-lua").live_grep()
            end,
            desc = "[G]rep",
        },
        {
            "<leader>sd",
            function()
                require("fzf-lua").diagnostics_workspace()
            end,
            desc = "[D]iagnostics",
        },
        {
            "<leader>sr",
            function()
                require("fzf-lua").resume()
            end,
            desc = "[R]esume",
        },
        {
            "<leader>sc",
            function()
                require("fzf-lua").commands()
            end,
            desc = "[C]ommands",
        },
        {
            "<leader><leader>",
            function()
                require("fzf-lua").buffers()
            end,
            desc = "Buffers",
        },
        {
            "<leader>sv",
            function()
                require("fzf-lua").nvim_options()
            end,
            desc = "[V]im",
        },
        {
            "<leader>sw",
            function()
                require("fzf-lua").grep_cword()
            end,
            desc = "[W]ord",
        },
        {
            "<leader>sw",
            function()
                require("fzf-lua").grep_visual()
            end,
            mode = "v",
            desc = "[W]ord",
        },
        {
            "<leader>so",
            function()
                require("fzf-lua").oldfiles()
            end,
            desc = "[O]ld Files",
        },
        {
            "<leader>/",
            function()
                require("fzf-lua").lgrep_curbuf()
            end,
            desc = "Grep Buffer",
        },
        {
            "<leader>sp",
            function()
                local root = vim.fs.root(0, { "package.json" }) or vim.fn.getcwd()
                require("fzf-lua").live_grep({ cwd = root })
            end,
            desc = "[P]ackage grep",
        },
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
        keymap = {
            builtin = {
                ["<C-u>"] = "preview-up",
                ["<C-d>"] = "preview-down",
            },
            fzf = {
                ["alt-s"] = "toggle",
                ["alt-a"] = "toggle-all",
            },
        },
        ui_select = {
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
                ["--exact"] = true,
            },
        },
    },
}
