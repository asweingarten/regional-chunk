module OnKeyDown exposing (update)

import Keyboard

import Model exposing (Model)
import Types exposing (..)

update : Model -> Keyboard.KeyCode -> (Model, Cmd Msg)
update model keycode =
  case keycode of
    -- Escape
    27 -> ({ model | showConfiguration = not model.showConfiguration }, Cmd.none)
    _ -> (model, Cmd.none)
