return {
    "ibhagwan/fzf-lua",
    -- Load at startup: setup() replaces `vim.ui.select` (styled by `ui_select`
    -- below), which code actions and other prompts rely on.
    lazy = false,
    keys = {
        { "<leader>sh", "<cmd>FzfLua help_tags<cr>", desc = "[H]elp" },
        { "<leader>sk", "<cmd>FzfLua keymaps<cr>", desc = "[K]eymaps" },
        { "<leader>sf", "<cmd>FzfLua files<cr>", desc = "[F]iles" },
        { "<leader>sq", "<cmd>FzfLua lgrep_quickfix<cr>", desc = "[Q]uickfix" },
        { "<leader>sb", "<cmd>FzfLua builtin<cr>", desc = "[B]uiltin" },
        { "<leader>sg", "<cmd>FzfLua live_grep<cr>", desc = "[G]rep" },
        { "<leader>sd", "<cmd>FzfLua diagnostics_workspace<cr>", desc = "[D]iagnostics" },
        { "<leader>sr", "<cmd>FzfLua resume<cr>", desc = "[R]esume" },
        { "<leader>sc", "<cmd>FzfLua commands<cr>", desc = "[C]ommands" },
        { "<leader><leader>", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
        { "<leader>sv", "<cmd>FzfLua nvim_options<cr>", desc = "[V]im" },
        { "<leader>sw", "<cmd>FzfLua grep_cword<cr>", desc = "[W]ord" },
        { "<leader>sw", "<cmd>FzfLua grep_visual<cr>", mode = "v", desc = "[W]ord" },
        { "<leader>so", "<cmd>FzfLua oldfiles<cr>", desc = "[O]ld Files" },
        { "<leader>/", "<cmd>FzfLua lgrep_curbuf<cr>", desc = "Grep Buffer" },
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
