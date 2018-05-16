#!/bin/bash

#Variablem
curdate=`date +%Y%m%d_%H%M%S`

#Änderungen an Dateien sammeln und array füllen
IFS=$'\n'
readarray -t changearray <<< "$(git commit -m "$curdate" | grep "geändert" | awk '{print $2}')"

#Geänderte Dateien hinzufügen
for i in "${changearray[@]}"
do
	echo "$i added!"
	git add $i        
done

#Änderungen Commiten
git commit -m "$curdate"

#Änderungen herunterladen
git pull https://github.com/tetesept/sysmaster.git master

#Änderungen hochladen
git push https://github.com/tetesept/sysmaster.git master


