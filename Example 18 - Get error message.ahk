
hnd := curl_easy_init()

errbuf := 0
curl_easy_setopt(hnd, "CURLOPT_ERRORBUFFER", &errbuf)

if curl_easy_perform(hnd) {
	MsgBox, % StrGet(&errbuf, "utf-8")
}
