require("lz.n").load({
	"nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	after = function()
		local lint = require("lint")

		-- only linters the language server does not already cover
		lint.linters_by_ft = {
			bash = { "shellcheck" },
			go = { "golangcilint" },
			nix = { "statix", "deadnix" },
			python = { "ruff" },
			sh = { "shellcheck" },
			zig = { "zlint" },
		}

		-- linter name -> binary, where they differ
		local cmds = { golangcilint = "golangci-lint" }

		vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
			group = vim.api.nvim_create_augroup("julius-lint", { clear = true }),
			callback = function()
				local names = lint.linters_by_ft[vim.bo.filetype] or {}
				local runnable = vim.tbl_filter(function(name)
					return vim.fn.executable(cmds[name] or name) == 1
				end, names)
				if #runnable > 0 then
					lint.try_lint(runnable)
				end
			end,
		})
	end,
})
