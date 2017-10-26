module HoverView exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Html exposing (..)
import Html.Attributes as A
import Plot exposing (..)
import Svg.Attributes as Attr
import Colors
import Formatting as F exposing (roundTo, print, (<>))


maxPoints : Int
maxPoints =
    30


modelsToXY : List HoverModel -> List ( Float, Float )
modelsToXY models =
    models
        |> List.take maxPoints
        |> List.indexedMap (\idx x -> ( toFloat idx, x.altitude ))


myCustomizations : List HoverModel -> PlotCustomizations msg
myCustomizations models =
    { defaultSeriesPlotCustomizations
        | height = 300
        , width = 400
        , horizontalAxis = myHorizontalAxis models
        , toRangeHighest = max <| toFloat maxPoints
        , toRangeLowest = min 0
        , toDomainHighest = max 250
        , toDomainLowest = min 70
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
                    print (F.s "Altitude: " <> roundTo 1) altitude
    in
        div []
            [ h2 [] [ text altStr ]
            , viewSeriesCustom
                (myCustomizations models)
                [ line <| List.map (\( x, y ) -> clear x y)
                , customSeries
                    normalAxis
                    (Linear Nothing [ Attr.stroke "#333333" ])
                    (always <| [ clear 0 180, clear (toFloat maxPoints) 180 ])
                ]
                (modelsToXY models)
            ]


hoverView : List HoverModel -> Html Msg
hoverView models =
    div [ A.style [ ( "height", "300px" ), ( "width", "400px" ) ] ]
        [ altitudeChart models ]
