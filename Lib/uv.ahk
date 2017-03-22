_uv_auto_load() {
	static hModule := DllCall("LoadLibrary", "Str", "libuv.dll", "Ptr")
}

uv_default_loop() {
	return DllCall("libuv\uv_default_loop", "ptr")
}

uv_timer_init(loop, handle) {
	return DllCall("libuv\uv_timer_init", "ptr", loop, "ptr", handle)
}

uv_timer_start(handle, cb, timeout, repeat) {
	return DllCall("libuv\uv_timer_start", "ptr", handle, "ptr", cb, "uint64", timeout, "uint64", repeat)
}

uv_run(loop, mode) {
	return DllCall("libuv\uv_run", "ptr", loop, "int", mode)
}

uv_poll_start(handle, events, cb) {
	return DllCall("libuv\uv_poll_start", "ptr", handle, "int", events, "ptr", cb)
}

uv_poll_stop(poll) {
	return DllCall("libuv\uv_poll_stop", "ptr", poll)
}

uv_poll_init_socket(loop, handle, socket) {
	return DllCall("libuv\uv_poll_init_socket", "ptr", loop, "ptr", handle, "ptr", socket)
}

uv_close(handle, close_cb) {
	DllCall("libuv\uv_close", "ptr", handle, "ptr", close_cb)
}