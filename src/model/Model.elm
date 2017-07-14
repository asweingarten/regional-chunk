module Model exposing (..)

import Task
import Mouse exposing (Position)
import Window exposing (Size)

import Types exposing (..)

type alias CommandPalette =
  { dimensions: Square
  , isActive: Bool
  , activeCommand: Maybe DwellCommand
  , activationTimeInMillis: Float
  }

type alias Model =
  { mousePosition: Position
  , commandPalette: CommandPalette
  , gazePosition: Position
  , windowSize : Size
  , screenSize : Size
  , direction : Maybe Direction
  , showConfiguration : Bool
  }

init : (Model, Cmd Msg)
init =
  (Model
    { x = -1, y = -1 }
    (CommandPalette { x = 0, y = 0, sideLength = 0} False Nothing 3000)
    {x = 0, y = 0}
    (Size 0 0)
    (Size 0 0)
    Nothing
    False
  , Task.perform WindowResize Window.size)
