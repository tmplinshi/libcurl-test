#NoEnv
#SingleInstance force
SetBatchLines -1

hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "http://dwz.cn/Je4")
curl_easy_setopt(hnd, "CURLOPT_FOLLOWLOCATION", true)
curl_easy_setopt(hnd, "CURLOPT_NOBODY", true)

curl_easy_perform(hnd)
curl_easy_getinfo(hnd, "CURLINFO_EFFECTIVE_URL", pUrl)
curl_easy_cleanup(hnd)

MsgBox, % StrGet(pUrl, "UTF-8")

/*
	   http://dwz.cn/Je4
	-> http://hao123.com/
	-> http://www.hao123.com/
*/