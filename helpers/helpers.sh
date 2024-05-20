#!/bin/bash

USER_FILE="utilizatori.csv"
logged_in_users=()

check_csv(){
    if [[ ! -f "$USER_FILE" ]]; then
        touch "$USER_FILE"
        echo "Fisierul a fost creat cu succes!"
    fi
}

generate_salt() {
    openssl rand -base64 6
}

#local - This means the variable is only accessible within the scope of that   
is_valid_email() {
    local email="$1"
    [[ "$email" == *[@]*.* ]]
}

is_valid_password() {
    local password="$1"
    local username="$2"
    [[ ${#password} -ge 8 && "$password" != "$username" ]]
}

user_exists() {
    local username="$1"
    grep -q "^$username " "$USER_FILE"
}

get_user_field() {
    local username="$1"
    local field="$2"
    grep "^$username " "$USER_FILE" | awk "{print \$$field}"
}

create_home_directory() {
    local username="$1"
    local home_directory="./home/$username"
    if [[ ! -d "$home_directory" ]]; then
        mkdir -p "$home_directory"
    fi
}

remove_empty_elements() {
    local new_array=()
    for element in "${logged_in_users[@]}"; do
        if [[ -n $element ]]; then
            new_array+=("$element")
        fi
    done
    logged_in_users=("${new_array[@]}")
}
