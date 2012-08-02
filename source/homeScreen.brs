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

Function preShowHomeScreen(breadA=invalid, breadB=invalid) As Object
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    if breadA <> invalid and breadB <> invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if
    screen.SetListStyle("arced-16x9")
    screen.setAdDisplayMode("scale-to-fit")
    
    'exit the app gently so that the screen doesn't flash to black
    screen.showMessage("")
    'sleep(1)
    return screen
End Function

Function showHomeScreen(screen) As Integer
    video_list = getVideoList()
    screen.SetContentList(video_list)
    screen.Show()
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roPosterScreenEvent" then
            print "showHomeScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListFocused() then
                print "list focused | index = "; msg.GetIndex(); " | category = "; m.curCategory
            else if msg.isListItemSelected() then
                print "list item selected | index = "; msg.GetIndex()
                print video_list[msg.GetIndex()].Title
                liveEvent = {
                    thumb_url:video_list[msg.GetIndex()].HDPosterURL
                    IsHD:false
                    Description:video_list[msg.GetIndex()].Description
                    Title:video_list[msg.GetIndex()].Title
                    hdURL:"http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8"
                    sdURL:video_list[msg.GetIndex()].UrlHD
                    }
                showLiveScreen(liveEvent)
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
    end while
    return 0
End Function

Function getVideoList() As Object
    conn = LoadContentAPI()    
    video_list = conn.LoadAPI(conn)
    return video_list
End Function
