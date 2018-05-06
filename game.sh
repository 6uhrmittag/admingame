#!/usr/bin/env bash
#set -e


#requirement
#curl
#wget

#setup


# Font colors
RED="$(printf '\033[1;31m')"
GREEN="$(printf '\033[1;32m')"
NORMAL="$(printf '\033[0m')"


# @description Setup. Sets up common variables with paths and filenames
# there
#
# @example setup
#
#
# @noargs
setup() {
    FOLDER_MISSIONS="missions"
    MISSIONS_FILENAME_TASKS="tasks.ini"
    MISSIONS_FILENAME_META="meta.ini"

    PROGRAM_FILENAME="$(echo ${0##*/})"
    PROGRAM_PATH_FULL="$(readlink -f "$PROGRAM_FILENAME")"
    PROGRAM_PATH_WORKDIR="$(echo ${0%/*})"
    #echo $PROGRAM_PATH_WORKDIR
    PROGRAM_PATH_MISSIONS="$PROGRAM_PATH_WORKDIR/$FOLDER_MISSIONS"
    PLAYER_FILE="$PROGRAM_PATH_WORKDIR/player/player.ini"
}

# @description Gets meta info for each mission. UNUSED
#
# @example
#

#
# @noargs
get_missions() {
    #gets all missions
    for FOLDER in $(ls "$PROGRAM_PATH_MISSIONS" ); do

      MISSION_FOLDER=$FOLDER
      #echo $MISSION_FOLDER
      #Get mission meta
      #"$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "title")"
        MISSION_PATH="$PROGRAM_PATH_MISSIONS/$MISSION_FOLDER"
        MISSION_type="$(echo "$MISSION_FOLDER" | cut -d '_' -f1)"
        MISSION_name="$(echo "$MISSION_FOLDER" | cut -d '_' -f2)"
        MISSION_keyword="$(echo "$MISSION_FOLDER" | cut -d '_' -f3)"
        #echo "---"
        #echo $MISSION_FOLDER
        #echo $MISSION_PATH
        #echo $MISSION_name
        #echo $MISSION_type
        #echo $MISSION_keyword
    done
}

# @description Fills $MISSION_PATH with full path to mission name UNUSED
#
# @example
#
#
#
# @arg $1 string mission-name
#
get_mission_path() {

    local MISSION_NAME=$1

    for FOLDER in $(ls "$PROGRAM_PATH_MISSIONS" ); do

        MISSION_FOLDER="$FOLDER"
        MISSION_PATH="$PROGRAM_PATH_MISSIONS/$MISSION_FOLDER"

        mission_title="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "title")"

        if [[ "$mission_title" == "$MISSION_NAME" ]];then
            MISSION_PATH="$PROGRAM_PATH_MISSIONS/$MISSION_FOLDER"
        return 0
        #echo -e "MISSION: $mission_title"
        fi
     done
return 1
}

# @description Outputs all missions with counter(mission number)
#
# @example
#
#
# @noargs
#
#
# @stdout 1 Install and run apache webserver
list_all_missions() {
    local counter=1

    echo ""
    echo "Available missions:"
    echo ""
    for FOLDER in $(ls "$PROGRAM_PATH_MISSIONS" ); do

        MISSION_FOLDER="$FOLDER"
        MISSION_PATH="$PROGRAM_PATH_MISSIONS/$MISSION_FOLDER"

        mission_title="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "title")"
        echo -e "\t$counter $mission_title"

        let "counter++"
     done
}

# @description Outputs full info of mission
#
# @example
#   show_tasks mission_current
#
# @arg $1 string mission
#
# @noargs
#
# @stdout Full mission info. Title + Tasks
#
show_tasks() {
    # Get a fresh array of all tasks in $TASK_LIST_OF_TASK

    MISSION_FOLDER="$1"

    get_all_tasks "$MISSION_FOLDER"


    mission_title="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "title")"

    mission_author="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "author")"
    mission_website="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "website")"

    echo ""
    echo "######################################################"
    echo "      Mission: $mission_title"
    echo ""
    echo -e "         by: "$mission_author" url: "$mission_website""
    #echo -e
    echo "######################################################"
    echo ""
    echo "Your Tasks:"
    echo ""
    #Show for each task
    for task in "${TASK_LIST_OF_TASK[@]}"
    do

        task_title="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "title")"
        task_desc="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "desc")"

        echo ""
        #echo "-----------"
        echo -e "⏵ $task_title"

        if [ -n "$task_desc" ]; then
            echo -e "\tDescription: $task_desc"
        fi

        why="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "why")"
        if [ -n "$why" ]; then
            echo -e "\tWhy: $why"
        fi


    done

    echo ""
    mission_note="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "title")"

    echo "Note: $mission_note"
    echo ""
    echo ""
}

# @description Resets solved-status of current mission+all tasks of mission.
#
# @example mission_reset
#

# @noargs
#
mission_reset() {
    # Get a fresh array of all tasks in $TASK_LIST_OF_TASK
    get_all_tasks "$(get_current_mission)"

    #Check each task
    for task in "${TASK_LIST_OF_TASK[@]}"
    do
        crudini --set "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "solved" "false"
        crudini --set "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "solved" "false"
    done

}




# @description Checks task status with help of "cmd" command in task.ini.
#
# @example check_success task1
#
# @exitcode 0 Task solved
# @exitcode 1 Task unsolved

# @arg $1 task
#
check_success() {
    check_task="$1"
    cmd="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$check_task" "cmd")"
    task_title="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$check_task" "title")"
    #echo "$desc:"

    task_status=$(eval "$cmd")
    #echo $cmd
    #echo $task_status


    # "ok" for if-checks
    # "OK" for http status
    # 0 for exit code

    if [[ "$task_status" == "ok" ]] || [[ "$task_status" = *"OK"* ]] || [[ "$task_status" == "0" ]]; then
            #echo "ok"
            return 0
        else
            #echo "fail"
            return 1
        fi

}

# @description Returns current mission from player.ini. Returns $MISSION_CURRENT
#
# @example get_all_tasks $(get_current_mission)
#
# @noargs
get_current_mission() {
    MISSION_CURRENT="$(crudini --get "$PLAYER_FILE" "player" "mission_current")"
    echo "$MISSION_CURRENT"
}

# @description Writes current mission to player.ini. Writes foldername of mission.
#
# @example
#   set_current_mission 1
#
# @arg $1 int Mission number. Output of `ls` stating at 1
set_current_mission() {

    local MISSION_NUMBER="$1"
    local counter=1

    for FOLDER in $(ls "$PROGRAM_PATH_MISSIONS" ); do
        if [[ "$MISSION_NUMBER" == "$counter"  ]];then
                crudini --set "$PLAYER_FILE" "player" "mission_current" "$FOLDER"
         return 0
        fi

        let "counter++"
     done
return 1
}

# @description Receives mission number from terminal input. Returns Mission number
#
# @example
#   input_mission_number
#   "Please select a mission [Input number]"
#   n
#   "Numbers only"
#   1
#
# @noargs
input_mission_number() {

    echo -e "Please select a mission [Input number]: "

    read MISSION_CURRENT_NUMBER
        while [[ "$MISSION_CURRENT_NUMBE" -lt 0 || "$MISSION_CURRENT_NUMBER" -gt 9999 ]]; do
            echo "Numbers only"
            read MISSION_CURRENT_NUMBER
        done
    return "$MISSION_CURRENT_NUMBER"
}

# @description Fills array $TASK_LIST_OF_TASK with names of all tasks of current mission.
#
# @example
#   get_all_tasks 1
#
# @ int Mission number. Output of `ls` stating at 1
#
get_all_tasks() {

    MISSION_FOLDER=$1

    MISSION_PATH=$PROGRAM_PATH_MISSIONS/$MISSION_FOLDER

    tasks="$(eval crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" | tr '\n' ' ')"

    IFS=' ' read -r -a TASK_LIST_OF_TASK <<< "$tasks"

    return 0
}

# @description Asks player to choose a mission. Lists missions and waits for input.
#
# @example input
#
# @noargs
#
#
# @stdout lists missions
input() {
    list_all_missions

    input_mission_number
    mission_number="$?"

    #mission_status=$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "solved")
    #echo "$mission_status"

    set_current_mission "$mission_number"

}

# @description Outputs full Result with status, points and hints
#
# @example
#
#
# @noargs
#
#
# @stdout Full mission status
check_result() {

    gamemode="$1"

    #get_current_mission

    # Get a fresh array of all tasks in $TASK_LIST_OF_TASK
    get_all_tasks "$(get_current_mission)"


    mission_title="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "title")"
    echo ""
    echo "Mission: $mission_title"
    echo ""
    echo "Your Result:"

    result_points_total=""
    result_points_got=""

    #Check each task
    for task in "${TASK_LIST_OF_TASK[@]}"
    do

        #Get points for task
        task_points="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "points")"
        result_points_total=$(( $result_points_total + $task_points ))
        task_title="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "title")"
        check_success "$task"
        STATUS=$?
        #echo ""
        if [ "$STATUS" == 0 ]; then

            echo -e "⏵ $task_title\t${GREEN}   solved ✔${NORMAL}"



            result_points_got=$(( $result_points_got + $task_points ))

            task_hintnext="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "hintnext")"

        else
            echo -e "⏵ $task_title\t${RED} unsolved ✘${NORMAL}"

            if [[ "$gamemode" != "tutor" ]]; then

                hint="$(crudini --get "$MISSION_PATH/$MISSIONS_FILENAME_TASKS" "$task" "hint")"
                if [ -n "$hint" ]; then
                    echo -e "🔎Hint: \t $hint"
                fi
            fi

            echo -e ""
        fi
        #echo ""
        echo -e "  Points:\t\t\t\t  "$task_points""
        echo "-------------------------"

    done

    echo ""
    echo -e "  Total Points:\t\t\t          $result_points_total"
    echo -e "  Your Points :\t\t\t          $result_points_got"
    echo ""



    if [ ! "$gamemode" == "tutor" ] && [[ "$result_points_got" == "$result_points_total" ]];then
            echo ""
            echo "You solved all tasks!"
            echo ""
            echo "Mission complete"
            sleep 2

            #mark mission as solved
            echo ""
            crudini --set "$MISSION_PATH/$MISSIONS_FILENAME_META" "mission" "solved" "true"
            echo "Mission marked as solved"
            echo ""
            echo ""
            exit 0
    else
         if [ "$gamemode" == "tutor" ] && [ ! "$task_hintnext" == "" ]; then
            echo ""
            echo "🔎 $task_hintnext"
            echo ""
         fi

    fi
    echo ""

}




setup








if [ "$1" == "testing" ]; then
    set -e # Exit with nonzero exit code if anything fails

    echo ""
    echo "------------------   TEST START   ------------------"
    echo ""
    echo "------------------   SETUP START  ------------------"
    setup
    echo "------------------   SETUP DONE   ------------------"
    source $PROGRAM_PATH_WORKDIR/tests/requirements.sh
    source $PROGRAM_PATH_WORKDIR/tests/test.sh
    echo ""
    echo "------------------   TEST END    ------------------"
    echo ""
fi

if [ "$1" == "tasks" ]; then
    MISSION_FOLDER="$(crudini --get "$PLAYER_FILE" "player" "mission_current")"
    show_tasks "$MISSION_FOLDER"
    exit 0
fi

if [ "$1" == "missions" ]; then
    list_all_missions
    exit 0
fi

if [ "$1" == "help" ] || [ "$1" == "-?" ] || [ "$1" == "--help" ] || [ "$1" == "" ]; then


echo " Linux admin game"
echo ""
echo " Start the game"
echo "    start   (list, select and start mission)"
echo ""
echo " In-game control"
echo "    tasks   (show tasks)"
echo "    end     (end game, show restult)"
echo ""
echo " Tutor mode:"
echo " Guides you through your mission. Checks every minute if you solved a task and shows hints."
echo "    tutor   (start tutor)"
echo ""
echo ""

#    echo -e "\n\n\n"
#    echo ""
#    echo -e "admingame missions: Lists available missions.\n"
#    echo -e "admingame start: Lists missions, let you choose a mission and starts the game.\n"
#    echo -e "admingame tasks: Lists all tasks.\n"
#    echo -e "admingame end: Checks your work and shows the result.\n"
#    echo -e "admingame tutor: Starts the game in tutor mode. Checks every minute if you solved a task and shows hints.\n"
#    echo ""
#
#    echo ""
#    echo -e "Lists available missionsadmingame missions\n"
#    echo -e "Lists missions, let you choose a mission and starts the game_ admingame start: \n"
#    echo -e "Lists all tasks: admingame tasks: \n"
#    echo -e "Checks your work and shows the result.: admingame end: \n"
#    echo -e ": admingame tutor: \n"
#    echo ""

    exit 0
fi

if [ "$1" == "reset" ]; then
    mission_reset
    exit 0
fi

if [ "$1" == "end" ]; then
    check_result
    exit 0
fi

if [ "$1" == "start" ]; then
    input
    show_tasks "$(get_current_mission)"
    exit $?
fi

if [ "$1" == "tutor" ]; then
    echo "Starting tutor"
    echo "The tutor checkes every minute for solved tasks and provides hints."
    echo ""
    source ./helper.sh

    background_helper &
    # Storing the background process' PID.
    bg_pid=$!

    # Trapping SIGKILLs so we can send them back to $bg_pid.
    trap "kill -15 $bg_pid" 2 15

    crudini --set "$PLAYER_FILE" "local" "helper_pid" "$bg_pid"
    #echo "PID: $bg_pid"

    #echo ""
    show_tasks $(get_current_mission)

fi