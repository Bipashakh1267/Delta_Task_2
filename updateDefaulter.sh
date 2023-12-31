#!/bin/bash
for room in $HOME/*; do
  if [ -d $room ]; then
    for student in $room/*; do
      if [ -d $student ]; then
        if [ $(awk 'NR==2 {print $2}' $student/fees.txt) -eq 0 ];then
          rollnumber=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT RollNumber FROM userDetails WHERE Name = '$(basename $student)';")
          if ! grep -q "$rollnumber" "$HOME/feeDefaulters.txt"; then
              echo "$(basename $student) $rollnumber" >> $HOME/feeDefaulters.txt
          fi
        fi
      fi
    done
  fi
done
