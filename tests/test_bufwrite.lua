-- example taken from TJ. DeVries on creating autocmds to run on save

-- buffer to write to
local bufnr = 347;

str_file = "tests/test_octave.m"

-- auto write command test example
vim.api.nvim_create_autocmd("BufWritePost", {
    group = vim.api.nvim_create_augroup("printonsave", {clear = true}),
    pattern = str_file,
    callback = function()
        vim.api.nvim_buf_set_lines(bufnr,-1,-1,false,{"output of: "..str_file})
        vim.fn.jobstart({"octave", str_file}, {
            stdout_buffered = true,
            on_stdout = function(_,data)
                if data then
                    vim.api.nvim_buf_set_lines(bufnr,-1,-1,false,data)
                end
            end,
            on_stderr = function(_,data)
                if data then
                    vim.api.nvim_buf_set_lines(bufnr,-1,-1,false,data)
                end
            end,
            })
    end,
})

