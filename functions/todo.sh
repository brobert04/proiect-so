#!/bin/bash

AGENDA_FILE="./agenda.txt"

show_menu() {
    clear
    echo "Agenda Personală"
    echo "1. Adăugare eveniment"
    echo "2. Ștergere eveniment"
    echo "3. Vizualizare evenimente"
    read -p "Alegeți o opțiune: " option
    case $option in
        1) add_event ;;
        2) delete_event ;;
        3) view_events ;;
        *) echo "Opțiune invalidă!" ;;
    esac
}


add_event() {
    read -p "Introduceți data evenimentului (YYYY-MM-DD): " date
    read -p "Introduceți ora evenimentului (HH:MM): " time
    read -p "Introduceți descrierea evenimentului: " description
    echo "$date $time - $description" >> "$AGENDA_FILE"
    echo "Eveniment adăugat cu succes!"
    read -p "Apasăți orice tastă pentru a continua..."
}


delete_event() {
    echo "Lista evenimentelor:"
    cat -n "$AGENDA_FILE"
    read -p "Introduceți numărul evenimentului pe care doriți să-l ștergeți: " event_number
    sed -i "${event_number}d" "$AGENDA_FILE"
    echo "Evenimentul a fost șters cu succes!"
    read -p "Apasăți orice tastă pentru a continua..."
}

view_events() {
    clear
    echo "Evenimentele din agenda personală:"
    if [ -s "$AGENDA_FILE" ]; then
        cat "$AGENDA_FILE"
    else
        echo "Nu există evenimente viitoare."
    fi
    read -p "Apasăți orice tastă pentru a continua..."
}
