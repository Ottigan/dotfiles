local set = vim.opt

-- Leader keys
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic settings
set.number = true -- Line numbers
set.relativenumber = true -- Relative line numbers
set.cursorline = true -- Highlight the current line
set.wrap = false -- Don't wrap lines
set.scrolloff = 10 -- Keep 10 lines above/below cursor
set.sidescrolloff = 8 -- Keep 8 columns left/right of cursor
set.sessionoptions:remove("terminal") -- Don't store terminal buffers in sessions
vim.lsp.document_color.enable(false)

-- Indentation
set.tabstop = 2 -- Tab width
set.shiftwidth = 2 -- Indent width
set.softtabstop = 2 -- Soft tab stop
set.expandtab = true -- Use spaces instead of tabs
set.smartindent = true -- Smart auto-indenting
set.breakindent = true -- Wrapped lines will be indented

-- Search settings
set.ignorecase = true -- Case-insensitive search
set.smartcase = true -- Case-sensitive if uppercase letters are used

-- Visual settings
set.signcolumn = "yes" -- Always show the sign column
set.winborder = "rounded" -- Rounded float borders
set.showmatch = true -- Highlight matching brackets
set.matchtime = 2 -- How long to show match
set.completeopt = "menuone,noselect" -- Completion options
set.showmode = false -- Don't show -- INSERT -- etc.
set.pumheight = 10 -- Popup menu height
set.pumblend = 10 -- Popup transparency
set.list = true -- Show whitespace characters
set.listchars = { tab = "→ ", trail = ".", lead = " ", nbsp = "␣" }
set.synmaxcol = 300 -- Don't syntax highlight long lines
set.foldlevelstart = 99 -- Start with all folds open
vim.o.guicursor = "n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20,t:ver25"

-- File handling
set.writebackup = false -- Don't create backup files while writing
set.swapfile = false -- Don't create swap files
set.undofile = true -- Enable persistent undo
set.undodir = vim.fn.expand("~/.vim/undodir") -- Undo directory
set.updatetime = 500 -- CursorHold delay; lower = more frequent LSP/gitsigns polling
set.timeoutlen = 500 -- Faster key sequence timeout
set.ttimeoutlen = 0 -- Don't wait for key codes

-- Behaviour settings
set.mouse = "a" -- Enable mouse support
set.clipboard:append("unnamedplus") -- Use system clipboard
set.confirm = true -- Confirm before exiting with unsaved changes

-- Split behavior
set.splitbelow = true -- Horizontal splits go below
set.splitright = true -- Vertical splits go right

-- Filetypes
vim.filetype.add({ extension = { pcss = "scss" } })
