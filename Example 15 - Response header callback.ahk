#NoEnv
#SingleInstance force
SetBatchLines -1


hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "http://baidu.com")

curl_easy_setopt(hnd, "CURLOPT_HEADERFUNCTION", cb("header_callback"))
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb("write_callback"))

ret := {body:"", headers:""}
curl_easy_setopt(hnd, "CURLOPT_HEADERDATA", &ret)
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &ret)

curl_easy_perform(hnd)
curl_easy_cleanup(hnd)

MsgBox, % ret.body
MsgBox, % ret.headers

write_callback(buffer, size, nmemb, userdata) {
	Object(userdata).body .= StrGet(buffer, size*nmemb, "utf-8")
	return size*nmemb
}

header_callback(buffer, size, nmemb, userdata) {
	Object(userdata).headers .= StrGet(buffer, size*nmemb, "utf-8")
	return size*nmemb
}

cb(FunctionName) {
	return RegisterCallback(FunctionName, "C F")
}