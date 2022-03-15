#!/bin/bash

function print_menu
{
clear
echo "---MENU GŁÓWNE---"
echo "1) Stwórz pokój"
echo "2) Usuń pokój"
echo "3) Wejdź do pokoju"
echo "4) Wyślij wiadomość prywatną"
echo "5) Pokaż wiadomości prywatne"
echo "6) Wyloguj i zakończ"
echo "-----------------"
}



clear

logincase=1

while [ $logincase = 1 ]
do
	echo -n "login: "
	read login
	grep -x "$login" ./files/users > /dev/null 2> /dev/null 
	if [ $? -eq 0 ]
	then
		echo "login jest już zajęty"
	else
		echo "Zalogowano."
		#wpisany na liste zalogowanych
		logincase=0
		echo "$login" >> ./files/users
		
		#stworzenie pokoju uzytkownika
		safelogin=`echo "$login" | tr " " "_"`
		touch "./files/private/$safelogin"
	fi
done

clear

while [ 1 ]
do
print_menu
echo -n "-> "
read option
case "$option" in

#-------tworzenie pokoju-------
"1")
clear
echo -n "nazwa nowego pokoju: "
read roomname
name=`echo $roomname | tr " " "_"`

if ls ./files/rooms | grep -w "$name" > /dev/null
then 
	echo "Pokój o danej nazwie już isnieje"
else 
	echo "Utworzono pokój $name"
	touch "./files/rooms/$name"
fi
sleep 1.5 
;;

#-------usuwanie pokoju-------
"2")
clear
echo "Dostępne pokoje:"
echo "`ls ./files/rooms/`" 
echo -n "-> "
read room

if ls ./files/rooms | grep -w "$room" > /dev/null
then 
	rm "./files/rooms/$room"
	echo "Pokój $room został usunięty"
else 
	echo "Nieprawidłowa nazwa pokoju"
fi
sleep 1.5
;;

#-------wchodzenie do pokoju-------
"3")
clear
echo "Dostępne pokoje:"
echo "`ls ./files/rooms/`" 
echo -n "-> "
read room

if ls ./files/rooms | grep -w "$room" > /dev/null
then 
	#-------pisanie w pokoju-------
	clear
	cat "./files/rooms/$room"
	while [ 1 ]
	do
		echo -n "-> "
		read wpis
		if [ "$wpis" = "!exit" ] || [ "$wpis" = "!e" ]
		then
			break
		elif [ "$wpis" = "!reload" ] || [ "$wpis" = "!r" ]
		then
			clear
			cat "./files/rooms/$room"
		else
			if [ "$1" = "-UPPER" ]
			then
				wpis_upper=`echo "$wpis" | tr "[:lower:]" "[:upper:]"`
				echo "$login: $wpis_upper" >> "./files/rooms/$room"
				clear
				cat "./files/rooms/$room"
			else
				echo "$login: $wpis" >> "./files/rooms/$room"
				clear
				cat "./files/rooms/$room"

			fi
		fi
	done
	#------------------------------
else 
	echo "Nieprawidłowa nazwa pokoju"
	sleep 1.5
fi
;;

#-------pisz priv-------
"4")
clear
echo "Dostępni użytkownicy: "
echo "$login (ja)"
sed "/^$login$/d" ./files/users
echo -n "-> "
read usr_room
usr_safe=`echo "$usr_room" | tr " " "_"`

if ls ./files/private | grep -w "$usr_safe" > /dev/null
then 	

	#-------pisanie wiad priv-------
	clear
	while [ 1 ]
	do
		echo -n "-> "
		read wpis
		if [ "$wpis" = "!exit" ] || [ "$wpis" = "!e" ]
		then
			break
		else
			echo "$login: $wpis" >> "./files/private/$usr_safe"
		fi
	done
	#-------------------------------
else 
	echo "Nieprawidłowa nazwa użytkownika"
	sleep 1.5
fi
;;

#-------twoje wiad priv-------
"5")
clear
echo "Wiadomości prywante $login"
cat "./files/private/$safelogin"
	while [ 1 ]
	do
		echo -n "-> "
		read wpis
		if [ "$wpis" = "!exit" ]		
		then
			break
		elif [ "$wpis" = "!reload" ] || [ "$wpis" = "!r" ]
		then
			clear
			cat "./files/private/$safelogin"
		else 
			break
		fi
	done
;;

#-------logout-------
"6")
clear
echo "`sed "/^$login$/d" ./files/users`" > ./files/users 2> /dev/null
rm "./files/private/$safelogin"
echo "Logging out..."
sleep 1
clear
exit 0
;;

#--------------------
*) ;;
esac

done


