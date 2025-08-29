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
vim.api.nvim_create_user_command("Vb", "execute \"normal! \\<C-v>\"", {});
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

-- make and check output
local function asyncrun_make()
    -- start make job
    local job_id = vim.fn.jobstart('make', {
        on_stdout = function(_, data)
            --       vim.fn.caddexpr(data)
        end,
        on_stderr = function(_, data)
            --      vim.fn.caddexpr(data)
        end,
        on_exit = function(_, exit_code, _, _)
            if exit_code == 0 then
                vim.cmd('echom "Build finished successfully!"')
            else
                vim.cmd('echom "Build FAILED!"')
            end


            -- find quickfix window
            local qf_win = vim.fn.bufwinnr('^quickfix$')

            -- check for quickfix window
            for _, win in ipairs(vim.fn.getwininfo()) do
                if win.quickfix == 1 then
                    is_open = true
                    break
                end
            end

            -- fill quickfix buffer
            local buf = vim.fn.bufnr()
            local qf_list = vim.fn.getbufline(buf, 1, '$')
            vim.fn.setqflist({}, 'r', { lines = qf_list })
        end,

        -- run in terminal
        pty = true,
    })
end


local mymodule = require('modules');

-- async run make
--vim.keymap.set("n", "<leader>asm", '<cmd>AsyncRun make<CR><cmd>echom "asyncrun make started"<CR>')
vim.keymap.set("n", "<leader>asm", function()
    vim.notify("🚀 asyncrun make started")
    vim.cmd("AsyncRun make")
end)


-- quickfix toggle
function QF_toggle()
    -- Check if the quickfix window exists and is a valid window
    local is_open = false
    local qf_win = vim.fn.bufwinnr('^quickfix$')

    -- check for quickfix window
    for _, win in ipairs(vim.fn.getwininfo()) do
        if win.quickfix == 1 then
            is_open = true
            break
        end
    end

    -- if open or not
    if is_open then
        vim.cmd('cclose')
    else
        vim.cmd('copen')
        vim.cmd('normal! G')
    end
end

vim.keymap.set("n", "<leader>qf", QF_toggle, { desc = "toggle quickfix" })
-- remap to search/replace with quickfix?

-- separate quickfix to argdo
--command! -nargs=0 -bar Qargs execute 'args' QuickfixFilenames()
----[[
--function! QuickfixFilenames()
--  let buffer_numbers = {}
--  for quickfix_item in getqflist()
--    let buffer_numbers[quickfix_item['bufnr']] = bufname(quickfix_item['bufnr'])
--  endfor
--  return join(map(values(buffer_numbers), 'fnameescape(v:val)'))
--endfunction- do a ripgrep <leader>ps then <C-q> to put in quickfix then :cdo s/foo/bar
----]]
