return {
  "folke/snacks.nvim",
  opts = {
    notifier = { enabled = true },
    picker = {
      sources = {
        explorer = {
          hidden = true,
          -- exclude = { "node_modules", ".git" },
        },
        files = {
            hidden = true,
            -- exclude = { "node_modules", ".git" },
        },
        grep = {
           hidden = true,
        },
      },
    },
},
}