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

function showHomeScreen() As Integer
    port = CreateObject("roMessagePort")
    screen = CreateObject("roPosterScreen")
    screen.SetMessagePort(port)
    screen.SetListStyle("arced-16x9")
    screen.setAdDisplayMode("scale-to-fit")
    tt=CreateObject("roScreen") 
    
    font_registery = CreateObject("roFontRegistry")
    font_regular = font_registery.GetDefaultFont() 
    tt.DrawText("Line One String", 150, 300, &h0000FFFF, font_regular)
    
    video_list = getVideoList()
    screen.SetContentList(video_list)
    screen.Show()
    if video_list.Count() > 3 then
        screen.SetFocusedListItem(3)
    end if
    timer=createobject("rotimespan")
    timer.mark()
    refreshTime = 30000
    currentTime = 0
  
    while true
        msg = wait(20, screen.GetMessagePort())
        currentTime = currentTime + timer.totalmilliseconds()
        timer.mark()
        if currentTime > refreshTime then
          currentTime = 0
          video_list = getVideoList()
          updateScreen(screen, video_list)
        end if
        
        if type(msg) = "roPosterScreenEvent" then
            print "showHomeScreen | msg = "; msg.GetMessage() " | index = "; msg.GetIndex()
            if msg.isListItemSelected() then
                print "list item selected | index = "; msg.GetIndex()
                showVideoDetailScreen(video_list[msg.GetIndex()])
            else if msg.isScreenClosed() then
                return -1
            end if
        end If
    end while
    return 0
end function

function updateScreen(screen As Object, video_list as Object) As Void
  dialog = CreateObject("roOneLineDialog")
  dialog.SetTitle("Loading Events....")
  dialog.ShowBusyAnimation()
  dialog.Show()
  Sleep(2000)
  dialog.Close()
  screen.SetContentList(video_list)
  screen.Show()
end function
function getVideoList() As Object
    conn = LoadContentAPI()
    video_list = conn.LoadAPI(conn)
    return video_list
end function
