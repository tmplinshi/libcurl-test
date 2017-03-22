#NoEnv
#SingleInstance force
SetBatchLines -1

filename := "test.png"
if !FileExist(filename) {
      MsgBox, 48, Error, "%filename%" not exist
      ExitApp
}

hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_URL", "https://sm.ms/api/upload")
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYPEER", false)
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYHOST", false)

post := last := 0
curl_formadd( post, last
            , "CURLFORM_COPYNAME", "format"
            , "CURLFORM_COPYCONTENTS", "json"
            , "CURLFORM_END")
curl_formadd( post, last
            , "CURLFORM_COPYNAME", "smfile"
            , "CURLFORM_FILE", filename
            , "CURLFORM_CONTENTTYPE", "image/png" ; Optinal
            , "CURLFORM_END")
curl_easy_setopt(hnd, "CURLOPT_HTTPPOST", post)

curl_slist_append(slist1, "Expect:")
curl_easy_setopt(hnd, "CURLOPT_HTTPHEADER", slist1)

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

curl_easy_perform(hnd)
curl_formfree(post)
curl_slist_free_all(slist1)
curl_easy_cleanup(hnd)

MsgBox, % curl.result


write_callback(pBuffer, size, nmemb, userdata) {
	dat := StrGet(pBuffer, size*nmemb, "utf-8")
	curl.result .= dat
	return size*nmemb
}
