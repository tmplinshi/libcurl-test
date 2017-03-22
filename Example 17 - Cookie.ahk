#NoEnv
#SingleInstance force
SetBatchLines -1


hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYPEER", false)
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYHOST", false)


; Read cookie from file
curl_easy_setopt(hnd, "CURLOPT_COOKIEFILE", "")

; Save cookie to file (when curl_easy_cleanup is called)
; curl_easy_setopt(hnd, "CURLOPT_COOKIEJAR", "savedCookie.txt")

; CURLOPT_COOKIEFILE or CURLOPT_COOKIEJAR will enable the cookie engine,
; the value can be empty

ret := {body: ""}
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &ret)
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb("write_callback"))

; Login
	ToolTip, Login...

	curl_easy_setopt(hnd, "CURLOPT_URL", "https://www.wutuofu.com/account/login")
	curl_easy_setopt(hnd, "CURLOPT_COPYPOSTFIELDS", "account=abcd&password=1234")
	curl_easy_perform(hnd)

	curl_easy_getinfo(hnd, "CURLINFO_REDIRECT_URL", pInfo)
	if ( StrGet(pInfo, "UTF-8") != "https://www.wutuofu.com/" ) {
		MsgBox, 48, Error, Login failed
		Goto, Exit
	}

; Test the cookie 
	ToolTip, Login success!

	curl_easy_setopt(hnd, "CURLOPT_HTTPGET", true)
	curl_easy_setopt(hnd, "CURLOPT_URL", "https://www.wutuofu.com/account")
	curl_easy_perform(hnd)

	RegExMatch(ret.body, "s`a)mod account-title.*?</div>", match)
	MsgBox, % match

Exit:
	curl_easy_cleanup(hnd)


write_callback(buffer, size, nmemb, userdata) {
	Object(userdata).body .= StrGet(buffer, size*nmemb, "utf-8")
	return size*nmemb
}

cb(FunctionName) {
	return RegisterCallback(FunctionName, "C F")
}