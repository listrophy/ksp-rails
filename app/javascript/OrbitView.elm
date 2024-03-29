module OrbitView exposing (..)

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


speedChart : List OrbitModel -> Html Msg
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
                        [ listItemFloat "Altitude" model.altitude
                        , listItemFloat "Speed" model.speed
                        , listItemFloat "Pitch" model.pitch
                        , listItemInt "Stage" model.stage
                        ]
                    ]
                ]


orbitView : List OrbitModel -> Html Msg
orbitView models =
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
