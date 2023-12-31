#!/bin/bash

mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; CREATE TABLE IF NOT EXISTS userDetails (Name VARCHAR(255),RollNumber VARCHAR(255),Department VARCHAR(255),Year VARCHAR(255),Hostel VARCHAR(255),Month VARCHAR(255),AllocatedMess VARCHAR(255),MessPreferences VARCHAR(255));"

useradd -m -d /home/HAD HAD
echo "password@123" | passwd --stdin HAD
echo -e "Mess capacity\n1 35\n2 35\n3 35\nStudent Preferences" > /home/HAD/mess.txt
chown HAD:HAD /home/HAD/mess.txt
groupadd students
if [ $# -eq 0 ]; then
   while true; do
    read -p "Enter name: " name
    read -p "Enter roll number: " rollnumber
    read -p "Enter hostel: " hostel
    read -p "Enter room: " room
    read -p "Enter mess: " mess
    read -p "Enter mess preference: " messpref
    echo "$name $rollnumber $hostel $room $mess $messpref" >> temp.txt
   done

    file=temp.txt
else
    file=$1
    if [ ! -f "$file" ]; then
      echo "Error: $file not found"
      exit 1
    fi
fi
tail -n +2 $file | while read line; do
   name=$(echo $line | awk '{print $1}')
   rollnumber=$(echo $line | awk '{print $2}')
   hostel=$(echo $line | awk '{print $3}')
   room=$(echo $line | awk '{print $4}')
   mess=$(echo $line | awk '{print $5}')
   messpref=$(echo $line | awk '{print $6}')
   dep_num=$(echo $rollnumber | cut -c2-4)
   if [ $dep_num == '021' ]; then
      Department="Chem"
   elif [ $dep_num == '061' ]; then
      Department="CSE"
   elif [ $dep_num == '031' ]; then
      Department="Civil"
   elif [ $dep_num == '101' ]; then
      Department="ICE"
   elif [ $dep_num == '131' ]; then
      Department="EE"
   elif [ $dep_num == '141' ]; then
      Department="PROD"
   elif [ $dep_num == '181' ]; then
      Department="EC"
   elif [ $dep_num == '011' ]; then
      Department="ARCH"
   elif [ $dep_num == '121' ]; then
      Department="Mt"
   fi
   curr_year=$(date +%y)
   admit_year=$(echo $rollnumber | cut -c5-6)
   yearNum=$((admit_year-curr_year+2))
   if [ $yearNum == '1' ]; then
      Year="1st"
   elif [ $yearNum == '2' ]; then
      Year="2nd"
   elif [ $yearNum == '3' ]; then
      Year="3rd"
   elif [ $yearNum == '4' ]; then
      Year="4th"
   fi

   if id "$hostel" >/dev/null 2>&1; then
      echo -n
   else
      useradd -m -d /home/HAD/$hostel $hostel
      echo "password@123" | passwd --stdin HAD
      touch /home/HAD/$hostel/announcements.txt
      chown $hostel:$hostel /home/HAD/$hostel/announcements.txt
      touch /home/HAD/$hostel/feeDefaulters.txt
      chown $hostel:$hostel /home/HAD/$hostel/feeDefaulters.txt
      echo "alias updateDefaulter='bash /home/updateDefaulter.sh'" >> /home/HAD/$hostel/.bashrc
      source /home/HAD/$hostel/.bashrc
   fi
   room=$(printf "%03d" $room)
   if [ ! -d "/home/HAD/$hostel/$room" ]; then
      mkdir /home/HAD/$hostel/$room
      chown $hostel:$hostel /home/HAD/$hostel/$room
   fi
   if id "$name" >/dev/null 2>&1; then
      echo "Student $name already registered"
   else
      count=$(ls -l /home/HAD/$hostel/$room | wc -l)
      if [ "$count" -gt 3 ]; then
         echo "Error: the room $room already has more than 2 students."
      else
         useradd -m -d /home/HAD/$hostel/$room/$name $name
         echo "password@123" | passwd --stdin HAD
         usermod -aG students $name
         usermod -aG $name $hostel
         mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; INSERT INTO userDetails (Name, RollNumber, Department, Year, Hostel, Month, AllocatedMess, MessPreferences) VALUES ('$name', '$rollnumber', '$Department', '$Year', '$hostel', '$(date '+%B')', '$mess', '$messpref');"
         echo -e "TuitionFee 0\nHostelRent 0\nServiceCharge 0\nMessFee 0 " > /home/HAD/$hostel/$room/$name/fees.txt
         chown $name:$name /home/HAD/$hostel/$room/$name/fees.txt
         echo "alias messAllocation='bash /home/student_messAllocation.sh'" >> /home/HAD/$hostel/$room/$name/.bashrc
         echo "alias feeBreakup='bash /home/feeBreakup.sh'" >> /home/HAD/$hostel/$room/$name/.bashrc
         source /home/HAD/$hostel/$room/$name/.bashrc
         messpref=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT MessPreferences FROM userDetails WHERE Name = '$name';")
         if [[ $messpref != *-* ]]; then
             echo $rollnumber >> /home/HAD/mess.txt
         fi
      fi
   fi
done

chgrp students /home/student_messAllocation.sh
chgrp HAD /home/office_messAllocation.sh
chgrp students /home/feeBreakup.sh
chmod g+x /home/student_messAllocation.sh
chmod g+x /home/office_messAllocation.sh
chmod g+x /home/feeBreakup.sh
chmod o+x /home/updateDefaulter.sh
echo "alias messAllocation='bash /home/office_messAllocation.sh'" >> /home/HAD/.bashrc
source /home/HAD/.bashrc
usermod -aG wheel HAD
