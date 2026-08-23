require("lz.n").load({
	"overseer.nvim",
	cmd = { "OverseerRun", "OverseerToggle", "OverseerQuickAction" },
	keys = {
		{
			"<leader>rr",
			function()
				require("overseer").run_task()
			end,
			desc = "Run task",
		},
		{
			"<leader>ro",
			function()
				require("overseer").toggle()
			end,
			desc = "Toggle task panel",
		},
		{
			"<leader>rl",
			function()
				local overseer = require("overseer")
				local task = overseer.list_tasks()[1]
				if task then
					overseer.run_action(task, "restart")
				else
					vim.notify("No previous overseer task", vim.log.levels.WARN)
				end
			end,
			desc = "Restart last task",
		},
	},
	after = function()
		require("overseer").setup({})
	end,
})
