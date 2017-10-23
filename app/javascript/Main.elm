module Main exposing (..)

import Json.Decode as JD
import Html exposing (Html, h1, text)
import Html.Attributes exposing (style)
import ActionCable as AC
import ActionCable.Identifier as ID
import ActionCable.Msg as ACMsg


-- MODEL


type alias Model =
    { cable :
        AC.ActionCable Msg
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( { cable =
            AC.initCable "ws://localhost:3000/cable"
                |> AC.onDidReceiveData (Just DataReceived)
                |> AC.onWelcome (Just OnWelcome)
                |> AC.withDebug True
      }
    , Cmd.none
    )



-- VIEW


view : Model -> Html Msg
view model =
    -- The inline style is being used for example purposes in order to keep this example simple and
    -- avoid loading additional resources. Use a proper stylesheet when building your own app.
    h1 [ style [ ( "display", "flex" ), ( "justify-content", "center" ) ] ]
        [ text "Hello Elm!" ]



-- MESSAGE


type Msg
    = DataReceived ID.Identifier JD.Value
    | OnWelcome ()
    | CableMsg ACMsg.Msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnWelcome () ->
            subscribe model

        DataReceived id value ->
            let
                _ =
                    Debug.log "value" value

                _ =
                    Debug.log "id" id
            in
                ( model, Cmd.none )

        CableMsg msg_ ->
            AC.update msg_ model.cable
                |> (\( cable, cmd ) -> ( { model | cable = cable }, cmd ))


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


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
