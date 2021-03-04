

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: 4664752ff1ddb1ea20ee77e909a024c2
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 10692,
                  "first_name": "Agent",
                  "last_name": "Example",
                  "email": "agent@example.com",
                  "admin": true
                }
              ]
            }

# Group Customers


## Customers [/retailers/api/v1/customers/:id]
Documentation of customer resources

### Update a customer [PUT /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `15122` (number, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/15122`

    + Headers

            Slug: test-connection
            Api-Key: 4d2429b0b937cf7c951d36ac84d35fec
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            customer[first_name]=Juan&customer[last_name]=Campos&customer[email]=juan%40email.com&customer[phone]=%2B12036534789&customer[notes]=New+notes&customer[address]=Calle+5&customer[city]=Fort+Worth&customer[state]=TX&customer[zip_code]=76106

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer updated successfully"
            }

+ Request assigns the customer to an agent
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/15123`

    + Headers

            Slug: test-connection
            Api-Key: 98e48c03de3dec1169c80050a4cfffd9
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            customer[first_name]=Juan&customer[last_name]=Campos&customer[email]=juan%40email.com&customer[phone]=%2B12036534789&customer[notes]=New+notes&customer[address]=Calle+5&customer[city]=Fort+Worth&customer[state]=TX&customer[zip_code]=76106&customer[agent_id]=10689

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer updated successfully"
            }

# Group Messenger Conversations


## Messenger Conversations [/retailers/api/v1/messenger_conversations]
Documentation of Messenger conversations

### Get Messenger conversations [GET /retailers/api/v1/messenger_conversations]


+ Request returns all messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100`

    + Headers

            Slug: test-connection
            Api-Key: 4bc4c7199a199a6c584d324cac2d2f69
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "results": 3,
              "total_pages": 1,
              "messenger_conversations": [
                {
                  "id": null,
                  "customer_id": 15125,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T19:11:53.637Z",
                  "first_name": "Esteban",
                  "last_name": "Bermúdez",
                  "email": "thomasina@boehm.net",
                  "agent_id": 10690
                },
                {
                  "id": null,
                  "customer_id": 15126,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T14:11:53.601Z",
                  "first_name": "Inés",
                  "last_name": "Rosado",
                  "email": "kareembartell@labadie.info",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 15124,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T10:11:53.467Z",
                  "first_name": "Elsa",
                  "last_name": "Narváez",
                  "email": "catarinawhite@batz.biz",
                  "agent_id": 10690
                }
              ]
            }

+ Request returns all unassigned messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 0deb90b1d23213580a4ef3c0980891b4
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "results": 1,
              "total_pages": 1,
              "messenger_conversations": [
                {
                  "id": null,
                  "customer_id": 15129,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T14:11:53.809Z",
                  "first_name": "Mercedes",
                  "last_name": "Gracia",
                  "email": "tomas@stokesbrekke.net",
                  "agent_id": null
                }
              ]
            }

# Group Notifications


## Notifications [/retailers/api/v1/whatsapp/send_notification_by_id]
Documentation of notifications resources

### Send a notification by ID [POST /retailers/api/v1/whatsapp/send_notification_by_id]


+ Request returns 400 - Bad Request
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 7edb1879cc5950b74fe33c48238caf12
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999

+ Response 400

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Error: Missing phone number and/or internal_id",
              "info": {
                "data": {
                }
              }
            }

+ Request returns 404 - Not Found
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 06ad5d7c6aea27e4b15aef1a39148ea6
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999&internal_id=xxxxxxxxxxxxxxx

+ Response 404

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Error: Template not found. Please check the ID sent.",
              "info": {
                "data": {
                }
              }
            }

+ Request returns 400 - Bad Request
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 57f361db56c491d1f8f9fb0c230cbdd7
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999&internal_id=997dd550-c8d8-4bf7-ad98-a5ac4844a1ed&template_params[]=test+1&template_params[]=test+2

+ Response 400

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Error: Parameters mismatch. Required 3, but 2 sent.",
              "info": {
                "data": {
                }
              }
            }

+ Request sends the notification
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: a70d29cc022ece8218481b264e542695
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999&internal_id=997dd550-c8d8-4bf7-ad98-a5ac4844a1ed&template_params[]=test+1&template_params[]=test+2&template_params[]=test+3

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Ok",
              "info": {
                "channel": "whatsapp",
                "content": {
                  "text": "Your OTP for test 1 is test 2. This is valid for test 3."
                },
                "direction": "outbound",
                "status": "submitted",
                "destination": "+593999999999",
                "country": "EC",
                "created_time": "2021-03-04T11:11:56.605-04:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: ca53f0b87d12e5d4f3c0d04712a6c4ba
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999&internal_id=997dd550-c8d8-4bf7-ad98-a5ac4844a1ed&template_params[]=test+1&template_params[]=test+2&template_params[]=test+3&agent_id=10715

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Ok",
              "info": {
                "channel": "whatsapp",
                "content": {
                  "text": "Your OTP for test 1 is test 2. This is valid for test 3."
                },
                "direction": "outbound",
                "status": "submitted",
                "destination": "+593999999999",
                "country": "EC",
                "created_time": "2021-03-04T11:11:56.719-04:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 6c9de1a3020b07d12eab8a355c389f43
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999&internal_id=997dd550-c8d8-4bf7-ad98-a5ac4844a1ed&template_params[]=test+1&template_params[]=test+2&template_params[]=test+3&first_name=First+Name&last_name=Last+Name&email=email%40email.com&address=Customer+address&city=Customer+city&state=Customer+state&zip_code=12345&notes=Notes+related+to+the+customer

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Ok",
              "info": {
                "channel": "whatsapp",
                "content": {
                  "text": "Your OTP for test 1 is test 2. This is valid for test 3."
                },
                "direction": "outbound",
                "status": "submitted",
                "destination": "+593999999999",
                "country": "EC",
                "created_time": "2021-03-04T11:11:56.808-04:00",
                "error": null
              }
            }

# Group WhatsApp Conversations


## WhatsApp Conversations [/retailers/api/v1/whatsapp_conversations]
Documentation of WhatsApp conversations

### Get WhatsApp conversations [GET /retailers/api/v1/whatsapp_conversations]


+ Request returns all whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100`

    + Headers

            Slug: test-connection
            Api-Key: b1da585ac40775295e2504583ad8973b
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "results": 3,
              "total_pages": 1,
              "whatsapp_conversations": [
                {
                  "id": null,
                  "customer_id": 15131,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T19:11:54.194Z",
                  "first_name": "Isabel",
                  "last_name": "Villareal",
                  "email": "hattie@welch.com",
                  "phone": "+593789584759",
                  "agent_id": 10693
                },
                {
                  "id": null,
                  "customer_id": 15132,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T14:11:54.160Z",
                  "first_name": "Gerardo",
                  "last_name": "Cano",
                  "email": "stephen@schmidt.com",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 15130,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T10:11:54.050Z",
                  "first_name": "Esteban",
                  "last_name": "Manzanares",
                  "email": "elwood@vandervort.info",
                  "phone": "+593123458475",
                  "agent_id": 10693
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 99880e33d17b4c91a0516cb5b2cf9cf8
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "results": 1,
              "total_pages": 1,
              "whatsapp_conversations": [
                {
                  "id": null,
                  "customer_id": 15135,
                  "message_count": 1,
                  "last_interaction": "2021-03-03T14:11:54.361Z",
                  "first_name": "Mario",
                  "last_name": "Hurtado",
                  "email": "adam@kohler.co",
                  "phone": "+593452365897",
                  "agent_id": null
                }
              ]
            }

# Group WhatsApp Templates


## WhatsApp Templates [/retailers/api/v1/whatsapp_templates]
Documentation of whatsapp templates resources

### Get WhatsApp templates [GET /retailers/api/v1/whatsapp_templates]


+ Request returns a list of whatsapp templates
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_templates`

    + Headers

            Slug: test-connection
            Api-Key: 3a1349361c4db46b88a7ef5269ac6ef0
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "templates": [
                {
                  "text": "Hi *. Welcome to our WhatsApp. We will be here for any question.",
                  "status": "active",
                  "template_type": "text",
                  "internal_id": "997dd550-c8d8-4bf7-ad98-a5ac4844a1ed"
                }
              ]
            }
