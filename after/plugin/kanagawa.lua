-- setup kanagawa to turn off the damn italics
require("kanagawa").setup({
  commentStyle = { italic = false },
  keywordStyle = { italic = false },
  overrides = function()
    return {
      ["@variable.builtin"] = { italic = false },
    }
  end
})
