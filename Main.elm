-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/web_sockets.html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode exposing (Decoder, int, string, decodeString)
import Json.Decode.Pipeline exposing (decode, required)
import WebSocket
import Debug exposing (log)



main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


eyeGazeServer : String
eyeGazeServer =
  "ws://localhost:8887"



-- MODEL


type alias Model =
  { input : String
  , mostRecentGazePoint : GazePoint
  , messages : List String
  }

type alias GazePoint =
  { state : Int
  , timestamp : Int
  , x : Int
  , y : Int
  }


gazePointDecoder : Decoder GazePoint
gazePointDecoder =
  decode GazePoint
    |> Json.Decode.Pipeline.required "state" int
    |> Json.Decode.Pipeline.required "timestamp" int
    |> Json.Decode.Pipeline.required "x" int
    |> Json.Decode.Pipeline.required "y" int


init : (Model, Cmd Msg)
init =
  (Model "" {state = 0, timestamp= 0, x= 0, y= 0} [], Cmd.none)



-- UPDATE

type Msg
  = NewGazePoint GazePoint
  | Send String
  | NewMessage String


update : Msg -> Model -> (Model, Cmd Msg)
update msg {input, mostRecentGazePoint, messages} =
  let _ = log "boop" messages
  in
  case msg of
    NewGazePoint gazePoint ->
      (Model input gazePoint ( (toString gazePoint.y) :: messages), Cmd.none)

    Send msg ->
      (Model "" mostRecentGazePoint messages, WebSocket.send eyeGazeServer msg)

    NewMessage str ->
      (Model input mostRecentGazePoint (str :: messages), Cmd.none)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen eyeGazeServer receiveMessage


receiveMessage : String -> Msg
receiveMessage payload =

  case decodeString gazePointDecoder payload of
    Err msg ->
      let _ = log "error msg" msg
      in
      NewGazePoint {state = -1, timestamp= 0, x= 1, y= 5}
    Ok gazePoint ->
      let _ = log "payload" payload
      in
      NewGazePoint gazePoint

-- VIEW


view : Model -> Html Msg
view model =
  let
    left = toString (model.mostRecentGazePoint.x - 15)
    right = toString (model.mostRecentGazePoint.y - 15)
    cursorStyle =
      style
        [ ("position", "fixed")
        , ("height", "30px")
        , ("width", "30px")
        , ("left", left ++ "px")
        , ("top", right ++ "px")
        , ("background-color", "rgba(40,40,40,0.4)")
        ]
  in
  div []
    [ button [onClick (Send "startTracker")] [text "Start"]
    , button [onClick (Send "stopTracker")] [text "Stop"]
    , p [] [text (toString model.mostRecentGazePoint.x)]
    , div [cursorStyle] [text "Beep boop"]
    , div [] (List.map viewMessage (List.reverse model.messages))
    ]


viewMessage : String -> Html msg
viewMessage msg =
  div [] [ text msg ]
