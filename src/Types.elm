module Types exposing (..)

import Time exposing(Time)
import Mouse exposing(Position)
import Window exposing(Size)
import Keyboard

type Direction
  = West
  | East
  | North
  | South
  | Northwest
  | Northeast
  | Southwest
  | Southeast

type alias DwellCommand =
  { direction : Direction
  , progress  : Int
  }

type Msg
  = CursorMoved Position
  | MouseClick Position
  | Dwell Direction Time
  | ChangeDirection Direction
  | NewGazePoint GazePoint
  | Send String
  | WindowResize Size
  | ScreenSize Size
  | SetActivationTime String
  | KeyDown Keyboard.KeyCode

type alias Square =
  { x: Int
  , y: Int
  , sideLength: Int
  }

type alias GazePoint =
  { state : Int
  , timestamp : Int
  , x : Int
  , y : Int
  }
