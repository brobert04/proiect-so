#!/bin/bash

open_terminal() {
    home_directory="$(pwd)"

    if [[ -d "$home_directory" ]]; then
        gnome-terminal --window --working-directory="$home_directory" &
        echo "S-a deschis un nou terminal în $home_directory"
        read -p "Apăsați Enter pentru a reveni la meniul principal..."
    fi
}