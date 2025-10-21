#!/bin/bash

items=(
  "Packaged meat"
  "Winter coat"
  "Camomile"
  "Painting"
  "Stove"
  "Paperclips"
  "Map"
  "Gloves"
  "Cargo pants"
  "Locket"
)


print_list() {
  echo ""
  echo "Items in the list:"
  for i in "${!items[@]}"; do
    echo "$((i+1)). ${items[$i]}"
  done
}

print_item() {
  read -p "Enter item position (1-${#items[@]}): " pos
  index=$((pos-1))
  if [[ $index -ge 0 && $index -lt ${#items[@]} ]]; then
    echo "Item at position $pos: ${items[$index]}"
  else
    echo "Invalid position."
  fi
}

add_item() {
  read -p "Enter new item to add: " new_item
  items+=("$new_item")
  echo "\"$new_item\" added to the list."
}

remove_last() {
  if [ ${#items[@]} -eq 0 ]; then
    echo "List is already empty."
  else
    unset 'items[-1]'
    items=("${items[@]}") #RE-index array to remove any gaps
  fi
}

remove_x() {
  read -p "Enter position to remove (1-${#items[@]}): " pos
  index=$((pos-1))
  if [[ $index -ge 0 && $index -lt ${#items[@]} ]]; then
    unset 'items[index]'
    items=("${items[@]}")
    echo "Item at position $pos removed."
  else
    echo "Invalid position."
  fi
}

while true; do
  echo ""
  echo "Menu:"
  echo "1. Print list"
  echo "2. Print item at X position"
  echo "3. Add item"
  echo "4. Remove last item"
  echo "5. Remove item at X position"
  echo "6. Exit"
  read -p "Enter option: " choice
  case "$choice" in
    1) print_list ;;
    2) print_item ;;
    3) add_item ;;
    4) remove_last ;;
    5) remove_x ;;
    6) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid option. Please try again." ;;
  esac
done