#!/bin/bash

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