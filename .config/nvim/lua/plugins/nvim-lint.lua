return {
  "mfussenegger/nvim-lint",
  opts = {
    -- Event to trigger linters
    events = { "BufWritePost", "BufReadPost", "InsertLeave" },
    linters_by_ft = {
      py = { "ruff", "pylint", "mypy" },
      -- Use the "_" filetype to run linters on filetypes that don't have other linters configured.
      -- ['_'] = { 'fallback linter' },
      ["*"] = { "typos" },
    },
  },
}
