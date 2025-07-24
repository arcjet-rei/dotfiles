-- Create an augroup
local ntgroup = vim.api.nvim_create_augroup("NERDTreeAutocmds", { clear = true })

-- open up a NERDtree at startup if there are no files provided
vim.api.nvim_create_autocmd("VimEnter", {
    group = ntgroup,
    callback = function()
        if vim.fn.argc() == 0 then
            vim.cmd("NERDTree")
        end
    end
})

-- autoquit if NERDtree is the last window open
vim.api.nvim_create_autocmd("BufEnter", {
    group = ntgroup,
    pattern = "*",
    callback = function()
        if vim.fn.winnr("$") == 1 and vim.b.NERDTreeType == "primary" then
            vim.cmd("q")
        end
    end,
})

