-- nvim-treesitter `main` branch: configs.setup{} is gone, parsers install to
-- stdpath('data')/site (already on rtp) and highlighting starts per-buffer.
local ok, ts = pcall(require, 'nvim-treesitter')
if not ok then return end

local ensure = {
    'matlab', 'c', 'cpp', 'lua', 'luadoc', 'vim', 'vimdoc', 'query',
    'python', 'markdown', 'markdown_inline', 'yaml', 'html', 'bash',
    'json', 'toml',
}

-- get_installed() scans the parser dir; memoize and only rescan on a miss so
-- async installs still get picked up
local cache
local function is_installed(lang)
    if cache and cache[lang] then return true end
    cache = {}
    for _, l in ipairs(ts.get_installed('parsers')) do cache[l] = true end
    return cache[lang] == true
end

local missing = vim.tbl_filter(function(lang)
    return not is_installed(lang)
end, ensure)
if #missing > 0 then
    ts.install(missing) -- async; never block startup
end

-- replaces master's highlight.enable; indent stays off (was indent.enable = false)
vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('kolbbond_treesitter', { clear = true }),
    callback = function(args)
        local lang = vim.treesitter.language.get_lang(args.match)
        if lang and is_installed(lang) then
            pcall(vim.treesitter.start, args.buf, lang)
        end
    end,
})

-- matlab %% section headers
vim.api.nvim_set_hl(0, "@section.matlab", { link = "Identifier" })
