#NoEnv
#SingleInstance force
SetBatchLines -1

ret := {}

curl_global_init()

; Prepare easy hanle 1
hnd1 := curl_easy_init()
curl_easy_setopt(hnd1, "CURLOPT_URL", "http://baidu.com")
curl_easy_setopt(hnd1, "CURLOPT_WRITEFUNCTION", cb("write_callback"))
curl_easy_setopt(hnd1, "CURLOPT_WRITEDATA", &ret)

; Prepare easy hanle 2
hnd2 := curl_easy_init()
curl_easy_setopt(hnd2, "CURLOPT_URL", "http://www.example.com")
curl_easy_setopt(hnd2, "CURLOPT_WRITEFUNCTION", cb("write_callback"))
curl_easy_setopt(hnd2, "CURLOPT_WRITEDATA", &ret)

; Create multi handle
multi_handle := curl_multi_init()

; Adding easy handles to multi handle
curl_multi_add_handle(multi_handle, hnd1)
curl_multi_add_handle(multi_handle, hnd2)

still_running := numfds := 0

curl_multi_perform(multi_handle, &still_running)

Loop {
	; wait for activity, timeout or "nothing"
	mc := curl_multi_wait(multi_handle, 0, 0, 1000, &numfds)

	if ( mc != curl.const("CURLM_OK") ) {
		MsgBox, 48, Error, curl_multi failed. Code: %mc%
		break
	}

	/*
		'numfds' being zero means either a timeout or no file descriptors to
		wait for. Try timeout on first occurrence, then assume no file
		descriptors and no file descriptors to wait for means wait for 100
		milliseconds.
	*/
	if (!numfds) {
		repeats += 1 ; count number of repeated zero numfds
		if (repeats > 1) {
			_debug("Sleep, 100")
			Sleep, 100
		}
	} else {
	    repeats := 0
	}

	curl_multi_perform(multi_handle, &still_running)

	QueryFinishedEasyHandles()

} Until !still_running

; QueryFinishedEasyHandles()

; clear:
; 	1. curl_multi_remove_handle 
; 	2. curl_easy_cleanup
; 	3. curl_multi_cleanup

curl_multi_cleanup(multi_handle)
curl_global_cleanup()

; -----------------------------
MsgBox, % ret.body
ExitApp
return

QueryFinishedEasyHandles() {
	global

	Loop {
		msgq := 0
		m := curl_multi_info_read(multi_handle, &msgq)
		if ( m && NumGet(m+0,"uint") == curl.const("CURLMSG_DONE") ) {
			e := NumGet(m+4) ; easy handle

			curl_easy_getinfo(e, "CURLINFO_EFFECTIVE_URL", thisUrl)
			thisUrl := StrGet(thisUrl, "UTF-8")
			_debug("easy handle finished: " thisUrl)

			curl_multi_remove_handle(multi_handle, e)
			curl_easy_cleanup(e)
		}
	} Until !m
}

write_callback(buffer, size, nmemb, userdata) {
	Object(userdata).body .= StrGet(buffer, size*nmemb, "utf-8")
	return size*nmemb
}

cb(FunctionName) {
	return RegisterCallback(FunctionName, "C F")
}