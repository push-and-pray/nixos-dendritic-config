local function view_is_open()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.w[win].dapview_win then
			return true
		end
	end
	return false
end

local function show_view(section)
	local view = require("dap-view")
	if not view_is_open() then
		view.open()
	end
	view.jump_to_view(section)
end

require("lz.n").load({
	"nvim-dap",
	keys = {
		{
			"<leader>db",
			function()
				require("dap").toggle_breakpoint()
			end,
			desc = "Toggle breakpoint",
		},
		{
			"<leader>dB",
			function()
				require("dap").set_breakpoint(vim.fn.input({ prompt = "Breakpoint condition: " }))
			end,
			desc = "Conditional breakpoint",
		},
		{
			"<leader>dc",
			function()
				require("dap").continue()
			end,
			desc = "Continue / start",
		},
		{
			"<leader>dC",
			function()
				require("dap").run_to_cursor()
			end,
			desc = "Run to cursor",
		},
		{
			"<leader>di",
			function()
				require("dap").step_into()
			end,
			desc = "Step into",
		},
		{
			"<leader>do",
			function()
				require("dap").step_over()
			end,
			desc = "Step over",
		},
		{
			"<leader>dO",
			function()
				require("dap").step_out()
			end,
			desc = "Step out",
		},
		{
			"<leader>dl",
			function()
				require("dap").run_last()
			end,
			desc = "Run last",
		},
		{
			"<leader>dr",
			function()
				show_view("repl")
			end,
			desc = "Toggle REPL",
		},
		{
			"<leader>dt",
			function()
				require("dap").terminate()
			end,
			desc = "Terminate",
		},
		{
			"<leader>du",
			function()
				require("dap-view").toggle()
			end,
			desc = "Toggle debug UI",
		},
		{
			"<leader>de",
			mode = { "n", "x" },
			function()
				require("dap-view").hover()
			end,
			desc = "Evaluate expression",
		},
		{
			"<leader>dd",
			function()
				show_view("disassembly")
			end,
			desc = "Disassembly",
		},
		{
			"<leader>dw",
			mode = { "n", "x" },
			function()
				require("dap-view").add_expr()
			end,
			desc = "Watch expression",
		},
	},
	after = function()
		vim.cmd.packadd("nvim-dap-view")
		vim.cmd.packadd("nvim-dap-disasm")

		local dap = require("dap")

		require("dap-view").setup({
			auto_toggle = true,
			virtual_text = { enabled = true },
			winbar = {
				sections = {
					"watches",
					"scopes",
					"exceptions",
					"breakpoints",
					"threads",
					"disassembly",
					"repl",
					"console",
				},
				controls = { enabled = true },
			},
		})

		require("dap-disasm").setup({
			dapview = { keymap = "D", label = "Disassembly" },
		})

		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
		vim.fn.sign_define("DapBreakpointRejected", { text = "○", texthl = "DiagnosticHint" })
		vim.fn.sign_define("DapLogPoint", { text = "◆", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticOk", linehl = "Visual" })

		local function program()
			return vim.fn.input({
				prompt = "Executable: ",
				default = vim.fn.getcwd() .. "/build/",
				completion = "file",
			})
		end

		local function args()
			return vim.split(vim.fn.input({ prompt = "Args: " }), " ", { trimempty = true })
		end

		local configurations = {}

		if vim.fn.executable("lldb-dap") == 1 then
			dap.adapters.lldb = {
				type = "executable",
				command = "lldb-dap",
				name = "lldb",
			}
			table.insert(configurations, {
				name = "Launch (lldb)",
				type = "lldb",
				request = "launch",
				program = program,
				args = args,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
			})
		end

		if vim.fn.executable("gdb") == 1 then
			dap.adapters.gdb = {
				type = "executable",
				command = "gdb",
				args = { "--interpreter=dap", "--eval-command", "set print pretty on" },
			}
			table.insert(configurations, {
				name = "Launch (gdb)",
				type = "gdb",
				request = "launch",
				program = program,
				args = args,
				cwd = "${workspaceFolder}",
				stopAtBeginningOfMainSubprogram = false,
			})
		end

		if #configurations == 0 then
			vim.notify("No debug adapter found (lldb-dap or gdb)", vim.log.levels.WARN)
		end

		dap.configurations.c = configurations
		dap.configurations.cpp = configurations
	end,
})
