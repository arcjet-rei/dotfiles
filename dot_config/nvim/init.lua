-- 零の「init.lua」 created fresh for Arcjet

-- ack.vim: set this so that ack doesn't need to be installed
vim.g.ackprg = "rg --vimgrep"

-- lazy must load first
require('config.lazy')

require('opts')
require('config.completion')
require('config.lualine')
require('config.nerdtree')

-- window shortcuts
vim.keymap.set("", "<C-k>", "<C-w>k")
vim.keymap.set("", "<C-j>", "<C-w>j")
vim.keymap.set("", "<C-l>", "<C-w>l")
vim.keymap.set("", "<C-h>", "<C-w>h")

-- CommandT bindings
vim.keymap.set('n', '<Leader>b', '<Plug>(CommandTBuffer)')
vim.keymap.set('n', '<Leader>j', '<Plug>(CommandTGit)')
vim.keymap.set('n', '<Leader>t', '<Plug>(CommandT)')

-- search shortcuts
-- (for some reason these have to go after Ack configuration)
--
-- from Practical Vim: make <Leader>h do a souped-up screen refresh.
-- Don't replace ctrl-l, because I'm using that for window navigation.
vim.keymap.set("n", "<Leader>h", "<Cmd>nohlsearch<CR><C-L>", { silent = true })

-- also from Practical Vim: & will repeat the previous search with the same
-- options, and will also work in visual mode
vim.keymap.set("n", "&", ":%&&<CR>", { silent = false })
vim.keymap.set("x", "&", ":&&<CR>", { silent = false })

-- Tabularize (godlygeek/tabular)
vim.keymap.set('', '<Leader>=', ':Tabularize /=<CR>', { noremap = true })
vim.keymap.set('', '<Leader>>', ':Tabularize /=><CR>', { noremap = true })
vim.keymap.set('', '<Leader>,', ':Tabularize /,\\zs<CR>', { noremap = true })

vim.cmd.colorscheme "fairyfloss"
