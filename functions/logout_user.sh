#!/bin/bash

logout_user() {
    if [[ -f "$LOGGED_IN_USERS_FILE" ]]; then
        if [[ -s "$LOGGED_IN_USERS_FILE" ]]; then  # Verifică dacă fișierul nu este gol
            current_user=$(head -n 1 "$LOGGED_IN_USERS_FILE")

            # Folosește sed pentru a elimina linia cu numele utilizatorului
            sed -i "/^$current_user$/d" "$LOGGED_IN_USERS_FILE"

            echo "$current_user a fost delogat."
            cd "../.." || echo "Eroare: Directorul home nu a putut fi accesat!" 
        else
            echo "Nu există utilizatori autentificați."
        fi
    else
        echo "Fișierul cu utilizatori autentificați nu există." 
    fi
}
