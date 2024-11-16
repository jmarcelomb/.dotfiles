return {
	"nvimtools/none-ls.nvim",
	config = function()
		local null_ls = require("null-ls")
		null_ls.setup({
			sources = {
				null_ls.builtins.formatting.stylua,
                null_ls.builtins.completion.spell,

				-- Python
				null_ls.builtins.diagnostics.mypy,
			    null_ls.builtins.diagnostics.pylint,

                -- C
                null_ls.builtins.formatting.clang_format
			},
		})
	end,
}
