return { -- Collection of various small independent plugins/modules
    "nvim-mini/mini.nvim",
    lazy = false,
    priority = 1000,
    config = function()
        local miniclue = require("mini.clue")
        require("mini.git").setup()

        miniclue.setup({
            -- Clue window settings
            window = {
                -- Floating window config
                config = { anchor = "SE", width = 50, height = 10, col = "auto", row = "auto" },

                -- Delay before showing clue window
                delay = 200,

                -- Keys to scroll inside the clue window
                scroll_up = "<C-u>",
                scroll_down = "<C-d>",
            },

            triggers = {
                -- Leader triggers
                { mode = { "n", "x" }, keys = "<Leader>" },

                -- `[` and `]` keys
                { mode = "n", keys = "[" },
                { mode = "n", keys = "]" },

                -- Built-in completion
                { mode = "i", keys = "<C-x>" },

                -- `g` key
                { mode = { "n", "x" }, keys = "g" },

                -- Marks
                { mode = { "n", "x" }, keys = "'" },
                { mode = { "n", "x" }, keys = "`" },

                -- Registers
                { mode = { "n", "x" }, keys = '"' },
                { mode = { "i", "c" }, keys = "<C-r>" },

                -- Window commands
                { mode = "n", keys = "<C-w>" },

                -- `z` key
                { mode = { "n", "x" }, keys = "z" },
            },

            clues = {
                { mode = "n", keys = "<Leader>s", desc = "+Search" },
                { mode = "n", keys = "<Leader>b", desc = "+Buffers" },
                { mode = "n", keys = "<Leader>g", desc = "+Git" },
                { mode = "n", keys = "<Leader>n", desc = "+Notifications" },
                { mode = "n", keys = "<Leader>c", desc = "+Copy" },
                { mode = "n", keys = "<Leader>t", desc = "+Test" },
                { mode = "n", keys = "<Leader>d", desc = "+Debug" },
                { mode = "n", keys = "<Leader>q", desc = "+Quit/Session" },
                { mode = "n", keys = "<Leader>x", desc = "+Diagnostic" },
                { mode = "n", keys = "<Leader>l", desc = "+Lists" },

                miniclue.gen_clues.square_brackets(),
                miniclue.gen_clues.builtin_completion(),
                miniclue.gen_clues.g(),
                miniclue.gen_clues.marks(),
                miniclue.gen_clues.registers(),
                miniclue.gen_clues.windows(),
                miniclue.gen_clues.z(),
            },
        })

        local mini_icons = require("mini.icons")
        mini_icons.setup({
            style = vim.g.have_nerd_font and "glyph" or "ascii",
            lsp = {
                error = { glyph = "", hl = "MiniIconsRed" },
                warn = { glyph = "", hl = "MiniIconsYellow" },
                hint = { glyph = "", hl = "MiniIconsBlue" },
                info = { glyph = "", hl = "MiniIconsCyan" },
            },
        })
        mini_icons.mock_nvim_web_devicons()
        mini_icons.tweak_lsp_kind()

        local hipatterns = require("mini.hipatterns")
        hipatterns.setup({
            options = {
                -- Skip files larger than 100 KB — pattern scanning on every keystroke
                -- in large generated/minified TS files causes measurable slowdown.
                max_file_size = 100 * 1024,
            },
            highlighters = {
                -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
                fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
                hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
                todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
                note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

                rgb_color = {
                    pattern = "()rgb%(%s*%d%d?%d?%s*,%s*%d%d?%d?%s*,%s*%d%d?%d?%s*%)()",
                    group = function(_, match)
                        local r, g, b = match:match("rgb%(%s*(%d%d?%d?)%s*,%s*(%d%d?%d?)%s*,%s*(%d%d?%d?)%s*%)")
                        r, g, b = tonumber(r), tonumber(g), tonumber(b)

                        if not r or not g or not b then
                            return nil
                        end

                        if r > 255 or g > 255 or b > 255 then
                            return nil
                        end

                        local hex = string.format("#%02x%02x%02x", r, g, b)
                        return hipatterns.compute_hex_color_group(hex, "bg")
                    end,
                },

                -- Highlight hex color strings (`#rrggbb`) using that color
                hex_color = hipatterns.gen_highlighter.hex_color(),
            },
        })

        -- better around/inside textobjects
        --
        -- examples:
        --  - va)  - [v]isually select [a]round [)]paren
        --  - vib  - [v]isually select [i]nside [b]
        --  - yinq - [y]ank [i]nside [n]ext [q]uote
        --  - ci'  - [c]hange [i]nside [']quote
        require("mini.ai").setup({ n_lines = 50 })

        -- add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sdn(   - [S]urround [D]elete [N]ext [(]paren
        -- - sr)'  - [S]urround [R]eplace [)] [']
        -- - srn({ - [S]urround [R]eplace [N]ext [(] with [{]brace
        require("mini.surround").setup()

        require("mini.files").setup({
            options = {
                use_as_default_explorer = true,
            },
            mappings = {
                show_help = "?",
                close = "q",
                go_in = "L",
                go_in_plus = "l",
                go_out = "h",
                go_out_plus = "H",
                mark_goto = "'",
                mark_set = "m",
                reset = "<BS>",
                reveal_cwd = "@",
                synchronize = "<cr>",
                trim_left = "<",
                trim_right = ">",
            },
            windows = {
                width_nofocus = 25,
                preview = false,
            },
        })

        vim.keymap.set("n", "<leader>e", function()
            local bufname = vim.api.nvim_buf_get_name(0)
            local path = vim.fn.fnamemodify(bufname, ":p")

            -- Noop if the buffer isn't valid.
            if path and vim.uv.fs_stat(path) then
                require("mini.files").open(bufname, true)
            end
        end, { desc = "File explorer" })

        local show_dotfiles = true

        local filter_show = function()
            return true
        end

        local filter_hide = function(fs_entry)
            return not vim.startswith(fs_entry.name, ".")
        end

        local toggle_dotfiles = function()
            show_dotfiles = not show_dotfiles
            local new_filter = show_dotfiles and filter_show or filter_hide
            MiniFiles.refresh({ content = { filter = new_filter } })
        end

        local map_split = function(buf_id, lhs, direction, close_on_file)
            local rhs = function()
                local new_target_window
                local cur_target_window = require("mini.files").get_explorer_state().target_window
                if cur_target_window ~= nil then
                    vim.api.nvim_win_call(cur_target_window, function()
                        vim.cmd("belowright " .. direction .. " split")
                        new_target_window = vim.api.nvim_get_current_win()
                    end)

                    require("mini.files").set_target_window(new_target_window)
                    require("mini.files").go_in({ close_on_file = close_on_file })
                end
            end

            local desc = "Open in " .. direction .. " split"
            if close_on_file then
                desc = desc .. " and close"
            end
            vim.keymap.set("n", lhs, rhs, { buffer = buf_id, desc = desc })
        end

        local mini_files_group = vim.api.nvim_create_augroup("MiniFilesConfig", { clear = true })

        vim.api.nvim_create_autocmd("User", {
            group = mini_files_group,
            pattern = "MiniFilesBufferCreate",
            callback = function(args)
                local buf_id = args.data.buf_id

                vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id, desc = "Toggle hidden files" })

                -- Close the whole explorer at once. Without this the global <Esc> map takes over
                -- and closes a single floating window per press, one directory column at a time.
                vim.keymap.set("n", "<Esc>", function()
                    MiniFiles.close()
                end, { buffer = buf_id, desc = "Close" })

                map_split(buf_id, "<C-s>", "horizontal", true)
                map_split(buf_id, "<C-v>", "vertical", true)
            end,
        })

        vim.api.nvim_create_autocmd("User", {
            group = mini_files_group,
            pattern = "MiniFilesActionRename",
            callback = function(event)
                Snacks.rename.on_rename_file(event.data.from, event.data.to)
            end,
        })

        -- ... and there is more!
        --  Check out: https://github.com/nvim-mini/mini.nvim
    end,
}
