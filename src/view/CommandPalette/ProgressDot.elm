module CommandPalette.ProgressDot exposing (view)

import Html exposing (..)
import Html.Attributes exposing (style)

import Model exposing (CommandPalette)
import Types exposing (..)

view : DwellCommand -> Int -> Int -> Int -> Html Msg
view command x y halfSideLength =
  let
    dotRadius = 20
    distanceToEdge = halfSideLength - dotRadius
    left = progressDotLeft command x dotRadius distanceToEdge
    top = progressDotTop command y dotRadius distanceToEdge
    progressDotStyle =
      style
        [ ("position", "fixed")
        , ("left", toPixels left)
        , ("top", toPixels top)
        , ("width", toPixels <| dotRadius * 2)
        , ("height", toPixels <| dotRadius * 2)
        , ("background-color", "rgba(224, 255, 255, 0.8)")
        , ("border-radius", toPixels dotRadius)
        ]
  in
  div [progressDotStyle] []

progressDotLeft : DwellCommand -> Int -> Int -> Int -> Int
progressDotLeft {direction, progress} x dotRadius distanceToEdge =
  case direction of
    North -> x - dotRadius
    South -> x - dotRadius
    East  -> x - dotRadius + ((distanceToEdge // 10 ) * progress)
    Northeast  -> x - dotRadius + ((distanceToEdge // 10 ) * progress)
    Southeast  -> x - dotRadius + ((distanceToEdge // 10 ) * progress)
    West  -> x - dotRadius - ((distanceToEdge // 10 ) * progress)
    Northwest  -> x - dotRadius - ((distanceToEdge // 10 ) * progress)
    Southwest  -> x - dotRadius - ((distanceToEdge // 10 ) * progress)

progressDotTop : DwellCommand -> Int -> Int -> Int -> Int
progressDotTop {direction, progress} y dotRadius distanceToEdge =
  case direction of
    North -> y - dotRadius - ((distanceToEdge // 10 ) * progress)
    Northwest  -> y - dotRadius - ((distanceToEdge // 10 ) * progress)
    Northeast  -> y - dotRadius - ((distanceToEdge // 10 ) * progress)
    South -> y - dotRadius + ((distanceToEdge // 10 ) * progress)
    Southeast  -> y - dotRadius + ((distanceToEdge // 10 ) * progress)
    Southwest  -> y - dotRadius + ((distanceToEdge // 10 ) * progress)
    East  -> y - dotRadius
    West  -> y - dotRadius

toPixels : Int -> String
toPixels int =
  (toString int) ++ "px"
