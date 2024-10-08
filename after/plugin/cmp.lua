local cmp = require("cmp");

-- `:` cmdline setup.
cmp.setup.cmdline(':', {
	-- C-n/C-p cycle through completions if a character has been typed and through
	-- command history if not (from https://www.reddit.com/r/neovim/comments/v5pfmy/comment/ibb61w3/)
	mapping = cmp.mapping.preset.cmdline({
		["<C-n>"] = { c = cmp.mapping.select_next_item() },
		["<C-p>"] = { c = cmp.mapping.select_prev_item() },
	}),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        {
            name = 'cmdline',
            option = {
                ignore_cmds = { 'Man', '!' }
            }
        }
    })
})
