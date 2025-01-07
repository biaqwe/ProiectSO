#!/bin/bash

#Gasirea tuturor fisierelor mai vechi de o data calendaristica introdusa
gasire(){
    read -p "Introduceti o data sau o perioada (ex: '2023-12-25', '10 zile', '2 luni' ): " perioada

    # Validare input
    if [[ ! "$perioada" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ && ! "$perioada" =~ ^[0-9]+[[:space:]]*(zile|luni|ani|saptamani)$ ]]; then
        echo "Format invalid. Introduceti o dată valida sau o perioada (ex: '10 zile', '2 luni' )."
        return
    fi

    # Determinare timp de referinta
    if [[ "$perioada" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Daca este o data calendaristica
        data_ref="$perioada"
    else
        # Daca este o perioada relativa (zile, luni, ani, etc.)
        unitate=$(echo "$perioada" | awk '{print $2}')
        valoare=$(echo "$perioada" | awk '{print $1}')

        # Calcularea datei de referinta
        case $unitate in
            zile) data_ref=$(date -d "-$valoare days" +%Y-%m-%d) ;;
            luni) data_ref=$(date -d "-$valoare months" +%Y-%m-%d) ;;
            ani) data_ref=$(date -d "-$valoare years" +%Y-%m-%d) ;;
            saptamani) data_ref=$(date -d "-$((valoare * 7)) days" +%Y-%m-%d) ;;
            *) echo "Unitate necunoscuta. Folositi 'zile', 'luni', 'ani', 'saptamani'."; return ;;
        esac
    fi

    # Cautam fisierele dorite 
    read -p "Introduceti directorul unde să căutăm fisiere: " director

    if [[ ! -d "$director" ]]; then
        echo "Directorul $director nu există."
        return
    fi

    echo "Căutăm fișiere mai vechi de $data_ref în directorul $director..."
    find "$director" -type f ! -newermt "$data_ref" -print
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
		read -p "Introduceti numele directorului din care sa se mute fisierele: " director_sursa
		#cautam directorul sursa
		director_sursa_gasit=$(find / -type d -name "$director_sursa" -print -quit 2>/dev/null)
		# verificam daca directorul sursa exista
		if [[ ! -n "$director_sursa_gasit" ]]; then
		    echo "Directorul $director_sursa nu exista"
		    exit 1
		fi

		read -p "Introduceti numele directorului in care sa se mute fisierele: " director
		# cautam directorul
		director_gasit=$(find / -type d -name "$director" -print -quit 2>/dev/null)

		# verificam daca directorul tinta exista
		if [[ -n "$director_gasit" ]]; then
		    # daca da, mutam toate fisierele din directorul sursa in directorul tinta
		    for fisier in "$director_sursa_gasit"/*; do
		        if [[ -f "$fisier" ]]; then
		            mv "$fisier" "$director_gasit"
		        fi
		    done
		else
		    echo "Directorul $director nu exista"
		    exit 1
		fi
		
		echo "Fisierele au fost mutate"
		;;
	    2)
		# mutare în Git
		read -p "Introduceti numele directorului din care sa se mute fisierele: " director_sursa
		director_sursa_gasit=$(find / -type d -name "$director_sursa" -print -quit 2>/dev/null)
		# verificam daca directorul sursa exista
		if [[ ! -n "$director_sursa_gasit" ]]; then
		    echo "Directorul $director_sursa nu exista"
		    exit 1
		fi

		read -p "Introduceti numele repository-ului Git local: " repository
		# cautam repository-ul
		repository_gasit=$(find / -type d -name "$repository" -exec test -d '{}/.git' \; -print -quit 2>/dev/null)
		
		#verificam daca repository-ul exista
		if [[ -n "$repository_gasit" ]]; then
		    # muta toate fisierele din directorul sursa in repository-ul Git
		    for fisier in "$director_sursa"/*; do
		        if [[ -f "$fisier" ]]; then
		            mv "$fisier" "$repository_gasit"
		            # merge in directorul unde este clonat repository-ul
		            cd "$repository_gasit"
		            
		            # adauga fisierul
		            git add "$(basename "$fisier")"
		            
		            read -p "Introduceți un mesaj pentru commit: " mesaj
		            
		            # se realizeaza commit-ul
		            git commit -m "$mesaj"
		        fi
		    done
		    
		    # da push pentru toate fisierele adaugate
		    git push origin HEAD
		else
		    echo "Repository-ul $repository nu exista"
		    exit 1
		fi
		
		echo "Fisierele au fost mutate"
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
    select o in "Criptare fisiere" "Stergere fisiere" "Redenumire fisiere" "Editare fisiere" "Comprimare fisiere" "Copiere fisiere" "Generare raport fisiere"; do
        case $o in 
            "Criptare fisiere")
                # Cere utilizatorului numele directorului care contine fisierele de criptat
                read -p "Introduceti numele directorului care contine fisierele de criptat: " director

                # Verifica daca directorul specificat exista
                if [[ ! -d "$director" ]]; then
                    echo "Directorul specificat nu exista."
                    break
                fi
    
                read -p "Introduceti cheia de criptare: " -s cheie
                echo
                
                # Verifica daca cheia de criptare nu este goala
                if [[ -z "$cheie" ]]; then
                    echo "Cheia de criptare nu poate fi goala."
                    break
                fi

                # Creaza fisierul daca nu exista deja 
                touch $director/cheie_decriptare.txt
                fisier_cheie="$director/cheie_decriptare.txt"
                echo "$cheie" > "$fisier_cheie" # Scrie cheia in fisierul decriptare
                chmod 600 "$fisier_cheie" # Restrictioneaza accesul la fisierul cheii pentru a fi mai sigur

                for fisier in "$director"/*; do
                    if [[ -f "$fisier" ]]; then
                        # Cripteaza fisierul folosind AES-256-CBC si salveaza cu extensia .enc
                        openssl enc -aes-256-cbc -salt -in "$fisier" -out "$fisier.enc" -pass pass:"$cheie"

                        # Verifica daca criptarea a fost reusita
                        if [[ $? -eq 0 ]]; then
                            # Daca criptarea a avut succes, sterge fisierul original
                            rm "$fisier"
                            echo "Fisierul $fisier a fost criptat."
                        else
                            echo "Eroare la criptarea fisierului $fisier."
                        fi
                    fi
                done

                echo "Toate fisierele au fost criptate. Cheia este salvata in $fisier_cheie."
                break
            ;;

            "Stergere fisiere")
                echo "Introduceti numele directorului din care vor fi sterse fisierele:"
                read director
                if [ -d "$director" ]; then
                    for fisier in "$director"/*; do
                        if [ -f "$fisier" ]; then
                            rm "$fisier"
                            echo "Fisierul $fisier a fost sters"
                        fi
                    done
                else
                    echo "Directorul $director nu exista"
                fi
                ;;
            "Redenumire fisiere")
                echo "Introduceti numele directorului in care vor fi redenumite fisierele:"
                read director
                if [ -d "$director" ]; then
                    for fisier in "$director"/*; do
                        if [ -f "$fisier" ]; then
                            mv "$fisier" "$fisier.old"
                            echo "Fisierul $fisier a fost redenumit in $fisier.old"
                        fi
                    done
                else
                    echo "Directorul $director nu exista"
                fi
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
                    for fisier in $director/*; do
                        arhiva="${fisier}_$(date +%Y%m%d).zip"
                        zip -j "$arhiva" "$fisier"
                        echo "Fisierul $fisier a fost comprimat in arhiva $arhiva"
                    done
                else
                    echo "Directorul $director nu exista"
                fi
                ;;
            "Copiere fisiere")
                echo "Introduceti numele directorului sursa:"
                read sursa
                echo "Introduceti numele directorului destinatie:"
                read destinatie
                if [ -d "$sursa" ]; then
                    if [ ! -d "$destinatie" ]; then
                        mkdir -p "$destinatie"
                    fi
                    for fisier in "$sursa"/*; do
                        if [ -f "$fisier" ]; then
                            cp "$fisier" "$destinatie"
                            echo "Fisierul $fisier a fost copiat in $destinatie"
                        fi
                    done
                else
                    echo "Directorul sursa $sursa nu exista"
                fi
                ;;
	    "Generare raport fisiere")
            	echo "Introduceti directorul pentru care doriti raportul:"
		read director

		#cautam directorul
		director_gasit=$(find / -type d -name "$director" -print -quit 2>/dev/null)
		# verificam daca directorul exista
		if [[ ! -n "$director_gasit" ]]; then
		    echo "Directorul $director nu exista"
		    exit 1
		fi

		#generare raport
		echo "Raport pentru directorul: $director_gasit"
		echo "Numar total de fișiere: $(find "$director_gasit" -type f | wc -l)"
		echo "Dimensiune totala: $(du -sh "$director_gasit" | cut -f1)"
		echo "Ultima modificare: $(stat -c %y "$director_gasit")"
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
            
