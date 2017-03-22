#NoEnv
#SingleInstance force
SetBatchLines -1


curl_global_init()

hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "http://www.baidu.com")

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

result := {bin:"", size: 0}
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &result)

curl_easy_perform(hnd)
curl_easy_cleanup(hnd)

curl_global_cleanup()

ret := StrGet(result.addr, result.size, "utf-8")
MsgBox, % ret

write_callback(pBuffer, size, nmemb, userdata) {
	realsize := size * nmemb
	dl := Object(userdata)

	dl.SetCapacity("bin", dl.size + realsize + 1)
	dl.addr := dl.GetAddress("bin")
	DllCall("RtlMoveMemory", "ptr", dl.addr+dl.size, "ptr", pBuffer, "uint", realsize)
	dl.size += realsize

	return realsize
}