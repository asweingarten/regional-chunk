module Model exposing (..)

import Task
import Mouse exposing (Position)
import Window exposing (Size)

import Types exposing (..)

type alias CommandPalette =
  { dimensions: Square
  , isActive: Bool
  , activeCommand: Maybe DwellCommand
  , candidateCommand: Maybe DwellCommand
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
  , showGazeCursor : Bool
  }

init : (Model, Cmd Msg)
init =
  (Model
    { x = -1, y = -1 }
    (CommandPalette { x = 920, y = 500, sideLength = 115} False Nothing Nothing 3000)
    {x = 0, y = 0}
    (Size 0 0)
    (Size 0 0)
    Nothing
    False
    False
  , Task.perform WindowResize Window.size)
