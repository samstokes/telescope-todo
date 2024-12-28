return require("telescope").register_extension({
	setup = function(ext_config, config) end,
	exports = {
		todo = require("telescope-todo").todo_picker,
	},
})
