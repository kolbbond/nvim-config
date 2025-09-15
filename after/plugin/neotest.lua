local gtest_status, gtest_adapter = pcall(require, "neotest-gtest")

local adapters = {}

if gtest_status then
    table.insert(adapters, gtest_adapter.setup({}))
end

require("neotest").setup({
    --adapters = {
    --   require("neotest-gtest").setup({})
    --}
    adapters = adapters
})
