module Messages exposing (..)

import ActionCable.Identifier as ID
import ActionCable.Msg as ACMsg
import Json.Decode as JD
import Material


type Msg
    = DataReceived ID.Identifier JD.Value
    | OnWelcome ()
    | CableMsg ACMsg.Msg
    | Mdl (Material.Msg Msg)
