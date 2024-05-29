#!/bin/bash

delete_user(){
    echo "Lista utilizatorilor: "
    tail -n +2 "$USER_FILE" | awk -F ',' '{print $1}'
    
    read -p "Introduceți numele utilizatorului pe care doriți să-l ștergeți: " user_name

    if [[ "$user_name" == "admin" ]]; then
        echo "Utilizatorul \"admin\" nu poate fi șters."
    else
        if grep -q "^$user_name," "$USER_FILE"; then
            sed -i "/^$user_name,/d" "$USER_FILE"
            echo "Utilizatorul \"$user_name\" a fost șters."
        else
            echo "Utilizatorul \"$user_name\" nu există."
        fi
    fi
}