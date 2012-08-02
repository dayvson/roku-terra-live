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

Function preShowDetailScreen(breadA=invalid, breadB=invalid) As Object
    port=CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetDescriptionStyle("video") 
    screen.SetMessagePort(port)
    if breadA<>invalid and breadB<>invalid then
        screen.SetBreadcrumbText(breadA, breadB)
    end if

    return screen
End Function

Function showDetailScreen(screen As Object, showList As Object, showIndex as Integer) As Integer
    refreshShowDetail(screen, showList, showIndex)
    'remote key id's for left/right navigation
    remoteKeyLeft  = 4
    remoteKeyRight = 5
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent" then
            if msg.isScreenClosed()
                print "Screen closed"
                exit while
            else if msg.isRemoteKeyPressed() 
                print "Remote key pressed"
                if msg.GetIndex() = remoteKeyLeft then
                        showIndex = getPrevShow(showList, showIndex)
                        if showIndex <> -1
                            refreshShowDetail(screen, showList, showIndex)
                        end if
                else if msg.GetIndex() = remoteKeyRight
                    showIndex = getNextShow(showList, showIndex)
                        if showIndex <> -1
                           refreshShowDetail(screen, showList, showIndex)
                        end if
                endif
            else if msg.isButtonPressed() 
                if msg.GetIndex() = 1
                    PlayStart = RegRead(showList[showIndex].ContentId)
                    if PlayStart <> invalid then
                        showList[showIndex].PlayStart = PlayStart.ToInt()
                    endif
                    showVideoScreen(showList[showIndex])
                endif
                if msg.GetIndex() = 2
                    showList[showIndex].PlayStart = 0
                    showVideoScreen(showList[showIndex])
                endif
                if msg.GetIndex() = 3
                endif
                print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
            end if
        else
            print "Unexpected message class: "; type(msg)
        end if
    end while
    return showIndex
End Function

Function refreshShowDetail(screen As Object, showList As Object, showIndex as Integer) As Integer
    show = showList[showIndex]
    screen.ClearButtons()
    screen.AddButton(1, "resume playing")    
    screen.AddButton(2, "play from beginning")    
    screen.SetContent(show)
    screen.Show()
    return 0
End Function

Function getNextShow(showList As Object, showIndex As Integer) As Integer
    nextIndex = showIndex + 1
    if nextIndex >= showList.Count() or nextIndex < 0 then
       nextIndex = 0 
    end if
    show = showList[nextIndex]
    return nextIndex
End Function

Function getPrevShow(showList As Object, showIndex As Integer) As Integer
    prevIndex = showIndex - 1
    if prevIndex < 0 or prevIndex >= showList.Count() then
        if showList.Count() > 0 then
            prevIndex = showList.Count() - 1 
        else
            return -1
        end if
    end if
    show = showList[prevIndex]
    return prevIndex
End Function
