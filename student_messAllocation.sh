#!/bin/bash
rollnumber=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT RollNumber FROM userDetails WHERE Name = '$(whoami)';")
messpref=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT MessPreferences FROM userDetails WHERE Name = '$(whoami)';")
if [[ $messpref == *-* ]]; then
    read -p "Enter your mess Preference :- " messpref
    mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; UPDATE userDetails SET MessPreferences = '$messpref' WHERE Name = '$(whoami)';"
    echo $rollnumber >> /home/HAD/mess.txt
else
    echo $rollnumber >> /home/HAD/mess.txt
fi
