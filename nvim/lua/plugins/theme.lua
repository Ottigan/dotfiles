return {
    "folke/tokyonight.nvim",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    ---@class tokyonight.Config
    ---@field on_colors fun(colors: ColorScheme)
    ---@field on_highlights fun(highlights: tokyonight.Highlights, colors: ColorScheme)
    opts = {
        cache = true,
        on_highlights = function(highlights, colors)
            -- General
            highlights.NormalFloat = { bg = "none" }
            highlights.FloatBorder = { bg = "none", fg = colors.blue }
            highlights.FloatTitle = { bg = "none", fg = colors.blue, bold = true }
            highlights.Whitespace = { fg = colors.terminal_black }
            highlights.NonText = { fg = colors.terminal_black }

            -- Blink
            highlights.BlinkCmpMenuBorder = { bg = "none", fg = colors.blue }
            highlights.BlinkCmpScrollBarThumb = { bg = colors.blue }
            highlights.BlinkCmpScrollBarGutter = { bg = "none" }

            -- FzfLua
            highlights.FzfLuaBorder = { bg = "none", fg = colors.blue }
            highlights.FzfLuaNormal = { bg = "none" }
        end,
        transparent = true,
        styles = {
            comments = { italic = false },
            sidebars = "transparent",
            floats = "transparent",
        },
    },
    config = function(_, opts)
        require("tokyonight").setup(opts)
        vim.cmd.colorscheme("tokyonight-night")
    end,
}
