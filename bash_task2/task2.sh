#!/bin/bash

# Full path of source file directory.
directory=$(dirname $(realpath $1))

# Array of lines without dash line.
log_lines=()

# Array of test durations.
durations=()

# Array of test statuses.
statuses=()

# Array of test messages.
messages=()

# Successful test results.
successes=0

# Failed test results.
fails=0

# Test result rating.
rating=0

# Test duration.
duration=0

# Reading file.
while read line; do
  if [[ $line =~ ^[-]+[-]$ ]]; then
    # Skipping lines consisting of only dash symbols.
    continue
  fi
  log_lines[${#log_lines[@]}]="${line}"
done < <(
  cat $1
  # Add new line at the end.
  echo
)

# Test name.
test_name=$(echo ${log_lines[0]} | awk -v FPAT='^[[a-zA-Z ]+]' '{print $1}')
# Removing square brackets and space.
test_name=${test_name:2:-2}

# Iterating through lines and filling arrays.
for i in ${!log_lines[@]}; do

  if ! [[ 0 -eq $i ]] && ! [[ $((${#log_lines[@]} - 1)) -eq $i ]]; then
    # Filling "durations" array.
    durations[$((${i} - 1))]=$(echo "${log_lines[$i]}" | awk '{print $NF}')

    # Filling "statuses" array.
    status=$(echo "${log_lines[$i]}" | awk -v FPAT='(^not ok)|(^ok)' '{print $1}')
    if [[ $status == "ok" ]]; then
      # Statuses with "true" value.
      statuses[$((${i} - 1))]=true
      # Incrementing successfull statuses.
      ((successes++))
    else
      # Statuses with "true" value
      statuses[$((${i} - 1))]=false
      # Incrementing successfull statuses.
      ((fails++))
    fi
    # Filling "messages" array.
    messages[$((${i} - 1))]=$(echo "${log_lines[$i]}" | awk -v FPAT='expecting [a-zA-Z (,]+)' '{print $1}')
  fi

  # Parsing rating and test duration values.
  if [[ $((${#log_lines[@]} - 1)) -eq $i ]]; then
    rating=$(echo "${log_lines[$i]}" | awk -v FPAT='rated as [0-9]+.[0-9]+%|[0-9]+%' '{print $1}' | awk -v FPAT='[0-9]+.[0-9]+|[0-9]+' '{print $1}')
    duration=$(echo "${log_lines[$i]}" | awk -v FPAT='[0-9]+ms$' '{print $1}')
  fi
done

# Creating output JSON file and filling with corresponding data.
printf '{
  "testName": "%s",
  "tests": [
  ' "$test_name" >${directory}/output.json

for i in ${!durations[@]}; do
  if [[ $((${#durations[@]} - 1)) -eq $i ]]; then
    printf '  {
      "name": "%s",
      "status": %s,
      "duration": "%s"
    }
  ' "${messages[$i]}" "${statuses[$i]}" "${durations[$i]}" >>${directory}/output.json
    continue
  fi
  printf '  {
      "name": "%s",
      "status": %s,
      "duration": "%s"
    },
  ' "${messages[$i]}" "${statuses[$i]}" "${durations[$i]}" >>${directory}/output.json
done

printf '],
  "summary": {
    "success": %s,
    "failed": %s,
    "rating": %s,
    "duration": "%s"
  }
}' "$successes" "$fails" "$rating" "$duration" >>${directory}/output.json
