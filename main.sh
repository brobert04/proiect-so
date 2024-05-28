#!/bin/bash

source ./helpers/helpers.sh
source ./functions/register_user.sh
source ./functions/login_user.sh
source ./functions/logout_user.sh
source ./functions/generate_raport.sh

check_csv  
check_logged_in_users_file  

while true; do
    echo "**************************************"
    echo "*   Bine ai venit! Alege o opțiune:  *"
    echo "**************************************"
    
    if [[ $(wc -l < "$LOGGED_IN_USERS_FILE") -eq 0 ]]; then
        echo "* 1. Înregistrare cont               *"
        echo "* 2. Autentificare                   *"
    else
        echo "* 3. Logout                          *"
        current_user=$(head -n 1 "$LOGGED_IN_USERS_FILE")
        if check_role "$current_user" "admin"; then
            echo "* 4. Generare raport                 *"
        fi
    fi
    echo "* 5. Ieșire                          *"
    echo "**************************************"

    read -p "Alegeți o opțiune: " choice

    case $choice in
        1)
            register_user
            ;;
        2)
            if [[ $(wc -l < "$LOGGED_IN_USERS_FILE") -eq 0 ]]; then
                login_user
            else
                echo "Nu poți să te autentifici când un utilizator este deja logat."
            fi
            ;;
        3)
            if [[ $(wc -l < "$LOGGED_IN_USERS_FILE") -gt 0 ]]; then
                logout_user
            else
                echo "Nu există utilizatori autentificați."
            fi
            ;;
        4)
            if [[ $(wc -l < "$LOGGED_IN_USERS_FILE") -gt 0 ]]; then
                current_user=$(head -n 1 "$LOGGED_IN_USERS_FILE")
                if check_role "$current_user" "admin"; then
                    generate_report
                else
                    echo "Nu ai permisiunea de a genera rapoarte."
                fi
            else
                echo "Nu există utilizatori autentificați."
            fi
            ;;
        5)
            break
            ;;
        *)
            echo "Opțiune invalidă!"
            ;;
    esac
done