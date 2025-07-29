return {
    "mfussenegger/nvim-dap",
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
        },
    },
}
