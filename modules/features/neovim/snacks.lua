require("snacks").setup({
	explorer = { enabled = true },
	gitbrowse = { enabled = true },
	lazygit = { enabled = true },
	picker = {
		enabled = true,
		ui_select = true,
	},
})

local map = vim.keymap.set
map("n", "<leader><leader>", function()
	Snacks.picker.explorer()
end, { desc = "Find files" })
map("n", "<leader>f:", function()
	Snacks.picker.command_history()
end, { desc = "Command history" })
map("n", "<leader>fr", function()
	Snacks.picker.grep()
end, { desc = "Grep" })
map("n", "<leader>fd", function()
	Snacks.picker.diagnostics()
end, { desc = "Workspace diagnostics" })
map({ "n", "x" }, "<leader>gB", function()
	Snacks.gitbrowse()
end, { desc = "Git browse" })
map("n", "<leader>gg", function()
	Snacks.lazygit()
end, { desc = "LazyGit" })
