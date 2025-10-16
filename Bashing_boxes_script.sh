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

# Loop through and print each item
for item in "${items[@]}"; do
	echo "$item$"
done