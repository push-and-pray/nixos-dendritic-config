vim.g.mapleader = " "
vim.g.maplocalleader = " "

local opt = vim.opt
opt.backup = false
opt.breakindent = true
opt.cmdheight = 0
opt.completeopt = { "menuone", "noselect", "noinsert" }
opt.cursorline = true
opt.expandtab = true
opt.ignorecase = true
opt.number = true
opt.relativenumber = true
opt.scrolloff = 8
opt.shiftwidth = 2
opt.showmode = false
opt.showtabline = 0
opt.smartcase = true
opt.smartindent = true
opt.softtabstop = 2
opt.splitbelow = true
opt.splitright = true
opt.swapfile = false
opt.tabstop = 2
opt.termguicolors = true
opt.undofile = true
opt.wrap = false

require("vim._core.ui2").enable({})
