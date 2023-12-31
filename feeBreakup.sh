#!/bin/bash
awk '{ if ($1 == "TuitionFee") $2 += 50000; print }' "$HOME/fees.txt" > "$HOME/temp.txt" && mv "$HOME/temp.txt" "$HOME/fees.txt"
awk '{ if ($1 == "HostelRent") $2 += 20000; print }' "$HOME/fees.txt" > "$HOME/temp.txt" && mv "$HOME/temp.txt" "$HOME/fees.txt"
awk '{ if ($1 == "ServiceCharge") $2 += 10000; print }' "$HOME/fees.txt" > "$HOME/temp.txt" && mv "$HOME/temp.txt" "$HOME/fees.txt"
awk '{ if ($1 == "MessFee") $2 += 20000; print }' "$HOME/fees.txt" > "$HOME/temp.txt" && mv "$HOME/temp.txt" "$HOME/fees.txt"

echo "Date of fee submission :- $(date +%Y-%m-%d)" >> $HOME/fees.txt
hostel=$(dirname $(dirname $HOME))
if [ $(cat $hostel/announcements.txt | wc -l) -lt 5 ]
then
    rollnumber=$(mysql -h mysql_container -u root -proot --silent -e "USE student_details_database; SELECT RollNumber FROM userDetails WHERE Name = '$(whoami)';")
    if ! grep -q "$rollnumber" "$hostel/announcements.txt"; then
        echo "$rollnumber" >> $hostel/announcements.txt
    fi
fi
echo "Fee successfully submitted"
