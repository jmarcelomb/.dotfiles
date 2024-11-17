return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local config = require "nvim-treesitter.configs"
            config.setup {
                auto_install = true,
                highlight = { enable = true },
                indent = { enable = true },
                ensure_installed = {
                    "lua",
                    "c",
                    "python",
                    "rust",
                    "dockerfile",
                    "bash",
                    "markdown",
                    "markdown_inline",
                    "json5",
                    "yaml",
                    "toml",
                    "vim",
                    "regex",
                },
            }
        end,
    },
}
