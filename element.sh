#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
ARGUMENT=$1

# check if argument is empty
if [[ -z $ARGUMENT ]]
then
  echo "Please provide an element as an argument."
else
  # check for argument type
  if [[ $ARGUMENT =~ ^([0-9]+)$ ]]
  then
    # try to find the periodic table row
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number = $ARGUMENT;")
  elif [[ $ARGUMENT =~ ^([A-Z][a-z]?)$ ]]
  then
    # try to find the periodic table row with symbol
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$ARGUMENT';")
  else
    # try to find the periodic table row with name
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$ARGUMENT';")
  fi

  # check if atomic_number is empty
  if [[ -z $ATOMIC_NUMBER ]]
    then
      # did not find atomic number
      echo "I could not find that element in the database."
    else
      # get the result
      RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = '$ATOMIC_NUMBER';")
      
      # split the result
      IFS='|' read -r TYPE_ID ATOMIC_NUMBER SYMBOL NAME MASS MELTING BOILING TYPE <<< "$RESULT"
      
      # format the result
      echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
    fi
    
fi
