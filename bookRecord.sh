#!/bin/bash
# author: Adam McCarthy
# version: 16/Feb/2026
# program description: A CRUD program to store books and their details

DATABASE="book_database.txt"
# menu functions

print_title () {
  echo "Book Record Manager"
  echo "==================="
  echo
}

print_greeting () {
  TODAY=$(date "+%d-%m-%Y")
  CURRENT_TIME=$(date "+%r")
  echo "--------------------------------------------------------------------"
  echo "Welcome to the book record manager. It is $CURRENT_TIME on $TODAY."
  echo "--------------------------------------------------------------------"
  echo
}

print_goodbye () {
  echo "You have exited the program."
  echo "Thank you for using the book record manager. Goodbye!"
}

print_main_menu () {
  echo "Please choose an option by entering an integer:"
  echo "1) Add a book"
  echo "2) List all books"
  echo "3) Update a book"
  echo "4) Remove a book"
  echo "5) Exit the program"
  echo
}

print_list_menu () {
  echo "Please choose an option by entering an integer: "
  echo "1) List all books"
  echo "2) List all books by author"
  echo "3) List all books before a year"
  echo "4) List all books after a year"
  echo "5) List all books below a certain page count"
  echo "0) Exit to the main menu"
}

main_menu_dispatcher () {
  FLAG=1
  while [[ FLAG -eq 1 ]]; do
    print_main_menu
    read -p "Please enter a choice: " choice
    case "$choice" in
      1)
        add_book
      ;;
      2)
        list_menu_dispatcher
      ;;
      4)
        delete_book
      ;;
      5)
        FLAG=0
      ;;
      *)
      echo "$choice is not a valid option. please try again..."
      echo
      ;;
    esac
 done
}

list_menu_dispatcher() {
  print_list_menu
  read -p "Please choose a menu option by entering an integer: " LIST_CHOICE
  FLAG=1
  while [[ FLAG -eq 1 ]]; do
    case "$LIST_CHOICE" in
    1)
      list_books
      FLAG=0 
    ;; 
    0) 
      main_menu_dispatcher
      FLAG=0
    ;;
    *)
      echo "$LIST_CHOICE" is not a valid option
      FLAG=1
    esac
 done
 }

# crud functions

add_book () {
  echo "Enter book details:" 
  read -p "Enter the title of the book: " BOOK_TITLE
  read -p "Enter the author of the book: " BOOK_AUTHOR
  read -p "Enter the year the book was published: " PUBLICATION_YEAR
  read -p "Enter the number of pages in the book: " BOOK_PAGE_COUNT
  read -p "Enter the publisher of the book: " BOOK_PUBLISHER
  BOOK_COUNT=$(tail -n1 "$DATABASE" | awk -F"|" '{print $1}')
  LINE="$(($BOOK_COUNT + 1))|$BOOK_TITLE|$BOOK_AUTHOR|$PUBLICATION_YEAR|\
$BOOK_PAGE_COUNT|$BOOK_PUBLISHER"

  echo "$LINE" >> "$DATABASE"
}

list_books_header () {
  printf "%-3s %-30s %-20s %-6s %-5s %s\n"\
    "ID"  "Title"  "Author" "Year"  "Pages"  "Publisher"
  printf "%-3s %-30s %-20s %-6s %-5s %s\n"\
    "--"  "-----"  "------" "----"  "-----"  "---------"
}

list_books () {
  list_books_header
  awk -F"|" '{printf "%-3s %-30.30s %-20.20s %-6s %-5s %s\n",\
    $1, $2, $3, $4, $5, $6}' "$DATABASE"
}
dist_books_by_author() {
  read -p "Enter the name of an author: " AUTHOR_CHOICE
}

delete_book() {
  list_books
  echo
  read -p "Enter the id of the book you wish to delete: " DELETE_CHOICE
  touch tmp   
  awk -F"|" -v id="$DELETE_CHOICE" '$1 != id' "$DATABASE" > tmp
  mv tmp "$DATABASE"
}

# Validation functions

# allow ids starting from 1 and upto 9999
validate_id () {
  if [[ $1 =~ ^[1-9][0-9]{0,3}$ ]]; then
    return 0
  else 
    return 1
  fi
}

# allow multi word alphanumeric book titles and publisher names
validate_title_publisher() {
  if [[ $1 =~ ^[[:alnum:]]+( [[:alnum:]]+)*$ ]]; then
    return 0
  else 
    return 1
  fi
}

# allow authors names with middle initials
validate_author_name () {
  if [[ $1 =~ ^[A-Z][a-z]+( [A-Z][a-z]+\.?)*$ ]]; then
    return 0
  else
    return 1
  fi
}

validate_year () {
  if [[ $1 =~ ^(1[5-9]|20)[0-9]{2}$ ]]; then
    return 0
  else
    return 1
  fi
}

validate_pages () {
  if [[ $1 =~ ^[1-9][0-9]{1,3}$ ]]; then
    return 0
  else
    return 1
  fi
}

# program loop
touch "$DATABASE"
print_greeting
print_title
main_menu_dispatcher
print_goodbye
