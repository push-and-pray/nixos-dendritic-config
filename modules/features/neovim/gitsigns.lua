require("lz.n").load({
	"gitsigns.nvim",
	event = { "BufReadPre", "BufNewFile" },
	after = function()
		require("gitsigns").setup({ current_line_blame = true })
	end,
})
