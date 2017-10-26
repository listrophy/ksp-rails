module HoverView exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Html exposing (..)
import Html.Attributes as A
import Plot exposing (..)
import Svg.Attributes as Attr
import Colors
import Formatting as F exposing (roundTo, print, (<>))


modelsToXY : List HoverModel -> List ( Float, Float )
modelsToXY models =
    models
        |> List.take 20
        |> List.indexedMap (\idx x -> ( toFloat idx, x.altitude ))


{--}
mySeries_ : (List ( Float, Float ) -> List (DataPoint msg)) -> Series (List ( Float, Float )) msg
mySeries_ models =
    { axis = normalAxis
    , interpolation = Linear Nothing [ Attr.stroke Colors.pinkStroke ]
    , toDataPoints = models
    }



{--
    customSeries
        myAxis
        myInterpolation
        (List.map (\( x, y ) -> clear x y))
--}


mySeries : Series (List ( Float, Float )) msg
mySeries =
    List.map (\( x, y ) -> clear x y)
        |> mySeries_


myCustomizations : List HoverModel -> PlotCustomizations msg
myCustomizations models =
    { defaultSeriesPlotCustomizations
        | height = 300
        , width = 400
        , horizontalAxis = myHorizontalAxis models
        , toRangeHighest = max 20
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
                , LabelCustomizations (viewLabel [] "+20") 20.0
                ]

            --, labels = List.map simpleLabel (decentPositions summary)
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
                    let
                        fmt =
                            F.s "Altitude: " <> roundTo 1
                    in
                        print fmt altitude
    in
        div []
            [ h2 [] [ text altStr ]
            , viewSeriesCustom
                (myCustomizations models)
                [ mySeries ]
                (modelsToXY models)
            ]


hoverView : List HoverModel -> Html Msg
hoverView models =
    div [ A.style [ ( "height", "300px" ), ( "width", "400px" ) ] ]
        [ altitudeChart models ]



-- models
--     |> List.map (\x -> div [] [ text <| toString x.altitude ])
--     |> div []
