return {
  {
    "tssm/fairyfloss.vim",
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  -- this is how you tell LazyVim to use a different color scheme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "fairyfloss",
    },
  },
}
