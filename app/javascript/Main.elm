module Main exposing (..)

import Json.Decode as JD
import Html exposing (..)
import Html.Attributes exposing (style)
import ActionCable as AC
import ActionCable.Identifier as ID
import ActionCable.Msg as ACMsg
import Models exposing (..)
import Messages exposing (..)
import HoverView exposing (hoverView)
import OrbitView exposing (orbitView)
import Material
import Material.Layout as Layout
import Material.Color as Color
import Material.Options as Options exposing (css)


-- INIT


type alias Flags =
    { environment : String }


server : Flags -> String
server { environment } =
    case environment of
        "development" ->
            "localhost:3000"

        _ ->
            "space.fail"


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { cable =
            AC.initCable ("ws://" ++ (server flags) ++ "/cable")
                |> AC.onDidReceiveData (Just DataReceived)
                |> AC.onWelcome (Just OnWelcome)
                |> AC.withDebug True
      , ksp = NotActive
      , mdl = Material.model
      }
    , Layout.sub0 Mdl
    )



-- VIEW


boxed : List (Options.Property a b)
boxed =
    [ css "margin" "auto"
    , css "padding-left" "8%"
    , css "padding-right" "8%"
    ]


view : Model -> Html Msg
view model =
    let
        subview =
            case model.ksp of
                NotActive ->
                    text "Not Active"

                Hover model_ ->
                    hoverView model_

                Orbit model_ ->
                    orbitView model_

                Crash model_ ->
                    crashView model_
    in
        Layout.render Mdl
            model.mdl
            []
            { header = myHeader model
            , drawer = []
            , tabs = ( [], [] )
            , main = [ mainWrapper subview ]
            }


mainWrapper : Html Msg -> Html Msg
mainWrapper contents =
    Options.div boxed
        [ Options.styled Html.h1
            [ Color.text Color.primary ]
            [ text "Telemetry" ]
        , contents
        ]


myHeader : Model -> List (Html Msg)
myHeader model =
    let
        stateStr =
            case model.ksp of
                NotActive ->
                    "Not Active"

                Hover _ ->
                    "Project Mercury: Hover"

                Orbit _ ->
                    "Project Gemini: Orbit"

                Crash _ ->
                    "Project Apollo: To The Mun"
    in
        [ Layout.row
            [ css "transition" "height 333ms ease-in-out 0s"
            ]
            [ Layout.title [] [ text "kerbal_space_program.rb" ]
            , Layout.spacer
            , Layout.navigation []
                [ text stateStr ]
            ]
        ]


crashView : List CrashModel -> Html Msg
crashView model =
    text "crashing"



-- UPDATE


dataDecoder : String -> JD.Decoder a -> JD.Decoder a
dataDecoder name subDecoder =
    let
        stringToDataDecoder =
            JD.decodeString subDecoder
                >> Result.map JD.succeed
                >> Result.withDefault (JD.fail "decoding failed")
    in
        JD.field name JD.string
            |> JD.andThen stringToDataDecoder


hoverDecoder : JD.Decoder KspPoint
hoverDecoder =
    let
        subDecoder : JD.Decoder HoverModel
        subDecoder =
            JD.map6 HoverModel
                (JD.field "altitude" JD.float)
                (JD.field "error" JD.float)
                (JD.field "derivative" JD.float)
                (JD.field "integral" JD.float)
                (JD.field "throttle" JD.float)
                (JD.field "fuel" JD.float)
    in
        dataDecoder "hover" subDecoder
            |> JD.map HoverPoint


orbitDecoder : JD.Decoder KspPoint
orbitDecoder =
    let
        subDecoder =
            JD.map4 OrbitModel
                (JD.field "altitude" JD.float)
                (JD.field "speed" JD.float)
                (JD.field "pitch" JD.float)
                (JD.field "stage" JD.string)
    in
        dataDecoder "orbit" subDecoder
            |> JD.map OrbitPoint


crashDecoder : JD.Decoder KspPoint
crashDecoder =
    let
        subDecoder =
            JD.map6 CrashModel
                (JD.field "throttle" JD.float)
                (JD.field "periapsis" JD.float)
                (JD.field "apoapsis" JD.float)
                (JD.field "stage" JD.string)
                (JD.field "orbitingBody" JD.string)
                (JD.field "warpFactor" JD.int)
    in
        dataDecoder "crash" subDecoder
            |> JD.map CrashPoint


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnWelcome () ->
            subscribe model

        DataReceived _ value ->
            ( dataReceived value model, Cmd.none )

        CableMsg msg_ ->
            AC.update msg_ model.cable
                |> (\( cable, cmd ) -> ( { model | cable = cable }, cmd ))

        Mdl message_ ->
            Material.update Mdl message_ model


dataReceived : JD.Value -> Model -> Model
dataReceived value ({ ksp } as model) =
    let
        decoders =
            [ hoverDecoder
            , orbitDecoder
            , crashDecoder
            ]

        newKsp =
            case JD.decodeValue (JD.oneOf decoders) value of
                Ok (HoverPoint model) ->
                    case ksp of
                        Hover list ->
                            Hover (model :: list)

                        _ ->
                            Hover (model :: [])

                Ok (OrbitPoint model) ->
                    case ksp of
                        Orbit list ->
                            Orbit (model :: list)

                        _ ->
                            Orbit (model :: [])

                Ok (CrashPoint model) ->
                    case ksp of
                        Crash list ->
                            Crash (model :: list)

                        _ ->
                            Crash (model :: [])

                _ ->
                    NotActive
    in
        { model | ksp = newKsp }


subscribe : Model -> ( Model, Cmd Msg )
subscribe model =
    case AC.subscribeTo (channelId "orbit") model.cable of
        Ok ( cable, cmd ) ->
            { model | cable = cable } ! [ cmd ]

        Err err ->
            ( model, Cmd.none )


channelId : String -> ID.Identifier
channelId _ =
    ID.newIdentifier "KspChannel" []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AC.listen CableMsg model.cable
        , Layout.subs Mdl model.mdl
        ]



-- MAIN


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
