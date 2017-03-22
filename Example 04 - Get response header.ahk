#NoEnv
#SingleInstance force
SetBatchLines -1


hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "https://www.nyaa.se/?page=download&tid=613616")
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYPEER", false)
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYHOST", false)
curl_easy_setopt(hnd, "CURLOPT_NOBODY", true)
curl_easy_setopt(hnd, "CURLOPT_HEADER", true)

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

curl_easy_perform(hnd)
curl_easy_getinfo(hnd, "CURLINFO_CONTENT_TYPE", pContentType)
curl_easy_cleanup(hnd)

MsgBox, % curl.result
MsgBox,, Content-Type, % StrGet(pContentType, "UTF-8")

write_callback(pBuffer, size, nmemb, userdata) {
	dat := StrGet(pBuffer, size*nmemb, "utf-8")
	curl.result .= dat
	return size*nmemb
}
