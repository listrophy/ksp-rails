module Models exposing (..)

import ActionCable as AC
import Material
import Messages exposing (..)


type alias Model =
    { cable : AC.ActionCable Msg
    , ksp : KSP
    , mdl : Material.Model
    }


type KSP
    = NotActive
    | Hover (List HoverModel)
    | Orbit (List OrbitModel)
    | Crash (List CrashModel)


type KspPoint
    = HoverPoint HoverModel
    | OrbitPoint OrbitModel
    | CrashPoint CrashModel


type alias HoverModel =
    { altitude : Float
    , error : Float
    , derivative : Float
    , integral : Float
    , throttle : Float
    , fuel : Float
    }


type alias OrbitModel =
    { altitude : Float
    , speed : Float
    , pitch : Float
    , stage : String
    }


type alias CrashModel =
    { throttle : Float
    , periapsis : Float
    , apoapsis : Float
    , stage : String
    , orbitingBody : String
    , warpFactor : Int
    }
