local toggle_breakpoint_str = "<leader>b"
local conditional_breakpoint_str = "<leader>B"
local clear_breakpoint_str = "<leader>cb"

vim.keymap.set("n", "<F5>", ":lua require'dap'.continue()<CR>", { silent = true })
vim.keymap.set("n", "<F9>", ":lua require'dap'.step_over()<CR>", { silent = true })
vim.keymap.set("n", "<F10>", ":lua require'dap'.step_into()<CR>", { silent = true })
vim.keymap.set("n", "<F22>", ":lua require'dap'.step_out()<CR>", { silent = true })
vim.keymap.set("n", "S-<F10>", ":lua require'dap'.step_out()<CR>", { silent = true })
vim.keymap.set("n", toggle_breakpoint_str, ":lua require'dap'.toggle_breakpoint()<CR>", { silent = true })
vim.keymap.set("n", conditional_breakpoint_str, ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>", { silent = true })
vim.keymap.set("n", "<leader>lm", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log message: '))<CR>", { silent = true })
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open()<CR>", { silent = true })


local opts = { noremap = true, silent = true }
local keymap = vim.api.nvim_set_keymap
-- Save breakpoints to file automatically.
keymap("n", toggle_breakpoint_str, "<cmd>lua require('persistent-breakpoints.api').toggle_breakpoint()<cr>", opts)
keymap("n", conditional_breakpoint_str, "<cmd>lua require('persistent-breakpoints.api').set_conditional_breakpoint()<cr>", opts)
keymap("n", clear_breakpoint_str, "<cmd>lua require('persistent-breakpoints.api').clear_all_breakpoints()<cr>", opts)
