module Main exposing (..)

import Html
import Mouse exposing (moves, clicks)
import Time exposing (millisecond, every)
import Window exposing (resizes, Size)
import Screen exposing (screenSize)

import Model exposing (Model)
import Update
import View
import Types exposing (..)
import EyeTracker

-- TODO
-- Change Square type to something that better described cursor activation zone

main =
  Html.program
  { init = Model.init
  , view = View.view
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

dwellCommandSubscription : Maybe DwellCommand -> Sub Msg
dwellCommandSubscription dwellCmd =
  case dwellCmd of
    Just dwellCmd ->
      every (200 * millisecond) (Dwell dwellCmd.direction)
    Nothing ->
      Sub.none
