    return {
        "easymotion/vim-easymotion",
        config = function()
            -- Optional: Set up default mappings for EasyMotion
            vim.g.EasyMotion_do_mapping = 0 -- Disable default mappings
            -- Define custom key mappings
            vim.keymap.set("n", "<leader>m2", "<Plug>(easymotion-s2)", { desc = "EasyMotion search 2-char" })
            vim.keymap.set("n", "<leader>mf", "<Plug>(easymotion-j)", { desc = "EasyMotion jump down" })
            vim.keymap.set("n", "<leader>mb", "<Plug>(easymotion-k)", { desc = "EasyMotion jump up" })
        end,
    }
