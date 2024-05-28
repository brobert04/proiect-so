#!/bin/bash

USER_FILE="$(pwd)/utilizatori.csv"
LOGGED_IN_USERS_FILE="$(pwd)/logged_in_users.txt"

check_csv() {
    if [[ ! -f "$USER_FILE" ]]; then
        touch "$USER_FILE"
        echo "nume,id,email,parola,last_login,rol" > "$USER_FILE"
        admin_password=$(openssl passwd -6 -salt "$(openssl rand -base64 6)" "admin123")
        echo "admin,1,admin@example.com,$admin_password,null,admin" >> "$USER_FILE"
        mkdir -p "$(pwd)/home/admin"
    fi
}

check_logged_in_users_file() {
    if [[ ! -f "$LOGGED_IN_USERS_FILE" ]]; then
        touch "$LOGGED_IN_USERS_FILE"
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
    grep -q "^$username," "$USER_FILE"
}

get_user_field() {
    local username="$1"
    local field="$2"
    awk -F, -v user="$username" -v fld="$field" '$1 == user {print $fld}' "$USER_FILE"
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

check_role() {
    local username="$1"
    local required_role="$2"
    user_role=$(get_user_field "$username" 6)
    if [[ "$user_role" != "$required_role" ]]; then
        return 1
    fi
    return 0
}