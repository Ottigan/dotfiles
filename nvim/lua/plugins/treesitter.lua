local parsers = {
    "lua",
    "javascript",
    "typescript",
    "tsx",
    "go",
    "gomod",
    "gosum",
    "gowork",
    "templ",
    "html",
    "css",
    "scss",
    "json",
    "yaml",
    "markdown",
    "markdown_inline",
    "bash",
    "rust",
}

-- `install()` takes parser names, but a `FileType` autocmd needs filetypes, and
-- the two are not interchangeable: `tsx` is the parser for `typescriptreact`,
-- `javascript` also serves `javascriptreact`, `markdown` also serves `pandoc`.
-- nvim-treesitter registers those pairs in its `plugin/filetypes.lua` (sourced
-- before this config runs), so derive the filetypes from the registrations
-- instead of assuming parser names double as filetypes.
local function filetypes_for(langs)
    local filetypes = {}
    local seen = {}

    for _, lang in ipairs(langs) do
        for _, filetype in ipairs(vim.treesitter.language.get_filetypes(lang)) do
            if not seen[filetype] then
                seen[filetype] = true
                table.insert(filetypes, filetype)
            end
        end
    end

    return filetypes
end

return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
        require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("TreesitterFolds", { clear = true }),
            pattern = filetypes_for(parsers),
            callback = function()
                vim.treesitter.start()
                vim.opt_local.foldmethod = "expr"
                vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
                vim.opt_local.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
            end,
        })
    end,
}
