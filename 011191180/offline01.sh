#!/bin/bash

declare -A tamperedDept  
total_tampered=0

while IFS= read -r -d '' file; do
  if [[ "$file" =~ ([0-9]{4})_([0-9]{2})_([0-9]{2}).log ]]; then
    year="${BASH_REMATCH[1]}"
    month="${BASH_REMATCH[2]}"
    day="${BASH_REMATCH[3]}"
  else
    echo "Invalid filename: $file"
    continue
  fi
  

  if ! date "+%Y-%m-%d" -d "$year-$month-$day" > /dev/null 2>&1; then
    dept=$(head -n 1 "$file")
    echo "Tampered file: $file"
    ((tamperedDept[$dept]++))
    ((total_tampered_files++))
    continue
  fi
  

  right_dept=$(echo "$file" | cut -d "/" -f 2)
  right_date="$year-$month-$day"
  actual_dept=$(head -n 1 "$file")
  actual_date=$(head -n 2 "$file" | tail -n 1)
  if [[ "$actual_dept" != "$right_dept" || "$actual_date" != "$right_date" ]]; then

    dept=$(head -n 1 "$file")
    echo "Tampered file: $file"
    ((tamperedDept[$dept]++))
    ((total_tampered_files++))
    continue
  fi
  
done < <(find logs -name "*.log" -type f -print0)


echo "Tampered files of department:"
for dept in "${!tamperedDept[@]}"; do
  count=${tamperedDept[$dept]}
  echo "$dept: $count"
done
echo "Total tampered files: $total_tampered_files"

