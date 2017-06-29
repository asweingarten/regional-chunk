module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Mouse exposing (Position, moves, clicks)
import Time exposing (Time)
import Debug exposing (log)
import Json.Decode exposing (decodeString)
import WebSocket
import Window exposing (resizes, Size)
import Task

import Views exposing (dwellButton, cursorZone, displacement, gazeCursor)
import Types exposing (..)
import Decoders exposing (gazePointJsonDecoder)
import DwellButton exposing (..)

import Screen exposing (screenSize)

-- TODO
-- Change Square type to something that better described cursor activation zone
-- Integrate web sockets

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
  { position: Position
  , dwellButtons: List DwellButton
  , cursorActivationZone: Square
  , isCursorActive: Bool
  , gazePoint: GazePoint
  , windowSize : Size
  , screenSize : Size
  , direction : Maybe Direction
  }

init : (Model, Cmd Msg)
init =
  (Model
    { x = -1, y = -1 }
    [DwellButton "hey" 0 False]
    { x = 0, y = 0, sideLength = 0}
    False
    {state = 0, timestamp= 0, x= 0, y= 0}
    (Size 0 0)
    (Size 0 0)
    Nothing
  , Task.perform WindowResize Window.size)

-- UPDATE
onCursorMoved : Position -> Model -> (Model, Cmd Msg)
onCursorMoved newPosition model =
  let
    threshold = model.cursorActivationZone.sideLength
    deltaX = newPosition.x - model.cursorActivationZone.x
    deltaY = newPosition.y - model.cursorActivationZone.y
    (isActive, left, right, up, down) =
      (model.isCursorActive, deltaX <= -threshold, deltaX >= threshold, deltaY <= -threshold, deltaY >= threshold)
  in
  case (isActive, left, right, up, down) of
    (True, True, False, False, False) ->
      update (FireEvent West) model
    (True, True, False, True, False) ->
      update (FireEvent Northwest) model
    (True, True, False, False, True) ->
      update (FireEvent Southwest) model
    (True, False, True, False, False) ->
      update (FireEvent East) model
    (True, False, True, True, False) ->
      update (FireEvent Northeast) model
    (True, False, True, False, True) ->
      update (FireEvent Southeast) model
    (True, False, False, True, False) ->
      update (FireEvent North) model
    (True, False, False, False, True) ->
      update (FireEvent South) model
    (False, False, False, False, False) ->
      ({model | isCursorActive = True}, Cmd.none)
    (_,_, _, _, _) ->
      (model, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CursorMoved newPosition ->
      -- depending on displacement, fire some command
      onCursorMoved newPosition model

    MouseClick position ->
      ({ model
        | cursorActivationZone = {x = position.x, y = position.y, sideLength = 200}
        , isCursorActive = True
        }
      , Cmd.none)
    ButtonEntered ->
      let _ = log "button entered" 5
      in
      ({ model | dwellButtons = List.map (\db -> {db | active = True}) model.dwellButtons}, Cmd.none)
    ButtonLeft ->
      let _ = log "button entered" 5
      in
      ({ model | dwellButtons = List.map (\db -> {db | active = False, progress = 0 }) model.dwellButtons}, Cmd.none)
    Dwell time ->
      let _ = log "time" time
      in
      ({ model | dwellButtons = List.map (\db -> {db | progress = db.progress+10}) model.dwellButtons}
      , Cmd.none)
    FireEvent direction ->
      let _ = log "yo" direction
      in
      ({ model
       | isCursorActive = False
       , direction = Just direction
      }
      , Cmd.none)
    NewGazePoint point ->
      onCursorMoved (Position point.x point.y) { model | gazePoint = point }
    Send msg ->
      (model, WebSocket.send eyeGazeServer msg)
    WindowResize wSize ->
      ({ model | windowSize = wSize }, Cmd.none)
    ScreenSize sSize ->
      ({ model | screenSize = sSize }, Cmd.none)



-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ moves CursorMoved
    , clicks MouseClick
    , dwellSubscriptions model.dwellButtons
    , WebSocket.listen eyeGazeServer (receiveMessage model.screenSize model.windowSize)
    , resizes WindowResize
    , screenSize ScreenSize
    ]

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
        x = round (gp.x / 1.5)-- round ( (gp.x / (toFloat screenSize.width)) * toFloat windowSize.width )
        y = round (gp.y / 1.6)-- round ( (gp.y / (toFloat screenSize.height)) * toFloat windowSize.height )
      in
      NewGazePoint (GazePoint gp.state gp.timestamp x y)

-- VIEW

view : Model -> Html Msg
view {position, dwellButtons, cursorActivationZone, isCursorActive, gazePoint, windowSize, screenSize, direction} =
  let
    x = toString position.x
    y = toString position.y
    wWidth = toString windowSize.width
    wHeight = toString windowSize.height
    sWidth = toString screenSize.width
    sHeight = toString screenSize.height
    buttons = List.map (\x -> dwellButton x) dwellButtons
    myStyle =
      style
        [ ("margin", "0 auto")
        , ("font-size", "48")
        ]
  in
  div []
    ([ text ("cursor pos: " ++ x ++ " :: " ++ y)
    , text ("window size: " ++ wWidth ++ " :: " ++ wHeight)
    , text ("screen size: " ++ sWidth ++ " :: " ++ sHeight)
    ]
    ++ buttons
    ++ ([cursorZone cursorActivationZone isCursorActive])
    ++ ([displacement position cursorActivationZone])
    ++ ([gazeCursor gazePoint])
    ++ ([div [class "div", myStyle] [text <| toString direction]])
    )
