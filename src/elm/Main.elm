module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (checked, class, for, type_, value)
import Html.Events exposing (onCheck, onClick, onInput)
import Navigation exposing (..)
import UrlParser exposing ((</>), oneOf)


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
    , editTask : String
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
    | EditTaskPage Int
    | NewTaskPage



-- route = o


init : Location -> ( Model, Cmd Msg )
init location =
    ( Model (locationToPage location) [] ""
    , Cmd.none
    )



-- UPDATE
-- route : Url.Parser (Route -> a) a


route : UrlParser.Parser (Page -> a) a
route =
    oneOf
        [ UrlParser.map TasksPage (UrlParser.s "tasks")
        , UrlParser.map EditTaskPage (UrlParser.s "edit" </> UrlParser.int)
        , UrlParser.map NewTaskPage (UrlParser.s "new")
        ]


type Msg
    = NewUrl String
    | UrlChange Navigation.Location
    | ToggleDone Int
    | RemoveDone
    | UpdateEditTask String
    | CreateTask
    | Cancel
    | UpdateTask TaskId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewUrl url ->
            -- Navigate to the new url
            ( model
            , Navigation.newUrl url
            )

        UrlChange location ->
            let
                page =
                    locationToPage location

                newEditTask =
                    case page of
                        EditTaskPage id ->
                            model.tasks
                                |> List.filter (\task -> task.id == id)
                                |> List.map (\task -> task.title)
                                |> List.head
                                |> Maybe.withDefault ""

                        _ ->
                            model.editTask
            in
                -- the url has changed, update the current page
                ( { model
                    | page = (locationToPage location)
                    , editTask = newEditTask
                  }
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

        UpdateEditTask text ->
            ( { model | editTask = text }, Cmd.none )

        CreateTask ->
            let
                newId =
                    model.tasks
                        |> List.map (\task -> task.id)
                        |> List.maximum
                        |> Maybe.withDefault 0
                        |> (\i -> i + 1)

                newTasks =
                    Task newId model.editTask False :: model.tasks
            in
                ( { model | tasks = newTasks, page = TasksPage, editTask = "" }, Cmd.none )

        Cancel ->
            ( { model | editTask = "", page = TasksPage }, Cmd.none )

        UpdateTask taskId ->
            let
                newTasks =
                    model.tasks
                        |> List.map
                            (\task ->
                                if task.id == taskId then
                                    { task | title = model.editTask }
                                else
                                    task
                            )
            in
                ( { model | tasks = newTasks, page = TasksPage, editTask = "" }, Cmd.none )


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

                EditTaskPage id ->
                    viewForm model (Just id)

                NewTaskPage ->
                    viewForm model Nothing
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
        , button [ class "btn btn-outline-primary", type_ "button", onClick (NewUrl "#new") ] [ text "Add Todo" ]
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
                , a [ class "float-right", onClick (NewUrl ("#edit/" ++ toString task.id)) ] [ text "Edit" ]
                ]
            ]


viewForm : Model -> Maybe TaskId -> Html Msg
viewForm model maybeId =
    let
        title =
            case maybeId of
                Just taskId ->
                    "Edit Todo"

                Nothing ->
                    "Nieuwe Todo"
    in
        div []
            [ h1 [] [ text title ]
            , div [ class "form-group mt-3" ]
                [ label [ for "comment" ] [ text "Todo item:" ]
                , textarea [ class "form-control", Html.Attributes.id "comment", onInput UpdateEditTask, value model.editTask ] []
                , viewFormButtons maybeId
                ]
            ]


viewFormButtons : Maybe TaskId -> Html Msg
viewFormButtons maybeId =
    let
        saveAction : Msg
        saveAction =
            case maybeId of
                Just taskId ->
                    UpdateTask taskId

                Nothing ->
                    CreateTask
    in
        div [ class "btn-group float-right mt-3" ]
            [ button [ class "btn btn-outline-secondary", type_ "button", onClick Cancel ]
                [ text "Cancel" ]
            , button [ class "btn btn-outline-primary", type_ "button", onClick saveAction ]
                [ text "Saven" ]
            ]
