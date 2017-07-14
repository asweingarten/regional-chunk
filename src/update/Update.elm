module Update exposing (update)

import Mouse exposing (Position)
import Debug exposing (log)

import Model exposing (Model)
import Types exposing (..)
import EyeTracker
import Ports

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CursorMoved newPosition ->
      onCursorMoved newPosition model
    MouseClick position ->
      let
        c = model.commandPalette
        commandPalette =
           { c
           | dimensions = {x = position.x, y = position.y, sideLength = 200}
           , isActive = True
           }
      in
      ( { model
        | commandPalette = commandPalette
        }
      , Cmd.none)
    Dwell direction time ->
      let
        c = model.commandPalette
        _ = log "time" time
        activeCommand =
          case model.commandPalette.activeCommand of
            Nothing ->
              { direction = direction, progress = 1 }
            Just command ->
              { command | progress = (command.progress + 1) % 10 }
      in
      case activeCommand.progress == 0 of
        False ->
          let commandPalette = { c | activeCommand = Just activeCommand }
          in
          ({ model | commandPalette = commandPalette }, Cmd.none)
        True ->
          let commandPalette = { c | activeCommand = Nothing, isActive = False }
          in
          ( { model | commandPalette = commandPalette }
          , Ports.commandFired <| toString activeCommand.direction) -- FIRE THE COMMAND
    ChangeDirection direction ->
      let
        _ = log "yo" direction
        activeCommand =
          case model.commandPalette.activeCommand of
            Nothing -> { direction = direction, progress = 0 }
            Just command ->
              case equivalentDirection command.direction direction of
                True -> command
                False -> { direction = direction, progress = 0 }
        cp = model.commandPalette
        commandPalette = { cp | activeCommand = Just activeCommand }
      in
        ({model | direction = Just direction, commandPalette = commandPalette }, Cmd.none)
    NewGazePoint point ->
      onCursorMoved (Position point.x point.y) { model | gazePosition = (Position point.x point.y) }
    Send msg ->
      (model, EyeTracker.send msg)
    WindowResize wSize ->
      ({ model | windowSize = wSize }, Cmd.none)
    ScreenSize sSize ->
      ({ model | screenSize = sSize }, Cmd.none)

equivalentDirection : Direction -> Direction -> Bool
equivalentDirection curDir newDir =
  case curDir of
    North -> newDir == curDir || newDir == Northeast || newDir == Northwest
    South -> newDir == curDir || newDir == Southeast || newDir == Southwest
    East  -> newDir == curDir || newDir == Northeast || newDir == Southeast
    West  -> newDir == curDir || newDir == Northwest || newDir == Southwest
    _     -> False

onCursorMoved : Position -> Model -> (Model, Cmd Msg)
onCursorMoved newPosition model =
  let
    cp = model.commandPalette
    threshold = cp.dimensions.sideLength
    deltaX = newPosition.x - cp.dimensions.x
    deltaY = newPosition.y - cp.dimensions.y
    (isActive, left, right, up, down) =
      ( cp.isActive
      , deltaX <= -threshold
      , deltaX >= threshold
      , deltaY <= -threshold
      , deltaY >= threshold
      )
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
      let commandPalette = { cp | isActive = True}
      in
      ({model | commandPalette = commandPalette }, Cmd.none)
    (_,_, _, _, _) ->
      (model, Cmd.none)
