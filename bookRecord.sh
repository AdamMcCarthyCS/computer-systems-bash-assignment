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
        list_books
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

# crud functions

add_book () {
  echo "Enter book details:" 
  read -p "Enter the title of the book: " BOOK_TITLE
  read -p "Enter the author of the book: " BOOK_AUTHOR
  read -p "Enter the year the book was published: " PUBLICATION_YEAR
  read -p "Enter the number of pages in the book: " BOOK_PAGE_COUNT
  read -p "Enter the publisher of the book: " BOOK_PUBLISHER
  BOOK_COUNT=$(wc -l "$DATABASE" | awk '{print $1}')
  LINE="$(($BOOK_COUNT + 1))|$BOOK_TITLE|$BOOK_AUTHOR|$PUBLICATION_YEAR|\
$BOOK_PAGE_COUNT|$BOOK_PUBLISHER"

  echo "$LINE" >> "$DATABASE"
}

list_books () {
  awk -F"|" 'BEGIN {
    printf "%-3s %-30s %-20s %-6s %-5s %s\n", "ID", "Title", "Author",\
      "Year", "Pages", "Publisher"
    printf "%-3s %-30s %-20s %-6s %-5s %s\n", "--", "-----", "------",\
      "----", "-----", "---------"}
    {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
    "$DATABASE"
}

# program loop
touch "$DATABASE"
print_greeting
print_title
main_menu_dispatcher
print_goodbye
