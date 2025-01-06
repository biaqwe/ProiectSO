#!/bin/bash

#Gasirea tuturor fisierelor mai vechi de o data calendaristica introdusa de la STDIN
gasire(){
    echo "a"
}

#Mutarea fisierelor
mutare(){
    echo "a"
}

#Stergerea fisierelor
stergere(){
    echo "Introduceti numele directorului din care vor fi sterse fisierele vechi:"
    read director

    #verifica daca directorul specificat exista
    if [ ! -d $director ]; then
        echo "Directorul $1 nu exista"
        return 1
    fi

    #calea completa a directorului
    director=$(realpath "$director")

    #comanda cron pentru a sterge fisierele mai vechi de 60 de zile din directorul selectat
    c="0 20 * * 1 find $director -type f -mtime +60 -exec rm {} \;"

    #adaugarea comenzii in crontab
    (crontab -l 2>/dev/null; echo "$c") | crontab -

    echo "Stergerea periodica a fost configurata"
}

#Optiuni de configurare aplicatiei
configurare(){
    echo "Alegeti o optiune:"
    select o in "Stergere fisiere" "Redenumire fisiere" "Editare fisiere"; do
        case $o in
            "Stergere fisiere")
                ;;
            "Redenumire fisiere")
                ;;
            "Editare fisiere")
                ;;
            *)
                echo "Optiune invalida"
                ;;
        esac
    done
}

#Help
help(){
    echo "Utilizare: $0 [optiuni]"
    echo "Optiuni disponibile:"
    echo "  -f <data>           Gaseste toate fisierele mai vechi de o data calendaristica introdusa"
    echo "  -m <destinatie>     Muta fisierele intr o locatie specificata/in cloud"
    echo "  -s <director>       Sterge periodic fisierele vechi"
    echo "  -c                  Configurarea aplicatiei (stergere, redenumire, editare)"
    echo "  -h, --help          Afiseaza acest mesaj"
    echo "  -u, --usage         Afiseaza un exemplu de utilizare"
    echo "  --debug=on/off      Activeaza/dezactiveaza modul de debug (implicit: off)"
}

#Usage
usage(){
    echo "Exemplu de utilizare:"
    echo "$0 -f"
    echo "$0 -m"
    echo "$0 -s"
}

#Parsarea optiunilor din linia de comanda cu getopts
OPTIUNI=$(getopt -o hu -l help,usage,debug: -- "$@")

if [ $? != 0 ]; then
    echo "Optiune invalida"
    exit 1
fi

eval set -- $OPTIUNI

while true; do
    case $1 in
        -h|--help)
            help
            exit 0
            ;;
        -u|--usage)
            usage
            exit 0
            ;;
        --debug)
            if [ $2 == "on" ]; then
                debug="on"
            elif [ $2 == "off" ]; then
                debug="off"
            else
                echo "Valoare invalida pentru --debug. Se asteapta 'on' sau 'off'"
                exit 1
            fi
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Optiune invalida: $1"
            help
            exit 1
            ;;
    esac
done

while true; do
    echo "Alegeti o optiune:"
    select o in "Gasire fisiere" "Mutare fisiere" "Stergere fisiere" "Configurare aplicatie" "Iesire"; do
        case $o in 
            "Gasire fisiere")
                gasire;
                break
                ;;
            "Mutare fisiere")
                mutare;
                break
                ;;
            "Stergere fisiere")
                stergere;
                break
                ;;
            "Configurare aplicatie")
                configurare;
                break
                ;;
            "Iesire")
                exit 0
                ;;
            *)
                echo "Optiune invalida"
                ;;
        esac
    done
done
            