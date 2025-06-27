return {
    "dense-analysis/ale",
    "kana/vim-smartinput",

    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    "neovim/nvim-lspconfig",
    "simrat39/rust-tools.nvim",

    -- Completion framework:
    "hrsh7th/nvim-cmp",

    -- LSP completion source:
    "hrsh7th/cmp-nvim-lsp",

    -- Useful completion sources:
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",

    {
        "wincent/command-t",
        build = "cd lua/wincent/commandt/lib && make",
        setup = function ()
            vim.g.CommandTPreferredImplementation = "lua"
        end,
        config = function()
            require("wincent.commandt").setup({
                -- Customizations go here.
            })
        end,
    },
}
