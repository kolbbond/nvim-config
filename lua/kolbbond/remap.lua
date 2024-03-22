-- remaps

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- move highlights around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv");
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv");

-- keep cursor in place
vim.keymap.set("n", "J", "mzJ'z");
vim.keymap.set("n", "J", "mzJ'z");

-- reset screen to center
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

-- don't hit capital Q?
vim.keymap.set("n", "Q", "<nop>");

-- tmux sessions
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>");

-- format
vim.keymap.set("n", "<leader>f", function()
	vim.lsp.buf.format()
end);


-- quick movements
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz");
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz");
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz");
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz");

-- crazy regex
vim.keymap.set("n", "<leader>s", [[:%s/\\<<C-r><C-w>\\>\<C-r><C-w>/gI<Left><Left><Left>]]);

-- add chmod
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>",
		{ silent = true} );

-- shoutout through leaderleader
vim.keymap.set("n", "<leader><leader>", function()
	vim.cmd("so")
end);












