#!/bin/bash

register_user() {
    check_csv
    while true; do
        read -p "Nume utilizator: " username

        if user_exists "$username"; then
            echo "Utilizatorul \"$username\" există deja!"
            continue
        fi

        while true; do
            read -p "Adresă email: " email
            if is_valid_email "$email"; then
                break
            else
                echo "Adresă email invalidă. Reîncearcă."
            fi
        done

        while true; do
            read -s -p "Parolă: " password
            echo ""
            if is_valid_password "$password" "$username"; then
                break
            else
                echo "Parola trebuie să aibă cel puțin 8 caractere și să fie diferită de numele de utilizator."
            fi
        done
       
        role="user"

        salt=$(generate_salt)
        encrypted_password=$(openssl passwd -6 -salt "$salt" "$password")

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

    create_home_directory "$username"
    
    echo "$username,$user_id,$email,$encrypted_password,$last_login,$role" >> "$USER_FILE"
    echo "Utilizator înregistrat cu succes!"
    echo ""
}