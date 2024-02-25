#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

#CREATE TABLE teams (team_id SERIAL PRIMARY KEY, name VARCHAR(50) UNIQUE NOT NULL);
#CREATE TABLE games (game_id SERIAL PRIMARY KEY, year INT NOT NULL, round VARCHAR(50) NOT NULL, winner_id INT REFERENCES teams(team_id) NOT NULL, opponent_id INT REFERENCES teams(team_id) NOT NULL, winner_goals INT NOT NULL, opponent_goals INT NOT NULL);

echo $($PSQL "TRUNCATE teams, games ")
echo $($PSQL "ALTER SEQUENCE games_game_id_seq RESTART " )
echo $($PSQL "ALTER SEQUENCE teams_team_id_seq RESTART " )

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_G OPPONENT_G
do
  if [[ $YEAR != "year" ]]
  then
    #get team_id w
    TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' ")

    #if not found
    if [[ -z $TEAM_ID_W ]]
    then

      #insert new team_w
      INSERT_TEAM_W=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_TEAM_W = "INSERT 0 1" ]]
      then
       echo Inserted team, $WINNER
      fi

      #get new team_id w
      TEAM_ID_W=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER' ")

    fi

    #get team_id o
    TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' ")

    #if not found

      #insert new team o
      INSERT_TEAM_O=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_TEAM_O = "INSERT 0 1" ]]
      then
       echo Inserted team, $OPPONENT
      fi

      #get new team_id o
      TEAM_ID_O=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT' ")

    #insert rows in game table
    INSERT_GAME_ROW=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals,opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_W, $TEAM_ID_O, $WINNER_G, $OPPONENT_G)")
    if [[ $INSERT_GAME_ROW = "INSERT 0 1" ]]
    then
      echo Inserte row, $YEAR : $ROUND
    fi

  fi
done

