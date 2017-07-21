module ChangeDirection exposing (update)

import Model exposing (Model)

import Types exposing (..)

{-
  - if there is an active command
    - create a candidate command that has a progress threshold equal to the progress of the active command
  - if there is not an active command
    - create a new active command with the current direction


-}

update : Model -> Direction -> (Model, Cmd Msg)
update model newDirection =
  let
    activeCommand =
      case model.commandPalette.activeCommand of
        Nothing -> { direction = newDirection, progress = 0, threshold = 10 }
        Just command ->
          case (equivalentDirection command.direction newDirection, command.progress > 0) of
            (_, True) -> command
            (True, False) -> command
            (False, False) -> DwellCommand newDirection 0 10
    candidateCmd = candidateCommand model.commandPalette.activeCommand newDirection
    cp = model.commandPalette
    commandPalette = { cp
                     | activeCommand = Just activeCommand
                     , candidateCommand = candidateCmd
                     }
  in
    ({model | direction = Just newDirection, commandPalette = commandPalette }, Cmd.none)

candidateCommand : Maybe DwellCommand -> Direction -> Maybe DwellCommand
candidateCommand activeCommand direction =
  case activeCommand of
    Nothing -> Nothing
    Just command ->
      case (command.progress, equivalentDirection command.direction direction) of
        (0, _) -> Nothing
        (_, True) -> Nothing
        (_, False) -> Just (DwellCommand direction 0 command.progress)

equivalentDirection : Direction -> Direction -> Bool
equivalentDirection curDir newDir =
  case curDir of
    North -> newDir == curDir || newDir == Northeast || newDir == Northwest
    South -> newDir == curDir || newDir == Southeast || newDir == Southwest
    East  -> newDir == curDir || newDir == Northeast || newDir == Southeast
    West  -> newDir == curDir || newDir == Northwest || newDir == Southwest
    _     -> False
