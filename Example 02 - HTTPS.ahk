#NoEnv
#SingleInstance force
SetBatchLines -1


hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "https://baidu.com/")
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYPEER", false)
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYHOST", false)
curl_easy_setopt(hnd, "CURLOPT_FOLLOWLOCATION", true)

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

curl_easy_perform(hnd)
curl_easy_getinfo(hnd, "CURLINFO_RESPONSE_CODE", retcode)
curl_easy_cleanup(hnd)

MsgBox, % retcode
MsgBox, % curl.result

write_callback(pBuffer, size, nmemb, userdata) {
	dat := StrGet(pBuffer, size*nmemb, "utf-8")
	curl.result .= dat
	return size*nmemb
}

