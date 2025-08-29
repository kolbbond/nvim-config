-- modules
local M = {}
M.notify_build_status = function()
    -- Check the status set by asyncrun.vim
    local status = vim.g.asyncrun_status
    local msg = ""
    local level = vim.log.levels.INFO

    vim.notify("🚧 Build process completed", vim.log.levels.INFO, { title = "Build Status", timeout = 3000 })
    vim.notify("🚧 Build process completed", vim.log.levels.INFO, { title = "Build Status", timeout = 3000 })
    vim.api.nvim_echo({ { "status: " .. status } }, false, {})

    if status == 'success' then
        msg = "✅ ✅ Build ✅ ✅ finished ✅ ✅ successfully! ✅ ✅"
        level = vim.log.levels.INFO
    elseif status == 'failure' then
        msg = "❌ Build failed. See quickfix for details."
        level = vim.log.levels.ERROR
    else
        msg = "Job completed with an unknown status."
        level = vim.log.levels.WARN
    end

    -- show in command line
    vim.api.nvim_echo({ { msg } }, false, {})
    vim.schedule(function()
        vim.api.nvim_echo({ { msg } }, false, {})
    end)

    -- show as popup
    vim.notify(msg, level, { title = "Build Status", timeout = 5000 })
end
return M
