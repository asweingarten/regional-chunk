module Configuration exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder, type_)
import Html.Events exposing (onInput, onClick)

import Model exposing (CommandPalette)
import Types exposing (..)

view : CommandPalette -> Html Msg
view commandPalette =
  let
    activationTime = (toString commandPalette.activationTimeInMillis) ++ "ms"
    configurationStyle =
      style
        [ ("position", "absolute")
        , ("width", "100%")
        , ("height", "100%")
        , ("background-color", "white")
        ]
    inputStyle =
      style
        [ ("width", "100%")
        , ("height", "40px")
        , ("padding", "10px 0")
        , ("font-size", "2em")
        , ("text-align", "center")
        ]
  in
  div [configurationStyle]
    [ input [ placeholder activationTime, onInput SetActivationTime, inputStyle ] []
    , label [ style [("padding", "20px")] ]
      [ input [ type_ "checkbox", onClick ToggleGazeCursor ] []
      , text "Gaze Cursor"
      ]
    ]
