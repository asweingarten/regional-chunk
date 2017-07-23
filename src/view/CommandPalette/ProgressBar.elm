module CommandPalette.ProgressBar exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)

import Model exposing (CommandPalette)
import Types exposing (..)

view : DwellCommand -> Html Msg
view {direction, progress} =
  let
    anchor = progressBarAnchor direction
    width = progressBarWidth direction progress
    height = progressBarHeight direction progress
    progressBarStyle =
      style
        (
          [ ("background-color", "rgba(25,25,25, 0.2)")
          , ("position", "fixed")
          , width
          , height
          ]
          ++ anchor
        )
  in
  div [progressBarStyle] []

progressBarAnchor : Direction -> List (String, String)
progressBarAnchor direction =
  case direction of
    Northwest -> [("bottom", "0")]
    North -> [("bottom", "0")]
    Northeast -> [("bottom", "0")]
    Southeast -> [("top", "0")]
    South -> [("top", "0")]
    Southwest -> [("top", "0")]
    East -> [("left", "0"), ("top", "0")]
    West -> [("right", "0"), ("top", "0")]

progressBarWidth : Direction -> Int -> (String, String)
progressBarWidth direction progress =
  let progressPercent = toString ((progress+1) * 10)  ++ "%"
  in
  case direction of
    Northwest -> ("width", "100%")
    North -> ("width", "100%")
    Northeast -> ("width", "100%")
    Southeast -> ("width", "100%")
    South -> ("width", "100%")
    Southwest -> ("width", "100%")
    East -> ("width", progressPercent)
    West -> ("width", progressPercent)

progressBarHeight : Direction -> Int -> (String, String)
progressBarHeight direction progress =
  let progressPercent = toString ((progress+1) * 10)  ++ "%"
  in
  case direction of
    Northwest -> ("height", progressPercent)
    North -> ("height", progressPercent)
    Northeast -> ("height", progressPercent)
    Southeast -> ("height", progressPercent)
    South -> ("height", progressPercent)
    Southwest -> ("height", progressPercent)
    East -> ("height", "100%")
    West -> ("height", "100%")

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
