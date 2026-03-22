#!/bin/bash
# author: Adam McCarthy
# version: 16/Feb/2026
# program description: A CRUD program to store books and their details

DATABASE="book_database.txt"
# menu functions

# function to pause allowing user to read output
pause () {
  read -n1 -sp "Press any key to continue..."
  printf "\n\n"
}

# prints titles on startup of program
print_title () {
  echo "Book Record Manager"
  echo "==================="
  echo
}

# prints greeting date and time on startup of program
print_greeting () {
  local today current_time
  today=$(date "+%d-%m-%y")
  current_time=$(date "+%r")
  echo "--------------------------------------------------------------------"
  echo "Welcome to the book record manager. It is $current_time on $today."
  echo "--------------------------------------------------------------------"
  echo
}

# when program is exited this message is printed
print_goodbye () {
  echo "You have exited the program."
  echo "Thank you for using the book record manager. Goodbye!"
}

print_main_menu () {
  echo "========="
  echo "MAIN MENU"
  echo "========="
  echo "1) Add books" 
  echo "2) List books"
  echo "3) Update books"
  echo "4) Remove books"
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
    # keep variable scope within function
    local choice 
    
    # read in user option and if valid call menu function
    print_main_menu
    read -p "Enter integer option (or X to exit the program): " choice
    if ! check_not_empty "$choice"; then
      pause
      continue
    fi
    echo
    
    case "$choice" in
      1)
        add_book_dispatcher
      ;;
      2)
        list_menu_dispatcher
      ;;
      4)
        delete_menu_dispatcher
      ;;
      x)
        break
      ;;
      *)
      # soft validation of user choice
      echo "$choice is not a valid option. Please try again..."
      pause
      ;;
    esac
  done
}

add_book_dispatcher() {
  while true; do
    # keep variable scope within function
    local add_choice
      
    # read user option and validate choice, then call menu function
    print_add_menu
    read -p "Enter integer option (or M to return to main menu): " add_choice
    if ! check_not_empty "$add_choice"; then
      pause
      continue
    fi
    echo

    case "$add_choice" in
    1) 
      add_book
    ;;
    M) 
      echo
      break
    ;;
    *) 
      echo "$add_choice is not a valid option. Please try again..."
    ;;
    esac
 done
}

list_menu_dispatcher () {
  while true; do
    # keep variable scope within function
    local list_choice
    
    # read user option and validate choice, then call menu function
    print_list_menu
    read -p "Enter integer option (or M to return to main menu): " list_choice
    if ! check_not_empty "$list_choice"; then
      pause
      continue
    fi
    echo

    case "$list_choice" in
    1)
      list_books
      pause
    ;; 
    2)
      list_books_with_string_in_title
    ;;
    3)
      list_books_by_author
      pause
    ;;
    4)
      list_books_by_era_dispatcher
    ;;
    5)
      list_books_below_page_count
    ;;
    M) 
      break
    ;;
    *)
      # soft validation of user choice
      echo "$list_choice" is not a valid option
      pause
    esac
 done
 }

delete_menu_dispatcher () {
  while true; do
    # keep variable scope within function
    local delete_choice
    
    # read user choice and validate option, then call menu function
    print_delete_menu 
    read -p "Enter integer option (or M to return to main menu): " delete_choice
    if ! check_not_empty "$delete_choice"; then
      pause
      continue
    fi
    echo

    case "$delete_choice" in
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
      echo "$delete_choice is not a valid option. Please try again..."
      pause
    ;;
    esac
 done
}

# crud functions

# This prompts and validates user input. It is separated as it will be reused
# for updating books, so the bash is "DRY".
prompt_book_fields () {

  # read in a valid book title
  while true; do
    local book_title
    read -p "Enter the title of the book: " book_title
    if check_not_empty "$book_title" && validate_title_publisher "$book_title"; then
      break
    fi
  done
  
  # read in a valid book author
  while true; do
    local book_author
    read -p "Enter the author of the book: " book_author
    if check_not_empty "$book_author" && validate_author_name "$book_author"; then
      break
    fi
  done

  # read in a valid publication year
  while true; do
    local publication_year
    read -p "Enter the year the book was published: " publication_year
    if check_not_empty "$publication_year" && validate_year "$publication_year"; then
      break
    fi
  done

  # read in a valid book page count
  while true; do
    local book_page_count 
    read -p "Enter the number of pages in the book: " book_page_count
    if check_not_empty "$book_page_count" && validate_pages "$book_page_count"; then
      break
    fi
  done

  # read in a valid book publisher
  while true; do
    local book_publisher  
    read -p "Enter the publisher of the book: " book_publisher
    if check_not_empty "$book_publisher" && validate_title_publisher "$book_publisher"; then
      break
    fi
  done

  # format the collected fields for database with | separators
  printf '%s|%s|%s|%s|%s' \
  "$book_title" "$book_author" "$publication_year" "$book_page_count" "$book_publisher"
  echo
}

# Create book functions

add_book () {
  local book_details book_count line confirm_add
  echo "Enter book details:" 
  echo "-------------------"
  # read in all the book fields by calling function prompt_book_fields and capture
  # and store the output
  book_details=$(prompt_book_fields)

  # get the id of the last book in the database (largest id)
  book_count=$(tail -n1 "$DATABASE" | awk -F"|" '{print $1}')

  # add 1 to the largest id and add to book details for storing in database
  line="$(($book_count + 1))|$book_details"
  
  #check if the book is already in the database using title and author
  # if it is already present then exit the adding process
  title=$(awk -F"|" '{print $2}' <<< "$line")
  author=$(awk -F"|" '{print $3}' <<< "$line")
  if book_exists "$title" "$author"; then
    echo "The book $title by $author is already in the database! Exiting operation" 
    pause
    return 1
  fi
  
  # if the book is a new entry display it and confirm user wants it added to the
  # database
  echo
  list_books_header
  awk -F"|" '{printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n",\
    $1, $2, $3, $4, $5, $6}' <<< "$line"
  echo
  read -p "Add this record to the database? (y/n): " confirm_add
  if [[ ${confirm_add,,} == "y" ]]; then
    # Used <<< (here string) which allows you to pass a string to stdin where a 
    # filename is expected (https://tldp.org/LDP/abs/html/x17837.html [see first example])
    echo "$line" >> "$DATABASE"
    awk -F"|" '{print "The book", $1, "by", $2, "was added"}' <<< "$book_details"
  else
      echo "Operation cancelled"
  fi
  pause
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
    # list all entries in the database in a readable format matching
    # the output of list_books_header function
    awk -F"|" '{printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n",\
      $1, $2, $3, $4, $5, $6}' "$DATABASE"
  }

  list_books_with_string_in_title () {
    local search_string search_results

    # read in a string to search book titles for
    read -p "Enter a string to search for in all titles: " search_string

    # if the search string is valid for a title then find any matching rows
    if check_not_empty "$search_string" && validate_title_publisher "$search_string"; then
      search_results=$(awk -F"|" -v value="$search_string"\
          'tolower($2) ~ tolower(value)\
          {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n",\
      $1, $2, $3, $4, $5, $6}' "$DATABASE")

      # if there are no matching rows then inform user and
      if [[ -z "$search_results" ]]; then
        echo "No books found containing $search_string" >&2
      else
      # if there are matching rows then print them in readable format
      list_books_header
      echo "$search_results"
      pause
      fi
    fi
  }

  list_books_by_author() {
    local author_choice
    # read in an author name from the user
    read -p "Enter the name of an author: " author_choice
    echo

    # if a valid author name is entered then output all books matching that author
    if check_not_empty "$author_choice" && validate_author_name "$author_choice" && \
      author_exists "$author_choice"; then
      list_books_header
      awk -F"|" -v author="$author_choice"\
      'tolower($3) ~ tolower(author) \
      {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n",\
      $1, $2, $3, $4, $5, $6}' "$DATABASE"
    fi
  }

  list_books_by_era_dispatcher () {
    while true; do
      local era_choice
      print_list_by_era_menu
      read -p "Enter integer option (or L to return to list menu): " ERA_CHOICE
      echo

      case "$era_choice" in
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
    local books_early_modern
    books_early_modern=$(awk -F"|" '$4 < 1800\
    {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
    "$DATABASE")
    if [[ -z "$books_early_modern" ]]; then
      echo "No books from early modern era found." >&2
    else
      list_books_header
      echo "$books_early_modern" 
    fi 
  } 

  list_victorian_era () {
    local books_victorian
    books_victorian=$(awk -F"|" '$4 >= 1800 && $4 < 1900\
    {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
    "$DATABASE")
    if [[ -z "$books_victorian" ]]; then
      echo "No books from early modern era found." >&2
    else
      list_books_header
      echo "$books_victorian"
    fi
  }

  list_modern_era () {
    local books_modern
    books_modern=$(awk -F"|" '$4 >= 1900 && $4 < 2000\
    {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
    "$DATABASE")
    if [[ -z "$books_modern" ]]; then
      echo "No books from early modern era found." >&2
    else
      list_books_header
      echo "$books_modern" 
    fi
  }

  list_contemporary_era () {
    local books_contemporary
    books_contemporary=$(awk -F"|" '$4 > 2000\
  {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
  "$DATABASE")
  if [[ -z "$books_contemporary" ]]; then
    echo "No books from early modern era found." >&2
  else
    list_books_header
    echo "$books_contemporary" 
  fi
}

  list_books_below_page_count () {
    local page_count results
    while true; do
      read -p "Enter the maxiumum number of pages: "  page_count
      echo
      if validate_pages "$page_count"; then
        break
      fi
    done
    results=$(awk -F"|" -v pages="$page_count" '$5 <= pages\
  {printf "%-3s %-30.30s %-20.20s %-6s %-5s %.25s\n", $1, $2, $3, $4, $5, $6}'\
  "$DATABASE")

    if [[ -z "$results" ]]; then
      echo "There are no books less than $page_count pages"
    else
      list_books_header
      echo "$results"
    fi
  }
  
# DELETE FUNCTIONS

delete_by_id () {
  # list all books so user can identify id of book they wish to delete
  list_books
  echo

  # read in a valid id to check against the database
  while true; do
    local delete_choice
    read -p "Enter the id of the book you wish to delete: " DELETE_CHOICE
    if check_not_empty "$delete_choice" && validate_id "$delete_choice"; then
      break
    fi
  done

  # check if id is in the database
  if id_exists "$delete_choice"; then
    local title author reply tmpDB
    # confirm deletion by prompting user with book title and author 
    title=$(awk -F"|" -v id="$delete_choice" '$1 == id {print $2}' "$DATABASE")
    author=$(awk -F"|" -v id="$delete_choice" '$1 == id {print $3}' "$DATABASE")
    read -p "Are you sure you want to delete $title by $author? (y/n): " reply
      if [[ "${reply,,}" == "y" ]]; then
        # perform the deletion by replacing the database with a copy that has that
        # entry removed
        touch tmpDB  
        awk -F"|" -v id="$delete_choice" '$1 != id' "$DATABASE" > tmpDB
        mv tmpDB "$DATABASE"
        # confirm deletion to user
        echo
        echo "$title deleted"
      else
        # notify user deletion was aborted
        echo
        echo "Deletion cancelled"
    fi
  fi
}

delete_all () {
  local reply
  # prompt user that they are about to delete entire database and cofirm
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
check_not_empty () {
  # check if the first argument is empty
  if [[ -z "$1" ]]; then
    # warnings sent to standard error to avoid being consumed by command substitutions
    echo "Entries must not be blank. Please try again." >&2
    return 1
  fi
  return 0
}

# allow ids starting from 1 and upto 9999
validate_id () {
  # check if the first argument starts with 1-9 and has up to 3 digits from 0-9 after
  if [[ $1 =~ ^[1-9][0-9]{0,3}$ ]]; then
    return 0
  else 
    echo "The ID must be a value between 1 and 9999. Please try again." >&2
    return 1
  fi
}

# allow multi word alphanumeric book titles and publisher names
validate_title_publisher() {
  # check if first argument is alphanumeric and allow multi word entries
  if [[ $1 =~ ^[[:alnum:]]+( [[:alnum:]]+)*$ ]]; then
    return 0
  else 
    echo "The name must be alphanumeric and may contain spaces. Please try again." >&2
    return 1
  fi
}

# allow authors names with middle initials
validate_author_name () {
  # check the first argument is in title case and allow "." or ' in middle or surnames
  # ^([A-Z]+(\.?)) - Can start with things like J.K. or just be Adam
  # ( [A-Z](\'?)([A-Za-z]+)?\.?)*$ - Can be multi word and have middle initials or O'Brien
  # or McCarthy 
  if [[ $1 =~ ^([A-Z]+(\.?))+[a-z]+( [A-Z](\'?)([A-Za-z]+)?\.?)*$ ]]; then
    return 0
  else
    echo "The name must be title case and may contain middle initials." >&2
      echo "Examples: Goethe, Cormac McCarthy, Booker T. Washington Flannery O' Connor" >&2
    return 1
  fi
}

# allow years from 1500-2099
validate_year () {
  # starts with a 15-20 followed by any two digits taken from 0-9
  if [[ $1 =~ ^(1[5-9]|20)[0-9]{2}$ ]]; then
    return 0
  else
    echo "The year of publication must be between 1500 and 2099. Please try again." >&2
    return 1
  fi
}

# allow books to have 10-9999 pages
validate_pages () {
  # starts with 1-9 followed by 1-3 digits from 0 to 9
  if [[ $1 =~ ^[1-9][0-9]{1,3}$ ]]; then
    return 0
  else
    echo "The book must have between 10-9999 pages. Please try again." >&2
    return 1
  fi
}

# Helper functions
author_exists () {
  local find_entries
  # use lower case version of user entry compared to lower case version of database entry
  find_entries=$(awk -F"|" -v string="$1" 'tolower($3) ~ tolower(string)' "$DATABASE")
  # if no author with this name is in the database inform user
  if [[ -z "$find_entries" ]]; then
    echo "The author $1 does not exist in the database" >&2
    return 1
  fi
  return 0
} 

id_exists() {
  local id
  id=$(awk -F"|" -v book_id="$1" '$1 == book_id {print $1}' "$DATABASE")
  if [[ -z "$id" ]]; then
    # if no entry in the database has this id inform the user
    echo "No book with the ID $1 exists in the database" >&2
    return 1
  fi
  return 0
}

book_exists () {
  local search_result
  # check a lowercase version of the user title and the database titles
  search_result=$(awk -F"|" -v title="$1" -v author="$2"\
      'tolower(title) == tolower($2) && tolower(author) == tolower($3) {print $0}'\
      "$DATABASE")
  if [[ -z "$search_result" ]]; then
    return 1
  fi
  return 0
}

# program execution

# This section runs the program
touch "$DATABASE" # create a database if it doesnt exist otherwise change timestamp
print_greeting
print_title
main_menu_dispatcher
print_goodbye
