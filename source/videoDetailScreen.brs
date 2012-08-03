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

function showVideoDetailScreen(content as object) As Boolean
    port=CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    screen.SetDescriptionStyle("video") 
    screen.SetMessagePort(port)

    preroll = {
        streamFormat: "mp4"
        stream: {
          url:  "http://stream-hlg03.terra.com.br/intel5s.mp4"
        }
    }

    screen.ClearButtons()
    screen.AddButton(1,"Assistir")
    screen.AddButton(2,"Voltar")
    screen.SetStaticRatingEnabled(false)
    screen.SetPosterStyle("rounded-rect-16x9-generic")
    screen.AllowUpdates(true)
    screen.SetContent(content)
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
                if msg.GetIndex() = 1
                    canvas = CreateObject("roImageCanvas")
                    canvas.SetLayer(0, "#000000")
                    canvas.Show()
                    if ShowPreroll(preroll)
                        ShowVideoScreen(content)
                    end if
                    canvas.Close()
                endif
                if msg.GetIndex() = 2
                    return true
                endif
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        else
            print "wrong type.... type=";msg.GetType(); " msg: "; msg.GetMessage()
        endif
    end while
    return true
end function