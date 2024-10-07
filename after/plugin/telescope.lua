require("telescope").setup({
    defaults = {
        mappings = {
            i = {
            }
        },
        -- @hey, this ignore is set because
        -- we were searching through giant jsons???
        file_ignore_patterns = {
            "*.json",
        },
    }
});

local builtin = require('telescope.builtin')

-- remaps
-- search for file in project
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})

-- search through git files
vim.keymap.set('n', '<leader>pg', builtin.git_files, {})

-- rip grep  through files
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)
