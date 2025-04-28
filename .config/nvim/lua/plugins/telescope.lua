return {
  "nvim-telescope/telescope.nvim",
  keys = {
    { "<C-p>", function() LazyVim.pick("find_files", {  })() end, desc = "Find Files" },
     {
      "<C-F>",
      function()
        LazyVim.pick("live_grep", {})()
      end,
      desc = "Live Grep (Literal)",
    },
  },
  opts = {
    pickers = {
      live_grep = {
        fixed_strings = true,
        case_mode = "smart_case",
      },
    },
  },
}