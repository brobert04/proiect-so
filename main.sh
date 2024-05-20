#!/bin/bash

source ./helpers/helpers.sh
source ./functions/register_user.sh
source ./functions/login_user.sh
source ./functions/logout_user.sh
source ./functions/generate_raport.sh

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