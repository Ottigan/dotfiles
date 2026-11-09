return {
    "nvim-lualine/lualine.nvim",
    opts = {
        options = {
            theme = "auto",
        },
        sections = {
            lualine_c = {
                {
                    "filename",
                    file_status = true, -- Displays file status (readonly status, modified status)
                    newfile_status = false, -- Display new file status (new file means no write after created)

                    -- 0: Just the filename
                    -- 1: Relative path
                    -- 2: Absolute path
                    -- 3: Absolute path, with tilde as the home directory
                    -- 4: Filename and parent dir, with tilde as the home directory
                    path = 1,
                    -- Shortens path to leave 40 spaces in the window
                    -- for other components. (terrible name, any suggestions?)
                    -- It can also be a function that returns
                    -- the value of `shorting_target` dynamically.
                    shorting_target = 40,
                    symbols = {
                        modified = "[+]", -- Text to show when the file is modified.
                        readonly = "[-]", -- Text to show when the file is non-modifiable or readonly.
                        unnamed = "[No Name]", -- Text to show for unnamed buffers.
                        newfile = "[New]", -- Text to show for newly created file before first write
                    },
                },
            },
            lualine_x = {
                {
                    function()
                        ---@type string|nil
                        local mode = require("noice").api.status.mode.get()

                        -- Skip status such as -- INSERT --, etc
                        if not mode or mode:sub(1, 2) == "--" then
                            return ""
                        end

                        return mode
                    end,
                    -- Don't force-load noice from the statusline; it arrives on
                    -- VeryLazy and the component starts showing up from then on.
                    cond = function()
                        return package.loaded["noice"] ~= nil and require("noice").api.status.mode.has()
                    end,
                    color = { fg = "#ff9e64" },
                },
            },
            lualine_y = { "searchcount", "lsp_status", "filetype" },
        },
    },
}
