module Main exposing (..)

import Html
import Mouse exposing (moves, clicks)
import Keyboard
import Time exposing (millisecond, every)
import Window exposing (resizes, Size)
import Screen exposing (screenSize)

import Model exposing (Model, CommandPalette)
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
    , dwellCommandSubscription model.commandPalette
    , Keyboard.downs KeyDown
    ]

dwellCommandSubscription : CommandPalette -> Sub Msg
dwellCommandSubscription commandPalette =
  let
    activeCommand = commandPalette.activeCommand
    candidateCommand = commandPalette.candidateCommand
    activationTimeInMillis = commandPalette.activationTimeInMillis / 10
  in
  case (activeCommand, candidateCommand) of
    (Just activeCmd, Just candidateCmd) ->
      every (activationTimeInMillis * millisecond) (Dwell candidateCmd candidateCmd.direction)
    (Just activeCmd, Nothing) ->
      every (activationTimeInMillis * millisecond) (Dwell activeCmd activeCmd.direction)
    (Nothing, _) ->
      Sub.none
