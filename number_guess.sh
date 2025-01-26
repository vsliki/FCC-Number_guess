#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Generate number
min=1
max=1000
NUMBER=$(( $RANDOM%($max-$min+1)+$min ))
# echo $NUMBER

#get username
echo "Enter your username:"
read USERNAME
  if [[ -z $USERNAME ]]
  then
    exit
  fi



NAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
#check if username in database
if [[ -z $NAME ]]

# if username not in database, add in database and welcom
then
  NAME_INSERT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo -e "\nWelcome, $(echo $USERNAME | sed 's/ //')! It looks like this is your first time here."
  #get id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")


# otherwise print sentence
else
#get ID and best score
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  BEST_SCORE=$($PSQL "SELECT MIN(score) FROM games WHERE user_id = $USER_ID") 

  GAMES_PLAYED=$($PSQL "SELECT COUNT(score) FROM games WHERE user_id=$USER_ID ")
  echo -e "\nWelcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_SCORE guesses."
fi

# ------------    Guess the number, enter your guess.   ------------
echo -e "\nGuess the secret number between 1 and 1000:"

#Var for number of guesses  :
NUMBER_OF_GUESSES=0

MAIN(){
read GUESS

#Initialize the number of guesses
let NUMBER_OF_GUESSES=NUMBER_OF_GUESSES+1 
# echo $NUMBER_OF_GUESSES

#If guess not a number
if [[ ! $GUESS =~ ^[0-9]+$  ]]
#Say its not a number 
then
  echo -e "\nThat is not an integer, guess again:"
  MAIN

#If number
else
  #if correct $GUESS = $NUMBER:
  if [[ $GUESS -eq $NUMBER ]]
  then
    echo -e "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"
    
    INSERT_SCORE=$($PSQL "INSERT INTO games(score, user_id) VALUES($NUMBER_OF_GUESSES, $USER_ID) ")
  fi

  #if lower $GUESS < $NUMBER
  if [[ $NUMBER -lt $GUESS ]]
  then
    echo -e "\nIt's lower than that, guess again:"
    MAIN
    
  fi

  #if $GUESS >  $NUMBER
  if [[ $NUMBER -gt $GUESS ]]
  then
    echo -e "\nIt's higher than that, guess again:"
    MAIN
  fi
  
fi
}

MAIN
