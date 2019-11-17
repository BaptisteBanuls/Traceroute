#!/bin/bash

case $1 in
	ah) echo "digraph G {" > carte.dot ;;  #Affiche digraph G { dans le fichier carte.dot
	fichier)
		for x in `cat routes.rte` # On boucle en prenant chaque ligne du fichier.rte que l'on met carte.dot, en récupèrant toutes les lignes sauf le label, d'où name
		do
			if [ $(echo $x | grep -v 'name') ] 
			then
				echo -n "\""$x"\" -> " >> carte.dot
			fi
		done
		echo "[label=\""`cat routes.rte | grep 'name' | cut -d":" -f2`"\"];" >> carte.dot # Affiche le nom du label dans le carte.dot
		echo -e "\n\n" >> carte.dot ;; # Prend en compte les \n
	salut)
		echo -e "\n}" >> carte.dot # Affiche la dernière accolade
		sed -i 's/\(.*\) ->/\1/' carte.dot # Permet de retirer la dernière flèche de la ligne 
		cat carte.dot
		dot -T pdf carte.dot -o carto.pdf # Permet la création de la cartographie du script carto.pdf à partir du fichier carte.dot
		evince carto.pdf # Ouvre le pdf
esac
