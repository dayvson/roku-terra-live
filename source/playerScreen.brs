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

function ShowVideoScreen(video) As Void
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
end function

function ShowPreRoll(video)
  result = true
  canvas = CreateObject("roImageCanvas")
  player = CreateObject("roVideoPlayer")
  port = CreateObject("roMessagePort")
  canvas.SetMessagePort(port)
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