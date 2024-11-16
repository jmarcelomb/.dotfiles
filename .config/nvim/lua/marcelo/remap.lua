vim.g.mapleader = " "
local function map(mode, lhs, rhs)
  -- vim.keymap.set(mode, lhs, rhs, { silent = true })
  vim.keymap.set(mode, lhs, rhs)
end

map("n", "<leader>pv", vim.cmd.Ex)

map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map("i", "<C-c>", "<Esc>")

map("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
-- map("n", "<leader>x", "<cmd>!chmod +x %<CR>")

map("n", "<leader>f", vim.lsp.buf.format)

-- Repeat last macro
map("", ",", "@@")
