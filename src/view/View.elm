module View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class)

import Model exposing (Model)
import CommandPalette
import GazeCursor
import Types exposing (..)

view : Model -> Html Msg
view {mousePosition, commandPalette, gazePosition, windowSize, screenSize, direction} =
  let
    x = toString mousePosition.x
    y = toString mousePosition.y
    wWidth = toString windowSize.width
    wHeight = toString windowSize.height
    sWidth = toString screenSize.width
    sHeight = toString screenSize.height
    progress =
      case commandPalette.activeCommand of
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
    , text ("screen sizeff: " ++ sWidth ++ " :: " ++ sHeight)
    ]
    ++ ([CommandPalette.view commandPalette.dimensions commandPalette.isActive commandPalette.activeCommand])
    -- ++ ([displacement mousePosition cursorActivationZone])
    -- ++ ([GazeCursor.view gazePosition])
    ++ ([div [class "div", myStyle] [text <| justDirection ++  " " ++ progress]])
    )

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
