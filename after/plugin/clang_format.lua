-- Force clang-format-15 for c/cpp (project pins that version)
-- Overrides <leader>af for these filetypes; other filetypes keep LSP format.

local bin = "clang-format-15"

local function clang_format_buffer()
    if vim.fn.executable(bin) == 0 then
        vim.notify(bin .. " not found on PATH", vim.log.levels.ERROR)
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local view = vim.fn.winsaveview()
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(lines, "\n")

    local cmd = { bin, "--assume-filename=" .. (fname ~= "" and fname or "a.cpp") }
    local out = vim.fn.systemlist(cmd, input)

    if vim.v.shell_error ~= 0 then
        vim.notify(bin .. " failed: " .. table.concat(out, "\n"), vim.log.levels.ERROR)
        return
    end

    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, out)
    vim.fn.winrestview(view)
end

vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "h", "hpp", "objc", "objcpp" },
    callback = function(args)
        vim.keymap.set("n", "<leader>af", clang_format_buffer,
            { buffer = args.buf, desc = "clang-format-15 buffer" })
    end,
})

vim.api.nvim_create_user_command("ClangFormat15", clang_format_buffer, {})
