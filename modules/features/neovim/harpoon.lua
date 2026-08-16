require("lz.n").load({
	"harpoon2",
	keys = {
		{
			"<leader>a",
			function()
				require("harpoon"):list():add()
			end,
			desc = "Harpoon add file",
		},
		{
			"<C-e>",
			function()
				local harpoon = require("harpoon")
				harpoon.ui:toggle_quick_menu(harpoon:list())
			end,
			desc = "Harpoon menu",
		},
		{
			"<leader>.",
			function()
				require("harpoon"):list():next()
			end,
			desc = "Harpoon next",
		},
		{
			"<leader>,",
			function()
				require("harpoon"):list():prev()
			end,
			desc = "Harpoon previous",
		},
	},
	after = function()
		require("harpoon"):setup()
	end,
})
