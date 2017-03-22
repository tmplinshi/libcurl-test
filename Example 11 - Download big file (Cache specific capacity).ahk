#NoEnv
#SingleInstance force
SetBatchLines -1

url := "http://dldir1.qq.com/qqfile/qq/QQ8.7/19113/QQ8.7.exe"
outFile := "QQ8.7.exe"

curl_global_init()

hnd := curl_easy_init()
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYPEER", false)
curl_easy_setopt(hnd, "CURLOPT_SSL_VERIFYHOST", false)
curl_easy_setopt(hnd, "CURLOPT_URL", url)

cb := RegisterCallback("write_callback", "C F")
curl_easy_setopt(hnd, "CURLOPT_WRITEFUNCTION", cb)

dl := New CacheDL("QQ8.7.exe")
curl_easy_setopt(hnd, "CURLOPT_WRITEDATA", &dl)

curl_easy_perform(hnd)
curl_easy_cleanup(hnd)

curl_global_cleanup()

dl.SaveToFile()
MsgBox, Download finish
ExitApp

write_callback(pBuffer, size, nmemb, userdata) {
	return Object(userdata).HandleData(pBuffer, size, nmemb)
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

	; 保存数据到临时文件
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