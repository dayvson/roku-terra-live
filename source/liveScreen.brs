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

Function showLiveScreen(liveEvent as object) As Boolean
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")
    preroll = {
        streamFormat: "mp4"
        stream: {
          url:  "http://stream-hlg03.terra.com.br/intel5s.mp4"
        }
    }
    content ={
        title:        liveEvent.Title
        sdPosterURL:  liveEvent.thumb_url
        hdPosterURL:  liveEvent.thumb_url
        description:  liveEvent.Description
        contentType:  "generic"
        streamFormat: "hls"
        stream: {
          url:  liveEvent.sdURL
        }
    }
    screen.SetMessagePort(port)
    screen.AllowUpdates(false)
    screen.ClearButtons()
    screen.AddButton(1,"Assistir")
    if liveEvent.IsHD = true
        screen.AddButton(2,"Assistir em HD")
    endif
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
                        if ShowPreroll(preroll)
                            displayVideo(1, liveEvent.hdURL, "hls", "Terra Ao Vivo :: "+liveEvent.Title)
                        end if
                    endif
                    if msg.GetIndex() = 3
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
End Function

sub ShowVideoScreen(video)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roVideoScreen")
  screen.SetMessagePort(port)
  screen.SetContent(video)
  screen.Show()
  while true
    msg = wait(0, port)
    if type(msg) = "roVideoScreenEvent"
      if msg.isScreenClosed()
        exit while
      end if
    end if
  end while
  screen.Close()
end sub

function ShowPreRoll(video)
  ' a true result indicates that playback finished without user intervention
  ' a false result indicates that the user pressed UP or BACK to terminate playback
  result = true
  canvas = CreateObject("roImageCanvas")
  player = CreateObject("roVideoPlayer")
  port = CreateObject("roMessagePort")

  canvas.SetMessagePort(port)
  ' build a very simple buffer screen for our preroll video
  'canvas.SetLayer(0, { text: "Aguarde a palavra de nossos patrocinadores" })
  'canvas.Show()

  ' be sure to use the same message port for both the canvas and the player
  ' so we can receive events from both
  player.SetMessagePort(port)
  player.SetDestinationRect(canvas.GetCanvasRect())
  player.AddContent(video)
  player.Play()
  while true
    msg = wait(0, canvas.GetMessagePort())
    if type(msg) = "roVideoPlayerEvent"
      if msg.isFullResult()
        ' the video played to the end without user intervention
        exit while
      else if msg.isStatusMessage()
        if msg.GetMessage() = "start of play"
          ' once the video starts, clear out the canvas so it doesn't cover the video
          canvas.SetLayer(0, { color: "#00000000", CompositionMode: "Source" })
          canvas.Show()
        end if
      end if
    else if type(msg) = "roImageCanvasEvent"
      if msg.isRemoteKeyPressed()
        index = msg.GetIndex()
        if index = 0 or index = 2
          ' the user pressed UP or BACK to terminate playback
          result = false
          exit while
        end if
      end if
    end if
  end while
  player.Stop()
  canvas.Close()
  return result
end function


Function displayVideo(hasHD as integer, theURL as string, stream as string, eventTitle as String)
    result = true
    print "Displaying video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)

    if hasHD = 1
        bitrates  = [2000]
        qualities = ["HD"]
    else
        bitrates  = [800]
        qualities = ["SD"]
    endif    
    urls = [theURL]
    StreamFormat = stream
    title = eventTitle
    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = urls
    videoclip.StreamQualities = qualities
    videoclip.StreamFormat = streamformat
    videoclip.Title = title

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