'******************************************************************************
'** Copyright (c) 2012 - Maxwell Dayvson <dayvson@gmail.com>
'** Copyright (c) 2012 - Marco Lovato <marco.lovato@gmail.com>
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

Function preShowLiveScreen(breadA=invalid, breadB=invalid) As Object
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    if breadA <> invalid and breadB <> invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if
    screen.SetListStyle("arced-landscape")
    screen.setAdDisplayMode("scale-to-fit")
    'exit the app gently so that the screen doesn't flash to black
    screen.showMessage("bbb")
    'sleep(25)
    return screen
End Function

Function showLiveScreen(screen) As Integer
    itemVenter = { ContentType:"generic"
           SDPosterUrl:"http://p1.trrsf.com.br/image/get?src=s1.trrsf.com.br/live/thumbs/20120729t100401z_1934_pt.jpg&amp;w=113&amp;h=63"
           HDPosterUrl:"http://p1.trrsf.com.br/image/get?src=s1.trrsf.com.br/live/thumbs/20120729t100401z_1934_pt.jpg&amp;w=113&amp;h=63"
           IsHD:False
           HDBranded:False
           ShortDescriptionLine1:"ShortDescriptionLine1"
           ShortDescriptionLine2:"ShortDescriptionLine2"
           Description:"Vôlei de Praia - Masculino"
           Categories:["Ao Vivo"]
           Title:"BRA x AUT"
           }

    showSpringboardScreen(itemVenter)
    screen.Show()

    while true

    end while
    return 0
End Function

Function showSpringboardScreen(item as object) As Boolean
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")

    print "showSpringboardScreen"
    
    screen.SetMessagePort(port)
    screen.AllowUpdates(false)
    if item <> invalid and type(item) = "roAssociativeArray"
        screen.SetContent(item)
    endif

    'screen.SetDescriptionStyle("movie") 'audio, movie, video, generic
                                        ' generic+episode=4x3,
    screen.ClearButtons()
    screen.AddButton(1,"Iniciar Evento em SD")
    screen.AddButton(2,"Iniciar Evento em HD")
    screen.AddButton(3,"Voltar")
    screen.SetStaticRatingEnabled(false)
    screen.SetPosterStyle("rounded-rect-16x9-generic")
    screen.AllowUpdates(true)
    screen.Show()

    downKey=3
    selectKey=6
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent"
            if msg.isScreenClosed()
                print "Screen closed"
                exit while                
            else if msg.isButtonPressed()
                    print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                    if msg.GetIndex() = 3
                         return true
                    else 
                         displayVideo()
                    endif
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        else 
            print "wrong type.... type=";msg.GetType(); " msg: "; msg.GetMessage()
        endif
    end while


    return true
End Function

Function displayVideo()
    print "Displaying video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)

    'bitrates  = [0]          ' 0 = no dots, adaptive bitrate
    'bitrates  = [348]    ' <500 Kbps = 1 dot
    'bitrates  = [664]    ' <800 Kbps = 2 dots
    'bitrates  = [996]    ' <1.1Mbps  = 3 dots
    'bitrates  = [2048]    ' >=1.1Mbps = 4 dots
    bitrates  = [0]    

    'Swap the commented values below to play different video clips...
    urls = ["http://fs-vdp-cdn17-cis.terra.com/live-mob/1150@1/playlist.m3u8?hash=155eac200abf78c054204c7dae1965af&ts=20120729082143"]
    qualities = ["HD"]
    StreamFormat = "hls"
    title = "Vôlei de Praia - Masculino"
'    srt = "http://dotsub.com/media/f65605d0-c4f6-4f13-a685-c6b96fba03d0/c/eng/srt"

'    urls = ["http://video.ted.com/talks/podcast/DanGilbert_2004_480.mp4"]
'    qualities = ["HD"]
'    StreamFormat = "mp4"
'    title = "Dan Gilbert asks, Why are we happy?"

    ' Apple's HLS test stream
    'urls = ["http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]
    'qualities = ["SD"]
    'streamformat = "hls"
    'title = "Apple BipBop Test Stream"

    ' Big Buck Bunny test stream from Wowza
    'urls = ["http://ec2-174-129-153-104.compute-1.amazonaws.com:1935/vod/smil:BigBuckBunny.smil/playlist.m3u8"]
    'qualities = ["SD"]
    'streamformat = "hls"
    'title = "Big Buck Bunny"
    
    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = urls
    videoclip.StreamQualities = qualities
    videoclip.StreamFormat = streamformat
    videoclip.Title = title
    'print "srt = ";srt
    'if srt <> invalid and srt <> "" then
    '    videoclip.SubtitleUrl = srt
    'end if
    
    video.SetContent(videoclip)
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 'position must change by more than this number of seconds before saving

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                print "Closing video screen"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        end if
    end while
End Function
