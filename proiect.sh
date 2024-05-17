#!/bin/bash

USER_FILE="utilizatori.csv"
logged_in_users=()

function register_user() {
    while true; do
        read -p "Nume utilizator: " username

        if grep -q "^$username " "$USER_FILE"; then
            echo "Utilizatorul \"$username\" există deja!"
            continue
        fi

        while true; do
            read -p "Adresă email: " email
            if [[ "$email" == *[@]*.* ]]; then
                break
            else
                echo "Adresă email invalidă. Reîncearcă."
            fi
        done

        while true; do
            read -s -p "Parolă: " password
            echo ""
            if [[ ${#password} -ge 8 && "$password" != "$username" ]]; then
                break
            else
                echo "Parola trebuie să aibă cel puțin 8 caractere și să fie diferită de numele de utilizator."
            fi
        done
        echo ""

        user_id=$(date +%s)
        last_login="null"

        home_directory="./home/$username"
        if [[ -d "$home_directory" ]]; then
            echo "Directorul home al utilizatorului \"$username\" există deja!"
            continue
        else
            break
        fi
    done
    mkdir -p "$home_directory"
    
    echo "$username $user_id $email $password $last_login" >> "$USER_FILE"
    echo "Utilizator înregistrat cu succes!"
    echo ""
}

function login_user() {
    read -p "Nume utilizator: " username
    read -s -p "Parola: " password
    echo ""

    if grep -q "^$username " "$USER_FILE"; then
        stored_password=$(grep "^$username " "$USER_FILE" | awk '{print $4}')
        if [[ "$password" == "$stored_password" ]]; then
            last_login=$(date)

            sed -i "/^$username / s/^\([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\) \([^.]*\)/\1 \2 \3 \4 $last_login/" "$USER_FILE"
            logged_in_users+=("$username")
            echo "Bun venit, $username!"
            cd "./home/$username" || echo "Directorul home nu a putut fi accesat!"
        else
            echo "Parola este incorectă!"
        fi
    else
        echo "Autentificare eșuată!"
    fi
    echo ""
}

function remove_empty_elements() {
    local new_array=()
    for element in "${logged_in_users[@]}"; do
        if [[ -n $element ]]; then
            new_array+=("$element")
        fi
    done
    logged_in_users=("${new_array[@]}")
}

function logout_user() {
    if [[ ${#logged_in_users[@]} -gt 0 ]]; then
        username="${logged_in_users[0]}"
        logged_in_users=("${logged_in_users[@]/$username}")
        remove_empty_elements

        echo "$username a fost delogat."
        cd "../.." || echo "Directorul home nu a putut fi accesat!"
    else
        echo "Nu există utilizatori autentificați."
    fi
}

function generate_report() {
    echo "Generare raport..."
    # Add your report generation logic here
    echo "Raport generat."
}

while true; do
    echo "Alege o optiune:"
    if [[ ${#logged_in_users[@]} -eq 0 ]]; then
        echo "1. Înregistrare utilizator"
        echo "2. Autentificare"
    else
        echo "3. Logout"
    fi
    echo "4. Generare raport"
    echo "5. Ieșire"
    read -p "Alegeți o opțiune: " choice

    case $choice in
        1)
            if [[ ${#logged_in_users[@]} -eq 0 ]]; then
                register_user
            else
                echo "Nu poți să adaugi alti utilizatori daca esti logat."
            fi
            ;;
        2)
            if [[ ${#logged_in_users[@]} -eq 0 ]]; then
                login_user
            else
                echo "Nu poți să te autentifici când un utilizator este deja logat."
            fi
            ;;
        3)
            if [[ ${#logged_in_users[@]} -gt 0 ]]; then
                logout_user
            else
                echo "Nu există utilizatori autentificați."
            fi
            ;;
        4)
            generate_report
            ;;
        5)
            break
            ;;
        *)
            echo "Opțiune invalidă!"
            ;;
    esac
done
