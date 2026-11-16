return {
    "nvim-lualine/lualine.nvim",
    opts = {
        sections = {
            lualine_c = {
                { "filename", path = 1 },
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
