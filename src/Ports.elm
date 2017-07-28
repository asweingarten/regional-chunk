port module Ports exposing (..)

import Window exposing (Size)

import Mouse exposing (Position)

port commandFired : String -> Cmd msg
port activated : String -> Cmd msg

port clicks : (Position -> msg) -> Sub msg
port moves : (Position -> msg) -> Sub msg

port screenSize : (Size -> msg) -> Sub msg
