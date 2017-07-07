module EyeTracker exposing (..)

import WebSocket
import Window exposing (Size)
import Debug exposing (log)
import Json.Decode exposing (Decoder, int, float)
import Json.Decode exposing (decodeString)
import Json.Decode.Pipeline exposing (decode, required)

import Types exposing (..)

type alias GazePointJson =
  { state : Int
  , timestamp : Int
  , x : Float
  , y : Float
  }

eyeGazeServer : String
eyeGazeServer =
  "ws://localhost:8887"

send : String -> Cmd Msg
send msg =
  WebSocket.send eyeGazeServer msg

subscription : Size -> Size -> Sub Msg
subscription screenSize windowSize =
  WebSocket.listen eyeGazeServer (receiveMessage screenSize windowSize)

receiveMessage : Size -> Size -> String -> Msg
receiveMessage screenSize windowSize payload =
  case decodeString gazePointJsonDecoder payload of
    Err msg ->
      let _ = log "error msg" msg
      in
      NewGazePoint {state = -1, timestamp= 0, x= 1, y= 5}
    Ok gp ->
      let
        _ = log "payload" payload
        --x = round (gp.x / 1.5)-- round ( (gp.x / (toFloat screenSize.width)) * toFloat windowSize.width )
        --y = round (gp.y / 1.6)-- round ( (gp.y / (toFloat screenSize.height)) * toFloat windowSize.height )
        x = round gp.x--round (gp.x / 1.5)-- round ( (gp.x / (toFloat screenSize.width)) * toFloat windowSize.width )
        yOffset = toFloat <| screenSize.height - windowSize.height
        y = round (gp.y - yOffset)--round (gp.y / 1.6)-- round ( (gp.y / (toFloat screenSize.height)) * toFloat windowSize.height )
      in
      NewGazePoint (GazePoint gp.state gp.timestamp x y)

gazePointJsonDecoder : Decoder GazePointJson
gazePointJsonDecoder =
  decode GazePointJson
    |> Json.Decode.Pipeline.required "state" int
    |> Json.Decode.Pipeline.required "timestamp" int
    |> Json.Decode.Pipeline.required "x" float
    |> Json.Decode.Pipeline.required "y" float
