#NoEnv
#SingleInstance force
SetBatchLines -1

Gui, Add, Button, gClearList, Clear List
Gui, Add, Text, x350 hp 0x200 ys, URL progress:
Gui, Add, Text, cRed x+5 hp 0x200 w100 vLog_UrlPg, 
Gui, Add, Progress, xm w500 h5 vpg cRed, 
Gui, Add, ListView, xm y+0 Grid vLV w500 r15, Handle|URL|Status Code
Gui, Add, Text, , Max handles:
Gui, Add, Edit, x+5 w80 Number Center vMaxEasyHandles, 10
Gui, Add, Text, xm, Url List:
Gui, Add, Link, x+50 gLoadTestUrls, <a>Test URL 1</a>
Gui, Add, Link, x+50 gLoadTestUrls, <a>Test URL 2</a>
Gui, Add, Edit, xm vUrlList w380 r5 gEnableDisableButtons, % testUrls1()
Gui, Add, Button, x+30 w80 hp Disabled, Query
Gui, Add, StatusBar, , 
Gui, Show

for idx, width in [92, 276, 105]
	LV_ModifyCol(idx, width)
Gosub, EnableDisableButtons
Return

ClearList:
	LV_Delete()
return

LoadTestUrls:
	GuiControl,, UrlList, % InStr(A_GuiControl, "1") ? testUrls1() : testUrls2()
	GuiControl, Enable, Query
return

ButtonQuery:
	Gui, Submit, NoHide

	UrlList := RegExReplace(UrlList, "[ `t]")
	UrlList := RegExReplace(UrlList, "\R+", "`n")
	UrlList := Trim(UrlList, "`n")
	thisArr := StrSplit(UrlList, "`n")

	if !thisArr.MaxIndex()
		return

	if !MaxEasyHandles
		MaxEasyHandles := 1

	; GuiControl,        , UrlList
	; GuiControl, Disable, Query

	if !started {
		curl_global_init()
		multi_handle := curl_multi_init()

		Handles := []
		Urls := []
		Url_CurrIdx := 0
	}

	Urls.InsertAt(1, thisArr*)

	; Update url counts
	GuiControl,, Log_UrlPg, % Urls.MaxIndex()
	GuiControl, % "+Range1-" Urls.MaxIndex(), pg

	while ( Handles.MaxIndex() < MaxEasyHandles )
	   && ( Url_CurrIdx < Urls.MaxIndex() ) {
		Url_CurrIdx += 1

		idx := Handles.Push( hnd := curl_easy_init() )
		curl_easy_setopt(hnd, "CURLOPT_NOBODY", true)
		curl_easy_setopt(hnd, "CURLOPT_URL", Urls[Url_CurrIdx])
		curl_easy_setopt(hnd, "CURLOPT_TIMEOUT", 1)

		; curl_easy_setopt(hnd, "CURLOPT_DEBUGFUNCTION", cb("debug_callback"))
		; curl_easy_setopt(hnd, "CURLOPT_VERBOSE", true)
		; curl_easy_setopt(hnd, "CURLOPT_PRIVATE", Urls.GetAddress(Url_CurrIdx))

		curl_multi_add_handle(multi_handle, hnd)
	}

	if !started
		SetTimer, LoopRun, -1
return

LoopRun:
	started := true

	still_running := numfds := 0
	curl_multi_perform(multi_handle, &still_running)

	Loop {
		; wait for activity, timeout or "nothing"
		mc := curl_multi_wait(multi_handle, 0, 0, 1000, &numfds)

		if ( mc != curl.const("CURLM_OK") ) {
			MsgBox, 48, Error, curl_multi failed. Code: %mc%
			break
		}

		/*
			'numfds' being zero means either a timeout or no file descriptors to
			wait for. Try timeout on first occurrence, then assume no file
			descriptors and no file descriptors to wait for means wait for 100
			milliseconds.
		*/
		if (!numfds) {
			repeats += 1 ; count number of repeated zero numfds
			if (repeats > 1) {
				; _debug("Sleep, 100")
				Sleep, 100
			}
		} else {
		    repeats := 0
		}

		curl_multi_perform(multi_handle, &still_running)

		Loop {
			msgq := 0
			m := curl_multi_info_read(multi_handle, &msgq)
			if ( m && NumGet(m+0,"uint") == curl.const("CURLMSG_DONE") ) {
				hnd := NumGet(m+4) ; easy handle

				CURLcode := NumGet(m + 4 + A_PtrSize, "uint")

				RecordToLV(hnd, CURLcode)
				finishCount += 1
				GuiControl,, Log_UrlPg, % finishCount "/" Urls.MaxIndex()
				GuiControl,, pg, % finishCount

				if ( Url_CurrIdx < Urls.MaxIndex() ) {
					curl_multi_remove_handle(multi_handle, hnd)

					Url_CurrIdx += 1
					curl_easy_setopt(hnd, "CURLOPT_URL", Urls[Url_CurrIdx])
					curl_easy_setopt(hnd, "CURLOPT_TIMEOUT", 1)
					; curl_easy_setopt(hnd, "CURLOPT_DEBUGFUNCTION", cb("debug_callback"))
					; curl_easy_setopt(hnd, "CURLOPT_VERBOSE", true)
					; curl_easy_setopt(hnd, "CURLOPT_PRIVATE", Urls.GetAddress(Url_CurrIdx))

					curl_multi_add_handle(multi_handle, hnd)
					curl_multi_perform(multi_handle, &still_running)
				}
			}
		} Until !m

	} Until !still_running

	for i, hnd in Handles {
		curl_multi_remove_handle(multi_handle, hnd)
		curl_easy_cleanup(hnd)
	}
	curl_multi_cleanup(multi_handle)
	curl_global_cleanup()

	Handles := []
	Urls := []
	Url_CurrIdx := 0
	finishCount := 0

	started := false

	Gui, +OwnDialogs
	MsgBox, finished!
return

RecordToLV(hnd, CURLcode) {

	curl_easy_getinfo(hnd, "CURLINFO_EFFECTIVE_URL", thisUrl)
	thisUrl := StrGet(thisUrl, "UTF-8")

	if CURLcode {
		if (CURLcode = curl.const("CURLE_OPERATION_TIMEDOUT"))
			col3 := "Error: Timeout"
		else
			col3 := "Error: " CURLcode
	} else {
		curl_easy_getinfo(hnd, "CURLINFO_RESPONSE_CODE", col3)
	}

	row := LV_Add("", hnd, thisUrl, col3)
	LV_Modify(row, "Vis")
}

EnableDisableButtons:
	GuiControlGet, UrlList
	if !UrlList {
		GuiControl, Disable, Query
		return
	}

	GuiControlGet, isEnabled, Enabled, Query
	if !isEnabled {
		GuiControl, Enable, Query
	}
return

GuiClose:
	curl_multi_cleanup(multi_handle)
	curl_global_cleanup()
ExitApp

cb(FunctionName) {
	return RegisterCallback(FunctionName, "C F")
}

testUrls1() {
	return "
	(LTrim
		http://update.123juzi.net/
		http://www.hao123.com/
		http://hi.baidu.com/
		http://12306.hao123.com/
		http://www.baidu.com/
		http://top.baidu.com/
		http://dl.123juzi.net/
		http://www.people.com.cn/
		http://www.xinhuanet.com/
		http://www.cctv.com/
		http://www.cri.cn/
		http://cn.chinadaily.com.cn/
		http://www.china.com.cn/
		http://www.ce.cn/
		http://www.gmw.cn/
		http://www.cnr.cn/
		http://www.qstheory.cn/
		http://www.youth.cn/
		http://www.cac.gov.cn/
		http://www.sina.com.cn/
		http://weibo.com/
		http://www.sohu.com/
		http://tuijian.hao123.com/
		http://www.qq.com/
		http://www.163.com/
		http://www.youku.com/
		http://game.hao123.com/
		http://www.4399.com/
		http://v.hao123.com/
		http://union.click.jd.com/
		http://tejia.hao123.com/
		http://s.click.taobao.com/
		http://jump.luna.58.com/
		http://www.fang.com/
		http://u.ctrip.com/
		http://www.ctrip.com/
		http://www.37.com/
		http://www.12306.cn/
		http://www.jiayuan.com/
		http://www.ganji.com/
		http://www.51job.com/
		http://www.bilibili.com/
		http://map.baidu.com/
		http://moe.hao123.com/
		http://juzi.hao123.com/
		http://www.zhibo8.cc/
		http://shouji.suning.com/
		http://caipiao.hao123.com/
		http://life.hao123.com/
		http://ai.taobao.com/
		http://gouwu.hao123.com/
		http://shouji.hao123.com/
		http://xyx.hao123.com/
		http://go.hao123.com/
		http://haitao.hao123.com/
		http://zt.chuanke.com/
		http://www.chuanke.com/
		http://jingyan.baidu.com/
		http://wenku.baidu.com/
		http://8.hao123.com/
		http://bank.eastmoney.com/
		http://music.hao123.com/
		http://y.baidu.com/
		http://pic.hao123.com/
		http://lady.hao123.com/
		http://w.x.baidu.com/
		http://live.hao123.com/
		http://news.hao123.com/
		http://www.weather.com.cn/
		http://pan.baidu.com/
		http://e.baidu.com/
		http://www.beian.gov.cn/
		http://www.12377.cn/
		http://www.bj.cyberpolice.cn/
		http://www.bjjubao.org/
		http://haokan.baidu.com/
		http://click.union.jd.com/
		http://huoche.tuniu.com/
		http://soft.hao123.com/
		http://www.iqiyi.com/
		http://v.baidu.com/
		http://v.qq.com/
		http://www.mgtv.com/
		http://www.17173.com/
		http://yx.2144.cn/
		http://news.sina.com.cn/
		http://mini.qq.com/
		http://news.sohu.com/
		http://news.baidu.com/
		http://news.163.com/
		http://www.thepaper.cn/
		http://www.huanqiu.com/
		http://military.china.com/
		http://v.ifeng.com/
		http://www.tiexue.net/
		http://www.xinjunshi.com/
		http://www.top81.com.cn/
		http://mil.qq.com/
		http://mil.news.sina.com.cn/
		http://sports.sina.com.cn/
		http://sports.sohu.com/
		http://sports.cntv.cn/
		http://www.hupu.com/
		http://www.taobao.com/
		http://www.suning.com/
		http://www.zhe800.com/
		http://www.smzdm.com/
		http://www.qunar.com/
		http://www.tuniu.com/
		http://flights.ctrip.com/
		http://www.mafengwo.cn/
		http://www.qidian.com/
		http://kanshu.baidu.com/
		http://www.zongheng.com/
		http://book.hao123.com/
		http://www.readnovel.com/
		http://www.xxsy.net/
		http://www.10086.cn/
		http://www.10010.com/
		http://www.zol.com.cn/
		http://mobile.pconline.com.cn/
		http://zs.91.com/
		http://www.ithome.com/
		http://www.zealer.com/
		http://www.mi.com/
		http://tieba.baidu.com/
		http://www.zhenai.com/
		http://www.baihe.com/
		http://www.tianya.cn/
		http://qzone.qq.com/
		http://www.6.cn/
		http://www.showself.com/
		http://www.panda.tv/
		http://www.huya.com/
		http://ganji.com/
		http://www.78.cn/
		http://www.lianjia.com/
		http://www.cr173.com/
		http://xiazai.zol.com.cn/
		http://www.skycn.com/
		http://www.onlinedown.net/
		http://www.zhaopin.com/
		http://www.liepin.com/
		http://www.yingjiesheng.com/
		http://www.chinahr.com/
		http://www.pcauto.com.cn/
		http://auto.sina.com.cn/
		http://che.hao123.com/
		http://www.jxedt.com/
		http://wyyx.hao123.com/
		http://vdax.youzu.com/
		http://tengguo.37.com/
		http://www.acfun.tv/
		http://baozoumanhua.com/
		http://music.baidu.com/
		http://www.1ting.com/
		http://www.kugou.com/
		http://www.kuwo.cn/
		http://fm.baidu.com/
		http://www.stockstar.com/
		http://finance.sina.com.cn/
		http://www.10jqka.com.cn/
		http://www.yicai.com/
		http://www.eastmoney.com/
		http://www.kxt.com/
		http://guba.eastmoney.com/
		http://www.hexun.com/
		http://www.jrj.com.cn/
		http://www.cnfol.com/
		http://xueqiu.com/
		http://hao123.lecai.com/
		http://www.rayli.com.cn/
		http://www.haibao.com/
		http://ent.sina.com.cn/
		http://www.pclady.com.cn/
		http://lady.163.com/
		http://www.chsi.com.cn/
		http://www.zhcw.com/
		http://www.sporttery.cn/
		http://trend.hao123.lecai.com/
		http://caipiao.baidu.com/
		http://www.icbc.com.cn/
		http://www.ccb.com/
		http://www.abchina.com/
		http://www.boc.cn/
		http://www.bankcomm.com/
		http://www.cmbchina.com/
		http://qianbao.baidu.com/
		http://mail.163.com/
		http://mail.126.com/
		http://mail.aliyun.com/
		http://mail.sina.com.cn/
		http://mail.qq.com/
		http://www.qiushibaike.com/
		http://www.xiachufang.com/
		http://huaban.com/
		http://open.163.com/
		http://news.ifeng.com/
		http://hot.ynet.com/
		http://bbs.miercn.com/
		http://society.cnr.cn/
		http://shehui.rmzxb.com.cn/
	)"
}

testUrls2() {
	return "
	(LTrim
		http://bbs.qianyan001.com/
		http://cuxiao.suning.com/
		http://www.xixi123.com/
	)"
}

debug_callback(hCurl, type, data, size, userptr) {
	_data := StrGet(data, size, "utf-8")
	curl_easy_getinfo(hCurl, "CURLINFO_PRIVATE", private)
	_url := StrGet(private)
	_debug(_url ": " infotypeStr(type) " (size:" size ") - " _data)
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