-- remaps

-- make space the "<leader>" key
vim.g.mapleader = " "

-- project viewer (telescope)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- move highlights around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv");
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv");

-- keep cursor in place
vim.keymap.set("n", "J", "mzJ'z");
vim.keymap.set("n", "J", "mzJ'z");

-- reset screen to center
-- while paging up/down
vim.keymap.set("n", "<C-d>", "<C-d>zz");
vim.keymap.set("n", "<C-u>", "<C-u>zz");
vim.keymap.set("n", "n", "nzzzv");
vim.keymap.set("n", "N", "Nzzzv");

-- greatest remap ever - primeagen
-- deletes to void register, preserves paste
vim.keymap.set("x", "<leader>p", "\"_dP");

-- 2nd greatest - primeagen - asbjornHaland
-- yanks to system clipboard "+ register"
vim.keymap.set("n", "<leader>y", "\"+y");
vim.keymap.set("v", "<leader>y", "\"+y");
vim.keymap.set("n", "<leader>Y", "\"+Y");

-- deletes to void register (preserve paste)
vim.keymap.set("n", "<leader>d", "\"_d");
vim.keymap.set("v", "<leader>d", "\"_d");

-- single character delete to void register 
vim.keymap.set("n", "<leader>x", "\"_x");

-- don't hit capital Q?
vim.keymap.set("n", "Q", "<nop>");

-- visual block override (as <C-v> is usually paste)
-- :command! Vb :execute "normal! \<C-v>"
vim.api.nvim_create_user_command("Vb","execute \"normal! \\<C-v>\"",{});
vim.keymap.set("n", "<leader>vb", ":Vb<CR>");

-- tmux sessions
--vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>");

-- quick movements
--vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz");
--vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz");
--vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz");
--vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz");

-- crazy regex
--vim.keymap.set("n", "<leader>s", [[:%s/\\<<C-r><C-w>\\>\<C-r><C-w>/gI<Left><Left><Left>]]);

-- add chmod
--vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>",
 --   { silent = true });

-- shoutout through leaderleader
-- reloads file in neovim
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end);

-- reload the current file (helps when using multiple editors for one file)
vim.keymap.set("n", "<leader>lf", function()
    vim.cmd("e!")
end);

-- copy file paths/directories to clipboard
vim.keymap.set("n", "<leader>cfp", "<cmd>let @+=expand(\"%:p\")<CR>")
vim.keymap.set("n", "<leader>crp", "<cmd>let @+=expand(\"%\")<CR>")
vim.keymap.set("n", "<leader>cfd", "<cmd>let @+=expand(\"%:p:h\")<CR>")
vim.keymap.set("n", "<leader>crd", "<cmd>let @+=expand(\"%:h\")<CR>")
vim.keymap.set("n", "<leader>cfn", "<cmd>let @+=expand(\"%:t\")<CR>")

-- remap to search/replace with quickfix?
-- do a ripgrep <leader>ps then <C-q> to put in quickfix then :cdo s/foo/bar
