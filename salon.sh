#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Main function
SELECT_SERVICE() {
  # Checking if there is a message attached when calling the function, if yes we print it.
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  else
    echo "Select the number of the service of your choice: "
  fi

  # We get all of the available services from the database and we print them
  SERVICES=$($PSQL "SELECT * FROM services")

  # We separate the id and the name by | and print each service in another format
  echo "$SERVICES" | while IFS="|" read ID NAME
  do
    echo "$ID) $NAME"
  done

  # Get the user input, and get the name of the service
  read SERVICE_ID_SELECTED
  CHOSEN_SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # Checking if the user entered a correct input. If not we recall the SELECT_SERVICE function with an 
  # error message to be printed, and we ask the user to pick a service again.
  if [[ -z $CHOSEN_SERVICE_NAME ]] 
  then
    SELECT_SERVICE "No chosen service"
  fi
    
  # We ask for the user to enter their phone number
  echo -e "\nPlease enter your phone number: "
  read CUSTOMER_PHONE
  # We check if there is a customer with that phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # If there isn't (-z) then we ask add the customer to the database!
  if [[ -z $CUSTOMER_NAME ]] 
  then
    # we ask for the customer's name 
    echo -e "\nNot in the database. Please enter your name to add you: "
    read CUSTOMER_NAME

    # we add the name and the phone number that were both entered by the user to the customers database
    echo $($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi

  # we ask for the service time they would prefer
  echo -e "\nPlease enter the service time:"
  read SERVICE_TIME

  # we get the customer id and store it in a variable to be used afterwards to add the appointment
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # we add the appointment
  echo $($PSQL "INSERT INTO appointments(customer_id, service_id, name, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$CUSTOMER_NAME', '$SERVICE_TIME')")
    
  # we print an output stating the service name, service time and the customer name.
  echo -e "\nI have put you down for a $CHOSEN_SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

  # we exit the program so it stops.
  exit
}

# starts the program.
SELECT_SERVICE