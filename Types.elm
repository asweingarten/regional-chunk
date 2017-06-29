module Types exposing (..)

import Time exposing(Time)
import Mouse exposing(Position)
import Window exposing(Size)

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
  | NewGazePoint GazePoint
  | Send String
  | WindowResize Size
  | ScreenSize Size

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

type alias GazePoint =
  { state : Int
  , timestamp : Int
  , x : Int
  , y : Int
  }

type alias GazePointJson =
  { state : Int
  , timestamp : Int
  , x : Float
  , y : Float
  }
