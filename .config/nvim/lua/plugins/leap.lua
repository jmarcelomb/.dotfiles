return {
  {
    "ggandor/leap.nvim",
    config = function()
      local leap = require "leap"

      -- Basic setup
      leap.add_default_mappings()

      -- Enable Leap for operator-pending mode (optional)
      leap.opts.safe_labels = {}
    end,
  },
}
