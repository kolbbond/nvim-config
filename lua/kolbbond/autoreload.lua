-- Reload buffers when their file changes on disk out-of-band.
--
-- Claude's Edit tool routes through claudecode.nvim diffs (no disk write until
-- you accept), but Claude's Bash tool (formatters, `sed -i`, `git checkout`)
-- writes directly. This makes nvim notice and reload, and warns loudly when it
-- can't (a dirty buffer whose file also changed underneath -- nvim refuses to
-- clobber your unsaved edits, which is correct).

vim.opt.autoread = true

local group = vim.api.nvim_create_augroup("kolbbond_autoreload", { clear = true })

-- Poll for external changes at natural pause points.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave" }, {
  group = group,
  callback = function()
    -- Skip special buffers (terminals, prompts) where checktime is meaningless.
    if vim.bo.buftype == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Announce when a reload actually happened, so an edit appearing under you is
-- never silent.
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function()
    vim.notify("File changed on disk -- buffer reloaded", vim.log.levels.INFO)
  end,
})
