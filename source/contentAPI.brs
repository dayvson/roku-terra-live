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

function LoadContentAPI() As Object
    conn = {
      urlAPI: "http://p1.trrsf.com.br/contentAPI/get?prd=live_guadalajara&srv=getListTickerElements&navigation_code=home&country_code=br&contentType=xml&status=2&eventType=1"
      LoadAPI: load_api
      GetEvents: getEvents
    }
    print "created api connection for " + conn.urlAPI
    return conn
end function

function load_api(conn As Object) As Dynamic
    loader = URLLoader(conn.urlAPI)
    data = loader.ReadDataWithRetry()
    xml = ParseXML(data)
    if xml=invalid or islist(xml.GetBody()) = false then
        print "No videos found"
        return VideoList()
    endif
    videos = m.GetEvents(xml)
    return videos
end function

function VideoList() As Object
    videos = CreateObject("roArray", 100, true)
    return videos
end Function

function getEvents(xml As Object) As Object
    videos = VideoList()
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
    return videos
end function

function CreateVideoItemByEvent(event As Object) As Object
    this = {
      sdPosterURL: event.CONFIGURATION.THUMB.GetText()
      hdPosterURL: event.CONFIGURATION.THUMB.GetText()
      contentId: event.CONFIGURATION@ID
      title: event.CONFIGURATION.TITLE.GetText()
      description: event.COVERAGE.GetText() + " :: " + event.CONFIGURATION.DESCRIPTION.GetText()
      country: event.CONFIGURATION.TITLE.GetText()
      streamFormat: "hls"
      live: true
      stream: {
       url: event.CONFIGURATION.LIVETV_HLS_URL.GetText()
      }
      shortDescriptionLine1: event.CONFIGURATION.TITLE.GetText()
      shortDescriptionLine2: event.CONFIGURATION.DESCRIPTION.GetText()
    }
    return this
end function