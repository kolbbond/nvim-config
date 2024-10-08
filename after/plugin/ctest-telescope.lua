-- Note: if you are using Lazy.nvim, pass these
-- arguments to `opts` instead of manually calling `setup`
require("ctest-telescope").setup({
  dap_config = {
    stopAtEntry = true,
    setupCommands = {
      {
        text = "-enable-pretty-printing",
        description = "Enable pretty printing",
        ignoreFailures = false,
      },
    },
  },
})
vim.keymap.set("n", "<F5>", function()
  local dap = require("dap")
  if dap.session() == nil and (vim.bo.filetype == "cpp" or vim.bo.filetype == "c") then
    -- Only call this on C++ and C files
    require("ctest-telescope").pick_test_and_debug()
  else
    dap.continue()
  end
end, { desc = "Debug: Start/Continue" })
