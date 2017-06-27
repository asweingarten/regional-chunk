module Types exposing (..)

import Time exposing(Time)
import Mouse exposing(Position)

type Msg
  = CursorMoved Position
  | MouseClick Position
  | ButtonEntered
  | ButtonLeft
  | Dwell Time
  | FireEvent String

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
