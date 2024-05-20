#!/bin/bash

function login_user() {
    read -p "Nume utilizator: " username
    read -s -p "Parola: " password
    echo ""

     if user_exists "$username"; then
        stored_password=$(get_user_field "$username" 4)

        stored_salt=$(echo "$stored_password" | cut -d'$' -f3)
        encrypted_input=$(openssl passwd -6 -salt "$stored_salt" "$password")
        
        if [[ "$encrypted_input" == "$stored_password" ]]; then
            last_login=$(date)

            home_dir="./home/$username"
            if [[ ! -d "$home_dir" ]]; then
                create_home_directory "$username"
                echo "Directorul home a fost creat pentru $username."
            fi

            sed -i "/^$username / s/^\([^ ]*\) \([^ ]*\) \([^ ]*\) \([^ ]*\) \([^.]*\)/\1 \2 \3 \4 $last_login/" "$USER_FILE"
            logged_in_users+=("$username")

            echo "Bun venit, $username!"
            cd "$home_dir" || echo "Directorul home nu a putut fi accesat!"
        else
            echo "Parola este incorectă!"
        fi
    else
        echo "Autentificare eșuată!"
    fi
    echo ""
}