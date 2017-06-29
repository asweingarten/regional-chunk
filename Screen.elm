port module Screen exposing (..)

import Window exposing (Size)

port screenSize : (Size -> msg) -> Sub msg
