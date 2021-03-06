; Credits: https://github.com/RaptorX/cURL-Wrapper


; Return: If this function returns NULL, something went wrong and you cannot use the other curl functions. 
curl_easy_init() {
	return DllCall("libcurl\curl_easy_init", "cdecl ptr")
}

; Return: CURLE_OK (zero) means that the option was set properly, non-zero means an error occurred as <curl/curl.h> defines.
; curl_easy_setopt(handle, opt, param) {
; 	if ( curl.type(param) = "string" ) {
; 		curl.strPutVar(param, paramA, "UTF-8")
; 		param := &paramA
; 	}
; 	paramType := InStr(opt, "_LARGE") ? "int64" : "ptr"
; 	return DllCall("libcurl\curl_easy_setopt", "ptr", handle, "uint", curl.const(opt), paramType, param, "cdecl")
; }
curl_easy_setopt(handle, opt, param) {
	if ( curl.type(param) = "string" ) {
		return DllCall("libcurl\curl_easy_setopt", "ptr", handle, "uint", curl.const(opt), "astr", param, "cdecl")
	} else {
		return DllCall("libcurl\curl_easy_setopt", "ptr", handle, "uint", curl.const(opt), "ptr", param, "cdecl")
	}
}

; Return: CURLE_OK (0) means everything was ok, non-zero means an error occurred as <curl/curl.h> defines
curl_easy_perform(handle) {
	return DllCall("libcurl\curl_easy_perform", "ptr", handle, "cdecl")
}

curl_easy_getinfo(handle, info, ByRef retCode) {
	return DllCall("libcurl\curl_easy_getinfo", "ptr", handle, "uint", curl.const(info), "int*", retCode, "cdecl")
	     ; , retCode := StrGet(retCode, "UTF-8")
}

; Return: None
curl_easy_cleanup(handle) {
	DllCall("libcurl\curl_easy_cleanup", "ptr", handle, "cdecl")
}

; Return: None
curl_easy_reset(handle) {
	DllCall("libcurl\curl_easy_reset", "ptr", handle, "cdecl")
}

; Note: The new handle will not inherit any state information, no connections, no SSL sessions and no cookies.
; Return: If this function returns NULL, something went wrong and no valid handle was returned.
curl_easy_duphandle(handle) {
	DllCall("libcurl\curl_easy_duphandle", "ptr", handle, "cdecl")
}

; -----------------------------------------------------

; Return: If this function returns non-zero, something went wrong and you cannot use the other curl functions. 
; CURL_GLOBAL_DEFAULT = CURL_GLOBAL_ALL = (CURL_GLOBAL_SSL|CURL_GLOBAL_WIN32) --> 3
curl_global_init(flags := 3) {
	return DllCall("libcurl\curl_global_init", "int", flags, "cdecl")
}

curl_global_cleanup() {
	DllCall("libcurl\curl_global_cleanup", "cdecl")
}

; -----------------------------------------------------

curl_version() {
	return DllCall("libcurl\curl_version", "cdecl astr")
}

; Return: Object
curl_version_info(CURLversion = 3) { ; CURLVERSION_NOW = 3
	pInfo := DllCall("libcurl\curl_version_info", "int", CURLversion, "cdecl ptr")
	return curl.parse_vinfo(pInfo)
}

; Return: A null pointer is returned if anything went wrong, otherwise the new list pointer is returned. 
curl_slist_append(ByRef slist, string) {
	curl.strPutVar(string, stringA, "UTF-8")
	return slist := DllCall("libcurl\curl_slist_append", "ptr", slist, "ptr", &stringA, "cdecl ptr")
}

curl_slist_free_all(curl_slist) {
	DllCall("libcurl\curl_slist_free_all", "ptr", curl_slist, "cdecl")
}

curl_formadd(ByRef firstitem, ByRef lastitem, params*) {
	strA := []
	For idx, val in params {
		if !Mod(idx, 2) && ( curl.type(val) = "string" ) {
			curl.strPutVar(val, valA, "UTF-8")
			strA[idx] := valA
			params[idx] := strA.GetAddress(idx)
		}
	}
	return DllCall("libcurl\curl_formadd"
		, "ptr*", firstitem
		, "ptr*", lastitem
		, "uint", curl.const(params.1), "ptr", params.2
		, "uint", curl.const(params.3), "ptr", params.4
		, "uint", curl.const(params.5), "ptr", params.6
		, "uint", curl.const(params.7), "ptr", params.8
		, "uint", curl.const(params.9)
		, "cdecl")
}

curl_formfree(form) {
	DllCall("libcurl\curl_formfree", "ptr", form, "cdecl")
}

curl_easy_escape(handle, string, len:=0) {
	curl.strPutVar(string, stringA, "UTF-8")
	return DllCall("libcurl\curl_easy_escape", "ptr", handle, "ptr", &stringA, "int", len, "cdecl ptr")
}

curl_easy_unescape(handle, pStr, inLen := 0, ByRef outLen := 0) {
	return DllCall("libcurl\curl_easy_unescape", "ptr", handle, "ptr", pStr
		, "int", length, "uint*", outLen, "cdecl ptr")
}

curl_free(pStr) {
	DllCall("libcurl\curl_free", "ptr", pStr, "cdecl")
}

; -----------------------------------------------------

; Return: This function returns a CURLM handle.
;         If this function returns NULL, something went wrong and you cannot use the other curl functions.
curl_multi_init() {
	return DllCall("libcurl\curl_multi_init", "cdecl ptr")
}

; Return: CURLMcode type, general libcurl multi interface error code.
curl_multi_remove_handle(multi_handle, easy_handle) {
	return DllCall("libcurl\curl_multi_remove_handle", "ptr", multi_handle, "ptr", easy_handle, "cdecl")
}

; Return: CURLMcode type, general libcurl multi interface error code.
curl_multi_add_handle(multi_handle, easy_handle) {
	return DllCall("libcurl\curl_multi_add_handle", "ptr", multi_handle, "ptr", easy_handle, "cdecl")
}

; Return: CURLMcode type, general libcurl multi interface error code. On success, CURLM_OK is returned.
curl_multi_cleanup(multi_handle) {
	return DllCall("libcurl\curl_multi_cleanup", "ptr", multi_handle, "cdecl")
}

; Return: CURLMcode type, general libcurl multi interface error code.
curl_multi_perform(multi_handle, running_handles) {
	return DllCall("libcurl\curl_multi_perform", "ptr", multi_handle, "ptr", running_handles, "cdecl")
}

curl_multi_wait(multi_handle, extra_fds, extra_nfds, timeout_ms, numfds) {
	return DllCall("libcurl\curl_multi_wait", "ptr", multi_handle
	                                        , "ptr", extra_fds
	                                        , "uint", extra_nfds
	                                        , "int", timeout_ms
	                                        , "ptr", numfds
	                                        , "cdecl")
}

; msgs_in_queue - contains the number of remaining messages after this function was called.
; Return: A pointer to a filled-in CURLMsg struct, or NULL if it failed or ran out of structs.
curl_multi_info_read(multi_handle, msgs_in_queue) {
	return DllCall("libcurl\curl_multi_info_read", "ptr", multi_handle, "ptr", msgs_in_queue, "cdecl ptr")
}

; Return: The standard CURLMcode for multi interface error codes.
;         Note that it returns a CURLM_UNKNOWN_OPTION if you try setting an option that this version of libcurl doesn't know of.
curl_multi_setopt(multi_handle, opt, param) {
	if ( curl.type(param) = "string" ) {
		curl.strPutVar(param, paramA, "UTF-8")
		param := &paramA
	}
	return DllCall("libcurl\curl_multi_setopt", "ptr", multi_handle, "uint", curl.const(opt), "ptr", param, "cdecl")
}

curl_multi_socket_action(multi_handle, sockfd, ev_bitmask, running_handles) {
	return DllCall("libcurl\curl_multi_socket_action", "ptr", multi_handle
	                                                 , "int", sockfd
	                                                 , "int", ev_bitmask
	                                                 , "ptr", running_handles
	                                                 , "cdecl")
}

curl_multi_assign(multi_handle, sockfd, sockptr) {
	return DllCall("libcurl\curl_multi_assign", "ptr", multi_handle
	                                          , "int", sockfd
	                                          , "ptr", sockptr
	                                          , "cdecl")
}

; -----------------------------------------------------

class curl
{
	static hModule := DllCall("LoadLibrary", "Str", "libcurl.dll", "Ptr")

	const(str) {
		static CURL_GLOBAL_SSL              := (1<<0)
		, CURL_GLOBAL_WIN32                 := (1<<1)
		, CURL_GLOBAL_ALL                   := (CURL_GLOBAL_SSL|CURL_GLOBAL_WIN32)
		, CURL_GLOBAL_NOTHING               := 0
		, CURL_GLOBAL_DEFAULT               := CURL_GLOBAL_ALL

		, CURL_ERROR_SIZE                   := 256

		; ************[CURL_VERSION]********
		, CURLVERSION_FIRST                 := 0
		, CURLVERSION_SECOND                := 1
		, CURLVERSION_THIRD                 := 2
		, CURLVERSION_FOURTH                := 3
		, CURLVERSION_LAST                  := 4
		, CURLVERSION_NOW                   := CURLVERSION_FOURTH

		, CURL_VERSION_IPV6                 := (1<<0)  ; IPv6-enabled
		, CURL_VERSION_KERBEROS4            := (1<<1)  ; Kerberos V4 auth is supported (deprecated)
		, CURL_VERSION_SSL                  := (1<<2)  ; SSL options are present
		, CURL_VERSION_LIBZ                 := (1<<3)  ; libz features are present
		, CURL_VERSION_NTLM                 := (1<<4)  ; NTLM auth is supported
		, CURL_VERSION_GSSNEGOTIATE         := (1<<5)  ; Negotiate auth is supported (deprecated)
		, CURL_VERSION_DEBUG                := (1<<6)  ; Built with debug capabilities
		, CURL_VERSION_ASYNCHDNS            := (1<<7)  ; Asynchronous DNS resolves
		, CURL_VERSION_SPNEGO               := (1<<8)  ; SPNEGO auth is supported
		, CURL_VERSION_LARGEFILE            := (1<<9)  ; Supports files larger than 2GB
		, CURL_VERSION_IDN                  := (1<<10) ; Internationized Domain Names are supported
		, CURL_VERSION_SSPI                 := (1<<11) ; Built against Windows SSPI
		, CURL_VERSION_CONV                 := (1<<12) ; Character conversions supported
		, CURL_VERSION_CURLDEBUG            := (1<<13) ; Debug memory tracking supported
		, CURL_VERSION_TLSAUTH_SRP          := (1<<14) ; TLS-SRP auth is supported
		, CURL_VERSION_NTLM_WB              := (1<<15) ; NTLM delegation to winbind helper is suported
		, CURL_VERSION_HTTP2                := (1<<16) ; HTTP2 support built-in
		, CURL_VERSION_GSSAPI               := (1<<17) ; Built against a GSS-API library
		, CURL_VERSION_KERBEROS5            := (1<<18) ; Kerberos V5 auth is supported
		, CURL_VERSION_UNIX_SOCKETS         := (1<<19) ; Unix domain sockets support
		, CURL_VERSION_PSL                  := (1<<20) ; Mozilla's Public Suffix List, used for cookie domain verification
		, CURL_VERSION_HTTPS_PROXY          := (1<<21) ; HTTPS-proxy support built-in

		; ************[CURLFORM]************
		, CURLFORM_COPYNAME                 := 1
		, CURLFORM_PTRNAME                  := 2
		, CURLFORM_NAMELENGTH               := 3
		, CURLFORM_COPYCONTENTS             := 4
		, CURLFORM_PTRCONTENTS              := 5
		, CURLFORM_CONTENTSLENGTH           := 6
		, CURLFORM_FILECONTENT              := 7
		, CURLFORM_ARRAY                    := 8
		, CURLFORM_FILE                     := 10
		, CURLFORM_BUFFER                   := 11
		, CURLFORM_BUFFERPTR                := 12
		, CURLFORM_BUFFERLENGTH             := 13
		, CURLFORM_CONTENTTYPE              := 14
		, CURLFORM_CONTENTHEADER            := 15
		, CURLFORM_FILENAME                 := 16
		, CURLFORM_END                      := 17

		; ************[CURLOPT]*************
		, CURLOPTTYPE_LONG                  := 0
		, CURLOPTTYPE_OBJECTPOINT           := 10000
		, CURLOPTTYPE_FUNCTIONPOINT         := 20000
		, CURLOPTTYPE_OFF_T                 := 30000

		, CURLOPT_FILE                      := 10001      ; 1   + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_URL                       := 10002      ; 2   + CURLOPTTYPE_OBJECTPOINT

		, CURLOPT_WRITEDATA                 := CURLOPT_FILE
		, CURLOPT_PORT                      := 3          ; 3   + CURLOPTTYPE_LONG
		, CURLOPT_PROXY                     := 10004      ; 4   + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_USERPWD                   := 10005      ; 5   + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_PROXYUSERPWD              := 10006      ; 6   + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_RANGE                     := 10007      ; 7   + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_INFILE                    := 10009      ; 9   + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_ERRORBUFFER               := 10010      ; 10  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_WRITEFUNCTION             := 20011      ; 11  + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_READFUNCTION              := 20012      ; 12  + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_TIMEOUT                   := 13         ; 13  + CURLOPTTYPE_LONG
		, CURLOPT_INFILESIZE                := 14         ; 14  + CURLOPTTYPE_LONG
		, CURLOPT_POSTFIELDS                := 10015      ; 15  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_REFERER                   := 10016      ; 16  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_FTPPORT                   := 10017      ; 17  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_USERAGENT                 := 10018      ; 18  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_LOW_SPEED_LIMIT           := 19         ; 19  + CURLOPTTYPE_LONG
		, CURLOPT_LOW_SPEED_TIME            := 20         ; 20  + CURLOPTTYPE_LONG
		, CURLOPT_RESUME_FROM               := 21         ; 21  + CURLOPTTYPE_LONG
		, CURLOPT_COOKIE                    := 10022      ; 22  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_HTTPHEADER                := 10023      ; 23  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_HTTPPOST                  := 10024      ; 24  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSLCERT                   := 10025      ; 25  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_KEYPASSWD                 := 10026      ; 26  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_CRLF                      := 27         ; 27  + CURLOPTTYPE_LONG
		, CURLOPT_QUOTE                     := 10028      ; 28  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_WRITEHEADER               := 10029      ; 29  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_COOKIEFILE                := 10031      ; 31  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSLVERSION                := 32         ; 32  + CURLOPTTYPE_LONG
		, CURLOPT_TIMECONDITION             := 33         ; 33  + CURLOPTTYPE_LONG
		, CURLOPT_TIMEVALUE                 := 34         ; 34  + CURLOPTTYPE_LONG
		, CURLOPT_CUSTOMREQUEST             := 10036      ; 36  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_STDERR                    := 10037      ; 37  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_POSTQUOTE                 := 10039      ; 39  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_WRITEINFO                 := 10040      ; 40  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_VERBOSE                   := 41         ; 41  + CURLOPTTYPE_LONG
		, CURLOPT_HEADER                    := 42         ; 42  + CURLOPTTYPE_LONG
		, CURLOPT_NOPROGRESS                := 43         ; 43  + CURLOPTTYPE_LONG
		, CURLOPT_NOBODY                    := 44         ; 44  + CURLOPTTYPE_LONG
		, CURLOPT_FAILONERROR               := 45         ; 45  + CURLOPTTYPE_LONG
		, CURLOPT_UPLOAD                    := 46         ; 46  + CURLOPTTYPE_LONG
		, CURLOPT_POST                      := 47         ; 47  + CURLOPTTYPE_LONG
		, CURLOPT_DIRLISTONLY               := 48         ; 48  + CURLOPTTYPE_LONG
		, CURLOPT_APPEND                    := 50         ; 50  + CURLOPTTYPE_LONG
		, CURLOPT_NETRC                     := 51         ; 51  + CURLOPTTYPE_LONG
		, CURLOPT_FOLLOWLOCATION            := 52         ; 52  + CURLOPTTYPE_LONG
		, CURLOPT_TRANSFERTEXT              := 53         ; 53  + CURLOPTTYPE_LONG
		, CURLOPT_PUT                       := 54         ; 54  + CURLOPTTYPE_LONG
		, CURLOPT_PROGRESSFUNCTION          := 20056      ; 56  + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_PROGRESSDATA              := 10057      ; 57  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_AUTOREFERER               := 58         ; 58  + CURLOPTTYPE_LONG
		, CURLOPT_PROXYPORT                 := 59         ; 59  + CURLOPTTYPE_LONG
		, CURLOPT_POSTFIELDSIZE             := 60         ; 60  + CURLOPTTYPE_LONG
		, CURLOPT_HTTPPROXYTUNNEL           := 61         ; 61  + CURLOPTTYPE_LONG
		, CURLOPT_INTERFACE                 := 10062      ; 62  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_KRBLEVEL                  := 10063      ; 63  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSL_VERIFYPEER            := 64         ; 64  + CURLOPTTYPE_LONG
		, CURLOPT_CAINFO                    := 10065      ; 65  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_MAXREDIRS                 := 68         ; 68  + CURLOPTTYPE_LONG
		, CURLOPT_FILETIME                  := 69         ; 69  + CURLOPTTYPE_LONG
		, CURLOPT_TELNETOPTIONS             := 10070      ; 70  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_MAXCONNECTS               := 71         ; 71  + CURLOPTTYPE_LONG
		, CURLOPT_CLOSEPOLICY               := 72         ; 72  + CURLOPTTYPE_LONG
		, CURLOPT_FRESH_CONNECT             := 74         ; 74  + CURLOPTTYPE_LONG
		, CURLOPT_FORBID_REUSE              := 75         ; 75  + CURLOPTTYPE_LONG
		, CURLOPT_RANDOM_FILE               := 10076      ; 76  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_EGDSOCKET                 := 10077      ; 77  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_CONNECTTIMEOUT            := 78         ; 78  + CURLOPTTYPE_LONG
		, CURLOPT_HEADERFUNCTION            := 20079      ; 79  + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_HTTPGET                   := 80         ; 80  + CURLOPTTYPE_LONG
		, CURLOPT_SSL_VERIFYHOST            := 81         ; 81  + CURLOPTTYPE_LONG
		, CURLOPT_COOKIEJAR                 := 10082      ; 82  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSL_CIPHER_LIST           := 10083      ; 83  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_HTTP_VERSION              := 84         ; 84  + CURLOPTTYPE_LONG
		, CURLOPT_FTP_USE_EPSV              := 85         ; 85  + CURLOPTTYPE_LONG
		, CURLOPT_SSLCERTTYPE               := 10086      ; 86  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSLKEY                    := 10087      ; 87  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSLKEYTYPE                := 10088      ; 88  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSLENGINE                 := 10089      ; 89  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSLENGINE_DEFAULT         := 90         ; 90  + CURLOPTTYPE_LONG
		, CURLOPT_DNS_USE_GLOBAL_CACHE      := 91         ; 91  + CURLOPTTYPE_LONG
		, CURLOPT_DNS_CACHE_TIMEOUT         := 92         ; 92  + CURLOPTTYPE_LONG
		, CURLOPT_PREQUOTE                  := 10093      ; 93  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_DEBUGFUNCTION             := 20094      ; 94  + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_DEBUGDATA                 := 10095      ; 95  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_COOKIESESSION             := 96         ; 96  + CURLOPTTYPE_LONG
		, CURLOPT_CAPATH                    := 10097      ; 97  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_BUFFERSIZE                := 98         ; 98  + CURLOPTTYPE_LONG
		, CURLOPT_NOSIGNAL                  := 99         ; 99  + CURLOPTTYPE_LONG
		, CURLOPT_SHARE                     := 10100      ; 100 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_PROXYTYPE                 := 101        ; 101 + CURLOPTTYPE_LONG
		, CURLOPT_ENCODING                  := 10102      ; 102 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_PRIVATE                   := 10103      ; 103 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_HTTP200ALIASES            := 10104      ; 104 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_UNRESTRICTED_AUTH         := 105        ; 105 + CURLOPTTYPE_LONG
		, CURLOPT_FTP_USE_EPRT              := 106        ; 106 + CURLOPTTYPE_LONG
		, CURLOPT_HTTPAUTH                  := 107        ; 107 + CURLOPTTYPE_LONG
		, CURLOPT_SSL_CTX_FUNCTION          := 20108      ; 108 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_SSL_CTX_DATA              := 10109      ; 109 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_FTP_CREATE_MISSING_DIRS   := 110        ; 110 + CURLOPTTYPE_LONG
		, CURLOPT_PROXYAUTH                 := 111        ; 111 + CURLOPTTYPE_LONG
		, CURLOPT_FTP_RESPONSE_TIMEOUT      := 112        ; 112 + CURLOPTTYPE_LONG
		, CURLOPT_IPRESOLVE                 := 113        ; 113 + CURLOPTTYPE_LONG
		, CURLOPT_MAXFILESIZE               := 114        ; 114 + CURLOPTTYPE_LONG
		, CURLOPT_INFILESIZE_LARGE          := 30115      ; 115 + CURLOPTTYPE_OFF_T
		, CURLOPT_RESUME_FROM_LARGE         := 30116      ; 116 + CURLOPTTYPE_OFF_T
		, CURLOPT_MAXFILESIZE_LARGE         := 30117      ; 117 + CURLOPTTYPE_OFF_T
		, CURLOPT_NETRC_FILE                := 10118      ; 118 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_USE_SSL                   := 119        ; 119 + CURLOPTTYPE_LONG
		, CURLOPT_POSTFIELDSIZE_LARGE       := 30120      ; 120 + CURLOPTTYPE_OFF_T
		, CURLOPT_TCP_NODELAY               := 121        ; 121 + CURLOPTTYPE_LONG
		, CURLOPT_FTPSSLAUTH                := 129        ; 129 + CURLOPTTYPE_LONG
		, CURLOPT_IOCTLFUNCTION             := 20130      ; 130 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_IOCTLDATA                 := 10131      ; 131 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_FTP_ACCOUNT               := 10134      ; 134 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_COOKIELIST                := 10135      ; 135 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_IGNORE_CONTENT_LENGTH     := 136        ; 136 + CURLOPTTYPE_LONG
		, CURLOPT_FTP_SKIP_PASV_IP          := 137        ; 137 + CURLOPTTYPE_LONG
		, CURLOPT_FTP_FILEMETHOD            := 138        ; 138 + CURLOPTTYPE_LONG
		, CURLOPT_LOCALPORT                 := 139        ; 139 + CURLOPTTYPE_LONG
		, CURLOPT_LOCALPORTRANGE            := 140        ; 140 + CURLOPTTYPE_LONG
		, CURLOPT_CONNECT_ONLY              := 141        ; 141 + CURLOPTTYPE_LONG
		, CURLOPT_CONV_FROM_NETWORK_FUNCTION:= 20142      ; 142 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_CONV_TO_NETWORK_FUNCTION  := 20143      ; 143 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_CONV_FROM_UTF8_FUNCTION   := 20144      ; 144 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_MAX_SEND_SPEED_LARGE      := 30145      ; 145 + CURLOPTTYPE_OFF_T
		, CURLOPT_MAX_RECV_SPEED_LARGE      := 30146      ; 146 + CURLOPTTYPE_OFF_T
		, CURLOPT_FTP_ALTERNATIVE_TO_USER   := 10147      ; 147 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SOCKOPTFUNCTION           := 20148      ; 148 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_SOCKOPTDATA               := 10149      ; 149 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSL_SESSIONID_CACHE       := 150        ; 150 + CURLOPTTYPE_LONG
		, CURLOPT_SSH_AUTH_TYPES            := 151        ; 151 + CURLOPTTYPE_LONG
		, CURLOPT_SSH_PUBLIC_KEYFILE        := 10152      ; 152 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_SSH_PRIVATE_KEYFILE       := 10153      ; 153 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_FTP_SSL_CCC               := 154        ; 154 + CURLOPTTYPE_LONG
		, CURLOPT_TIMEOUT_MS                := 155        ; 155 + CURLOPTTYPE_LONG
		, CURLOPT_CONNECTTIMEOUT_MS         := 156        ; 156 + CURLOPTTYPE_LONG
		, CURLOPT_HTTP_TRANSFER_DECODING    := 157        ; 157 + CURLOPTTYPE_LONG
		, CURLOPT_HTTP_CONTENT_DECODING     := 158        ; 158 + CURLOPTTYPE_LONG
		, CURLOPT_NEW_FILE_PERMS            := 159        ; 159 + CURLOPTTYPE_LONG
		, CURLOPT_NEW_DIRECTORY_PERMS       := 160        ; 160 + CURLOPTTYPE_LONG
		, CURLOPT_POST301                   := 161        ; 161 + CURLOPTTYPE_LONG
		, CURLOPT_SSH_HOST_PUBLIC_KEY_MD5   := 10162      ; 162 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_OPENSOCKETFUNCTION        := 20163      ; 163 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_OPENSOCKETDATA            := 10164      ; 164 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_COPYPOSTFIELDS            := 10165      ; 165 + CURLOPTTYPE_OBJECTPOINT

		, CURLOPT_XFERINFOFUNCTION          := 20219      ; 219 + CURLOPTTYPE_FUNCTIONPOINT
		, CURLOPT_XFERINFODATA              := 10057      ; 57  + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_ACCEPT_ENCODING           := 10102      ; 102 + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_READDATA                  := 10009      ; 9   + CURLOPTTYPE_OBJECTPOINT
		, CURLOPT_HEADERDATA                := 10029      ; 29  + CURLOPTTYPE_OBJECTPOINT

		; ************[CURLINFO]************
		, CURLINFO_STRING                   := 0x100000
		, CURLINFO_LONG                     := 0x200000
		, CURLINFO_DOUBLE                   := 0x300000
		, CURLINFO_SLIST                    := 0x400000

		, CURLINFO_EFFECTIVE_URL            := 1048577    ; CURLINFO_STRING + 1
		, CURLINFO_RESPONSE_CODE            := 2097154    ; CURLINFO_LONG   + 2
		, CURLINFO_TOTAL_TIME               := 3145731    ; CURLINFO_DOUBLE + 3
		, CURLINFO_NAMELOOKUP_TIME          := 3145732    ; CURLINFO_DOUBLE + 4
		, CURLINFO_CONNECT_TIME             := 3145733    ; CURLINFO_DOUBLE + 5
		, CURLINFO_PRETRANSFER_TIME         := 3145734    ; CURLINFO_DOUBLE + 6
		, CURLINFO_SIZE_UPLOAD              := 3145735    ; CURLINFO_DOUBLE + 7
		, CURLINFO_SIZE_DOWNLOAD            := 3145736    ; CURLINFO_DOUBLE + 8
		, CURLINFO_SPEED_DOWNLOAD           := 3145737    ; CURLINFO_DOUBLE + 9
		, CURLINFO_SPEED_UPLOAD             := 3145738    ; CURLINFO_DOUBLE + 10
		, CURLINFO_HEADER_SIZE              := 2097163    ; CURLINFO_LONG  + 11
		, CURLINFO_REQUEST_SIZE             := 2097164    ; CURLINFO_LONG  + 12
		, CURLINFO_SSL_VERIFYRESULT         := 2097165    ; CURLINFO_LONG  + 13
		, CURLINFO_FILETIME                 := 2097166    ; CURLINFO_LONG  + 14
		, CURLINFO_CONTENT_LENGTH_DOWNLOAD  := 3145743    ; CURLINFO_DOUBLE + 15
		, CURLINFO_CONTENT_LENGTH_UPLOAD    := 3145744    ; CURLINFO_DOUBLE + 16
		, CURLINFO_STARTTRANSFER_TIME       := 3145745    ; CURLINFO_DOUBLE + 17
		, CURLINFO_CONTENT_TYPE             := 1048594    ; CURLINFO_STRING + 18
		, CURLINFO_REDIRECT_TIME            := 3145747    ; CURLINFO_DOUBLE + 19
		, CURLINFO_REDIRECT_COUNT           := 2097172    ; CURLINFO_LONG   + 20
		, CURLINFO_PRIVATE                  := 1048597    ; CURLINFO_STRING + 21
		, CURLINFO_HTTP_CONNECTCODE         := 2097174    ; CURLINFO_LONG   + 22
		, CURLINFO_HTTPAUTH_AVAIL           := 2097175    ; CURLINFO_LONG   + 23
		, CURLINFO_PROXYAUTH_AVAIL          := 2097176    ; CURLINFO_LONG   + 24
		, CURLINFO_OS_ERRNO                 := 2097177    ; CURLINFO_LONG   + 25
		, CURLINFO_NUM_CONNECTS             := 2097178    ; CURLINFO_LONG   + 26
		, CURLINFO_SSL_ENGINES              := 4194331    ; CURLINFO_SLIST  + 27
		, CURLINFO_COOKIELIST               := 4194332    ; CURLINFO_SLIST  + 28
		, CURLINFO_LASTSOCKET               := 2097181    ; CURLINFO_LONG   + 29
		, CURLINFO_FTP_ENTRY_PATH           := 1048606    ; CURLINFO_STRING + 30

		, CURLINFO_REDIRECT_URL             := 1048607    ; CURLINFO_STRING + 31


		; ************[CURLPAUSE]***********
		, CURLPAUSE_RECV                    := (1<<0)
		, CURLPAUSE_RECV_CONT               := (0)
		, CURLPAUSE_SEND                    := (1<<2)
		, CURLPAUSE_SEND_CONT               := (0)
		, CURLPAUSE_ALL                     := (CURLPAUSE_RECV | CURLPAUSE_SEND)
		, CURLPAUSE_CONT                    := (CURLPAUSE_RECV_CONT | CURLPAUSE_SEND_CONT)
		, CURL_READFUNC_PAUSE               := 0x10000001
		, CURL_WRITEFUNC_PAUSE              := 0x10000001

		; ************[CURLE]***************
		, CURLE_OK                          := 0
		, CURLE_UNSUPPORTED_PROTOCOL        := 1
		, CURLE_FAILED_INIT                 := 2
		, CURLE_URL_MALFORMAT               := 3
		, CURLE_OBSOLETE4                   := 4          ; NOT USED
		, CURLE_COULDNT_RESOLVE_PROXY       := 5
		, CURLE_COULDNT_RESOLVE_HOST        := 6
		, CURLE_COULDNT_CONNECT             := 7
		, CURLE_FTP_WEIRD_SERVER_REPLY      := 8
		, CURLE_REMOTE_ACCESS_DENIED        := 9          ; A service was denied by the server
		                                                ; due to lack of access - when login fails
		                                                ; this is not returned.     
		, CURLE_OBSOLETE10                  := 10         ; NOT USED
		, CURLE_FTP_WEIRD_PASS_REPLY        := 11
		, CURLE_OBSOLETE12                  := 12         ; NOT USED
		, CURLE_FTP_WEIRD_PASV_REPLY        := 13
		, CURLE_FTP_WEIRD_227_FORMAT        := 14
		, CURLE_FTP_CANT_GET_HOST           := 15
		, CURLE_OBSOLETE16                  := 16         ; NOT USED
		, CURLE_FTP_COULDNT_SET_TYPE        := 17
		, CURLE_PARTIAL_FILE                := 18
		, CURLE_FTP_COULDNT_RETR_FILE       := 19
		, CURLE_OBSOLETE20                  := 20         ; NOT USED
		, CURLE_QUOTE_ERROR                 := 21         ; quote command failure
		, CURLE_HTTP_RETURNED_ERROR         := 22
		, CURLE_WRITE_ERROR                 := 23
		, CURLE_OBSOLETE24                  := 24         ; NOT USED
		, CURLE_UPLOAD_FAILED               := 25         ; failed upload "command"
		, CURLE_READ_ERROR                  := 26         ; couldn't open/read from file
		, CURLE_OUT_OF_MEMORY               := 27         ; Note: CURLE_OUT_OF_MEMORY may 
		                                                ; sometimes indicate a conversion error
		                                                ; instead of a memory allocation error
		                                                ; if CURL_DOES_CONVERSIONS is defined
		, CURLE_OPERATION_TIMEDOUT          := 28         ; the timeout time was reached
		, CURLE_OBSOLETE29                  := 29         ; NOT USED
		, CURLE_FTP_PORT_FAILED             := 30         ; FTP PORT operation failed
		, CURLE_FTP_COULDNT_USE_REST        := 31         ; the REST command failed 
		, CURLE_OBSOLETE32                  := 32         ; NOT USED 
		, CURLE_RANGE_ERROR                 := 33         ; RANGE "command" didn't work 
		, CURLE_HTTP_POST_ERROR             := 34 
		, CURLE_SSL_CONNECT_ERROR           := 35         ; wrong when connecting with SSL 
		, CURLE_BAD_DOWNLOAD_RESUME         := 36         ; couldn't resume download 
		, CURLE_FILE_COULDNT_READ_FILE      := 37 
		, CURLE_LDAP_CANNOT_BIND            := 38 
		, CURLE_LDAP_SEARCH_FAILED          := 39 
		, CURLE_OBSOLETE40                  := 40         ; NOT USED 
		, CURLE_FUNCTION_NOT_FOUND          := 41 
		, CURLE_ABORTED_BY_CALLBACK         := 42 
		, CURLE_BAD_FUNCTION_ARGUMENT       := 43 
		, CURLE_OBSOLETE44                  := 44         ; NOT USED 
		, CURLE_INTERFACE_FAILED            := 45         ; CURLOPT_INTERFACE failed 
		, CURLE_OBSOLETE46                  := 46         ; NOT USED 
		, CURLE_TOO_MANY_REDIRECTS          := 47         ; catch endless redirect loops 
		, CURLE_UNKNOWN_TELNET_OPTION       := 48         ; User specified an unknown option 
		, CURLE_TELNET_OPTION_SYNTAX        := 49         ; Malformed telnet option 
		, CURLE_OBSOLETE50                  := 50         ; NOT USED 
		, CURLE_PEER_FAILED_VERIFICATION    := 51         ; peer's certificate or fingerprint wasn't verified correctly
		, CURLE_GOT_NOTHING                 := 52         ; when this is a specific error 
		, CURLE_SSL_ENGINE_NOTFOUND         := 53         ; SSL crypto engine not found 
		, CURLE_SSL_ENGINE_SETFAILED        := 54         ; can not set SSL crypto engine as
		                                                ; default 
		, CURLE_SEND_ERROR                  := 55         ; failed sending network data 
		, CURLE_RECV_ERROR                  := 56         ; failure in receiving network data 
		, CURLE_OBSOLETE57                  := 57         ; NOT IN USE 
		, CURLE_SSL_CERTPROBLEM             := 58         ; problem with the local certificate 
		, CURLE_SSL_CIPHER                  := 59         ; couldn't use specified cipher 
		, CURLE_SSL_CACERT                  := 60         ; problem with the CA cert (path?) 
		, CURLE_BAD_CONTENT_ENCODING        := 61         ; Unrecognized transfer encoding 
		, CURLE_LDAP_INVALID_URL            := 62         ; Invalid LDAP URL 
		, CURLE_FILESIZE_EXCEEDED           := 63         ; Maximum file size exceeded 
		, CURLE_USE_SSL_FAILED              := 64         ; Requested FTP SSL level failed 
		, CURLE_SEND_FAIL_REWIND            := 65         ; Sending the data requires a rewind
		                                                ; that failed 
		, CURLE_SSL_ENGINE_INITFAILED       := 66         ; failed to initialise ENGINE 
		, CURLE_LOGIN_DENIED                := 67         ; user, password or similar was not
		                                                ; accepted and we failed to login 
		, CURLE_TFTP_NOTFOUND               := 68         ; file not found on server 
		, CURLE_TFTP_PERM                   := 69         ; permission problem on server 
		, CURLE_REMOTE_DISK_FULL            := 70         ; out of disk space on server 
		, CURLE_TFTP_ILLEGAL                := 71         ; Illegal TFTP operation 
		, CURLE_TFTP_UNKNOWNID              := 72         ; Unknown transfer ID 
		, CURLE_REMOTE_FILE_EXISTS          := 73         ; File already exists 
		, CURLE_TFTP_NOSUCHUSER             := 74         ; No such user 
		, CURLE_CONV_FAILED                 := 75         ; conversion failed 
		, CURLE_CONV_REQD                   := 76         ; caller must register conversion
		                                                ; callbacks using curl_easy_setopt options
		                                                ; CURLOPT_CONV_FROM_NETWORK_FUNCTION,
		                                                ; CURLOPT_CONV_TO_NETWORK_FUNCTION, and
		                                                ; CURLOPT_CONV_FROM_UTF8_FUNCTION
		, CURLE_SSL_CACERT_BADFILE          := 77         ; could not load CACERT file, missing or wrong format 
		, CURLE_REMOTE_FILE_NOT_FOUND       := 78         ; remote file not found 
		, CURLE_SSH                         := 79         ; error from the SSH layer, somewhat
		                                                ; generic so the error message will be of
		                                                ; interest when this has happened 
		, CURLE_SSL_SHUTDOWN_FAILED         := 80         ; Failed to shut down the SSL connection 
		, CURLE_AGAIN                       := 81         ; socket is not ready for send/recv,
		                                                ; wait till it's ready and try again (Added in 7.18.2) 
		, CURLE_SSL_CRL_BADFILE             := 82         ; could not load CRL file, 
		                                                ; missing or wrong format (Added in 7.19.0)
		, CURLE_SSL_ISSUER_ERROR            := 83         ; Issuer check failed.  (Added in 7.19.0) 
		, CURLE_FTP_PRET_FAILED             := 84         ; a PRET command failed 
		, CURLE_RTSP_CSEQ_ERROR             := 85         ; mismatch of RTSP CSeq numbers 
		, CURLE_RTSP_SESSION_ERROR          := 86         ; mismatch of RTSP Session Identifiers 
		, CURLE_FTP_BAD_FILE_LIST           := 87         ; unable to parse FTP file list 
		, CURLE_CHUNK_FAILED                := 88     

		; ************[CURLM]***************
		, CURLM_CALL_MULTI_PERFORM          := -1       ; please call curl_multi_perform() or curl_multi_socket*() soon
		, CURLM_OK                          := 0
		, CURLM_BAD_HANDLE                  := 1        ; the passed-in handle is not a valid CURLM handle
		, CURLM_BAD_EASY_HANDLE             := 2        ; an easy handle was not good/valid
		, CURLM_OUT_OF_MEMORY               := 3        ; if you ever get this, you're in deep sh*t
		, CURLM_INTERNAL_ERROR              := 4        ; this is a libcurl bug
		, CURLM_BAD_SOCKET                  := 5        ; the passed in socket argument did not match
		, CURLM_UNKNOWN_OPTION              := 6        ; curl_multi_setopt() with unsupported option
		, CURLM_ADDED_ALREADY               := 7        ; an easy handle already added to a multi handle was attempted to get added - again

		; ************[CURLMSG]***************
		, CURLMSG_DONE                      := 1        ; This easy handle has completed. 'result' contains the CURLcode of the transfer

		, CURL_POLL_NONE   := 0
		, CURL_POLL_IN     := 1
		, CURL_POLL_OUT    := 2
		, CURL_POLL_INOUT  := 3
		, CURL_POLL_REMOVE := 4


		if (str != "") {
			if (%str% = "") {
				throw, (str) " is not defined."
			}
			return (%str%)
		}
	}

	; From /docs/commands/StrPutGet.htm
	strPutVar(string, ByRef var, encoding) {
		; Ensure capacity.
		VarSetCapacity( var, StrPut(string, encoding)
			; StrPut returns char count, but VarSetCapacity needs bytes.
			* ((encoding="utf-16"||encoding="cp1200") ? 2 : 1) )
		; Copy or convert the string.
		return StrPut(string, &var, encoding)
	}

	; https://autohotkey.com/boards/viewtopic.php?t=2306
	; Object version - depends on current float format including a decimal point.
	type(v) {
	    if IsObject(v)
	        return "Object"
	    return v="" || [v].GetCapacity(1) ? "String" : InStr(v,".") ? "Float" : "Integer"
	}

	; Parse struct returned by curl_version_info()
	parse_vinfo(pInfo) {
		info := {}, offset := 0

		;-------------------------------------------------------------------------------------------
		info.age := NumGet(pInfo+0, offset, "int")

		if (info.age >= 0) {
			info.version         := StrGet( NumGet(pInfo+0, offset+=A_PtrSize, "uptr"), "UTF-8" )
			info.version_num     :=         NumGet(pInfo+0, offset+=A_PtrSize, "uint")
			info.host            := StrGet( NumGet(pInfo+0, offset+=A_PtrSize, "uptr"), "UTF-8" )
			info.features        :=         NumGet(pInfo+0, offset+=A_PtrSize, "int")
			info.ssl_version     := StrGet( NumGet(pInfo+0, offset+=A_PtrSize, "uptr"), "UTF-8" )
			info.ssl_version_num :=         NumGet(pInfo+0, offset+=A_PtrSize, "int")
			info.libz_version    := StrGet( NumGet(pInfo+0, offset+=A_PtrSize, "uptr"), "UTF-8" )
			info.protocols       :=         NumGet(pInfo+0, offset+=A_PtrSize, "uptr")
		}
		if (info.age >= 1) {
			info.ares            := StrGet( NumGet(pInfo+0, offset+=A_PtrSize, "uptr"), "UTF-8" )
			info.ares_num        :=         NumGet(pInfo+0, offset+=A_PtrSize, "int")
		}
		if (info.age >= 2) {
			info.libidn          := StrGet( NumGet(pInfo+0, offset+=A_PtrSize, "uptr"), "UTF-8" )
		}
		if (info.age >= 3) {
			info.iconv_ver_num   :=         NumGet(pInfo+0, offset+=A_PtrSize, "int")
		}

		info.libssh_version      := StrGet( NumGet(pInfo+0, offset+=A_PtrSize, "uptr"), "UTF-8" )
		;-------------------------------------------------------------------------------------------
		if info.features {
			names := [ "AsynchDNS", "CONV", "CURLDebug", "debug", "GSSAPI", "GSSNegotiate", "HTTP2", "HTTPS_PROXY", "IDN", "IPv6", "Kerberos4"
                     , "Kerberos5", "LargeFile", "libz", "NTLM", "NTLM_WB", "PSL", "SPNEGO", "SSL", "SSPI", "TLSAUTH_SRP", "Unix_Sockets" ]
			for i, name in names {
				if ( info.features & this.const("CURL_VERSION_" name) )
					features_str .= name . " "
			}
			info.features := Trim(features_str)
		}

		if info.protocols {
			Loop {
				addr := info.protocols + (A_Index-1)*A_PtrSize
			    if s := StrGet( NumGet(addr+0, "uptr"), "UTF-8" )
					protocols_str .= s . " "
			} Until (s = "")
			info.protocols := Trim(protocols_str)
		}
		;-------------------------------------------------------------------------------------------
		return "libcurl " . info.version . " (" . info.host . ") " . info.ssl_version . (info.libz_version ? " zlib/" info.libz_version : "") . "`n`n"
		     . "Protocols: " . info.protocols . "`n`n"
		     . "Features: "  . info.features
	}
}


