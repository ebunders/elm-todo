module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onCheck, onClick)
import Navigation exposing (..)
import UrlParser exposing (oneOf)


main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { page : Page }


type Page
    = TasksPage
    | EditTaskPage



-- route = o


init : Location -> ( Model, Cmd Msg )
init location =
    ( { page = (locationToPage location) }
    , Cmd.none
    )



-- UPDATE
-- route : Url.Parser (Route -> a) a


route : UrlParser.Parser (Page -> a) a
route =
    oneOf
        [ UrlParser.map TasksPage (UrlParser.s "tasks")
        , UrlParser.map EditTaskPage (UrlParser.s "edit")
        ]


type Msg
    = NewUrl String
    | UrlChange Navigation.Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUrl url ->
            -- Navigate to the new url
            ( model
            , Navigation.newUrl url
            )

        UrlChange location ->
            -- the url has changed, update the current page
            ( { model | page = (locationToPage location) }
            , Cmd.none
            )


locationToPage : Location -> Page
locationToPage location =
    case (UrlParser.parseHash route location) of
        Just page ->
            page

        Nothing ->
            TasksPage



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        page =
            case model.page of
                TasksPage ->
                    viewTasksPage model

                EditTaskPage ->
                    viewEditTaskPage model
    in
        div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-6 mx-auto" ]
                    [ viewNavigation
                    , page
                    ]
                ]
            ]


viewNavigation : Html Msg
viewNavigation =
    div []
        [ a [ onClick (NewUrl "#tasks") ] [ text "Tasks page" ]
        , span [] [ text " - " ]
        , a [ onClick (NewUrl "#edit") ] [ text "Edit page" ]
        ]


viewTasksPage : Model -> Html Msg
viewTasksPage model =
    h1 [] [ text "Tasks Page" ]


viewEditTaskPage : Model -> Html msg
viewEditTaskPage model =
    h1 [] [ text "Edit task page" ]
