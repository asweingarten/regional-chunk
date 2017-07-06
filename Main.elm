module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Mouse exposing (Position, moves, clicks)
import Time exposing (Time)
import Debug exposing (log)
import Window exposing (resizes, Size)
import Screen exposing (screenSize)
import Task

import Views exposing (dwellButton, displacement, gazeCursor)
import CommandSquare exposing (commandSquare, dwellCommandSubscription)
import Types exposing (..)
import EyeTracker

-- TODO
-- Change Square type to something that better described cursor activation zone

main =
  Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

-- MODEL
type alias Model =
  { mousePosition: Position
  , cursorActivationZone: Square
  , isCursorActive: Bool
  , gazePosition: Position
  , windowSize : Size
  , screenSize : Size
  , direction : Maybe Direction
  , activeCommand : Maybe DwellCommand
  }

init : (Model, Cmd Msg)
init =
  (Model
    { x = -1, y = -1 }
    { x = 0, y = 0, sideLength = 0}
    False
    {x = 0, y = 0}
    (Size 0 0)
    (Size 0 0)
    Nothing
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
      update (ChangeDirection West) model
    (True, True, False, True, False) ->
      update (ChangeDirection Northwest) model
    (True, True, False, False, True) ->
      update (ChangeDirection Southwest) model
    (True, False, True, False, False) ->
      update (ChangeDirection East) model
    (True, False, True, True, False) ->
      update (ChangeDirection Northeast) model
    (True, False, True, False, True) ->
      update (ChangeDirection Southeast) model
    (True, False, False, True, False) ->
      update (ChangeDirection North) model
    (True, False, False, False, True) ->
      update (ChangeDirection South) model
    (False, False, False, False, False) ->
      ({model | isCursorActive = True}, Cmd.none)
    (_,_, _, _, _) ->
      (model, Cmd.none)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CursorMoved newPosition ->
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
      (model, Cmd.none)
    ButtonLeft ->
      let _ = log "button entered" 5
      in
      (model, Cmd.none)
    Dwell direction time ->
      let
        _ = log "time" time
        activeCommand =
          case model.activeCommand of
            Nothing ->
              { direction = direction, progress = 1 }
            Just command ->
              { command | progress = (command.progress + 1) % 10 }
      in
      case activeCommand.progress == 0 of
        False ->
          ({model | activeCommand = Just activeCommand }, Cmd.none)
        True ->
          ({ model | activeCommand = Nothing, direction = Nothing }, Cmd.none) -- FIRE THE COMMAND
    ChangeDirection direction ->
      let
        _ = log "yo" direction
        activeCommand =
          case model.activeCommand of
            Nothing -> { direction = direction, progress = 0 }
            Just command ->
              case command.direction == direction of
                True -> command
                False -> { direction = direction, progress = 0 }
      in
        ({model | direction = Just direction, activeCommand = Just activeCommand }, Cmd.none)
    NewGazePoint point ->
      onCursorMoved (Position point.x point.y) { model | gazePosition = (Position point.x point.y) }
    Send msg ->
      (model, EyeTracker.send msg)
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
    , EyeTracker.subscription model.screenSize model.windowSize
    , resizes WindowResize
    , screenSize ScreenSize
    , dwellCommandSubscription model.activeCommand
    ]

-- VIEW

view : Model -> Html Msg
view {mousePosition, cursorActivationZone, isCursorActive, gazePosition, windowSize, screenSize, direction, activeCommand} =
  let
    x = toString mousePosition.x
    y = toString mousePosition.y
    wWidth = toString windowSize.width
    wHeight = toString windowSize.height
    sWidth = toString screenSize.width
    sHeight = toString screenSize.height
    progress =
      case activeCommand of
        Nothing -> toString 0
        Just command -> toString command.progress
    justDirection =
      case direction of
        Nothing -> ""
        Just d -> toString d
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
    ++ ([commandSquare cursorActivationZone isCursorActive activeCommand])
    ++ ([displacement mousePosition cursorActivationZone])
    ++ ([gazeCursor gazePosition])
    ++ ([div [class "div", myStyle] [text <| justDirection ++  " " ++ progress]])
    )
