vim.g.autoformat = true

-- Disable autoformat for Karabiner config
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = "*/karabiner/karabiner.json",
	callback = function()
		vim.b.autoformat = false
	end,
})

return {
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				json = { "prettierd" },
			},
		},
	},
}
