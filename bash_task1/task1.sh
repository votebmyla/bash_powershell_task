#!/bin/bash

# Array of capitalized names.
names=()

# Array of logins. Firstname's first letter + lastname. All lowercase.
logins=()

# Array of duplicated logins. Needed when email logins create.
duplicated_logins=()

# Array of ids.
ids=()

# Array of location ids.
loc_ids=()

# Array of titles.
titles=()

# Array of departments.
departments=()

# Domain string for email.
domain="@abc.com"

# Full path of source file directory.
directory=$(dirname $(realpath $1))

# Function for adding capitalized names to "names" array.
create_names() {
  names[${#names[@]}]="${1^} ${2^}"
}

# Function for creating login from name.
create_logins() {
  fname=${1,,}
  lname=${2,,}
  logins[${#logins[@]}]="${fname::1}${lname}"
}

# Reading data from source file and fill corresponding arrays
while IFS="," read id location_id name title email department; do
  create_names $name
  create_logins $name
  ids[${#ids[@]}]=$id
  loc_ids[${#loc_ids[@]}]="${location_id}"
  departments[${#departments[@]}]=$department
done < <(tail +2 $1)

# Filling "titles" array with data that contains double quotes.
for t in ${!ids[@]}; do
  titles[$t]=$(awk -v FPAT='"[^"]*"|[^,]*' 'NR=='$t+2' { print $4 }' $1)
done

# Filling "duplicated_logins" array with non-unique email logins.
while read e; do
  duplicated_logins[${#duplicated_logins[@]}]=$e
done < <(printf "%s\n" "${logins[@]}" | sort | uniq -d)

# Creating "accounts_new.csv" file with corresponging headers.
echo "id,location_id,name,title,email,department" >${directory}/accounts_new.csv

# Filling "accounts_new.csv" file with data.
for i in ${!ids[@]}; do
  # Adding location id to the non-unique email logins.
  if [[ "${duplicated_logins[*]}" =~ "${logins[$i]}" ]]; then
    echo "${ids[$i]},${loc_ids[$i]},${names[$i]},${titles[$i]},${logins[$i]}${loc_ids[$i]}$domain,${departments[$i]}" >>${directory}/accounts_new.csv
    continue
  fi
  # Adding simple record.
  echo "${ids[$i]},${loc_ids[$i]},${names[$i]},${titles[$i]},${logins[$i]}$domain,${departments[$i]}" >>${directory}/accounts_new.csv
done
