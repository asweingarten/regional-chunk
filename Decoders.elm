module Decoders exposing (..)

import Json.Decode exposing (Decoder, int, float)
import Json.Decode.Pipeline exposing (decode, required)

import Types exposing (GazePointJson)

gazePointJsonDecoder : Decoder GazePointJson
gazePointJsonDecoder =
  decode GazePointJson
    |> Json.Decode.Pipeline.required "state" int
    |> Json.Decode.Pipeline.required "timestamp" int
    |> Json.Decode.Pipeline.required "x" float
    |> Json.Decode.Pipeline.required "y" float
