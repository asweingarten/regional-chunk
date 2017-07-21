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
      onCursorMoved newPosition model
    MouseClick position ->
      let
        c = model.commandPalette
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
