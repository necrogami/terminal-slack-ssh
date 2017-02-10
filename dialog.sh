#!/bin/bash

# while-menu-dialog: a menu driven system information program

DIALOG_CANCEL=1
DIALOG_ESC=255
HEIGHT=0
WIDTH=0

while true; do
    name=${BASH_ARGV[0]}
    exec 3>&1
    selection=$(dialog \
        --backtitle "C4 Slack Terminal" \
        --title "C4 Slack" \
        --clear \
        --cancel-label "Exit" \
        --menu "Please select:" $HEIGHT $WIDTH 4 \
        "1" "Choose Existing Slack Team" \
        "2" "Add New Slack Team" \
        "3" "Remove Slack Team" \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-
    case $exit_status in
        $DIALOG_CANCEL)
            clear
            exit
            ;;
        $DIALOG_ESC)
            clear
            echo "Program aborted." >&2
            exit 1
            ;;
    esac
    case $selection in
        0 )
            clear
            echo "Program terminated."
            ;;
        1 )
            let i=0 # define counting variable
            W=() # define working array
            while read -r line; do # process file by file
                let i=$i+1
                W+=($i "$line")
            done < <( ls -1 keys/${name} )
            FILE=$(dialog --title "Server Selection" --backtitle "C4 Slack Terminal" --clear --cancel-label "Go Back" --menu "Choose which server you'd like to connect to." 24 80 17 "${W[@]}" 3>&2 2>&1 1>&3) # show dialog and store output
            exit_status=$?
            case $exit_status in
                $DIALOG_CANCEL)
                    clear
                    continue
                    ;;
                $DIALOG_ESC)
                    clear
                    continue
                    ;;
            esac
            dir=($(ls -1 keys/${name}))
            export SLACK_TOKEN=$(cat keys/${name}/${dir[FILE-1]})
            node terminal-slack/main.js
            clear
            ;;
        2 )
            TEAM=$(dialog --title "Team Name" --backtitle "C4 Slack Terminal" --inputbox "Enter the name of the team." 8 60  3>&2 2>&1 1>&3) # show dialog and store output
            exit_status=$?
            case $exit_status in
                $DIALOG_CANCEL)
                    clear
                    continue
                    ;;
                $DIALOG_ESC)
                    clear
                    continue
                    ;;
            esac
            APIKEY=$(dialog --title "Slack API Key" --backtitle "C4 Slack Terminal" --inputbox "Enter the Slack API Key." 8 60  3>&2 2>&1 1>&3) # show dialog and store output
            exit_status=$?
            case $exit_status in
                $DIALOG_CANCEL)
                    clear
                    continue
                    ;;
                $DIALOG_ESC)
                    clear
                    continue
                    ;;
            esac

            echo "$APIKEY" > keys/${name}/$TEAM

            ;;
        3 )
            let i=0 # define counting variable
            W=() # define working array
            while read -r line; do # process file by file
                let i=$i+1
                W+=($i "$line")
            done < <( ls -1 keys/${name} )
            FILE=$(dialog --title "Team Removal" --backtitle "C4 Slack Terminal" --clear --cancel-label "Go Back" --menu "Choose which server you'd like to remove." 24 80 17 "${W[@]}" 3>&2 2>&1 1>&3) # show dialog and store output
            exit_status=$?
            case $exit_status in
                $DIALOG_CANCEL)
                    clear
                    continue
                    ;;
                $DIALOG_ESC)
                    clear
                    continue
                    ;;
            esac
            dir=($(ls -1 keys/${name}))
            rm -f keys/${name}/${dir[FILE-1]}
            clear
            ;;
    esac
done
