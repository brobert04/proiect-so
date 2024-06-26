#!/bin/bash

login_user() {
    read -p "Nume utilizator: " username
    local attempts=0

    while (( attempts < 3 )); do
        read -s -p "Parola: " password
        echo ""

        if user_exists "$username"; then
            stored_password=$(get_user_field "$username" 4)
            stored_salt=$(echo "$stored_password" | cut -d'$' -f3)
            encrypted_input=$(openssl passwd -6 -salt "$stored_salt" "$password")
            
            if [[ "$encrypted_input" == "$stored_password" ]]; then
                last_login=$(date +"%Y-%m-%d %H:%M:%S")
                home_dir="./home/$username"
                if [[ ! -d "$home_dir" ]]; then
                    create_home_directory "$username"
                    echo "Directorul home a fost creat pentru $username."
                fi

                awk -F, -v user="$username" -v date="$last_login" -v OFS=, '{
                    if ($1 == user) {
                        $5 = "\""date"\""
                    }
                    print
                }' "$USER_FILE" > tmp && mv tmp "$USER_FILE"

                if ! grep -q "^$username$" "logged_in_users.txt"; then
                    echo "$username" >> "logged_in_users.txt"
                fi

                echo "Bun venit, $username!"
                cd "$home_dir" || echo "Directorul home nu a putut fi accesat!"
                return
            else
                echo "Parola este incorectă!"
                ((attempts++))
            fi
        else
            echo "Autentificare eșuată!"
            return
        fi
    done

    if (( attempts == 3 )); then
        read -p "Ți-ai uitat parola? (da/nu): " response
        if [[ "$response" == "da" ]]; then
            forget_password "$username"
        else
            echo "Încercări eșuate de autentificare!"
        fi
    fi
    echo ""
}
