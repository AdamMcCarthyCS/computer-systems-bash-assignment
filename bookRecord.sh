#!/bin/bash
# author: Adam McCarthy
# version: 16/Feb/2026
# program description: A CRUD program to store books and their details

DATABASE="book_database.txt"
# menu functions

pause () {
  read -n1 -sp "Press any key to continue..."
  printf "\n\n"
}

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
  echo "========="
  echo "MAIN MENU"
  echo "========="
  echo "Please choose an option by entering an integer:"
  echo "1) Add a book"
  echo "2) List all books"
  echo "3) Update a book"
  echo "4) Remove a book"
  echo "----------------"
  echo "X) Exit the program"
  echo
}

print_add_menu () {
  echo "========"
  echo "ADD MENU"
  echo "========"
  echo "1) Add a book"
  echo "-------------"
  echo "M) Exit to the main menu"
  echo
}

print_list_menu () {
  echo "========="
  echo "LIST MENU"
  echo "========="
  echo "1) List all books"
  echo "2) List all books whose titles contain a string"
  echo "3) List all books by author"
  echo "4) List books by era"
  echo "5) List all books below a certain page count"
  echo "--------------------------------------------"
  echo "M) Exit to the main menu"
  echo
}

print_list_by_era_menu () {
  echo "==========="
  echo "LIST BY ERA"
  echo "==========="
  echo "1) Early modern era (1500-1800)"
  echo "2) Victorian era (1800-1900)"
  echo "3) Modern era (1900-2000)"
  echo "4) Contemporary era (2000-present)"
  echo
}

print_delete_menu () {
  echo "==========="
  echo "DELETE MENU"
  echo "==========="
  echo "1) Delete a book using its ID"
  echo "2) Delete all books"
  echo "-------------------"
  echo "M) Exit to the main menu"
  echo
}

main_menu_dispatcher () {
 
  while true; do
    print_main_menu
    read -p "Enter integer option (or X to exit the program): " CHOICE
    case "$CHOICE" in
      1)
        add_book_dispatcher
      ;;
      2)
        list_menu_dispatcher
      ;;
      4)
        delete_menu_dispatcher
      ;;
      X)
        break
      ;;
      *)
      echo "$CHOICE is not a valid option. Please try again..."
      pause
      ;;
    esac
  done
}

add_book_dispatcher() {
  while true; do
    print_add_menu
    read -p "Enter integer option (or M to return to main menu): " ADD_CHOICE

    case "$ADD_CHOICE" in
    1) 
      add_book
    ;;
    M) 
      break
    ;;
    *) 
      echo "$ADD_CHOICE is not a valid option. Please try again..."
    ;;
    esac
 done
}

list_menu_dispatcher () {
  while true; do
    print_list_menu
    read -p "Enter integer option (or M to return to main menu): " LIST_CHOICE

    case "$LIST_CHOICE" in
    1)
      list_books
      pause
    ;; 
    3)
      list_books_by_author
      pause
    ;;
    4)
      list_books_by_era_dispatcher
    ;;
    M) 
      break
    ;;
    *)
      echo "$LIST_CHOICE" is not a valid option
      pause
    esac
 done
 }

delete_menu_dispatcher () {
  while true; do
    print_delete_menu 
    read -p "Enter integer option (or M to return to main menu): " DELETE_CHOICE
    
    case "$DELETE_CHOICE" in
    1)
      delete_by_id
      pause
    ;;
    2)
      delete_all
      pause
    ;;
    M)
      break
    ;;
    *)
      echo "$DELETE_CHOICE is not a valid option. Please try again..."
      pause
    ;;
   esac
 done
}

# crud functions

# This prompts and validates user input. It is separated as it will be reused
# for updating books, so the bash is "DRY".
prompt_book_fields () {
  while true; do
    read -p "Enter the title of the book: " BOOK_TITLE
    if check_empty "$BOOK_TITLE" && validate_title_publisher "$BOOK_TITLE"; then
      break
    fi
  done

  while true; do
    read -p "Enter the author of the book: " BOOK_AUTHOR
    if check_empty "$BOOK_AUTHOR" && validate_author_name "$BOOK_AUTHOR"; then
      break
    fi
  done

  while true; do
    read -p "Enter the year the book was published: " PUBLICATION_YEAR
    if check_empty "$PUBLICATION_YEAR" && validate_year "$PUBLICATION_YEAR"; then
      break
    fi
  done

  while true; do
    read -p "Enter the number of pages in the book: " BOOK_PAGE_COUNT
    if check_empty "$BOOK_PAGE_COUNT" && validate_pages "$BOOK_PAGE_COUNT"; then
      break
    fi
  done

  while true; do
    read -p "Enter the publisher of the book: " BOOK_PUBLISHER
    if check_empty "$BOOK_PUBLISHER" && validate_title_publisher "$BOOK_PUBLISHER"; then
      break
    fi
  done

  printf '%s|%s|%s|%s|%s' \
  "$BOOK_TITLE" "$BOOK_AUTHOR" "$PUBLICATION_YEAR" "$BOOK_PAGE_COUNT" "$BOOK_PUBLISHER"
}

# Create book functions

add_book () {
  echo "Enter book details:" 
  BOOK_DETAILS=$(prompt_book_fields)
  BOOK_COUNT=$(tail -n1 "$DATABASE" | awk -F"|" '{print $1}')
  LINE="$(($BOOK_COUNT + 1))|$BOOK_DETAILS"
  # Used <<< (here string) which allows you to pass a string to stdin where a 
  # filename is expected (https://tldp.org/LDP/abs/html/x17837.html [see first example])
  awk -F"|" '{print "The book", $1, "by", $2, "was added"}' <<< "$BOOK_DETAILS"
  echo "$LINE" >> "$DATABASE"
}

# List books functions

# This function prints the header for all listing operations. I separated it from
# each fuction rather than rewriting it several times within all the list functions
list_books_header () {
  printf "%-3s %-30s %-20s %-6s %-5s %s\n"\
    "ID"  "Title"  "Author" "Year"  "Pages"  "Publisher" 
  printf "%-3s %-30s %-20s %-6s %-5s %s\n"\
    "--"  "-----"  "------" "----"  "-----"  "---------"
}

list_books () {
  list_books_header
  awk -F"|" '{printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n",\
    $1, $2, $3, $4, $5, $6}' "$DATABASE"
}
list_books_by_author() {
  read -p "Enter the name of an author: " AUTHOR_CHOICE
  if check_empty "$AUTHOR_CHOICE" && validate_author_name "$AUTHOR_CHOICE" && \
    author_exists "$AUTHOR_CHOICE"; then
    list_books_header
    awk -F"|" -v author="$AUTHOR_CHOICE"\
    '$3 ~ author {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n",\
    $1, $2, $3, $4, $5, $6}' "$DATABASE"
  fi
}

list_books_by_era_dispatcher () {
  while true; do
    print_list_by_era_menu
    read -p "Enter integer option (or L to return to list menu): " ERA_CHOICE
    
    case "$ERA_CHOICE" in
    1)
      list_early_modern_era
    ;;
    2) 
      list_victorian_era
    ;;
    3)
      list_modern_era
    ;;
    4) 
      list_contemporary_era
    ;;
    L)
      break
    ;;
    esac
 done
}

list_early_modern_era () {
  BOOKS_EARLY_MODERN=$(awk -F"|" '$4 < 1800\
  {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
  "$DATABASE")
  if [[ -z "$BOOKS_EARLY_MODERN" ]]; then
    echo "No books from early modern era found." >&2
  else
    list_books_header
    echo "$BOOKS_EARLY_MODERN" 
  fi 
} 

list_victorian_era () {
  BOOKS_VICTORIAN=$(awk -F"|" '$4 >= 1800 && $4 < 1900\
  {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
  "$DATABASE")
  if [[ -z "$BOOKS_VICTORIAN" ]]; then
    echo "No books from early modern era found." >&2
  else
    list_books_header
    echo "$BOOKS_VICTORIAN"
  fi
}

list_modern_era () {
  BOOKS_MODERN=$(awk -F"|" '$4 >= 1900 && $4 < 2000\
  {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
  "$DATABASE")
  if [[ -z "$BOOKS_MODERN" ]]; then
    echo "No books from early modern era found." >&2
  else
    list_books_header
    echo "$BOOKS_MODERN" 
  fi
}

list_contemporary_era () {
  BOOKS_CONTEMPORARY=$(awk -F"|" '$4 > 2000\
  {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
  "$DATABASE")
  if [[ -z "$BOOKS_CONTEMPORARY" ]]; then
    echo "No books from early modern era found." >&2
  else
    list_books_header
    echo "$BOOKS_CONTEMPORARY" 
  fi
}

# DELETE FUNCTIONS

delete_by_id () {
  list_books
  echo
  while true; do
    read -p "Enter the id of the book you wish to delete: " DELETE_CHOICE
    if check_empty "$DELETE_CHOICE" && validate_id "$DELETE_CHOICE"; then
      break
    fi
  done
  if id_exists "$DELETE_CHOICE"; then
  local title author reply
  # confirm deletion using a prompt
  title=$(awk -F"|" -v id="$DELETE_CHOICE" '$1 == id {print $2}' "$DATABASE")
  author=$(awk -F"|" -v id="$DELETE_CHOICE" '$1 == id {print $3}' "$DATABASE")
  read -p "Are you sure you want to delete $title by $author? (y/n): " reply
  # check the id exists and if it does check the user wants to delete the book
    if [[ "${reply,,}" == "y" ]]; then
      # perform the deletion by replacing the database  with a copy that has that
      # entry removed
      touch tmp   
      awk -F"|" -v id="$DELETE_CHOICE" '$1 != id' "$DATABASE" > tmp
      mv tmp "$DATABASE"
      echo
      echo "$title deleted"
    else
      echo
      echo "Deletion cancelled"
    fi
  fi
}

delete_all () {
  local reply
  read -p "You are about to delete the entire database. Are you sure? (y/n): " reply 
  # Here I use the parameter expansion method to convert a string to lowercase
  # https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html#:~:text=%24%7Bparameter%2C%2Cpattern%7D
  if [[ "${reply,,}" == "y" ]]; then
    touch tmpdb && mv tmpdb "$DATABASE"
    echo # newline to aid reading the outcome of the deletion operation
    echo "The database $DATABASE has been cleared"
  else
    echo # newline to aid reading the outcome of the deletion operation
    echo "Deletion aborted"
  fi
}

# Validation functions

# check value entered is not blank
check_empty () {
  if [[ -z "$1" ]]; then
    # The warning is sent to stderr bc it would not be output otherwise
    # see https://mywiki.wooledge.org/BashFAQ/002#:~:text=the%20example%20above%2C-,dig,-wrote%20output%20to (basically everything to stdout after the command 
    # substitution gets captured by it. TLDR: Echo wont output to stdout if its # called by a fn executed within command substitution
    echo "Entries must not be blank. Please try again." >&2
    return 1
  fi
  return 0
}

# allow ids starting from 1 and upto 9999
validate_id () {
  if [[ $1 =~ ^[1-9][0-9]{0,3}$ ]]; then
    return 0
  else 
    echo "The ID must be a value between 1 and 9999. Please try again." >&2
    return 1
  fi
}

# allow multi word alphanumeric book titles and publisher names
validate_title_publisher() {
  if [[ $1 =~ ^[[:alnum:]]+( [[:alnum:]]+)*$ ]]; then
    return 0
  else 
    echo "The name must be alphanumeric and may contain spaces. Please try again." >&2
    return 1
  fi
}

# allow authors names with middle initials
validate_author_name () {
  if [[ $1 =~ ^[A-Z][a-z]+( [A-Z]([a-z]+)?\.?)*$ ]]; then
    return 0
  else
    echo "The name must be title case and may contain middle initials." >&2
      echo "Examples: Goethe, Lao Tzu, Booker T. Washington" >&2
    return 1
  fi
}

# allow years from 1500-2099
validate_year () {
  if [[ $1 =~ ^(1[5-9]|20)[0-9]{2}$ ]]; then
    return 0
  else
    echo "The year of publication must be between 1500 and 2099. Please try again." >&2
    return 1
  fi
}

# allow books to have 10-9999 pages
validate_pages () {
  if [[ $1 =~ ^[1-9][0-9]{1,3}$ ]]; then
    return 0
  else
    echo "The book must have between 10-9999 pages. Please try again." >&2
    return 1
  fi
}

# search functions
author_exists () {
  FIND_ENTRIES=$(awk -F"|" -v STRING="$1" 'tolower($3) ~ tolower(STRING)' "$DATABASE")
  if [[ -z "$FIND_ENTRIES" ]]; then
    echo "The author $1 does not exist in the database" >&2
    return 1
  fi
  return 0
} 

id_exists() {
  local id
  id=$(awk -F"|" -v book_id="$1" '$1 == book_id {print $1}' "$DATABASE")
  if [[ -z "$id" ]]; then
    echo "No book with the ID $1 exists in the database" >&2
    return 1
  fi
  return 0
}

# program execution

touch "$DATABASE"
print_greeting
print_title
main_menu_dispatcher
print_goodbye
