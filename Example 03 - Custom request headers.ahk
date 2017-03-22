#NoEnv
#SingleInstance force
SetBatchLines -1


hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "http://baidu.com/")
curl_easy_setopt(hnd, "CURLOPT_VERBOSE", true)

curl_slist_append(header, "Accept: text/plain")
curl_slist_append(header, "test: abc")
curl_easy_setopt(hnd, "CURLOPT_HTTPHEADER", header)

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

curl_easy_perform(hnd)
curl_slist_free_all(header)
curl_easy_cleanup(hnd)

MsgBox, % curl.result

write_callback(pBuffer, size, nmemb, userdata) {
	dat := StrGet(pBuffer, size*nmemb, "utf-8")
	curl.result .= dat
	return size*nmemb
}
