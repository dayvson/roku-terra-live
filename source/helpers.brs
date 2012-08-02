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


Function RegRead(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    if sec.Exists(key) then return sec.Read(key)
    return invalid
End Function

Function RegWrite(key, val, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Write(key, val)
    sec.Flush() 'commit it
End Function

Function RegDelete(key, section=invalid)
    if section = invalid then section = "Default"
    sec = CreateObject("roRegistrySection", section)
    sec.Delete(key)
    sec.Flush()
End Function

Function tostr(any)
    ret = AnyToString(any)
    if ret = invalid ret = type(any)
    if ret = invalid ret = "unknown" 'failsafe
    return ret
End Function

Function islist(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifArray") = invalid return false
    return true
End Function

Function isint(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifInt") = invalid return false
    return true
End Function

Function isnonemptystr(obj)
    if isnullorempty(obj) return false
    return true
End Function

Function isnullorempty(obj)
    if obj = invalid return true
    if not isstr(obj) return true
    if Len(obj) = 0 return true
    return false
End Function

Function validstr(obj As Dynamic) As String
    if isnonemptystr(obj) return obj
    return ""
End Function

Function isstr(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifString") = invalid return false
    return true
End Function

Function isbool(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifBoolean") = invalid return false
    return true
End Function

Function isfloat(obj as dynamic) As Boolean
    if obj = invalid return false
    if GetInterface(obj, "ifFloat") = invalid return false
    return true
End Function

'Convert int to string. This is necessary because the builtin Stri(x) prepends whitespace
Function itostr(i As Integer) As String
    str = Stri(i)
    return strTrim(str)
End Function

Function strTrim(str As String) As String
    st=CreateObject("roString")
    st.SetString(str)
    return st.Trim()
End Function

Function strReplace(basestr As String, oldsub As String, newsub As String) As String
    newstr = ""
    i = 1
    while i <= Len(basestr)
        x = Instr(i, basestr, oldsub)
        if x = 0 then
            newstr = newstr + Mid(basestr, i)
            exit while
        endif
        if x > i then
            newstr = newstr + Mid(basestr, i, x-i)
            i = x
        endif
        newstr = newstr + newsub
        i = i + Len(oldsub)
    end while
    return newstr
End Function

Function GetXMLElementsByName(xml As Object, name As String) As Object
    list = CreateObject("roArray", 100, true)
    if islist(xml.GetBody()) = false return list

    for each e in xml.GetBody()
        if e.GetName() = name then
            list.Push(e)
        endif
    next

    return list
End Function

Function GetFirstXMLElementByName(xml As Object, name As String) As dynamic
    if islist(xml.GetBody()) = false return invalid
    for each e in xml.GetBody()
        if e.GetName() = name return e
    next
    return invalid
End Function

Function ParseXML(str As String) As dynamic
    if str = invalid return invalid
    xml=CreateObject("roXMLElement")
    if not xml.Parse(str) return invalid
    return xml
End Function

'Walk a list and print it
Sub PrintList(list as Object)
    print "---- list ----"
    PrintAnyList(0, list)
    print "--------------"
End Sub

'Print an associativearray
Sub PrintAnyAA(depth As Integer, aa as Object)
    for each e in aa
        x = aa[e]
        PrintAny(depth, e + ": ", aa[e])
    next
End Sub

Sub PrintAnyList(depth As Integer, list as Object)
    i = 0
    for each e in list
        PrintAny(depth, "List(" + itostr(i) + ")= ", e)
        i = i + 1
    next
End Sub

Sub PrintAny(depth As Integer, prefix As String, any As Dynamic)
    if depth >= 10
        print "**** TOO DEEP " + itostr(5)
        return
    endif
    prefix = string(depth*2," ") + prefix
    depth = depth + 1
    str = AnyToString(any)
    if str <> invalid
        print prefix + str
        return
    endif
    if type(any) = "roAssociativeArray"
        print prefix + "(assocarr)..."
        PrintAnyAA(depth, any)
        return
    endif
    if islist(any) = true
        print prefix + "(list of " + itostr(any.Count()) + ")..."
        PrintAnyList(depth, any)
        return
    endif
    print prefix + "?" + type(any) + "?"
End Sub

Function AnyToString(any As Dynamic) As dynamic
    if any = invalid return "invalid"
    if isstr(any) return any
    if isint(any) return itostr(any)
    if isbool(any)
        if any = true return "true"
        return "false"
    endif
    if isfloat(any) return Str(any)
    if type(any) = "roTimespan" return itostr(any.TotalMilliseconds()) + "ms"
    return invalid
End Function