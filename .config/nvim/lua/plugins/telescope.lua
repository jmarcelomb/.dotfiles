return {
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.5",
        dependencies = {
            "nvim-lua/plenary.nvim",
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

            "nvim-telescope/telescope-smart-history.nvim",
            "nvim-telescope/telescope-ui-select.nvim",
            "kkharji/sqlite.lua",
        },
        config = function()
            local data = assert(vim.fn.stdpath "data") --[[@as string]]
            require("telescope").setup {
                defaults = {
                    file_ignore_patterns = { "dune.lock" },
                    find_command = { "rg", "--files", "--color", "never", "--sortr", "modified" },
                },
                extensions = {
                    wrap_results = true,

                    fzf = {},
                    -- history = {
                    --   path = vim.fs.joinpath(data, "telescope_history.sqlite3"),
                    --   limit = 100,
                    -- },
                    ["ui-select"] = {
                        require("telescope.themes").get_dropdown {},
                    },
                },
            }
            pcall(require("telescope").load_extension, "fzf")
            -- pcall(require("telescope").load_extension, "smart_history")
            pcall(require("telescope").load_extension, "ui-select")

            local builtin = require "telescope.builtin"

            vim.keymap.set("n", "<C-p>", builtin.find_files)
            vim.keymap.set("n", "<space>fd", builtin.find_files)
            vim.keymap.set("n", "<space>of", builtin.oldfiles)
            vim.keymap.set("n", "<space>p", builtin.command_history)
            vim.keymap.set("n", "<space>ft", builtin.git_files)
            -- vim.keymap.set("n", "<space>fh", builtin.help_tags)
            vim.keymap.set("n", "<space>fg", builtin.live_grep)
            vim.keymap.set("n", "<space>fb", builtin.buffers)
            vim.keymap.set("n", "<space>/", builtin.current_buffer_fuzzy_find)

            vim.keymap.set("n", "<space>gw", builtin.grep_string)
            vim.keymap.set("n", "<space>fh", function()
                require("telescope.builtin").find_files { hidden = true, follow = true, path_display = { "smart" } }
            end, { desc = "Find files including hidden ones" })
            vim.keymap.set("n", "<leader>gr", function()
                local register_content = vim.fn.getreg '"'
                require("telescope.builtin").live_grep {
                    default_text = register_content,
                    prompt_title = "Live Grep with Register Content",
                }
            end, { desc = "Live grep with register content" })
        end,
    },
}
