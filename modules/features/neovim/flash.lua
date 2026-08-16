require("lz.n").load({
	"flash.nvim",
	keys = {
		{ "f", mode = { "n", "x", "o" } },
		{ "F", mode = { "n", "x", "o" } },
		{ "t", mode = { "n", "x", "o" } },
		{ "T", mode = { "n", "x", "o" } },

		{
			"<leader>s",
			mode = { "n", "x", "o" },
			function()
				require("flash").jump()
			end,
			desc = "Flash Jump",
		},
		{
			"<leader>S",
			mode = { "n", "x", "o" },
			function()
				require("flash").treesitter()
			end,
			desc = "Flash Treesitter",
		},
		{
			"r",
			mode = "o",
			function()
				require("flash").remote()
			end,
			desc = "Remote Flash",
		},
		{
			"R",
			mode = { "o", "x" },
			function()
				require("flash").treesitter_search()
			end,
			desc = "Treesitter Search",
		},
	},
	after = function()
		require("flash").setup({
			modes = {
				char = { jump_labels = true },
				treesitter_search = { remote_op = { restore = true, motion = true } },
			},
		})
	end,
})
