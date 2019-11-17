#!/bin/bash

bash dot.sh ah

# Si aucun agrument n'est indiqué, cela affiche simplement "Arguments invalide, indiquez une adresse sur le premier argument"

if [ "$#" -eq 0 ]
then
	echo "Arguments invalide, indiquez une adresse sur le premier argument"
	
	#S'il y a au moins 1 argument, tout ce qui suit se fait
	
else 

	#Ici, on boucle sur chaque argument
	
	for b in $*
	do
		final=0
		
		#Permet de vider le fichier routes.rte
		
		echo "" > routes.rte
		
		#Permet d'afficher l'argument que l'on traite
		
		echo -e "                    "$b"\n"
		
		#S'il y a au moins une lettre dans l'argument, cela permet de considèrer que c'est un nom de domaine, d'où le host pour déterminer l'IP
		
		if [ $(echo $b | grep -e '[a-z]') ]
		then
			dest=`host $b | grep 'has address' | cut -d" " -f4 | head -n1`
		else
		
			#S'il n'y a pas de lettre dans l'argument, on considère que c'est une IP
			
			dest=$b
		fi
		
		#Ici, on va boucler de 1 à 30 sauts
		
		for i in `seq 1 30`
		do
			#Permet l'affichage du numéro du saut
			
			echo "Saut "$i
			baptisto=0
			
			#Ici, on boucle en utilisant plusieurs protocoles/ports afin d'avoir plus de chance que le routeur réponde
			
			for var in "-I" "-U -p 53" "-T -p 443" "-T -p 80" "-T -p 22" "-T -p 25"
			do
				((baptisto++))
				
				#On affiche quel protocole on essaye au fur et à mesure des essais
				
				echo -n "Protocole "
				case $(echo $var | cut -c2) in
					I) echo -ne "ICMP\n";;
					U) echo -ne "UDP port "$(echo $var | awk '{print $3}')"\n";;
					T) echo -ne "TCP port "$(echo $var | awk '{print $3}')"\n"
				esac
				
				#On fait la commande traceroute avec tous les parametres adaptés (temps de réponse, destination, ports, saut, AS, suppression des étoiles ...)
				
				r=$(sudo traceroute -w0.5 $dest $var -f$i -m$i -q1 -n -A | sed '1d' | awk '{print $2$3}' | sed 's/*//' | sed "s/\[\]//")
				
				#Si la variable $r est non vide, cela signifie que l'on a trouvé l'IP
				
				if [ ! -z $r ]
				then
				
					#On affiche l'IP dans la console
					
					echo $r
					
					#Puis, écrit l'IP dans le fichier routes.rte
					
					echo $r >> routes.rte
					
					#Si l'IP est égale à l'IP de destination, cela signifie que le paquet est arrivé à destination, on break la boucle des protocoles et on met une variable à 1 qui servira à break la boucle des sauts
					
					if [ $(echo "$r" | cut -d"[" -f1) = "$dest" ]
					then
						final=1
						break
					fi 
					break
				fi
				
				#Si la variable $baptisto est égale à 6, cela signifie que l'on a testé tous les protocoles et que le routeur n'a répondu à aucun d'entre eux, donc on affiche "non-trouvé" dans la console et "non-trouvé" + le numéro du saut dans le fichier routes.rte
				
				if [ $baptisto -eq 6 ]
				then
					echo "non-trouve"
					echo "non-trouve"$i >> routes.rte
				fi
			done
			
			#Si la varialbe $final est égale à 1, cela signifie que l'on a trouvé l'IP de destination et donc on break la boucle des sauts		
			
			if [ $final -eq 1 ]
			then
				break
			fi
			echo -e "\n"
		done
		
		#On écrit le nom de l'argument à la suite des IP dans le fichier routes.rte afin de pouvoir faire le label dans le DOT permetant d'identifier les branches de la carto.pdf 
		
		echo "name:"$b >> routes.rte
		bash dot.sh fichier
	done
	bash dot.sh salut
fi
