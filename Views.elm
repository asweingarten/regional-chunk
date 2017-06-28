module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave, onMouseOver, onMouseOut)
import Mouse exposing (Position)

import Types exposing (..)

dwellButton : DwellButton -> Html Msg
dwellButton {text, progress} =
  let
    buttonStyle =
      style
        [ ("width", "120px")
        , ("height", "120px")
        , ("background-color", "rgba(25,25,25,0.1)")
        ]
    progressPx = (progress |> toString) ++ "%"
    progressStyle =
      style
        [ ("width", progressPx )
        , ("height", "100%")
        , ("background-color", "rgba(25, 0, 25, 0.3)")
        ]
  in
  div
    [ buttonStyle
    , onMouseEnter ButtonEntered
    , onMouseLeave ButtonLeft
    ]
    [ div
      [ progressStyle
      ]
      []
    ]

cursorZone : Square -> Bool -> Html Msg
cursorZone {x, y, sideLength} isActive =
  let
    left = toPixels (x - sideLength)
    top = toPixels (y - sideLength)
    len = toPixels (sideLength * 2)
    color = case isActive of
      True ->
        "rgba(25,25,75,0.8)"
      False ->
        "rgba(25,25,75,0.2)"
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
        , ("left", toPixels (x - sideLength - 45))
        , ("top", toPixels (y - 12))
        ]
    northStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels (x - 24))
        , ("top", toPixels (y - sideLength - 18))
        ]
    eastStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels (x + sideLength))
        , ("top", toPixels (y - 12))
        ]
    southStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels (x - 24))
        , ("top", toPixels (y + sideLength))
        ]
  in
  div []
    [ div [myStyle] []
    , div [westStyle] [text "West"]
    , div [northStyle] [text "North"]
    , div [eastStyle] [text "East"]
    , div [southStyle] [text "South"]
    ]

displacement : Position -> Square -> Html Msg
displacement position square =
  let
    deltaX = toString (position.x - square.x)
    deltaY = toString (position.y - square.y)
  in
  text (deltaX ++ " :: " ++ deltaY)

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
