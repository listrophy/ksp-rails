module CrashView exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Html exposing (..)
import Html.Attributes as A
import Plot exposing (..)
import Svg.Attributes as Attr
import Colors
import Formatting as F exposing (roundTo, print, (<>))
import Material.Card as Card
import Material.Elevation as Elevation
import Material.Options as Options exposing (css)
import Material.Grid as G
import Material.List as L
import Dict exposing (Dict)


stageNames : Dict Int String
stageNames =
    Dict.fromList
        [ ( 0, "determining insertion burn delta v" )
        , ( 1, "determining insertion burn location" )
        , ( 2, "waiting for insertion burn far" )
        , ( 3, "waiting for insertion burn mid" )
        , ( 4, "waiting for insertion burn near" )
        , ( 5, "insertion burning" )
        , ( 6, "finalizing insertion burn" )
        , ( 7, "transmunar orbit" )
        , ( 8, "outer munar orbit" )
        , ( 9, "mid munar orbit" )
        , ( 10, "final approach" )
        ]


stageName : Int -> String
stageName i =
    Dict.get i stageNames
        |> Maybe.withDefault "?"


formatFloat : Float -> String
formatFloat =
    print (roundTo 1)


listItemFloat : String -> Float -> Html Msg
listItemFloat title value =
    listItemString title <| formatFloat value


listItemInt : String -> Int -> Html Msg
listItemInt title value =
    listItemString title <| toString value


listItemString : String -> String -> Html Msg
listItemString title value =
    L.li []
        [ L.content [] [ text title ]
        , L.content2 [] [ text value ]
        ]


speedChart : List CrashModel -> Html Msg
speedChart models =
    case List.head models of
        Nothing ->
            text "?"

        Just model ->
            Card.view
                [ Elevation.e2
                , Card.expand
                , css "width" "auto"
                ]
                [ Card.text []
                    [ L.ul []
                        [ listItemFloat "Throttle" (100.0 * model.throttle)
                        , listItemFloat "Periapsis" model.periapsis
                        , listItemFloat "Apoapsis" model.apoapsis
                        , listItemString "Stage" (stageName model.stage)
                        , listItemString "Orbiting" model.orbitingBody
                        , listItemInt "Warp Factor" model.warpFactor
                        ]
                    ]
                ]


crashView : List CrashModel -> Html Msg
crashView models =
    G.grid []
        [ G.cell [ G.size G.All 5 ] [ speedChart models ] ]



-- [ G.cell [ G.size G.All 5 ] [ altitudeChart models ]
-- , G.cell [ G.size G.All 5 ] [ pidChart models ]
-- , G.cell [ G.size G.All 2 ]
--     [ models
--         |> List.head
--         |> Maybe.map fuelChart
--         |> Maybe.withDefault (text "")
--     ]
-- , G.cell [ G.size G.All 12 ] [ throttleView models ]
-- ]
