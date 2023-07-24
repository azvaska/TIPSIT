# Routes

## POST
- **/create_user** per creare l'utente
- **/login** per loggare l'utente, ritorna un token JWT
- **/create_bacaro** per creare un bacaro
- **/add_score/:id_base64** per segnare che l'utente ha visitato un bacaro
- **/profile** ritorna i dati dell'utente loggato

## GET
- **/nearest_bacaro/:lat/:lng/:radius** ritorna il bacaro più vicino alla posizione passata come parametro
- **/bacari** ritorna tutti i bacari
- **/bacaro/:id** ritorna il bacaro con l'id passato come parametro
- **/user/:id** ritorna l'utente con l'id passato come parametro

## PATCH
- **/update_user** per aggiornare i dati dell'utente
- **/update_bacaro** per aggiornare i dati del bacaro

## DELETE
- **/delete_user** per eliminare l'utente
- **/delete_bacaro** per eliminare il bacaro

dev docker
 docker run --name=mysql1 -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -d mysql