#!/bin/bash

logout_user() {
    if [[ ${#logged_in_users[@]} -gt 0 ]]; then
        # Găsește indexul utilizatorului curent în array
        for i in "${!logged_in_users[@]}"; do
            if [[ "${logged_in_users[i]}" == "$username" ]]; then
                index=$i
                break
            fi
        done

        # Elimină utilizatorul de la indexul găsit
        unset logged_in_users[$index]
        logged_in_users=("${logged_in_users[@]}")  # Reindexează array-ul

        # Actualizează fișierul temporar și array-ul local
        update_logged_in_users

        echo "$username a fost delogat."
        cd "../.." || echo "Directorul home nu a putut fi accesat!"
    else
        echo "Nu există utilizatori autentificați."
    fi
}