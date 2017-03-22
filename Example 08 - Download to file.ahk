#NoEnv
#SingleInstance force
SetBatchLines -1


curl_global_init()

hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "http://dldir1.qq.com/qqfile/qq/QQ8.7/19113/QQ8.7.exe")

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

f := FileOpen("QQ8.7.exe", "w")
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &f)

ToolTip, Downloading...
curl_easy_perform(hnd)
curl_easy_cleanup(hnd)

curl_global_cleanup()
f.Close()

ToolTip
MsgBox, Download Finish!

write_callback(pBuffer, size, nmemb, userdata) {
	return Object(userdata).RawWrite(pBuffer+0, size*nmemb)
}