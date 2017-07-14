module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class)
import Mouse exposing (Position, moves, clicks)
import Time exposing (Time)
import Debug exposing (log)
import Window exposing (resizes, Size)
import Screen exposing (screenSize)

import Model exposing (Model)
import Update
import Views exposing (displacement, gazeCursor)
import CommandSquare exposing (commandSquare, dwellCommandSubscription)
import Types exposing (..)
import EyeTracker

-- TODO
-- Change Square type to something that better described cursor activation zone

main =
  Html.program
  { init = Model.init
  , view = view
  , update = Update.update
  , subscriptions = subscriptions
  }

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.batch
    [ moves CursorMoved
    , clicks MouseClick
    , EyeTracker.subscription model.screenSize model.windowSize
    , resizes WindowResize
    , screenSize ScreenSize
    , dwellCommandSubscription model.commandPalette.activeCommand
    ]

-- VIEW

view : Model -> Html Msg
view {mousePosition, commandPalette, gazePosition, windowSize, screenSize, direction} =
  let
    x = toString mousePosition.x
    y = toString mousePosition.y
    wWidth = toString windowSize.width
    wHeight = toString windowSize.height
    sWidth = toString screenSize.width
    sHeight = toString screenSize.height
    -- progress =
    --   case activeCommand of
    --     Nothing -> toString 0
    --     Just command -> toString command.progress
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
    ++ ([commandSquare commandPalette.dimensions commandPalette.isActive commandPalette.activeCommand])
    -- ++ ([displacement mousePosition cursorActivationZone])
    ++ ([gazeCursor gazePosition])
    ++ ([div [class "div", myStyle] [text <| justDirection ++  " "]])-- ++ progress]])
    )
