module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (checked, class, type_)
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
    { page : Page
    , tasks : List Task
    }


type alias TaskId =
    Int


type alias Task =
    { id : TaskId
    , title : String
    , done : Bool
    }


type Page
    = TasksPage
    | EditTaskPage



-- route = o


init : Location -> ( Model, Cmd Msg )
init location =
    let
        tasks =
            [ Task 1 "task 1" False
            , Task 2 "task 2" False
            , Task 3 "task 3" True
            ]
    in
        ( Model (locationToPage location) tasks
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
    | ToggleDone Int
    | RemoveDone


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

        ToggleDone taskId ->
            let
                newTasks =
                    List.map
                        (\task ->
                            if task.id == taskId then
                                { task | done = not task.done }
                            else
                                task
                        )
                        model.tasks
            in
                ( { model | tasks = newTasks }, Cmd.none )

        RemoveDone ->
            let
                newTasks =
                    List.filter (\task -> not task.done) model.tasks
            in
                ( { model | tasks = newTasks }, Cmd.none )


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
                    [ page
                    ]
                ]
            ]


viewTasksPage : Model -> Html Msg
viewTasksPage model =
    div []
        [ h1 [] [ text "Tasks Page" ]
        , (viewTasks model.tasks)
        , viewButtons
        ]


viewButtons : Html Msg
viewButtons =
    div [ class "btn-group float-right mt-3" ]
        [ button [ class "btn btn-outline-secondary", type_ "button", onClick RemoveDone ] [ text "Remove done" ]
        , button [ class "btn btn-outline-primary", type_ "button" ] [ text "Add Todo" ]
        ]


viewTasks : List Task -> Html Msg
viewTasks tasks =
    ul [ class "list-group mt-3" ]
        (List.map viewTask tasks)


viewTask : Task -> Html Msg
viewTask task =
    let
        taskTitle =
            case task.done of
                True ->
                    del [] [ text task.title ]

                False ->
                    text task.title
    in
        li [ class "list-group-item" ]
            [ div []
                [ label []
                    [ input [ onClick (ToggleDone task.id), type_ "checkbox", checked task.done ] []
                    , span [] [ taskTitle ]
                    ]
                , a [ class "float-right" ] [ text "Edit" ]
                ]
            ]


viewEditTaskPage : Model -> Html msg
viewEditTaskPage model =
    h1 [] [ text "Edit task page" ]
