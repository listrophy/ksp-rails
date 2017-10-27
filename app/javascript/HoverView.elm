module HoverView exposing (..)

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
import Material.Options as Options exposing (css, cs)
import Material.Grid as G


formatFloat : Float -> String
formatFloat =
    print (roundTo 1)


floatLabel : String -> Float -> String
floatLabel title num =
    print (F.s (title ++ ": ") <> roundTo 1) num


maxPoints : Int
maxPoints =
    30


modelAltitudesToXY : List HoverModel -> List ( Float, Float )
modelAltitudesToXY models =
    models
        |> List.take maxPoints
        |> List.indexedMap (\idx x -> ( toFloat idx, x.altitude ))


modelPidsToXY : List HoverModel -> List ( Float, Float, Float, Float )
modelPidsToXY models =
    models
        |> List.take maxPoints
        |> List.indexedMap (\idx x -> ( toFloat idx, x.error, x.integral, x.derivative ))


altitudeCustomizations : List HoverModel -> PlotCustomizations msg
altitudeCustomizations models =
    { defaultSeriesPlotCustomizations
        | height = 300
        , width = 400
        , horizontalAxis = myHorizontalAxis models
        , toRangeHighest = max <| toFloat maxPoints
        , toRangeLowest = min 0
        , toDomainHighest = max 350
        , toDomainLowest = min 100
    }


pidCustomizations : List HoverModel -> PlotCustomizations msg
pidCustomizations models =
    { defaultSeriesPlotCustomizations
        | height = 300
        , width = 400
        , horizontalAxis = myHorizontalAxis models
        , toRangeHighest = max <| toFloat maxPoints
        , toRangeLowest = min 0
    }


myHorizontalAxis : List HoverModel -> Axis
myHorizontalAxis models =
    customAxis <|
        \summary ->
            { position = closestToZero
            , axisLine = Just (simpleLine summary)
            , ticks = List.map simpleTick (decentPositions summary)
            , labels =
                [ LabelCustomizations (viewLabel [] "now") 0.0
                , LabelCustomizations (viewLabel [] ("+" ++ toString maxPoints)) (toFloat maxPoints)
                ]
            , flipAnchor = False
            }


altitudeChart : List HoverModel -> Html Msg
altitudeChart models =
    let
        altStr =
            case List.head models of
                Nothing ->
                    "Altitude: ?"

                Just { altitude } ->
                    floatLabel "Altitude" altitude
    in
        Card.view
            [ Elevation.e2 ]
            [ Card.title [] [ Card.head [] [ text altStr ] ]
            , Card.text [] <|
                [ viewSeriesCustom
                    (altitudeCustomizations models)
                    [ line <| List.map (\( x, y ) -> clear x y)
                    , customSeries
                        normalAxis
                        (Linear Nothing [ Attr.stroke "#333333" ])
                        (always <| [ clear 0 250, clear (toFloat maxPoints) 250 ])
                    ]
                    (modelAltitudesToXY models)
                ]
            ]


pidChart : List HoverModel -> Html Msg
pidChart models =
    Card.view
        [ Elevation.e2 ]
        [ Card.title [] [ Card.head [] [ text "PID values" ] ]
        , Card.text [] <|
            [ viewSeriesCustom
                (pidCustomizations models)
                [ coloredLine "#f00" <| List.map (\( x, p, _, _ ) -> clear x p)
                , coloredLine "#0f0" <| List.map (\( x, _, i, _ ) -> clear x i)
                , coloredLine "#00f" <| List.map (\( x, _, _, d ) -> clear x d)
                ]
                (modelPidsToXY models)
            ]
        ]


coloredLine : String -> (data -> List (DataPoint msg)) -> Series data msg
coloredLine color toDataPoints =
    { axis = normalAxis
    , interpolation = Linear Nothing [ Attr.stroke color ]
    , toDataPoints = toDataPoints
    }


fuelChart : HoverModel -> Html Msg
fuelChart { fuel } =
    let
        maxFuel =
            400.0

        fuelGauge =
            Options.div
                [ css "width" "40px"
                , css "height" "200px"
                , css "display" "flex"
                , css "flex-direction" "column"
                , css "justify-content" "flex-end"
                , css "border" "1px solid #999"
                , css "padding" "2px"
                ]
                [ Options.div
                    [ css "height" ((toString <| 100.0 * fuel / maxFuel) ++ "%")
                    , css "background-color" "red"
                    ]
                    []
                ]
    in
        Card.view
            [ Elevation.e2
            , Card.expand
            , css "width" "auto"
            ]
            [ Card.title [] [ Card.head [] [ text "Fuel" ] ]
            , Card.text
                []
                [ Options.div
                    [ css "display" "flex"
                    , css "flex-direction" "column"
                    , css "align-items" "center"
                    , css "padding-right" "16px"
                    ]
                    [ fuelGauge
                    , text <| formatFloat fuel
                    ]
                ]
            ]


throttleView : List HoverModel -> Html Msg
throttleView models =
    let
        throttle =
            models
                |> List.head
                |> Maybe.map (.throttle >> ((*) 100.0))
                |> Maybe.withDefault 0.0
                |> formatFloat
                |> flip (++) "%"
    in
        Card.view
            [ Elevation.e2
            , Card.expand
            , css "width" "auto"
            ]
            [ Card.title []
                [ Card.head
                    [ css "display" "flex"
                    , css "width" "100%"
                    , css "align-items" "stretch"
                    ]
                    [ Options.div
                        [ css "flex-grow" "0"
                        , css "margin-right" "2em"
                        ]
                        [ text "Throttle" ]
                    , Options.div
                        [ css "flex-grow" "1"
                        , css "border" "1px solid #333"
                        , css "padding" "2px"
                        , css "display" "flex"
                        , css "height" "24px"
                        , css "margin-right" "2em"
                        , cs "throttle-gauge"
                        ]
                        [ Options.div
                            [ css "background-color" "green"
                            , css "width" throttle
                            , css "height" "100%"
                            ]
                            []
                        ]
                    , Options.div
                        [ css "flex-grow" "0"
                        , css "flex-basis" "5em"
                        ]
                        [ text throttle ]
                    ]
                ]
            ]


hoverView : List HoverModel -> Html Msg
hoverView models =
    G.grid []
        [ G.cell [ G.size G.All 5, G.size G.Phone 12 ] [ altitudeChart models ]
        , G.cell [ G.size G.All 5, G.size G.Phone 12 ] [ pidChart models ]
        , G.cell [ G.size G.All 2, G.size G.Phone 12 ]
            [ models
                |> List.head
                |> Maybe.map fuelChart
                |> Maybe.withDefault (text "")
            ]
        , G.cell [ G.size G.All 12 ] [ throttleView models ]
        , G.cell [ G.size G.All 12 ] [ br [] [], br [] [], br [] [] ]
        ]
