module DwellCursor exposing (..)

import Html exposing (..)
import Mouse exposing (Position, moves)

main =
  Html.program
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

-- MODEL

type alias Model = Position

init : (Model, Cmd Msg)
init =
  ({ x = -1, y = -1 }, Cmd.none)

-- UPDATE
type Msg
  = CursorMoved Position

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    CursorMoved position ->
      (position, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  moves CursorMoved

view : Model -> Html Msg
view model =
  let
    x = toString model.x
    y = toString model.y
  in
  div [] [text (x ++ " :: " ++ y)]
