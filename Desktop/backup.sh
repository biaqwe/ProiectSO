#!/bin/bash

#Gasirea tuturor fisierelor mai vechi de o data calendaristica introdusa de la STDIN
gasire(){
    echo "a"
}

#Mutarea fisierelor
mutare(){
    echo "Selectati unde doriti sa mutati fisierele:"
    echo "1. Mutare locala"
    echo "2. Mutare în Git"
    read -p "Introduceti optiunea: " optiune

    case $optiune in
        1)
            # mutare locala
            read -p "Introduceti numele fisierului pe care doriti sa il mutati: " fisier
            # verificam daca fisierul exista in directorul curent
            if [[ -f "$fisier" ]]; then
                fisier=$(realpath "$fisier")
            else
            	echo "Fiserul $fisier nu exista"
            	exit 1
            fi

            read -p "Introduceți directorul in care sa fie mutat fisierul: " director
            # cauta directorul
	        director_gasit=$(find / -type d -name "$director" -print -quit 2>/dev/null)

    	    # verificam daca directorul exista
    	    if [[ -n "$director_gasit" ]]; then
    	        # daca da, mutam fisierul 
    	        mv "$fisier" "$director_gasit"
    	    else
        		echo "Directorul $director nu exista"
        		exit 1
    	    fi
            
            echo "Fisierul a fost mutat"
            ;;
        2)
            # mutare în git
            read -p "Introduceti numele fisierului pe care vreti sa il mutati: " fisier
            # verificam daca fisierul exista
            if [[ -f "$fisier" ]]; then
                read -p "Introduceti numele repository-ului Git local: " repository
                # cautam repository-ul
                repository_gasit=$(find / -type d -name "$repository" -exec test -d '{}/.git' \; -print -quit 2>/dev/null)
                #verificam daca repository-ul exista
                if [[ -n "$repository/.git" ]]; then
                   # muta fisierul 
        		    mv "$fisier" "$repository_gasit"
        		    
        		    # merge in directorul unde este clonat repository-ul
        		    cd "$repository_gasit"
        		    
        		    # adauga fisierul
        		    git add "$(basename "$fisier")"
        		    
        		    read -p "Introduceți un mesaj pentru commit: " mesaj
        		    
        		    # se realizeaza commit-ul
        		    git commit -m "$mesaj"
        		    
        		    git push origin HEAD
                    
                else
                    echo "Directorul $repository nu exista"
                    exit 1
                fi
            else
                echo "Fisierul $fisier nu exista"
                exit 1
            fi
            
            echo "Fisierul a fost mutat in Git"
            ;;
        *)
            echo "Optiune invalida"
            ;;
    esac
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
    select o in "Stergere fisiere" "Redenumire fisiere" "Editare fisiere" "Comprimare fisiere" "Copiere fisiere" "Criptare fisiere"; do
        case $o in
            "Stergere fisiere")
                echo "Introduceti numele directorului din care vor fi sterse fisierele:"
                read director
                # if [ -d $director ]; then
                #     for fisier in $director/*; do
                #     done
                # else
                #     echo "Directorul $director nu exista"
                #fi
                ;;
            "Redenumire fisiere")
                echo "Introduceti numele directorului in care vor fi redenumite fisierele:"
                read director
                # if [ -d $director ]; then
                #     for fisier in $director/*; do
                #     done
                # else
                #     echo "Directorul $director nu exista"
                #fi
                ;;
            "Editare fisiere")
                echo "Introduceti numele directorului in care vor fi editate fisierele:"
                read director
                if [ -d $director ]; then
                    for fisier in $director/*; do
                        echo "##### DEPRECATED #####" >> $fisier
                        echo "Fisierul $fisier a fost editat"
                    done
                else
                    echo "Directorul $director nu exista"
                fi
                ;;
            "Comprimare fisiere")
                echo "Introduceti numele directorului in care vor fi comprimate fisierele:"
                read director
                if [ -d $director ]; then
                    arhiva="$director/backup_$(date +%Y%m%d).zip"
                    zip -r "$arhiva" "$director"
                    echo "Arhiva $arhiva a fost creata"
                else
                    echo "Directorul $director nu exista"
                fi
                ;;
            "Copiere fisiere")
                echo "Introduceti numele directorului in care vor fi copiate fisierele:"
                read director
                # if [ -d $director ]; then
                #     for fisier in $director/*; do
                #     done
                # else
                #     echo "Directorul $director nu exista"
                #fi
                ;;
            "Criptare fisiere")
                echo "Introduceti numele directorului in care vor fi criptate fisierele:"
                read director
                # if [ -d $director ]; then
                #     for fisier in $director/*; do
                #     done
                # else
                #     echo "Directorul $director nu exista"
                #fi
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
}

#Parsarea optiunilor din linia de comanda cu getopts
OPTIUNI=$(getopt -o hu -l help,usage,debug: -- "$@")

if [ $? != 0 ]; then
    echo "Optiune invalida"
    exit 1
fi

eval set -- "$OPTIUNI"

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
            
