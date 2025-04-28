-- ignore file
if true then return {} end

return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "v",
        node_incremental = "v",
        node_decremental = "V",
      },
    },
  },
}