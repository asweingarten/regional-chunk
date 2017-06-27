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

cursorZone : Square -> Html Msg
cursorZone {x, y, sideLength} =
  let
    left = toPixels x
    top = toPixels y
    len = toPixels sideLength
    myStyle =
      style
        [ ("position", "fixed")
        , ("left", left)
        , ("top", top)
        , ("width", len)
        , ("height", len)
        , ("background-color", "rgba(25,25,75,0.4)")
        ]
  in
  div [myStyle] []

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
