# Bacaro Tour

Bacaro Tour è un'applicazione sviluppata in Flutter che permette di accumulare punti visitando i bacari di Venezia.

## Funzionalità

L'applicazione permette di scannerizzare un codice QR (stampato e attaccato in ogni bacaro) con la fotocamera del proprio dispositivo. Se ci si trova nelle effettive prossimità (tramite GPS) del bacaro registrato nel database, si otterranno dei punti. 

Utilizza un database SQL per registrare i dati degli utenti e dei bacari.

## Tecnologie utilizzate

L'applicazione è stata sviluppata utilizzando il framework Flutter per la parte frontend e il framework Node.js per il backend. In particolare, il backend è stato sviluppato utilizzando la tecnologia RESTFUL. Il database è PostgreSQL

## Backend

E' un server Node.js che utilizza il framework Express.js per gestire le richieste HTTP. Ha diversi endpoint che consentono agli utenti di registrarsi, effettuare il login e accedere alla dashboard. Il server utilizza un database PostgreSQL con l'ORM Sequelize per memorizzare i dati degli utenti.

### Librerie

Dipende inoltre da diverse librerie, tra cui:

- **express:** per gestire le richieste HTTP
- **bcrypt:** per crittografare le password degli utenti
- **jsonwebtoken:** per gestire l'autenticazione tramite token JWT
- **fs:** per leggere e scrivere su file system
- **crypto:** per generare valori casuali di stringhe
- **AdminJS:** per creare un'interfaccia amministrativa per il server
- **AdminJSExpress:** per collegare l'interfaccia amministrativa a Express.js
- **AdminJSSequelize:** per gestire l'interfaccia amministrativa tramite Sequelize.js
- **HttpStatusCode:** per utilizzare codici HTTP predefiniti
- **fileUpload:** per gestire l'upload di file da parte degli utenti
- **png-to-jpeg:** per convertire immagini PNG in JPEG

### Endpoints

    /signup: endpoint per la registrazione di un nuovo utente
    /login: endpoint per l'autenticazione di un utente esistente
    /bacari: endpoint per ottenere informazioni sui bacari
    /bacari/:id: endpoint per ottenere informazioni su un bacaro specifico
    /score: endpoint per aggiungere un punteggio a un bacaro
    /user/:id/score: endpoint per ottenere il punteggio di un utente
    /leaderboard: endpoint per ottenere la classifica degli utenti
    /leaderboard/:id/bacari: endpoint per ottenere la classifica dei bacari
 
## Autenticazione JWT

Il server utilizza token JWT per autenticare gli utenti. I token sono firmati con una stringa segreta definita come ***TOKEN_SECRET*** e hanno una durata di 12 giorni. Al momento della registrazione o dell'accesso, il server genera un token JWT che viene poi inviato al client. Questo token contiene informazioni sull'utente, come l'ID e il ruolo, ed è firmato con una chiave segreta. In questo modo, il server può verificare che il token non sia stato manomesso e concedere l'accesso alle risorse protette solo agli utenti autorizzati che presentano un token valido.
