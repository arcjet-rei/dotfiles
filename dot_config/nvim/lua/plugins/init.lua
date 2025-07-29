return {
    "dense-analysis/ale",
    "kana/vim-smartinput",

    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    {
        "zapling/mason-lock.nvim",
        init = function()
            require("mason-lock").setup({
                lockfile_path = vim.fn.stdpath("config") .. "/mason-lock.json", -- (default)
            })
        end,
    },

    "neovim/nvim-lspconfig",
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                css = { "prettierd", "prettier" },
                html = { "prettierd", "prettier" },
                javascript = { "prettierd", "prettier" },
                javascriptreact = { "prettierd", "prettier" },
                json = { "prettierd", "prettier" },
                lua = { "stylua" },
                markdown = { "prettierd", "prettier" },
                rust = { "rustfmt" },
                typescript = { "prettierd", "prettier" },
                typescriptreact = { "prettierd", "prettier" },
            },
        },
    },

    {
        "mrcjkb/rustaceanvim",
        version = "^6", -- Recommended
        lazy = false, -- This plugin is already lazy
    },
    -- set up NeoVim config editing
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {},
    },
    -- Completion framework:
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            opts.sources = opts.sources or {}
            table.insert(opts.sources, {
                name = "lazydev",
                group_index = 0, -- set group index to 0 to skip loading LuaLS completions
            })
        end,
    },
    -- Optional blink completion source for require statements and module annotations
    {
        "saghen/blink.cmp",
        dependencies = { "rafamadriz/friendly-snippets" },
        build = "rustup run nightly cargo build --release",
        opts = {
            sources = {
                -- add lazydev to your completion providers
                default = { "lazydev", "lsp", "path", "snippets", "buffer" },
                providers = {
                    lazydev = {
                        name = "LazyDev",
                        module = "lazydev.integrations.blink",
                        -- make lazydev completions top priority (see `:h blink.cmp`)
                        score_offset = 100,
                    },
                },
            },
        },
    },

    -- LSP completion source:
    "hrsh7th/cmp-nvim-lsp",

    -- Useful completion sources:
    "hrsh7th/cmp-nvim-lua",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-vsnip",
    "hrsh7th/vim-vsnip",

    -- live Markdown previwe
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
}
