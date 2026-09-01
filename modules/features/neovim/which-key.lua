require("lz.n").load({
	"which-key.nvim",
	event = "DeferredUIEnter",
	after = function()
		require("which-key").setup({
			spec = {
				{ "<leader>c", group = "code" },
				{ "<leader>d", group = "debug" },
				{ "<leader>e", group = "diagnostics" },
				{ "<leader>f", group = "find" },
				{ "<leader>g", group = "git" },
				{ "<leader>r", group = "run" },
			},
		})
	end,
})
