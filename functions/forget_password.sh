#!/bin/bash

function forget_password() {
    local username="$1"
    if user_exists "$username"; then
        while true; do
            read -s -p "Introdu o nouă parolă: " new_password
            echo ""
            read -s -p "Confirmă noua parolă: " confirm_password
            echo ""
            if [[ "$new_password" == "$confirm_password" && ${#new_password} -ge 8 ]]; then
                new_salt=$(generate_salt)
                new_hashed_password=$(openssl passwd -6 -salt "$new_salt" "$new_password")

                awk -F, -v user="$username" -v new_pass="$new_hashed_password" -v OFS=, '{
                    if ($1 == user) {
                        $4 = new_pass
                    }
                    print
                }' "$USER_FILE" > tmp && mv tmp "$USER_FILE"

                echo "Parola a fost resetată cu succes."
                return
            else
                echo "Parolele nu se potrivesc sau nu sunt suficient de puternice. Reîncearcă."
            fi
        done
    else
        echo "Utilizatorul \"$username\" nu există."
    fi
}
