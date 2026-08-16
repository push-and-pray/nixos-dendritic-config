local highlighted = {
	"bash",
	"c",
	"go",
	"java",
	"lua",
	"markdown",
	"nix",
	"python",
	"rust",
	"scala",
	"yaml",
	"zig",
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("julius-treesitter", { clear = true }),
	pattern = highlighted,
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
