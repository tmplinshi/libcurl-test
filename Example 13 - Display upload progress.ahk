#NoEnv
#SingleInstance force
SetBatchLines -1

filename := "test.jpg"
if !FileExist(filename) {
      MsgBox, 48, Error, "%filename%" not exist
      ExitApp
}

hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "https://img42.com/")
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYPEER", false)
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYHOST", false)

FileRead, bin, *c %filename%
FileGetSize, binLen, %filename%
curl_easy_setopt(hnd, "CURLOPT_POSTFIELDS", &bin)
curl_easy_setopt(hnd, "CURLOPT_POSTFIELDSIZE", binLen)

curl_slist_append(slist1, "Expect:")
curl_easy_setopt(hnd, "CURLOPT_HTTPHEADER", slist1)

curl_easy_setopt(hnd, "CURLOPT_NOPROGRESS", false)
curl_easy_setopt(hnd, "CURLOPT_XFERINFOFUNCTION", cb("progress_callback"))
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb("write_callback"))

global result := ""

curl_easy_perform(hnd)
curl_slist_free_all(slist1)
curl_easy_cleanup(hnd)

Progress, Off
MsgBox,, Upload finish, %result%

; int progress_callback(void *clientp,   double dltotal,   double dlnow,   double ultotal,   double ulnow);
progress_callback(clientp, dltotal_l, dltotal_h, dlnow_l, dlnow_h, ultotal_l, ultotal_h, ulnow_l, ulnow_h) {
	if ultotal_l {
		pct := Round( ulnow_l / ultotal_l * 100, 2 )
		Progress, %pct%, % pct "% " ulnow_l "/" ultotal_l, Uploading...
	}
}

write_callback(pBuffer, size, nmemb, userdata) {
	result .= StrGet(pBuffer, size*nmemb, "utf-8")
	return size*nmemb
}

cb(FunctionName) {
	return RegisterCallback(FunctionName, "C F")
}
