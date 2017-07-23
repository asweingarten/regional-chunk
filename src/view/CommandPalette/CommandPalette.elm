module CommandPalette exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)

import Model exposing (CommandPalette)
import Types exposing (..)

import CommandPalette.ProgressBar as ProgressBar
import CommandPalette.ProgressDot as ProgressDot


view : CommandPalette -> Html Msg
view {dimensions, isActive, activeCommand, candidateCommand, activationTimeInMillis} =
  let
    x = dimensions.x
    y = dimensions.y
    sideLength = dimensions.sideLength
    left = toPixels (x - sideLength)
    top = toPixels (y - sideLength)
    len = toPixels (sideLength * 2)
    color = case isActive of
      True ->
        "rgba(25,25,75,0.5)"
      False ->
        "rgba(25,25,75,0.2)"
    progressDot =
      case activeCommand of
        Nothing -> div [] []
        Just command -> ProgressDot.view command x y sideLength
    progressBar =
      case activeCommand of
        Nothing -> div [] []
        Just command -> ProgressBar.view command
    candidateBar =
      case candidateCommand of
        Nothing -> div [] []
        Just command -> ProgressBar.view command
    fullscreenStyle =
      style
        [ ("position", "absolute")
        , ("width", "100%")
        , ("height", "100%")
        , ("left", "0")
        , ("top", "0")
        ]
    myStyle =
      style
        [ ("position", "fixed")
        , ("left", left)
        , ("top", top)
        , ("width", len)
        , ("height", len)
        , ("background-color", color)
        ]
    westStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels (x - sideLength - 170))
        , ("top", toPixels (y - 12))
        , ("font-size", toPixels 48 )
        ]
    northStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels (x - 24))
        , ("top", toPixels (y - sideLength - 70))
        , ("font-size", toPixels 48 )
        ]
    eastStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels (x + sideLength))
        , ("top", toPixels (y - 12))
        , ("font-size", toPixels 48 )
        ]
    southStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels (x - 24))
        , ("top", toPixels (y + sideLength))
        , ("font-size", toPixels 48 )
        ]
  in
  div []
    [ div [myStyle] []
    -- , progressDot
    , progressBar
    , candidateBar
    , div [westStyle] [text "Previous"]
    , div [northStyle] [text "Up"]
    , div [eastStyle] [text "Next"]
    , div [southStyle] [text "Select"]
    ]

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
