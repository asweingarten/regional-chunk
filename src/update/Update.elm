module Update exposing (update)

import Mouse exposing (Position)
import Debug exposing (log)

import Model exposing (Model)
import Types exposing (..)
import EyeTracker
import Ports
import OnKeyDown
import ChangeDirection
import Dwell

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CursorMoved newPosition ->
      let _ = log "MAUS MOVE" newPosition
      in
      onCursorMoved newPosition model
    MouseClick position ->
      let
        c = model.commandPalette
        _ = log "MAUS CLICK" position
        commandPalette =
           { c
           | dimensions = {x = position.x, y = position.y, sideLength = 115}
           , isActive = True
           }
        updatedModel = case model.showConfiguration of
          True -> model
          False -> { model | commandPalette = commandPalette }
      in
      ( updatedModel
      , Cmd.none
      )
    Dwell command direction time ->
      let (updatedModel, cmd) = Dwell.update model command direction time
      in
      (updatedModel, cmd)
    ChangeDirection direction ->
      ChangeDirection.update model direction
    NewGazePoint point ->
      onCursorMoved (Position point.x point.y) { model | gazePosition = (Position point.x point.y) }
    Send msg ->
      (model, EyeTracker.send msg)
    WindowResize wSize ->
      ({ model | windowSize = wSize }, Cmd.none)
    ScreenSize sSize ->
      ({ model | screenSize = sSize }, Cmd.none)
    SetActivationTime newTime ->
      let
        commandPalette = model.commandPalette
        newTimeFloat = case String.toFloat newTime of
          Ok time -> time
          Err _ -> commandPalette.activationTimeInMillis
      in
      ({ model | commandPalette = { commandPalette | activationTimeInMillis = newTimeFloat } }
      , Cmd.none)
    KeyDown keyCode ->
      OnKeyDown.update model keyCode
    ToggleGazeCursor ->
      ({ model | showGazeCursor = not model.showGazeCursor }, Cmd.none)


onCursorMoved : Position -> Model -> (Model, Cmd Msg)
onCursorMoved newPosition model =
  let
    cp = model.commandPalette
    threshold = cp.dimensions.sideLength
    deltaX = newPosition.x - cp.dimensions.x
    deltaY = newPosition.y - cp.dimensions.y
    (isActive, left, right, up, down) =
      -- calculated incorrectly. dominant direction should take precendence
      ( cp.isActive
      , deltaX <= -threshold
      , deltaX >= threshold
      , deltaY <= -threshold
      , deltaY >= threshold
      )
    (isNewlyActive, currentDirection) =
      case (isActive, left, right, up, down) of
        (True, True, False, False, False) -> (False, Just West)
        (True, True, False, True, False) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Northwest direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just West)
                False -> (False, Just North)
        (True, True, False, False, True) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Southwest direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just West)
                False -> (False, Just South)
        (True, False, True, False, False) -> (False, Just East)
        (True, False, True, True, False) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Northeast direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just East)
                False -> (False, Just North)
        (True, False, True, False, True) ->
          case (abs deltaX) == (abs deltaY) of
            True -> (False, Nothing) -- Don't report Southeast direction
            False ->
              case (abs deltaX) > (abs deltaY) of
                True -> (False, Just East)
                False -> (False, Just South)
        (True, False, False, True, False) -> (False, Just North)
        (True, False, False, False, True) -> (False, Just South)
        (False, False, False, False, False) -> (True, Nothing)
        (_, _, _, _, _) -> (False, Nothing)
  in
  case (isNewlyActive, model.direction, currentDirection) of
    (True, _, _) ->
      let commandPalette = { cp | isActive = True}
      in
      ({model | commandPalette = commandPalette }, Ports.activated "foo")
    (False, Nothing, Just curDir) -> update (ChangeDirection curDir) model
    (False, _, Nothing) -> (model, Cmd.none)
    (False, Just prevDir, Just curDir) ->
      case prevDir |> isEquivalentTo curDir of
        True -> (model, Cmd.none)
        False -> update (ChangeDirection curDir) model


isEquivalentTo : Direction -> Direction -> Bool
isEquivalentTo curDir newDir =
  case curDir of
    North -> newDir == curDir || newDir == Northeast || newDir == Northwest
    South -> newDir == curDir || newDir == Southeast || newDir == Southwest
    East  -> newDir == curDir || newDir == Northeast || newDir == Southeast
    West  -> newDir == curDir || newDir == Northwest || newDir == Southwest
    _     -> False
