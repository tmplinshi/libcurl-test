#NoEnv
#SingleInstance force
SetBatchLines -1

MsgBox, % curl_version()
MsgBox, % curl_version_info()
