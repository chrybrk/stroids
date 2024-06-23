_G.window_settings = {
	width = 1200,
	height = 700,
	title = "stroids"
}

function love.conf(T)
	-- set window title
	T.window.title = window_settings.title

	-- set window size
	T.window.width = window_settings.width
	T.window.height = window_settings.height

	-- set window as resizable
	T.window.resizable = false
end
