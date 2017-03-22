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

; If "Transfer-Encoding: chunked" is specified, then CURLOPT_POSTFIELDSIZE can be omited.

curl_slist_append(slist1, "Expect:")
curl_slist_append(slist1, "Transfer-Encoding: chunked")
curl_easy_setopt(hnd, "CURLOPT_HTTPHEADER", slist1)

curl_easy_setopt(hnd, "CURLOPT_POST", true)

; ----------------------------------
	curl_easy_setopt(hnd, "CURLOPT_DEBUGFUNCTION", cb("debug_callback"))
	curl_easy_setopt(hnd, "CURLOPT_VERBOSE", true)

dat := {}
dat.oFile := FileOpen(filename, "r")
curl_easy_setopt(hnd, "CURLOPT_READDATA", &dat)
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &dat)
curl_easy_setopt(hnd, "CURLOPT_READFUNCTION", cb("read_callback"))
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb("write_callback"))

curl_easy_perform(hnd)
curl_slist_free_all(slist1)
curl_easy_cleanup(hnd)

MsgBox, 0x40000, Upload finish, % dat.result
ExitApp

write_callback(buffer, size, nmemb, userdata) {
	Object(userdata).result .= StrGet(buffer, size*nmemb, "utf-8")
	return size*nmemb
}

read_callback(buffer, size, nmemb, userdata) {
	oFile := Object(userdata).oFile

	pct := Round( oFile.Pos / oFile.Length * 100, 2 )
	Progress, %pct%, % pct "% " oFile.Pos "/" oFile.Length, Uploading...

	return oFile.RawRead(buffer+0, size*nmemb)
}

debug_callback(hCurl, type, data, size, userptr) {
	_data := StrGet(data, size, "utf-8")
	_debug(infotypeStr(type) " (size:" size ") - " _data)
}

infotypeStr(n) {
	static t := { 0: "CURLINFO_TEXT"
	            , 1: "CURLINFO_HEADER_IN"
	            , 2: "CURLINFO_HEADER_OUT"
	            , 3: "CURLINFO_DATA_IN"
	            , 4: "CURLINFO_DATA_OUT"
	            , 5: "CURLINFO_SSL_DATA_IN"
	            , 6: "CURLINFO_SSL_DATA_OUT" }
	return t[n]
}

cb(FunctionName) {
	return RegisterCallback(FunctionName, "C F")
}
