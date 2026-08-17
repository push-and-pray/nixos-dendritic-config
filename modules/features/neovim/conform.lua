require("lz.n").load({
	"conform.nvim",
	event = { "BufReadPre", "BufNewFile" },
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>cf",
			mode = { "n", "x" },
			function()
				require("conform").format({ async = true })
			end,
			desc = "Format buffer",
		},
		{ "<leader>ct", "<cmd>FormatToggle!<cr>", desc = "Toggle format on save" },
	},
	after = function()
		require("conform").setup({
			default_format_opts = { lsp_format = "fallback" },
			formatters_by_ft = {
				bash = { "shfmt" },
				c = { "clang_format" },
				cpp = { "clang_format" },
				go = { "goimports", "gofumpt" },
				java = { "google-java-format" },
				json = { "prettierd", "prettier", stop_after_first = true },
				lua = { "stylua" },
				markdown = { "prettierd", "prettier", stop_after_first = true },
				nix = { "nixfmt" },
				python = { "ruff_organize_imports", "ruff_format" },
				rust = { "rustfmt" },
				sbt = { "scalafmt" },
				scala = { "scalafmt" },
				sh = { "shfmt" },
				yaml = { "prettierd", "prettier", stop_after_first = true },
				zig = { "zigfmt" },
			},
			format_on_save = function(bufnr)
				if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
					return
				end
				return { timeout_ms = 3000, lsp_format = "fallback" }
			end,
		})

		vim.api.nvim_create_user_command("FormatToggle", function(args)
			if args.bang then
				vim.g.disable_autoformat = not vim.g.disable_autoformat
				vim.notify("Format on save " .. (vim.g.disable_autoformat and "disabled" or "enabled"))
			else
				vim.b.disable_autoformat = not vim.b.disable_autoformat
				vim.notify(
					"Format on save " .. (vim.b.disable_autoformat and "disabled" or "enabled") .. " for this buffer"
				)
			end
		end, { bang = true, desc = "Toggle format on save (! for global)" })
	end,
})
