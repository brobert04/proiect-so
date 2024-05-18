#!/bin/bash

USER_FILE="utilizatori.csv"
logged_in_users=()

function check_csv(){
    if [[ ! -f "$USER_FILE" ]]; then
        touch "$USER_FILE"
        echo "Fisierul a fost creat cu succes!"
    fi
}

function generate_salt() {
    openssl rand -base64 6
}

function register_user() {
    check_csv
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
    mkdir -p "$home_directory"
    
    echo "$username $user_id $email $encrypted_password $last_login" >> "$USER_FILE"
    echo "Utilizator înregistrat cu succes!"
    echo ""
}

function login_user() {
    read -p "Nume utilizator: " username
    read -s -p "Parola: " password
    echo ""

    if grep -q "^$username " "$USER_FILE"; then
        stored_password=$(grep "^$username " "$USER_FILE" | awk '{print $4}')


        stored_salt=$(echo "$stored_password" | cut -d'$' -f3)
        encrypted_input=$(openssl passwd -6 -salt "$stored_salt" "$password")
        

        if [[ "$encrypted_input" == "$stored_password" ]]; then
            last_login=$(date)

            home_dir="./home/$username"
            if [[ ! -d "$home_dir" ]]; then
                mkdir -p "$home_dir"
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
    read -p "Nume utilizator: " username
    if grep -q "^$username " "$USER_FILE"; then
        home_dir="./home/$username"
        if [[ -d "$home_dir" ]]; then
        ( 
            num_files=$(find "$home_dir" -type f | wc -l)
            num_dirs=$(find "$home_dir" -mindepth 1 -type d | wc -l)
            size_kb=$(du -sk "$home_dir" | cut -f1)
            echo "Raport pentru $username:" > "$home_dir/report.txt"
            echo "Fișiere: $num_files" >> "$home_dir/report.txt"
            echo "Directoare: $num_dirs" >> "$home_dir/report.txt"
            echo "Dimensiune: $size_kb KB" >> "$home_dir/report.txt"
        ) &
        echo "Generarea raportului a început. Acesta va fi disponibil în $home_dir/report.txt"
        else
            echo "Directorul home al utilizatorului \"$username\" nu există!"
        fi
    else
        echo "Utilizatorul \"$username\" nu există!"
        return
    fi
}

while true; do
    echo "Alege o optiune:"
    if [[ ${#logged_in_users[@]} -eq 0 ]]; then
        echo "1. Înregistrare utilizator"
        echo "2. Autentificare"
        echo "4. Generare raport"
    else
        echo "3. Logout"
    fi
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
            if [[ ${#logged_in_users[@]} -eq 0 ]]; then
                generate_report
            else
                echo "Nu poți genera un raport daca esti autentificat."
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


# The issue with your password encryption is that openssl passwd -1 generates a new salt each time it is called, resulting in different hashed values even for the same input password. This behavior makes it impossible to compare the stored hash with the hash of the entered password correctly.

# To fix this, you should use a consistent hashing method that allows verifying passwords against stored hashes. A common choice is openssl passwd -6 for SHA-512, which provides an option to specify a salt.

# Here's how you can modify your script to use a consistent salt for hashing passwords and verifying them correctly:

# Store the salt with the hash when registering a user.
# Extract the salt from the stored hash when verifying a password during login.
# Here is the updated script: