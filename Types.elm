module Types exposing (..)

import Time exposing(Time)
import Mouse exposing(Position)

type Direction
  = West
  | East
  | North
  | South
  | Northwest
  | Northeast
  | Southwest
  | Southeast

type Msg
  = CursorMoved Position
  | MouseClick Position
  | ButtonEntered
  | ButtonLeft
  | Dwell Time
  | FireEvent Direction

type alias DwellButton =
  { text: String
  , progress: Int
  , active: Bool
  }

type alias Square =
  { x: Int
  , y: Int
  , sideLength: Int
  }
