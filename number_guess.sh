#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# generar un número al azar entre 1 y 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1));

# pedir por nombre del usuario
echo -e "\nEnter your username:"
read USERNAME

# ¿aceptar mayúsculas, minúsculas, mezclado?
# ¿convertir a minúsculas salvo la primera letra?
# ¿el username  debería ser único?

# buscar en la base de datos
RESULT_USERNAME=$($PSQL "SELECT * from users WHERE name = '$USERNAME';")

# si no existe
if [[ -z "$RESULT_USERNAME" ]]
then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

    # registrar el usuario en la base de datos en la tabla de usuarios
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME');") 
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME';") 
else
    # pedir a la base de datos la info
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME';")
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM users FULL JOIN games USING(user_id) WHERE user_id = $USER_ID;")
    BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM users FULL JOIN games USING(user_id) WHERE user_id = $USER_ID;")
    # mostrar mensaje
    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# empezar a jugar
NUMBER_OF_GUESSES=0
echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

while [[ ! $GUESS =~ ^[0-9]+$ ]]
      do
      echo -e "\nThat is not an integer, guess again:"
      read GUESS
done

while [[ $GUESS != $SECRET_NUMBER ]]
      do
            
            (( NUMBER_OF_GUESSES+=1 ))

            if [[ $GUESS > $SECRET_NUMBER ]]
              then
                  echo -e "\nIt's lower than that, guess again:"
              else
                  echo -e "\nIt's higher than that, guess again:"
            fi
            read GUESS

            # y acá tendrías que volver a ver si lo que pone es un número
            while [[ ! $GUESS =~ ^[0-9]+$ ]]
                  do
                      echo -e "\nThat is not an integer, guess again:"
                      read GUESS
                  done
done

# acá tenés que sumar 1 al contador para que te incluya el último en el que acertaste
(( NUMBER_OF_GUESSES+=1 ))

# afuera del loop; descubriste el secret
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# registrar el juego en la base de datos
INSERT_GAME_RESULTS=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES);")
