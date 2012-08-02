'******************************************************************************
'** Copyright (c) 2012 - Maxwell Dayvson <dayvson@gmail.com>
'** Copyright (c) 2012 - Marco Lovato <maglovato@gmail.com>
'** All rights reserved.
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

Function LoadContentAPI() As Object
    conn = CreateObject("roAssociativeArray")
    conn.urlAPI  = "http://p1.trrsf.com.br/contentAPI/get?prd=live_guadalajara&srv=getListTickerElements&navigation_code=home&country_code=br&contentType=xml&status=2&eventType=1"
    conn.Timer = CreateObject("roTimespan")
    conn.LoadAPI    = load_api
    conn.ParseAPI   = parse_api
    print "created api connection for " + conn.urlAPI
    return conn
End Function

Function load_api(conn As Object) As Dynamic
    print "url: " + conn.urlAPI
    http = NewHttp(conn.urlAPI)
    m.Timer.Mark()
    rsp = http.GetToStringWithRetry()
    videos = VideoList()
    xml = ParseXML(rsp)
    if xml=invalid then
        print "Can't parse feed"
        return videos
    endif
    if islist(xml.GetBody()) = false then
        print "no video found"
        return videos
    endif
    m.Timer.Mark()
    m.ParseAPI(xml, videos)
    print "Show API Parse Took : " + itostr(m.Timer.TotalMilliseconds())
    return videos
End Function

Function VideoList() As Object
    videos = CreateObject("roArray", 100, true)
    return videos
End Function

Function CreateVideoItemByEvent(event As Object) As Object
    video = CreateObject("roAssociativeArray")
    video.sdPosterURL = event.CONFIGURATION.THUMB.GetText()
    video.hdPosterURL = event.CONFIGURATION.THUMB.GetText()
    video.contentId = event.CONFIGURATION@ID
    video.title = event.CONFIGURATION.TITLE.GetText()
    video.description = event.COVERAGE.GetText() + " :: " + event.CONFIGURATION.DESCRIPTION.GetText()
    video.country = event.CONFIGURATION.TITLE.GetText()
    video.streamFormat = "hls"
    video.stream = {
       url: event.CONFIGURATION.LIVETV_HLS_URL.GetText()
    }
    video.contentType = "generic"
    video.shortDescriptionLine1 = event.CONFIGURATION.TITLE.GetText()
    video.shortDescriptionLine2 = event.CONFIGURATION.DESCRIPTION.GetText()
    return video
End Function

Function parse_api(xml As Object, videos As Object) As Void
    groups = xml.GetChildElements()[1].GetChildElements()[0].GetChildElements()[1]
    group_list = GetXMLElementsByName(groups, "GROUP")
    for each item in group_list
        events = item.CONTENT.GetChildElements()
        for each event in events
          video = CreateVideoItemByEvent(event)
          videos.Push(video)
        next event
        skipitem:
            print "skipped item"
    next
End Function
