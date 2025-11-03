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

DATA_DIR="data"

# Ensure data directory exists
[ ! -d "$DATA_DIR" ] && mkdir "$DATA_DIR"

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
    items=("${items[@]}")
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

save_box() {
  read -p "Enter name for the save file: " filename
  # Input validation: allow only alphanumeric, underscore, or dash
  if [[ ! "$filename" =~ ^[A-Za-z0-9_-]+$ ]]; then
    echo "Invalid filename. Use only letters, numbers, _ or -."
    return
  fi
  file_path="$DATA_DIR/$filename.box"
  printf "%s\n" "${items[@]}" > "$file_path"
  echo "Box saved to $file_path"
}

load_box() {
  echo "Available boxes:"
  ls "$DATA_DIR"/*.box 2>/dev/null | xargs -n 1 basename
  read -p "Enter the filename to load (without extension): " filename
  file_path="$DATA_DIR/$filename.box"
  if [ ! -f "$file_path" ]; then
    echo "Save file '$filename.box' does not exist."
    return
  fi
  mapfile -t items < "$file_path"
  echo "Box loaded from $file_path"
}

list_boxes() {
  echo "Saved boxes:"
  ls "$DATA_DIR"/*.box 2>/dev/null | xargs -n 1 basename
}

delete_box() {
  echo "Available boxes for deletion:"
  ls "$DATA_DIR"/*.box 2>/dev/null | xargs -n 1 basename
  read -p "Enter the filename to delete (without extension): " filename
  file_path="$DATA_DIR/$filename.box"
  if [ ! -f "$file_path" ]; then
    echo "Save file '$filename.box' does not exist."
    return
  fi
  rm "$file_path"
  echo "Deleted $file_path"
}

exit_game() {
  while true; do
    read -p "Would you like to save before exiting? (y/n): " yn
    case $yn in
      [Yy]*) save_box; break;;
      [Nn]*) break;;
      *) echo "Please enter y or n.";;
    esac
  done
  echo "Goodbye!"
  sleep 5
  echo "Returning to terminal..."
  exit 0
}

while true; do
  echo ""
  echo "Menu:"
  echo "1. Print list"
  echo "2. Print item at X position"
  echo "3. Add item"
  echo "4. Remove last item"
  echo "5. Remove item at X position"
  echo "6. Save current box"
  echo "7. Load a saved box"
  echo "8. List saved boxes"
  echo "9. Delete a saved box"
  echo "10. Exit"
  read -p "Enter option: " choice
  case "$choice" in
    1) print_list ;;
    2) print_item ;;
    3) add_item ;;
    4) remove_last ;;
    5) remove_x ;;
    6) save_box ;;
    7) load_box ;;
    8) list_boxes ;;
    9) delete_box ;;
    10) exit_game ;;
    *) echo "Invalid option. Please try again." ;;
  esac
done