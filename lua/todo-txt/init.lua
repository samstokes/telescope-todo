-- Store the job and cache state
local M = {
	_current_job = nil,
	_cached_output = "",
	_cache_timestamp = 0,
	_cache_duration = 10000, -- Cache duration in ms
}

local setup = function(opts)
	-- Allow configuring cache duration
	if opts and opts.cache_duration then
		M._cache_duration = opts.cache_duration
	end

	local ok, telescope = pcall(require, "telescope")
	if ok then
		telescope.load_extension("todo")
	end
end

local handle_todo_count = function(output)
	if output == "0 TODO" then
		return ""
	else
		return output
	end
end

local todo_count = function()
	---@diagnostic disable-next-line: undefined-field
	local current_time = vim.loop.now()

	-- Return cached result if it's still fresh
	if current_time - M._cache_timestamp < M._cache_duration then
		return handle_todo_count(M._cached_output)
	end

	-- Cancel any existing job
	if M._current_job and not M._current_job.is_shutdown then
		M._current_job:shutdown()
	end

	-- Create new job
	local Job = require("plenary.job")
	---@diagnostic disable-next-line: missing-fields
	M._current_job = Job:new({
		command = "todo",
		args = { "-c" },
		on_exit = function(j, return_val)
			if return_val == 0 then
				M._cached_output = j:result()[1]
				M._cache_timestamp = current_time
			end
		end,
	})

	M._current_job:start()
	return handle_todo_count(M._cached_output)
end

local todo_picker = function(opts)
	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local conf = require("telescope.config").values

	opts = opts or {}
	pickers
		.new(opts, {
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
		})
		:find()
end

return {
	setup = setup,
	todo_count = todo_count,
	todo_picker = todo_picker,
}
