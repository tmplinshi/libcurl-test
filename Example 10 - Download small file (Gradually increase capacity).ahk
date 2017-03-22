#NoEnv
#SingleInstance force
SetBatchLines -1


curl_global_init()

hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "http://s.cn.bing.net/az/hprichbg/rb/MicoDeNoche_ZH-CN10514469675_1920x1080.jpg")

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

result := {bin:"", size: 0}
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &result)

curl_easy_perform(hnd)
curl_easy_cleanup(hnd)

curl_global_cleanup()

FileOpen("out.jpg", "w").RawWrite(result.addr, result.size)
MsgBox, Download finish

write_callback(pBuffer, size, nmemb, userdata) {
	realsize := size * nmemb
	dl := Object(userdata)

	dl.SetCapacity("bin", dl.size + realsize + 1)
	dl.addr := dl.GetAddress("bin")
	DllCall("RtlMoveMemory", "ptr", dl.addr+dl.size, "ptr", pBuffer, "uint", realsize)
	dl.size += realsize
	
	return realsize
}