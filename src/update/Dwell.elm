module Dwell exposing (update)

import Time exposing (Time)

import Model exposing (Model)
import Types exposing (..)
import Ports

-- How can the Dwell message distnguish between activeCommand and candidateCommand.... should it?
-- we can check the states of the active and candidate commands after this returns

update : Model -> DwellCommand -> Direction -> Time -> (Model, Cmd Msg)
update model command direction time =
  let
    c = model.commandPalette
    updatedCommand = { command | progress = command.progress + 1 }
    thresholdReached = updatedCommand.progress == updatedCommand.threshold
  in
    case (c.activeCommand, c.candidateCommand, thresholdReached) of
      (Just activeCommand, Nothing, True) ->
        let cmdP = { c | activeCommand = Nothing, isActive = False }
        in
        ({ model | commandPalette = cmdP }, Ports.commandFired <| toString activeCommand.direction)
      (Just activeCommand, Nothing, False) ->
        let cmdP = { c | activeCommand = Just updatedCommand }
        in
        ({ model | commandPalette = cmdP }, Cmd.none)
      (Just activeCommand, Just candidateCommand, True) ->
        let updatedActiveCommand = activeCommand.direction == updatedCommand.direction
        in
        case updatedActiveCommand of
          True ->
            -- Active Command is fired
            let cmdP = { c | activeCommand = Nothing, isActive = False, candidateCommand = Nothing }
            in
            ({ model | commandPalette = cmdP }, Ports.commandFired <| toString activeCommand.direction)
          False ->
            -- Candidate Command takes over
            let newActiveCmd = Just { candidateCommand | threshold = 10 }
                cmdP = { c | activeCommand = newActiveCmd, candidateCommand = Nothing }
            in
            ({ model | commandPalette = cmdP }, Cmd.none)

      (Just activeCommand, Just candidateCommand, False) ->
        let updatedActiveCommand = activeCommand.direction == updatedCommand.direction
        in
        case updatedActiveCommand of
          True ->
            -- update the active command
            let cmdP = { c | activeCommand = Just updatedCommand }
            in
            ({ model | commandPalette = cmdP }, Cmd.none)
          False ->
            -- update the candidate command
            let cmdP = { c | candidateCommand = Just updatedCommand }
            in
            ({ model | commandPalette = cmdP }, Cmd.none)
      (_,_,_) -> (model, Cmd.none)


  -- case updatedCommand.progress >= updatedCommand.threshold of
  --   False ->
  --     let commandPalette = { c | activeCommand = Just updatedCommand }
  --     in
  --     ({ model | commandPalette = commandPalette }, Cmd.none)
  --   True ->
  --     let commandPalette = { c | activeCommand = Nothing, isActive = False }
  --     in
  --     ( { model | commandPalette = commandPalette }
  --     , Ports.commandFired <| toString activeCommand.direction) -- FIRE THE COMMAND
