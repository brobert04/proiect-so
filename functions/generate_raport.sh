#!/bin/bash

generate_report() {
    read -p "Nume utilizator: " username
    if user_exists "$username"; then
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