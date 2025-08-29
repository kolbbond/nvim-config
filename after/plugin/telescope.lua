require("telescope").setup({
    defaults = {
        prompt_prefix = ' !  ',
        entry_prefix = '  ',
        selection_caret = '-> ',
        multi_icon = ' │ ',
        winblend = 0,
        borderchars = { '*', '│', '─', '|', '┌', '┐', '┘', '└' },
        mappings = {
            i = {
            }
        },
        -- @hey, this ignore is set because
        -- we were searching through giant jsons???
        file_ignore_patterns = {
            "*.json","*.xml","*.vtk",
        },
        color_devicons = true,
        devicons = require("nvim-web-devicons"),
    }
});

local builtin = require('telescope.builtin')

-- remaps
-- search for file in project
vim.keymap.set('n', '<leader>pf', builtin.find_files, {})

-- test additional search with hidden files
vim.keymap.set('n', '<leader>ff',
    "<cmd>lua require'telescope.builtin'.find_files({ find_command = {'rg', '--files', '--hidden', '-g', '!.git' }})<cr>",
    {})
-- search through git files
vim.keymap.set('n', '<leader>pg', builtin.git_files, {})

-- rip grep  through files
vim.keymap.set('n', '<leader>ps', function()
    builtin.grep_string({ search = vim.fn.input("Grep > ") });
end)

-- extensions
-- require('telescope').load_extension('tmuxinator')
