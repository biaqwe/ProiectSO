#!/bin/bash

#Gasirea tuturor fisierelor mai vechi de o data calendaristica introdusa de la STDIN
gasire(){

}

#Mutarea fisierelor
mutare(){

}

#Stergerea fisierelor
stergere(){

}

#Optiuni de configurare aplicatiei
configurare(){
    echo "Alegeti o optiune:"
    select o in "1) Stergere fisiere" "2) Redenumire fisiere" "Editare fisiere"; do
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
    echo "  -s                  Sterge periodic fisierele vechi"
    echo "  -c                  Configurarea aplicatiei (stergere, redenumire, editare)"
    echo "  -h, --help          Afiseaza acest mesaj"
    echo "  -u, --usage         Afiseaza un exemplu de utilizare"
    echo "  --debug=on/off      Activeaza/dezactiveaza modul de debug (implicit: off)"
}

#Usage
usage(){
    echo "Exemplu de utilizare:"
}

#Meniu interactiv
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
            
            