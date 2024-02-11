require("marcelo.remap")

require("marcelo.debug_map")

local python_packages = {'black', 'ruff', 'mypy', 'pylint', 'debugpy'}

local registry = require("mason-registry")
local mason = require("mason").setup()

local packages = python_packages
for i=1, #packages do
  local installed = registry.is_installed(packages[i]);
  if installed == false then
    registry.get_package(packages[i]):install()
  -- else
  --   print(string.format("%s is already installed!", packages[i]))
  end
end


-- Debug
--require("dap").setup()
require("nvim-dap-virtual-text").setup()
--require("dap-python").setup()
require("dapui").setup()
require('persistent-breakpoints').setup{
	load_breakpoints_event = { "BufReadPost" }
}
require('Comment').setup()


local rt = require("rust-tools")
rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      -- vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      vim.keymap.set("n", "<Leader>h", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})
-- Set inlay hints for the current buffer
require('rust-tools').inlay_hints.set()
-- Enable inlay hints auto update and set them for all the buffers
require('rust-tools').inlay_hints.enable()
require('rust-tools').hover_actions.hover_actions()
