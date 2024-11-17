return {
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    config = function()
      local onedark = require("onedark")
      onedark.setup({
        style = "darker",
      })
    end,
  },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "onedark",
    },
  },
}
