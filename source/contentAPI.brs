Function LoadContentAPI() As Object
    conn = CreateObject("roAssociativeArray")
    conn.urlAPI   = "http://p1.trrsf.com.br/contentAPI/get?prd=live_guadalajara&srv=getListTickerElements&navigation_code=not&country_code=br&contentType=xml&status=2"
    conn.Timer = CreateObject("roTimespan")
    conn.LoadAPI    = load_api
    conn.ParseAPI   = parse_api
    conn.InitItem   = newVideo
    print "created api connection for " + conn.urlAPI
    return conn
End Function


Function load_api(conn As Object) As Dynamic
    print "url: " + conn.urlAPI
    http = NewHttp(conn.urlAPI)
    m.Timer.Mark()
    rsp = http.GetToStringWithRetry()
    videos = newVideos()
   
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

Function newVideos() As Object
    videos = CreateObject("roArray", 100, true)
    return videos
End Function

Function newVideo() As Object
    video = CreateObject("roAssociativeArray")
    video.ContentId        = ""
    video.Title            = ""
    video.ContentType      = ""
    video.ContentQuality   = ""
    video.Country          = ""
    video.UrlSD            = ""
    video.UrlHD            = ""
    video.ThumbSD         = ""
    video.ThumbHD         = ""
    video.SDPosterURL = ""
    video.HDPosterURL = ""
    video.StarRating = "95"
    video.HDBranded = false
    video.isHD = false
    return video
End Function

Function parse_api(xml As Object, videos As Object) As Void
    groups = xml.GetChildElements()[1].GetChildElements()[0].GetChildElements()[1]
    group_list = GetXMLElementsByName(groups, "GROUP")
    for each item in group_list        
        events = item.CONTENT.GetChildElements()
        for each event in events
          if event.STATUS.GetText() <> "2" then
            goto skipEvent
          endif 
          video = newVideo()
          video.type = "normal"
          video.SDPosterURL = validstr(event.CONFIGURATION.THUMB.GetText()) 
          video.HDPosterURL = validstr(event.CONFIGURATION.THUMB.GetText())
          video.ContentId = validstr(event.CONFIGURATION@ID) 
          video.Title = validstr(event.CONFIGURATION.TITLE.GetText())
          video.Description = validstr(event.EVENT_DESCRIPTION.GetText())
          video.Country = validstr(event.CONFIGURATION.TITLE.GetText())
          video.UrlSD = validstr(event.CONFIGURATION.LIVETV_HLS_URL.GetText())
          video.UrlHD = validstr(event.CONFIGURATION.LIVETV_HLS_URL.GetText())
          print video.Title
          videos.Push(video)
          skipEvent:
            print "skipped event"
        next event

        skipitem:
            print "skipped item"
    next
End Function
