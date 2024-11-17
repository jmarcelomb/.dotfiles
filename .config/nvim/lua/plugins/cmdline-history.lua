return {
  "dmitmel/cmp-cmdline-history",
  event = "InsertEnter",
  config = function()
    local cmp = require("cmp")
    local config = cmp.get_config()
    table.insert(config.sources, {
      name = "cmdline_history",
    })
    config.mapping = cmp.mapping.preset.cmdline()
    cmp.setup.cmdline(":", config)
    cmp.setup(config)
  end,
}
