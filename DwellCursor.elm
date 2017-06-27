module DwellCursor exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Mouse exposing (Position, moves, clicks)
import Time exposing (millisecond, every, Time)
import Debug exposing (log)

import Views exposing (dwellButton, cursorZone, displacement)
import Types exposing (..)

main =
  Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

-- MODEL
type alias Model =
  { position: Position
  , dwellButtons: List DwellButton
  , cursorActivationZone: Square
  }

init : (Model, Cmd Msg)
init =
  (Model { x = -1, y = -1 } [DwellButton "hey" 0 False] { x = 0, y = 0, sideLength = 0}
  , Cmd.none)

-- UPDATE
onCursorMoved : Position -> Model -> (Model, Cmd Msg)
onCursorMoved newPosition model =
  let
    threshold = 10
    deltaX = newPosition.x - model.cursorActivationZone.x
    deltaY = newPosition.y - model.cursorActivationZone.y
    (left, right, up, down) = (deltaX <= -threshold, deltaX >= threshold, deltaY <= -threshold, deltaY >= threshold)
  in
  case (left, right, up, down) of
    (True, False, False, False) ->
      update (FireEvent "left") model
    (True, False, True, False) ->
      update (FireEvent "up left") model
    (True, False, False, True) ->
      update (FireEvent "down left") model
    (False, True, False, False) ->
      update (FireEvent "right") model
    (False, True, True, False) ->
      update (FireEvent "up right") model
    (False, True, False, True) ->
      update (FireEvent "down right") model
    (False, False, True, False) ->
      update (FireEvent "up") model
    (False, False, False, True) ->
      update (FireEvent "down") model
    (_, _, _, _) ->
      (model, Cmd.none)


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CursorMoved newPosition ->
      -- depending on displacement, fire some command
      onCursorMoved newPosition model

    MouseClick position ->
      ({ model | cursorActivationZone = {x = position.x, y = position.y, sideLength = 20} }, Cmd.none)
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
    FireEvent string ->
      let _ = log "yo" string
      in
      (model, Cmd.none)


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ moves CursorMoved
    , clicks MouseClick
    , dwellSubscriptions model.dwellButtons
    ]

dwellSubscriptions : List DwellButton -> Sub Msg
dwellSubscriptions dwellButtons =
  let
    subs = List.map dwellSubscription dwellButtons
  in
  Sub.batch subs

dwellSubscription : DwellButton -> Sub Msg
dwellSubscription b =
  let _ = log "b" b
  in
  case b.active of
    True ->
      every (200*millisecond) Dwell
    False ->
      Sub.none

-- VIEW

view : Model -> Html Msg
view {position, dwellButtons, cursorActivationZone} =
  let
    x = toString position.x
    y = toString position.y
    buttons = List.map (\x -> dwellButton x) dwellButtons
  in
  div []
    ([ text (x ++ " :: " ++ y) ]
    ++ buttons
    ++ ([cursorZone cursorActivationZone])
    ++ ([displacement position cursorActivationZone])
    )
