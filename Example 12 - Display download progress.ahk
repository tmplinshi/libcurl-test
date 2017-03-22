#NoEnv
#SingleInstance force
SetBatchLines -1


hnd := curl_easy_init()

curl_easy_setopt(hnd, "CURLOPT_URL", "http://dldir1.qq.com/qqfile/qq/QQ8.7/19113/QQ8.7.exe")

; curl_easy_setopt(hnd, "CURLOPT_URL", "https://www.hao123.com/")
; curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYPEER", false)
; curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYHOST", false)
; curl_easy_setopt(hnd, "CURLOPT_FOLLOWLOCATION", true)

curl_easy_setopt(hnd, "CURLOPT_NOPROGRESS", false)

curl_easy_setopt(hnd, "CURLOPT_XFERINFOFUNCTION", cb("progress_callback"))
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb("write_callback"))

dat := New CacheDL("QQ8.7.exe")
curl_easy_setopt(hnd, "CURLOPT_XFERINFODATA", &dat)
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &dat)

curl_easy_perform(hnd)
curl_easy_cleanup(hnd)

dat.SaveToFile()
Progress, Off
MsgBox, Download finish

; int progress_callback(void *clientp,   double dltotal,   double dlnow,   double ultotal,   double ulnow);
progress_callback(clientp, dltotal_l, dltotal_h, dlnow_l, dlnow_h, ultotal_l, ultotal_h, ulnow_l, ulnow_h) {
	if dltotal_l
		Object(clientp).pg := {dlnow: dlnow_l, dltotal: dltotal_l}
}

write_callback(pBuffer, size, nmemb, userdata) {
	pg := Object(userdata).pg
	if pg.dltotal {
		pct := Ceil( pg.dlnow / pg.dltotal * 100 )
		Progress, %pct%, % pct "% " pg.dlnow "/" pg.dltotal, Downloading
	}
	return Object(userdata).HandleData(pBuffer, size, nmemb)
}

cb(FunctionName) {
	return RegisterCallback(FunctionName, "C F")
}

class CacheDL
{
	/*
		FileName - 输出文件名
		StepSize - 缓存空间递增大小 (单位: MB)
		MaxSize  - 最大缓存大小 (单位: MB)。达到此大小，数据将会写入到文件
	*/
	__New(FileName, StepSize := 5, MaxSize := 128) {
		this.STEP_SIZE := StepSize * 1024 * 1024
		this.MAX_SIZE  := MaxSize  * 1024 * 1024

		this.cachedSize := 0
		this.capacity   := 0
		this.cachedBin  := ""

		this.outFile   := FileName
		this.tempFile  := FileName ".curl_dl"
		this.oTempFile := FileOpen(this.TempFile, "w")
	}

	SaveToTempFile() {
		this.oTempFile.RawWrite(this.binAddr, this.cachedSize)
		this.ClearCache()
	}

	ClearCache() {
		this.cachedSize := this.capacity := 0
		this.cachedBin := ""
	}

	SaveToFile() {
		if (this.cachedSize) {
			this.SaveToTempFile()
		}
		this.oTempFile.Close()
		FileMove, % this.tempFile, % this.outFile, 1

		this.ClearCache()
	}

	HandleData(pBuffer, size, nmemb) {
		realsize := size * nmemb

		if (this.capacity < this.cachedSize + realsize) { ; 容量不够则递增
			this.capacity += realsize + this.STEP_SIZE
			this.SetCapacity("cachedBin", this.capacity)

			this.binAddr := this.GetAddress("cachedBin")
		}

		DllCall("RtlMoveMemory", "ptr", this.binAddr+this.cachedSize, "ptr", pBuffer, "uint", realsize)
		this.cachedSize += realsize

		if (this.cachedSize >= this.MAX_SIZE) {
			this.SaveToTempFile()
		}
		return realsize
	}
}