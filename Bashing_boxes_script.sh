#!/bin/bash

data_dir="data"
if [ ! -d "$data_dir" ]; then
    mkdir "$data_dir"
fi

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
    for i in "${!box_items[@]}"
    do
        echo "$((i+1)). ${box_items[$i]}"
    done
}

print_item_at_position() {
    read -p "Enter position (1-${#box_items[@]}): " pos
    idx=$((pos-1))
    if [ $idx -ge 0 ]; then
        if [ $idx -lt ${#box_items[@]} ]; then
            echo "${box_items[$idx]}"
        else
            echo "Invalid position (number too big)."
        fi
    else
        echo "Invalid position (must be at least 1)."
    fi
}

add_item_to_box() {
    read -p "Enter item to add: " item
    box_items+=("$item")
    echo "Added: $item"
}

remove_last_item_from_box() {
    if [ ${#box_items[@]} -eq 0 ]; then
        echo "Box is empty."
    else
        unset 'box_items[-1]'
        box_items=("${box_items[@]}")
        echo "Removed last item."
    fi
}

remove_item_at_position() {
    read -p "Enter position to remove (1-${#box_items[@]}): " pos
    idx=$((pos-1))
    if [ $idx -ge 0 ]; then
        if [ $idx -lt ${#box_items[@]} ]; then
            unset 'box_items[idx]'
            box_items=("${box_items[@]}")
            echo "Removed item at position $pos."
        else
            echo "Invalid position (number too big)."
        fi
    else
        echo "Invalid position (must be at least 1)."
    fi
}

save_box_to_file() {
    read -p "Save as file name (letters, numbers, _ or - only): " fname
    if [[ "$fname" =~ ^[A-Za-z0-9_-]+$ ]]; then
        path="$data_dir/$fname.box"
        printf "%s\n" "${box_items[@]}" > "$path"
        echo "Box saved: $path"
    else
        echo "Invalid filename."
    fi
}

load_box_from_file() {
    ls "$data_dir"/*.box 2>/dev/null | xargs -n 1 basename
    read -p "Enter filename to load (without extension): " fname
    path="$data_dir/$fname.box"
    if [ -f "$path" ]; then
        mapfile -t box_items < "$path"
        echo "Box loaded from $path"
    else
        echo "File not found."
    fi
}

list_saved_boxes() {
    ls "$data_dir"/*.box 2>/dev/null | xargs -n 1 basename || echo "None saved."
}

delete_box_file() {
    ls "$data_dir"/*.box 2>/dev/null | xargs -n 1 basename
    read -p "File to delete (without extension): " fname
    path="$data_dir/$fname.box"
    if [ -f "$path" ]; then
        rm "$path"
        echo "Deleted $path."
    else
        echo "File not found."
    fi
}

prompt_save_and_exit() {
    read -p "Save box before exiting? (y/n): " yn
    if [ "$yn" = "y" ] || [ "$yn" = "Y" ]; then
        save_box_to_file
    fi
    echo "Goodbye!"
    sleep 3
    exit 0
}

while :
do
    echo
    echo "Bashing Boxes Menu:"
    echo "1. View all items"
    echo "2. View item by position"
    echo "3. Add item"
    echo "4. Remove last item"
    echo "5. Remove item by position"
    echo "6. Save box"
    echo "7. Load box"
    echo "8. List saved boxes"
    echo "9. Delete saved box"
    echo "10. Exit"
    read -p "Choose an option: " choice

    if [ "$choice" = "1" ]; then
        print_box_items
    elif [ "$choice" = "2" ]; then
        print_item_at_position
    elif [ "$choice" = "3" ]; then
        add_item_to_box
    elif [ "$choice" = "4" ]; then
        remove_last_item_from_box
    elif [ "$choice" = "5" ]; then
        remove_item_at_position
    elif [ "$choice" = "6" ]; then
        save_box_to_file
    elif [ "$choice" = "7" ]; then
        load_box_from_file
    elif [ "$choice" = "8" ]; then
        list_saved_boxes
    elif [ "$choice" = "9" ]; then
        delete_box_file
    elif [ "$choice" = "10" ]; then
        prompt_save_and_exit
    else
        echo "Invalid option, try again!"
    fi
done