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

-- single character delete to void register 
vim.keymap.set("n", "<leader>x", "\"_x");

-- don't hit capital Q?
vim.keymap.set("n", "Q", "<nop>");

-- tmux sessions
--vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>");

-- format
--[[
vim.keymap.set("n", "<leader>af", function()
    vim.lsp.buf.format()
end);
--]]

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
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end);

-- reload the current file (helps when using multiple editors for one file)
vim.keymap.set("n", "<leader>lf", function()
    vim.cmd("e!")
end);

--vim.keymap.set("n", "<leader>cfp", vim.cmd(':let @+=expand("%:p")<CR>'))
vim.keymap.set("n", "<leader>cfp", "<cmd>let @+=expand(\"%:p\")<CR>")
vim.keymap.set("n", "<leader>crp", "<cmd>let @+=expand(\"%\")<CR>")
vim.keymap.set("n", "<leader>cfd", "<cmd>let @+=expand(\"%:p:h\")<CR>")
vim.keymap.set("n", "<leader>crd", "<cmd>let @+=expand(\"%:h\")<CR>")
vim.keymap.set("n", "<leader>cfn", "<cmd>let @+=expand(\"%:t\")<CR>")

--[[
" relative path
:let @+ = expand("%")

" full path
:let @+ = expand("%:p")

" just filename
:let @+ = expand("%:t")

--]]

-- matlab connectivity
-- we can manual type this
--vim.keymap.set("n", "<leader>mls", function()
    --vim.cmd(":MatlabLaunchServer")
--end);



-- use j&k to navigate menus 
--[[
vim.api.nvim_set_keymap('i', '<C-j>', 'pumvisible() ? "\\<c-n>" : "\\<c-j>"' ,
{ noremap = true, expr=true })
vim.api.nvim_set_keymap('n', '<C-j>', 'pumvisible() ? "\\<c-n>" : "\\<c-j>"' ,
{ noremap = true, expr=true })
vim.api.nvim_set_keymap('i', '<C-k>', 'pumvisible() ? "\\<c-p>" : "\\<c-j>"' , 
{ noremap = true, expr=true })
vim.api.nvim_set_keymap('n', '<C-k>', 'pumvisible() ? "\\<c-p>" : "\\<c-j>"' , 
{ noremap = true, expr=true })
--]]
