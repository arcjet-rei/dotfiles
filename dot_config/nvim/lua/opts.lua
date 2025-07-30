-- 零 created: 2025-05-29

-- ported from vim configuration, only set when different from NeoVim defaul
vim.opt.smartindent = true
vim.opt.autowrite = true
vim.opt.number = true
vim.opt.undofile = true
vim.opt.termguicolors = true

--Set completeopt to have a better completion experience
-- :help completeopt
-- menuone: popup even when there's only one match
-- noinsert: Do not insert text until a selection is made
-- noselect: Do not select, force to select one from the menu
-- shortness: avoid showing extra messages when using completion
-- updatetime: set updatetime for CursorHold
vim.opt.completeopt = { "menuone", "noselect", "noinsert" }
vim.opt.shortmess = vim.opt.shortmess + { c = true }

-- Fixed column for diagnostics to appear
-- Show autodiagnostic popup on cursor hover_range
-- Goto previous / next diagnostic warning / error
-- Show inlay_hints more frequently
vim.cmd([[
set signcolumn=yes
autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focusable = false})
]])

vim.opt.switchbuf = { "usetab" }

-- search tweaks
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- case sensitive if you include upper case
vim.opt.infercase = true -- fix completion to work the same as search + smartcase

-- UI tweaks
vim.opt.wildmode = "full" -- explicitly set wildmode
vim.opt.wildmenu = true -- use enhanced command completion

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])
