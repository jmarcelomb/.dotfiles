return {
  "hrsh7th/nvim-cmp",
  opts = function(_, opts)
    local cmp = require("cmp")

    opts.mapping = vim.tbl_deep_extend("force", opts.mapping, {
      ["<CR>"] = cmp.config.disable,
      ["<C-y"] = LazyVim.cmp.confirm({ select = true }),
    })
  end,
}
