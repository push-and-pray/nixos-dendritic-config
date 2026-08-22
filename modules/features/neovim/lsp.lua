require("blink.cmp").setup({
	keymap = {
		preset = "enter",
		["<Tab>"] = { "select_next", "fallback" },
		["<S-Tab>"] = { "select_prev", "accept", "fallback" },
	},
	signature = { enabled = true },
	snippets = { preset = "default" },
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
		providers = {
			buffer = { score_offset = -7 },
		},
	},
})

local capabilities = require("blink.cmp").get_lsp_capabilities()
vim.lsp.config("*", { capabilities = capabilities })

local servers = {
	clangd = { cmd = "clangd" },
	gopls = { cmd = "gopls" },
	jdtls = { cmd = "jdtls" },
	metals = {
		cmd = "metals",
		config = {
			init_options = { statusBarProvider = "off" },
		},
	},
	nixd = { cmd = "nixd" },
	pyright = { cmd = "pyright-langserver" },
	rust_analyzer = {
		cmd = "rust-analyzer",
		config = {
			settings = {
				["rust-analyzer"] = {
					check = { command = "clippy" },
					files = { excludeDirs = { ".direnv" } },
				},
			},
		},
	},
	yamlls = {
		cmd = "yaml-language-server",
		config = {
			settings = {
				yaml = {
					schemas = {
						kubernetes = "*.yaml",
						["https://json.schemastore.org/chart"] = "Chart.{yml,yaml}",
						["https://json.schemastore.org/kustomization"] = "kustomization.{yml,yaml}",
					},
				},
			},
		},
	},
	zls = {
		cmd = "zls",
		config = {
			settings = {
				zls = { enable_build_on_save = true },
			},
		},
	},
}

for name, server in pairs(servers) do
	if vim.fn.executable(server.cmd) == 1 then
		if server.config then
			vim.lsp.config(name, server.config)
		end
		vim.lsp.enable(name)
	end
end

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("julius-lsp", { clear = true }),
	callback = function(args)
		local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
		if client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
		if client:supports_method("textDocument/codeLens") then
			vim.lsp.codelens.enable(true, { bufnr = args.buf })
		end
	end,
})

local map = vim.keymap.set
map("n", "gD", vim.lsp.buf.declaration, { desc = "Go to declaration" })
map("n", "gT", vim.lsp.buf.type_definition, { desc = "Go to type definition" })
map("n", "gws", vim.lsp.buf.workspace_symbol, { desc = "Workspace symbols" })
map("n", "<leader>ee", vim.diagnostic.open_float, { desc = "Show diagnostics" })
map("n", "<leader>e.", function()
	vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "<leader>e,", function()
	vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code action" })
map("n", "<leader>cl", vim.lsp.codelens.run, { desc = "Run code lens" })

require("lz.n").load({
	"fidget.nvim",
	event = "LspAttach",
	after = function()
		require("fidget").setup()
	end,
})
