-- clang-format integration for c/cpp.
--
-- Resolves the binary at first use instead of hardcoding a version, so this
-- works both here (system clang-format) and on a machine that really does pin
-- an older release. Search order:
--   1. vim.g.clang_format_bin, if set (explicit override)
--   2. clang-format-15  (some projects pin this)
--   3. highest-numbered clang-format-<N> on PATH
--   4. plain clang-format
--
-- Overrides <leader>af for these filetypes; other filetypes keep LSP format.

local PINNED = "clang-format-15"
local resolved -- cached after the first successful lookup

-- Every clang-format-<N> on PATH, highest version first.
local function versioned_on_path()
    local by_version = {}
    for dir in vim.gsplit(vim.env.PATH or "", ":", { trimempty = true }) do
        local ok, iter = pcall(vim.fs.dir, dir)
        if ok then
            for name in iter do
                local v = name:match("^clang%-format%-(%d+)$")
                if v then by_version[tonumber(v)] = name end
            end
        end
    end

    local versions = vim.tbl_keys(by_version)
    table.sort(versions, function(a, b) return a > b end)
    return vim.tbl_map(function(v) return by_version[v] end, versions)
end

local function candidates()
    local list = {}
    if vim.g.clang_format_bin and vim.g.clang_format_bin ~= "" then
        table.insert(list, vim.g.clang_format_bin)
    end
    table.insert(list, PINNED)
    vim.list_extend(list, versioned_on_path())
    table.insert(list, "clang-format")
    return list
end

local function resolve()
    if resolved then return resolved end
    local tried = candidates()
    for _, bin in ipairs(tried) do
        if vim.fn.executable(bin) == 1 then
            resolved = bin
            return bin
        end
    end
    return nil, tried
end

local function clang_format_buffer()
    local bin, tried = resolve()
    if not bin then
        vim.notify(
            "no clang-format binary found on PATH (tried: "
                .. table.concat(tried, ", ")
                .. ")\nInstall clang, or set vim.g.clang_format_bin to a full path.",
            vim.log.levels.ERROR
        )
        return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local view = vim.fn.winsaveview()
    local fname = vim.api.nvim_buf_get_name(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local input = table.concat(lines, "\n")

    -- --assume-filename lets clang-format locate the right .clang-format
    -- when reading from stdin.
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
            { buffer = args.buf, desc = "clang-format buffer" })
    end,
})

vim.api.nvim_create_user_command("ClangFormat", clang_format_buffer, {})
-- kept so existing muscle memory / scripts still work
vim.api.nvim_create_user_command("ClangFormat15", clang_format_buffer, {})

vim.api.nvim_create_user_command("ClangFormatInfo", function()
    local bin, tried = resolve()
    if not bin then
        vim.notify("no clang-format found (tried: " .. table.concat(tried, ", ") .. ")",
            vim.log.levels.WARN)
        return
    end
    local version = vim.fn.systemlist({ bin, "--version" })[1] or "?"
    vim.notify("clang-format: " .. bin .. "\n" .. version, vim.log.levels.INFO)
end, {})
