module Configuration exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style, placeholder, type_, checked)
import Html.Events exposing (onInput, onClick)

import Model exposing (Model)
import Types exposing (..)

view : Model -> Html Msg
view model =
  let
    commandPalette = model.commandPalette
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
    ]
