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
import Material


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
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view { ksp } =
    let
        subview =
            case ksp of
                NotActive ->
                    text "Not Active"

                Hover model ->
                    hoverView model

                Orbit model ->
                    orbitView model

                Crash model ->
                    crashView model
    in
        div []
            [ header
                []
                [ h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
                    [ text "Hello KRW!" ]
                ]
            , main_ [] [ subview ]
            ]


orbitView : List OrbitModel -> Html Msg
orbitView model =
    text "orbiting"


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
            JD.map OrbitModel
                (JD.field "throttle" JD.float)
    in
        dataDecoder "orbit" subDecoder
            |> JD.map OrbitPoint


crashDecoder : JD.Decoder KspPoint
crashDecoder =
    let
        subDecoder =
            JD.map CrashModel
                (JD.field "throttle" JD.float)
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
