#!/bin/bash
mess1=$(awk 'FNR == 2 {print $2}' /home/HAD/mess.txt)
mess2=$(awk 'FNR == 3 {print $2}' /home/HAD/mess.txt)
mess3=$(awk 'FNR == 4 {print $2}' /home/HAD/mess.txt)
tail -n +6 /home/HAD/mess.txt | while read line; do
   roll_mess=$(echo $line | awk '{print $1}')
   for hostel in /home/HAD/*; do
    if [ -d "$hostel" ]; then
     for room in "$hostel"/*; do
      if [ -d "$room" ]; then
        for student in "$room"/*; do
         if [ -d "$student" ]; then
          rollnumber=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT RollNumber FROM userDetails WHERE Name = '$(basename $student)';")
          if [[ $roll_mess == $rollnumber ]]; then
               messpref=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT MessPreferences FROM userDetails WHERE Name = '$(basename $student)';")
               if [[ $messpref == 1 ]] && [[ $mess1 != 0 ]]; then
                 mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; UPDATE userDetails SET AllocatedMess = '$messpref' WHERE Name = '$(basename $student)';"
                 ((mess1=mess1-1))
               elif [[ $messpref == 2 ]] && [[ $mess2 != 0 ]]; then
                 mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; UPDATE userDetails SET AllocatedMess = '$messpref' WHERE Name = '$(basename $student)';"  
                 ((mess2=mess2-1))
               elif [[ $messpref == 3 ]] && [[ $mess3 != 0 ]]; then
                 mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; UPDATE userDetails SET AllocatedMess = '$messpref' WHERE Name = '$(basename $student)';"
                 ((mess3=mess3-1))
               fi
          fi
         fi
        done
      fi
     done
    fi
   done
done

for hostel in /home/HAD/*; do
  if [ -d "$hostel" ]; then
    for room in "$hostel"/*; do
      if [ -d "$room" ]; then
        for student in "$room"/*; do
         if [ -d "$student" ]; then
          messpref=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT MessPreferences FROM userDetails WHERE Name = '$(basename $student)';")
           if [[ $messpref == *-* ]]; then
              if [[ $mess1 != 0 ]]; then
                 mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; UPDATE userDetails SET AllocatedMess = '1' WHERE Name = '$(basename $student)';"
                 ((mess1=mess1-1))
               elif [[ $mess2 != 0 ]]; then
                 mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; UPDATE userDetails SET AllocatedMess = '2' WHERE Name = '$(basename $student)';" 
                 ((mess2=mess2-1))
               elif [[ $mess3 != 0 ]]; then
                 mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; UPDATE userDetails SET AllocatedMess = '3' WHERE Name = '$(basename $student)';"
                 ((mess3=mess3-1))
               fi
           fi
         fi
        done
      fi
    done
  fi
done

         
