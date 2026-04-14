return {
  {
    "LazyVim/LazyVim",
    init = function()
      local M = {}

      local script_path = "/Users/tobbe/dev/dotfiles/pi-session/pi-session"

      local function shell_error_message(result)
        local stderr = (result.stderr or ""):gsub("%s+$", "")
        local stdout = (result.stdout or ""):gsub("%s+$", "")

        if stderr ~= "" then
          return stderr
        end
        if stdout ~= "" then
          return stdout
        end

        return string.format("unknown error (exit code %s)", tostring(result.code))
      end

      local function get_buffer_path()
        local path = vim.api.nvim_buf_get_name(0)
        if path == "" then
          return nil
        end
        return path
      end

      local function resolve_range(command_opts)
        if command_opts and command_opts.range and command_opts.range > 0 then
          return command_opts.line1, command_opts.line2
        end

        local line = vim.api.nvim_win_get_cursor(0)[1]
        return line, line
      end

      local function git_root_for_file(file_path)
        local file_dir = vim.fn.fnamemodify(file_path, ":h")
        local result = vim.system({ "git", "-C", file_dir, "rev-parse", "--show-toplevel" }, { text = true }):wait()
        if result.code ~= 0 then
          return nil
        end

        local root = (result.stdout or ""):gsub("%s+$", "")
        if root == "" then
          return nil
        end

        return root
      end

      local function relative_to_root(file_path, git_root)
        if not git_root or git_root == "" then
          return vim.fn.fnamemodify(file_path, ":.")
        end

        local prefix = git_root .. "/"
        if file_path:sub(1, #prefix) == prefix then
          return file_path:sub(#prefix + 1)
        end

        return vim.fn.fnamemodify(file_path, ":.")
      end

      local function build_prefill_prompt(file_path, line_start, line_end, git_root)
        local relative_path = relative_to_root(file_path, git_root)
        if line_start == line_end then
          return string.format("%s:L%d\n\n", relative_path, line_start)
        end

        return string.format("%s:L%d-%d\n\n", relative_path, line_start, line_end)
      end

      local function draft_file_path(git_root)
        local key = git_root
        if not key or key == "" then
          key = vim.loop.cwd() or ""
        end

        local hash = vim.fn.sha256(key)
        local dir = vim.fn.stdpath("state") .. "/pi-session-drafts"
        vim.fn.mkdir(dir, "p")

        return dir .. "/" .. hash .. ".txt"
      end

      local function read_draft(git_root)
        local path = draft_file_path(git_root)
        if vim.fn.filereadable(path) ~= 1 then
          return nil
        end

        local lines = vim.fn.readfile(path)
        return table.concat(lines, "\n")
      end

      local function write_draft(git_root, text)
        local path = draft_file_path(git_root)
        local lines = vim.split(text or "", "\n", { plain = true })
        vim.fn.writefile(lines, path)
      end

      local function clear_draft(git_root)
        local path = draft_file_path(git_root)
        if vim.fn.filereadable(path) == 1 then
          vim.fn.delete(path)
        end
      end

      local function open_prompt_box(initial_text, on_submit, on_cancel)
        local width = math.floor(vim.o.columns * 0.7)
        local height = math.max(8, math.floor(vim.o.lines * 0.3))
        local row = math.floor((vim.o.lines - height) / 2 - 1)
        local col = math.floor((vim.o.columns - width) / 2)

        local buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        vim.bo[buf].filetype = "markdown"

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          style = "minimal",
          border = "rounded",
          width = width,
          height = height,
          row = row,
          col = col,
          title = " Pi prompt ",
          title_pos = "center",
        })

        local initial_lines = vim.split(initial_text or "", "\n", { plain = true })
        if #initial_lines == 0 then
          initial_lines = { "" }
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, initial_lines)
        vim.api.nvim_win_set_option(win, "wrap", true)

        local last_line = #initial_lines
        local last_col = #initial_lines[last_line]
        vim.api.nvim_win_set_cursor(win, { last_line, last_col })

        local function close_box()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end

        local function submit()
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local text = table.concat(lines, "\n")
          text = vim.trim(text)
          close_box()
          on_submit(text)
        end

        local function cancel()
          local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local text = table.concat(lines, "\n")
          close_box()
          if on_cancel then
            on_cancel(text)
            return
          end
          on_submit(nil)
        end

        local map_opts = { buffer = buf, silent = true, nowait = true }
        vim.keymap.set("i", "<C-s>", submit, map_opts)
        vim.keymap.set("n", "<CR>", submit, map_opts)
        vim.keymap.set({ "i", "n" }, "<C-c>", cancel, map_opts)
        vim.keymap.set("n", "<Esc>", cancel, map_opts)

        vim.notify("Pi prompt: Ctrl+S submit, Esc cancel (from normal mode), Ctrl+C cancel", vim.log.levels.INFO)
        vim.cmd("startinsert")
      end

      local open_or_focus_session

      local function parse_sessions_tsv(stdout)
        local sessions = {}

        for line in stdout:gmatch("[^\r\n]+") do
          local fields = vim.split(line, "\t", { plain = true })
          if #fields >= 9 then
            local line_start = tonumber(fields[6]) or 0
            local line_end = tonumber(fields[7]) or line_start
            local line_text
            if line_start == line_end then
              line_text = tostring(line_start)
            else
              line_text = string.format("%d-%d", line_start, line_end)
            end

            table.insert(sessions, {
              session = fields[1],
              status = fields[2],
              repo = fields[3],
              git_root = fields[4],
              file = fields[5],
              line_start = line_start,
              line_end = line_end,
              display = string.format("[%s] %s (%s) %s:%s", fields[2], fields[1], fields[3], fields[5], line_text),
            })
          end
        end

        return sessions
      end

      function M.start(command_opts)
        if vim.fn.executable(script_path) ~= 1 then
          vim.notify("pi-session script not executable: " .. script_path, vim.log.levels.ERROR)
          return
        end

        local file_path = get_buffer_path()
        if not file_path then
          vim.notify("Current buffer has no file path", vim.log.levels.ERROR)
          return
        end

        local line_start, line_end = resolve_range(command_opts)

        local git_root = git_root_for_file(file_path)
        local prefill = build_prefill_prompt(file_path, line_start, line_end, git_root)
        local draft = read_draft(git_root)
        local initial_text = draft or prefill

        open_prompt_box(initial_text, function(input)
          if not input or vim.trim(input) == "" then
            write_draft(git_root, input or "")
            return
          end

          local cmd = {
            script_path,
            "start",
            "--file",
            file_path,
            "--line-start",
            tostring(line_start),
            "--line-end",
            tostring(line_end),
            "--prompt",
            input,
          }

          local result = vim.system(cmd, { text = true }):wait()
          if result.code ~= 0 then
            write_draft(git_root, input)
            vim.notify("pi-session start failed: " .. shell_error_message(result), vim.log.levels.ERROR)
            return
          end

          clear_draft(git_root)

          local out = (result.stdout or ""):gsub("%s+$", "")
          local started_session = out:match("^started\t([^\r\n]+)$")
          if started_session and open_or_focus_session then
            open_or_focus_session({ session = started_session })
            return
          end

          if out == "" then
            vim.notify("Pi session started", vim.log.levels.INFO)
          else
            vim.notify(out, vim.log.levels.INFO)
          end
        end, function(cancelled_text)
          write_draft(git_root, cancelled_text or "")
        end)
      end

      local function find_open_session_target(session_name)
        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.b[buf].pi_session_name == session_name then
              return tab, win, buf
            end

            if vim.bo[buf].buftype == "terminal" then
              local buf_name = vim.api.nvim_buf_get_name(buf)
              if buf_name:find("tmux attach %-t " .. vim.pesc(session_name), 1, false) then
                return tab, win, buf
              end
            end
          end
        end

        local hidden_buf = nil
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf) then
            if vim.b[buf].pi_session_name == session_name then
              hidden_buf = buf
              break
            end

            if vim.bo[buf].buftype == "terminal" then
              local buf_name = vim.api.nvim_buf_get_name(buf)
              if buf_name:find("tmux attach %-t " .. vim.pesc(session_name), 1, false) then
                hidden_buf = buf
                break
              end
            end
          end
        end

        for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
          local ok, tab_session_name = pcall(vim.api.nvim_tabpage_get_var, tab, "pi_session_name")
          if ok and tab_session_name == session_name then
            return tab, vim.api.nvim_tabpage_get_win(tab), hidden_buf
          end
        end

        return nil, nil, hidden_buf
      end

      open_or_focus_session = function(choice)
        if vim.fn.executable("tmux") ~= 1 then
          vim.notify("tmux is not executable", vim.log.levels.ERROR)
          return
        end

        local existing_tab, existing_win, existing_buf = find_open_session_target(choice.session)
        if existing_tab and existing_win then
          local ok_tab = pcall(vim.api.nvim_set_current_tabpage, existing_tab)
          if ok_tab then
            pcall(vim.api.nvim_set_current_win, existing_win)
            if existing_buf and vim.api.nvim_buf_is_valid(existing_buf) then
              pcall(vim.api.nvim_win_set_buf, existing_win, existing_buf)
            end
            pcall(vim.cmd, "startinsert")
          end
          return
        end

        if existing_buf and vim.api.nvim_buf_is_valid(existing_buf) then
          vim.cmd("tabnew")
          local current_tab = vim.api.nvim_get_current_tabpage()
          vim.api.nvim_tabpage_set_var(current_tab, "pi_session_name", choice.session)
          vim.api.nvim_win_set_buf(0, existing_buf)
          vim.cmd("startinsert")
          return
        end

        vim.cmd("tabnew")
        local current_tab = vim.api.nvim_get_current_tabpage()
        vim.api.nvim_tabpage_set_var(current_tab, "pi_session_name", choice.session)
        vim.fn.termopen({ "tmux", "attach", "-t", choice.session })
        local term_buf = vim.api.nvim_get_current_buf()
        vim.b[term_buf].pi_session_name = choice.session
        vim.b[term_buf].pi_session_title = "tmux - pi-session"
        vim.bo[term_buf].buflisted = true
        vim.bo[term_buf].bufhidden = "hide"
        vim.keymap.set("n", "qd", "<cmd>bdelete! | tabclose<cr>", {
          buffer = term_buf,
          silent = true,
          nowait = true,
          desc = "Kill pi-session terminal buffer and close tab",
        })
        vim.api.nvim_create_autocmd("TermClose", {
          buffer = term_buf,
          once = true,
          callback = function(ev)
            vim.schedule(function()
              if not vim.api.nvim_buf_is_valid(ev.buf) then
                return
              end

              local tabpages = vim.api.nvim_list_tabpages()
              local target_tab = nil
              for _, tab in ipairs(tabpages) do
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
                  if vim.api.nvim_win_get_buf(win) == ev.buf then
                    target_tab = tab
                    break
                  end
                end
                if target_tab then
                  break
                end
              end

              if not target_tab then
                pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
                return
              end

              if #tabpages <= 1 then
                pcall(vim.api.nvim_buf_delete, ev.buf, { force = true })
                return
              end

              local tabnr = vim.api.nvim_tabpage_get_number(target_tab)
              pcall(vim.cmd, tostring(tabnr) .. "tabclose")
            end)
          end,
        })
        vim.cmd("startinsert")
      end

      function M.list()
        if vim.fn.executable(script_path) ~= 1 then
          vim.notify("pi-session script not executable: " .. script_path, vim.log.levels.ERROR)
          return
        end

        local result = vim.system({ script_path, "list", "--tsv" }, { text = true }):wait()
        if result.code ~= 0 then
          vim.notify("pi-session list failed: " .. shell_error_message(result), vim.log.levels.ERROR)
          return
        end

        local sessions = parse_sessions_tsv(result.stdout or "")
        if #sessions == 0 then
          vim.notify("No pi tmux sessions found", vim.log.levels.INFO)
          return
        end

        if #sessions == 1 then
          open_or_focus_session(sessions[1])
          return
        end

        vim.ui.select(sessions, {
          prompt = "Pi sessions",
          format_item = function(item)
            return item.display
          end,
        }, function(choice)
          if not choice then
            return
          end

          open_or_focus_session(choice)
        end)
      end

      vim.api.nvim_create_user_command("PiSessionPrompt", function(opts)
        M.start(opts)
      end, {
        desc = "Start a pi tmux session with prompt context",
        range = true,
      })

      vim.api.nvim_create_user_command("PiSessionList", function()
        M.list()
      end, {
        desc = "List running pi tmux sessions",
      })
    end,
  },
}
