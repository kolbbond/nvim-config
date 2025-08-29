-- nvim-notify
local mod = require("notify")
mod.setup({
    background_colour = "#000000", -- dark background
    fps = 60,                      -- animation speed
    timeout = 3000,                -- milliseconds to show message
    icons = {
        ERROR = "❌",
        WARN  = "⚠️",
        INFO  = "ℹ️",
        DEBUG = "🐛",
        TRACE = "🔍",
    },
})
