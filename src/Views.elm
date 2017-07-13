module Views exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseEnter, onMouseLeave, onMouseOver, onMouseOut, onClick)
import Mouse exposing (Position)

import Types exposing (..)

-- commandProgressIndicator : DwellButton -> Html Msg
-- commandProgressIndicator {text, progress} =
--   let
--     -- buttonStyle =
--     --   style
--     --     [ ("width", "120px")
--     --     , ("height", "120px")
--     --     , ("background-color", "rgba(25,25,25,0.1)")
--     --     ]
--
--     progressPx = (progress |> toString) ++ "%"
--     progressStyle =
--       style
--         [ ("width", progressPx )
--         , ("height", "100%")
--         , ("background-color", "rgba(25, 0, 25, 0.3)")
--         ]
--   in
--   div
--     [ buttonStyle
--     ]
--     [ div
--       [ progressStyle
--       ]
--       []
--     ]

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
