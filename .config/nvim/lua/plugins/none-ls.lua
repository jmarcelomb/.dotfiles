return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
				-- Python
				null_ls.builtins.diagnostics.ruff,
				null_ls.builtins.diagnostics.python,
			},
		})
	end,
}
