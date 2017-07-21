module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class)

import Model exposing (Model)
import CommandPalette
import GazeCursor
import Configuration
import Types exposing (..)

view : Model -> Html Msg
view model =
  let
    commandPalette = model.commandPalette
    x = toString model.mousePosition.x
    y = toString model.mousePosition.y
    wWidth = toString model.windowSize.width
    wHeight = toString model.windowSize.height
    sWidth = toString model.screenSize.width
    sHeight = toString model.screenSize.height
    progress =
      case commandPalette.activeCommand of
        Nothing -> toString 0
        Just command -> toString command.progress
    justDirection =
      case model.direction of
        Nothing -> ""
        Just d -> toString d
    configuration =
      case model.showConfiguration of
        True -> Configuration.view model
        False -> div [] []
    gazeCursor =
      case model.showGazeCursor of
        True -> GazeCursor.view model.gazePosition
        False -> div [] []
    myStyle =
      style
        [ ("margin", "0 auto")
        , ("font-size", "48")
        ]
  in
  div []
    ([ text ("cursor pos: " ++ x ++ " :: " ++ y)
    , text ("window size: " ++ wWidth ++ " :: " ++ wHeight)
    , text ("screen sizeff: " ++ sWidth ++ " :: " ++ sHeight)
    ]
    ++ ([CommandPalette.view commandPalette])
    -- ++ ([displacement mousePosition cursorActivationZone])
    ++ ([gazeCursor])
    ++ ([configuration])
    ++ ([div [class "div", myStyle] [text <| justDirection ++  " " ++ progress]])
    )

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
