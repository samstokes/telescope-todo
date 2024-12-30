return require("telescope").register_extension({
	setup = function(ext_config, config) end,
	exports = {
		todo = require("todo-txt").todo_picker,
	},
})
