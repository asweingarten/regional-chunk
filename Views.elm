module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave, onMouseOver, onMouseOut, onClick)
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
        , ("left", toPixels (x - sideLength - 120))
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

gazeCursor : Position -> Html Msg
gazeCursor point =
  let
    left = toPixels (point.x - 15)
    right = toPixels (point.y - 15)
    cursorStyle =
      style
        [ ("position", "fixed")
        , ("height", "30px")
        , ("width", "30px")
        , ("left", left)
        , ("top", right)
        , ("background-color", "rgba(40,40,40,0.4)")
        ]
  in
  div []
    [ button [onClick (Send "startTracker")] [text "Start"]
    , button [onClick (Send "stopTracker")] [text "Stop"]
    , p [] [text (toString point.x)]
    , div [cursorStyle] []
    ]

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
