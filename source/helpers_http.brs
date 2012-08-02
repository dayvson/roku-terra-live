'******************************************************************************
'** Copyright (c) 2012 - Maxwell Dayvson <dayvson@gmail.com>
'** Copyright (c) 2012 - Marco Lovato <maglovato@gmail.com>
'** All rights reserved.
'**
'** Redistribution and use in source and binary forms, with or without
'** modification, are permitted provided that the following conditions
'** are met:
'** 1. Redistributions of source code must retain the above copyright
'**    notice, this list of conditions and the following disclaimer.
'** 2. Redistributions in binary form must reproduce the above copyright
'**    notice, this list of conditions and the following disclaimer in the
'**    documentation and/or other materials provided with the distribution.
'** 3. Neither the name of the University nor the names of its contributors
'**    may be used to endorse or promote products derived from this software
'**    without specific prior written permission.
'**
'** THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
'** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
'** IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
'** ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
'** FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
'** DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
'** OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
'** HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
'** LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
'** OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
'** SUCH DAMAGE.
'******************************************************************************

Function CreateURLTransferObject(url As String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
    obj.AddHeader("Content-Type", "application/x-www-form-urlencoded")
    obj.EnableEncodings(true)
    return obj
End Function

Function NewHttp(url As String) as Object
    obj = CreateObject("roAssociativeArray")
    obj.Http                        = CreateURLTransferObject(url)
    obj.FirstParam                  = true
    obj.AddParam                    = http_add_param
    obj.AddRawQuery                 = http_add_raw_query
    obj.GetToStringWithRetry        = http_get_to_string_with_retry
    obj.PrepareUrlForQuery          = http_prepare_url_for_query
    obj.GetToStringWithTimeout      = http_get_to_string_with_timeout
    obj.PostFromStringWithTimeout   = http_post_from_string_with_timeout
    if Instr(1, url, "?") > 0 then obj.FirstParam = false
    return obj
End Function

Function CreateURLTransferObject2(url As String, contentHeader As String) as Object
    obj = CreateObject("roUrlTransfer")
    obj.SetPort(CreateObject("roMessagePort"))
    obj.SetUrl(url)
	  obj.AddHeader("Content-Type", contentHeader)
    obj.EnableEncodings(true)
    return obj
End Function

Function NewHttp2(url As String, contentHeader As String) as Object
    obj = CreateObject("roAssociativeArray")
    obj.Http                        = CreateURLTransferObject2(url, contentHeader)
    obj.FirstParam                  = true
    obj.AddParam                    = http_add_param
    obj.AddRawQuery                 = http_add_raw_query
    obj.GetToStringWithRetry        = http_get_to_string_with_retry
    obj.PrepareUrlForQuery          = http_prepare_url_for_query
    obj.GetToStringWithTimeout      = http_get_to_string_with_timeout
    obj.PostFromStringWithTimeout   = http_post_from_string_with_timeout
    if Instr(1, url, "?") > 0 then obj.FirstParam = false
    return obj
End Function

Function HttpEncode(str As String) As String
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
End Function

Function http_prepare_url_for_query() As String
    url = m.Http.GetUrl()
    if m.FirstParam then
        url = url + "?"
        m.FirstParam = false
    else
        url = url + "&"
    endif
    m.Http.SetUrl(url)
    return url
End Function

Function http_add_param(name As String, val As String) as Void
    q = m.Http.Escape(name)
    q = q + "="
    url = m.Http.GetUrl()
    if Instr(1, url, q) > 0 return    'Parameter already present
    q = q + m.Http.Escape(val)
    m.AddRawQuery(q)
End Function

Function http_add_raw_query(query As String) as Void
    url = m.PrepareUrlForQuery()
    url = url + query
    m.Http.SetUrl(url)
End Function

Function http_get_to_string_with_retry() as String
    timeout%         = 1500
    num_retries%     = 5
    str = ""
    while num_retries% > 0
        if (m.Http.AsyncGetToString())
            event = wait(timeout%, m.Http.GetPort())
            if type(event) = "roUrlEvent"
                str = event.GetString()
                exit while
            elseif event = invalid
                m.Http.AsyncCancel()
                m.Http = CreateURLTransferObject(m.Http.GetUrl())
                timeout% = 2 * timeout%
            else
                print "roUrlTransfer::AsyncGetToString(): unknown event"
            endif
        endif
        num_retries% = num_retries% - 1
    end while
    return str
End Function

Function http_get_to_string_with_timeout(seconds as Integer) as String
    timeout% = 1000 * seconds
    str = ""
    m.Http.EnableFreshConnection(true) 'Don't reuse existing connections
    if (m.Http.AsyncGetToString())
        event = wait(timeout%, m.Http.GetPort())
        if type(event) = "roUrlEvent"
            str = event.GetString()
        elseif event = invalid
            print "AsyncGetToString timeout"
            m.Http.AsyncCancel()
        else
            print "AsyncGetToString unknown event"
        endif
    endif

    return str
End Function

Function http_post_from_string_with_timeout(val As String, seconds as Integer) as String
    timeout% = 1000 * seconds
    str = ""
    if (m.Http.AsyncPostFromString(val))
        event = wait(timeout%, m.Http.GetPort())
        if type(event) = "roUrlEvent"
			      print "roUrlEvent"
			      str = event.GetString()
        elseif event = invalid
			      print "AsyncPostFromString timeout"
            m.Http.AsyncCancel()
        else
			      print "AsyncPostFromString unknown event"
        endif
    endif
    return str
End Function
