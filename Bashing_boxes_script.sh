#!/bin/bash

data_dir="data"
object_file="warehouse_of_objects.txt"
repeats_allowed=0

mkdir -p "$data_dir"

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

# load object pool
load_object_pool() {
    if [ ! -f "$object_file" ]; then
        echo "Source file not found."
        return 1
    fi
    mapfile -t pool < <(grep -vE '^\s*$|^\s*#' "$object_file")
    if [ ${#pool[@]} -eq 0 ]; then
        echo "Object file is empty."
        return 1
    fi
    return 0
}

# prompt for size
prompt_for_box_size() {
    while true; do
        read -p "Enter box size: " size
        if [[ "$size" =~ ^[0-9]+$ ]] && [ "$size" -gt 0 ]; then
            echo "$size"
            return
        fi
        echo "Invalid size."
    done
}

# random box generator
generate_box_randomly() {
    load_object_pool || return
    size=$(prompt_for_box_size)
    max=${#pool[@]}

    if [ "$repeats_allowed" -eq 0 ] && [ "$size" -gt "$max" ]; then
        echo "Too large for unique items."
        return
    fi

    box_items=()

    if [ "$repeats_allowed" -eq 1 ]; then
        for ((i=0; i<size; i++)); do
            r=$((RANDOM % max))
            box_items+=("${pool[$r]}")
        done
    else
        temp=("${pool[@]}")
        for ((i=0; i<size; i++)); do
            r=$((RANDOM % ${#temp[@]}))
            box_items+=("${temp[$r]}")
            unset "temp[$r]"
            temp=("${temp[@]}")
        done
    fi

    echo "New random box generated."
}

# print box
print_box_items() {
    if [ ${#box_items[@]} -eq 0 ]; then
        echo "Box is empty."
        return
    fi
    for i in "${!box_items[@]}"; do
        echo "$((i+1)). ${box_items[$i]}"
    done
}

# print item by position
print_item_at_position() {
    read -p "Enter position: " pos
    idx=$((pos-1))
    if [ $idx -ge 0 ] && [ $idx -lt ${#box_items[@]} ]; then
        echo "${box_items[$idx]}"
    else
        echo "Invalid position."
    fi
}

# add item
add_item_to_box() {
    read -p "Enter item: " item
    box_items+=("$item")
    echo "Added."
}

# remove last
remove_last_item_from_box() {
    if [ ${#box_items[@]} -eq 0 ]; then
        echo "Empty."
        return
    fi
    unset 'box_items[-1]'
    box_items=("${box_items[@]}")
    echo "Removed."
}

# remove by position
remove_item_at_position() {
    read -p "Position: " pos
    idx=$((pos-1))
    if [ $idx -ge 0 ] && [ $idx -lt ${#box_items[@]} ]; then
        unset "box_items[$idx]"
        box_items=("${box_items[@]}")
        echo "Removed."
    else
        echo "Invalid position."
    fi
}

# save box
save_box_to_file() {
    read -p "Filename: " fname
    if [[ "$fname" =~ ^[A-Za-z0-9_-]+$ ]]; then
        printf "%s\n" "${box_items[@]}" > "$data_dir/$fname.box"
        echo "Saved."
    else
        echo "Invalid filename."
    fi
}

# load box
load_box_from_file() {
    ls "$data_dir"/*.box 2>/dev/null | xargs -n 1 basename
    read -p "Load which file: " fname
    if [ -f "$data_dir/$fname.box" ]; then
        mapfile -t box_items < "$data_dir/$fname.box"
        echo "Loaded."
    else
        echo "Not found."
    fi
}

# list saves
list_saved_boxes() {
    ls "$data_dir"/*.box 2>/dev/null | xargs -n 1 basename || echo "None."
}

# delete file
delete_box_file() {
    ls "$data_dir"/*.box 2>/dev/null | xargs -n 1 basename
    read -p "Delete which: " fname
    if [ -f "$data_dir/$fname.box" ]; then
        rm "$data_dir/$fname.box"
        echo "Deleted."
    else
        echo "Not found."
    fi
}

# search in box
search_box() {
    read -p "Search box for: " term
    matched=0
    for item in "${box_items[@]}"; do
        if [[ "${item,,}" == *"${term,,}"* ]]; then
            echo "$item"
            matched=1
        fi
    done
    [ $matched -eq 0 ] && echo "No matches."
}

# search in file
search_file() {
    read -p "Search file for: " term
    load_object_pool || return
    grep -i "$term" "$object_file" || echo "No matches."
}

# sort box
sort_box() {
    if [ ${#box_items[@]} -eq 0 ]; then
        echo "Empty."
        return
    fi
    mapfile -t box_items < <(printf "%s\n" "${box_items[@]}" | sort)
    print_box_items
}

# filtered build
build_filtered_box() {
    load_object_pool || return
    read -p "Start letter: " letter
    letter="${letter,,}"

    filtered=()
    for item in "${pool[@]}"; do
        first="${item:0:1}"
        if [[ "${first,,}" == "$letter" ]]; then
            filtered+=("$item")
        fi
    done

    if [ ${#filtered[@]} -eq 0 ]; then
        echo "No items with that letter."
        return
    fi

    box_items=("${filtered[@]}")
    echo "Filtered box created."
}

# toggle repeats
toggle_repeats() {
    if [ "$repeats_allowed" -eq 0 ]; then
        repeats_allowed=1
        echo "Repeats allowed."
    else
        repeats_allowed=0
        echo "Repeats disabled."
    fi
}

# save and exit
prompt_save_and_exit() {
    read -p "Save box before exiting? (y/n): " yn
    [ "$yn" = "y" ] || [ "$yn" = "Y" ] && save_box_to_file
    echo "Returning to terminal..."
    sleep 5
    exit 0
}

# main menu
while true; do
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
    echo "10. Generate random box from file"
    echo "11. Search box"
    echo "12. Search file"
    echo "13. Sort box"
    echo "14. Build filtered box"
    echo "15. Toggle repeats"
    echo "16. Exit"
    read -p "Option: " choice

    case $choice in
        1) print_box_items ;;
        2) print_item_at_position ;;
        3) add_item_to_box ;;
        4) remove_last_item_from_box ;;
        5) remove_item_at_position ;;
        6) save_box_to_file ;;
        7) load_box_from_file ;;
        8) list_saved_boxes ;;
        9) delete_box_file ;;
        10) generate_box_randomly ;;
        11) search_box ;;
        12) search_file ;;
        13) sort_box ;;
        14) build_filtered_box ;;
        15) toggle_repeats ;;
        16) prompt_save_and_exit ;;
        *) echo "Invalid." ;;
    esac
done