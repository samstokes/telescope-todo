local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local conf = require('telescope.config').values

local setup = function(opts)
  require('telescope').load_extension('todo')
  require('plenary')
end

local todo_picker = function(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "TODO",
    finder = finders.new_oneshot_job({ "todo", "--raw" }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        print(selection[1])
      end)
      return true
    end,
  }):find()
end

local _todo_output = '0 TODO'

local handle_todo_count = function(output)
  if (output == '0 TODO') then
    return ''
  else
    return output
  end
end

local todo_count = function(opts)
  local Job = require('plenary.job')
  Job:new({
    command = 'todo',
    args = { '-c' },
    on_exit = function(j, return_val)
      if (return_val == 0) then
        _todo_output = j:result()[1]
      end
    end,
  }):start()

  return handle_todo_count(_todo_output)
end

return { setup = setup, todo_picker = todo_picker, todo_count = todo_count }
