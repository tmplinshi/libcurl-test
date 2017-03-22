#NoEnv
#SingleInstance force
SetBatchLines -1


hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "http://www.baidu.com/")
curl_easy_setopt(hnd, "CURLOPT_ACCEPT_ENCODING", "")

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

curl_easy_perform(hnd)
curl_easy_cleanup(hnd)

MsgBox, % curl.result

write_callback(pBuffer, size, nmemb, userdata) {
	dat := StrGet(pBuffer, size*nmemb, "utf-8")
	curl.result .= dat
	return size*nmemb
}
