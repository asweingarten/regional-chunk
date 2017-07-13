module DwellButton exposing(..)

import Time exposing (millisecond, every)


import Types exposing(..)

dwellSubscriptions : List DwellButton -> Sub Msg
dwellSubscriptions dwellButtons =
  let
    subs = List.map dwellSubscription dwellButtons
  in
  Sub.batch subs

dwellSubscription : DwellButton -> Sub Msg
dwellSubscription b =
  case b.active of
    True ->
      every (200*millisecond) Dwell
    False ->
      Sub.none
