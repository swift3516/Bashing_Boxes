#!/bin/bash
# Bashing Boxes - Cleaned and Organized Version

# Ensure the data directory exists
data_dir="data"
if [ ! -d "$data_dir" ]; then
    mkdir "$data_dir"
fi

# Array holding your current box of items
box_items=(
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

print_box_items() {
    echo
    echo "Items in your box:"
    for i in "${!box_items[@]}"; do
        echo "$((i+1)). ${box_items[$i]}"
    done
}

print_item_at_position() {
    read -p "Enter item position (1-${#box_items[@]}): " position
    index=$((position-1))
    if [[ $index -ge 0 && $index -lt ${#box_items[@]} ]]; then
        echo "Item at position $position: ${box_items[$index]}"
    else
        echo "Invalid position."
    fi
}

add_item_to_box() {
    read -p "Enter new item to add: " new_item
    box_items+=("$new_item")
    echo "\"$new_item\" added to the box."
}

remove_last_item_from_box() {
    if [ ${#box_items[@]} -eq 0 ]; then
        echo "Box is already empty."
    else
        unset 'box_items[-1]'
        box_items=("${box_items[@]}")
        echo "Last item removed."
    fi
}

remove_item_at_position() {
    read -p "Enter position to remove (1-${#box_items[@]}): " position
    index=$((position-1))
    if [[ $index -ge 0 && $index -lt ${#box_items[@]} ]]; then
        unset 'box_items[index]'
        box_items=("${box_items[@]}")
        echo "Item at position $position removed."
    else
        echo "Invalid position."
    fi
}

save_box_to_file() {
    read -p "Enter name for the save file: " filename
    if [[ ! "$filename" =~ ^[A-Za-z0-9_-]+$ ]]; then
        echo "Invalid filename. Use only letters, numbers, _ or -."
        return
    fi
    file_path="$data_dir/$filename.box"
    printf "%s\n" "${box_items[@]}" > "$file_path"
    echo "Box saved to $file_path"
}

load_box_from_file() {
    list_saved_boxes
    read -p "Enter filename to load (without extension): " filename
    file_path="$data_dir/$filename.box"
    if [ ! -f "$file_path" ]; then
        echo "Save file '$filename.box' does not exist."
        return
    fi
    mapfile -t box_items < "$file_path"
    echo "Box loaded from $file_path"
}

list_saved_boxes() {
    echo "Saved boxes:"
    ls "$data_dir"/*.box 2>/dev/null | xargs -n 1 basename || echo "No saved boxes found."
}

delete_box_file() {
    list_saved_boxes
    read -p "Enter the filename to delete (without extension): " filename
    file_path="$data_dir/$filename.box"
    if [ ! -f "$file_path" ]; then
        echo "Save file '$filename.box' does not exist."
        return
    fi
    rm "$file_path"
    echo "Deleted $file_path"
}

prompt_save_and_exit() {
    while true; do
        read -p "Would you like to save before exiting? (y/n): " yn
        case $yn in
            [Yy]*) save_box_to_file; break;;
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
    echo
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
    read -p "Enter option: " user_selection
    case "$user_selection" in
        1) print_box_items ;;
        2) print_item_at_position ;;
        3) add_item_to_box ;;
        4) remove_last_item_from_box ;;
        5) remove_item_at_position ;;
        6) save_box_to_file ;;
        7) load_box_from_file ;;
        8) list_saved_boxes ;;
        9) delete_box_file ;;
        10) prompt_save_and_exit ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done