

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: f1595c50b515562f379c758fb23c8e1a
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 873,
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

### Get all customers [GET /retailers/api/v1/customers]


+ Request returns all customers
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers?page=1`

    + Headers

            Slug: test-connection
            Api-Key: 63d3ca402b3778fc88a6dfef64b958ba
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "results": 1,
              "total_pages": 1,
              "customers": [
                {
                  "id": "1050kectb1180",
                  "first_name": "Samuel",
                  "last_name": "Flórez",
                  "email": "leopoldohickle@von.info",
                  "phone": "+593670130924",
                  "meli_customer_id": null,
                  "meli_nickname": null,
                  "id_type": "ruc",
                  "id_number": "566-40-8795",
                  "address": "Paseo Julio César 7 Puerta 101",
                  "city": "Quito",
                  "state": "Pichincha",
                  "zip_code": "170207",
                  "country_id": "EC",
                  "notes": null,
                  "whatsapp_opt_in": false,
                  "whatsapp_name": null,
                  "tags": [
                    {
                      "tag": "Test tag",
                      "web_id": "1050zbkar52"
                    }
                  ],
                  "custom_fields": [
                    {
                      "field_name": "asperiores",
                      "field_content:": "Test Field"
                    }
                  ]
                }
              ]
            }

### Get a customer [GET /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `1051ndelr1181` (string, required)

+ Request returns a customer
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/1051ndelr1181`

    + Headers

            Slug: test-connection
            Api-Key: f0ee77388af5a5e8b661dd3d2f6fb8a2
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer found successfully",
              "customer": {
                "id": "1051ndelr1181",
                "first_name": "Josefina",
                "last_name": "Gil",
                "email": "mickey@tromp.co",
                "phone": "+593695.221.618",
                "meli_customer_id": null,
                "meli_nickname": null,
                "id_type": "ruc",
                "id_number": "094-42-0660",
                "address": "Huerta Eloisa 69",
                "city": "Quito",
                "state": "Pichincha",
                "zip_code": "170207",
                "country_id": "EC",
                "notes": null,
                "whatsapp_opt_in": false,
                "whatsapp_name": null,
                "tags": [
            
                ],
                "custom_fields": [
            
                ]
              }
            }

### Update a customer [PUT /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `1052uzjkd1182` (string, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/1052uzjkd1182`

    + Headers

            Slug: test-connection
            Api-Key: 37cd63092294bb22d25bc625d44dc1bb
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/1053riyho1183`

    + Headers

            Slug: test-connection
            Api-Key: 544d00e6ba2b49f263c875b84c8f4801
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            customer[first_name]=Juan&customer[last_name]=Campos&customer[email]=juan%40email.com&customer[phone]=%2B12036534789&customer[notes]=New+notes&customer[address]=Calle+5&customer[city]=Fort+Worth&customer[state]=TX&customer[zip_code]=76106&customer[agent_id]=870

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
            Api-Key: 60d08e595be00488df2810cc22c69ca7
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
                  "customer_id": 1185,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T21:24:31.596Z",
                  "first_name": "Conchita",
                  "last_name": "Vélez",
                  "email": "zoilagaylord@mohr.info",
                  "agent_id": 871
                },
                {
                  "id": null,
                  "customer_id": 1186,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T16:24:31.582Z",
                  "first_name": "José Emilio",
                  "last_name": "Chávez",
                  "email": "elviramarvin@mann.io",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 1184,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T12:24:31.543Z",
                  "first_name": "José Luis",
                  "last_name": "Velasco",
                  "email": "beverly@mohrhickle.com",
                  "agent_id": 871
                }
              ]
            }

+ Request returns all unassigned messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 0eaca46009a398203ab9ea8903062bd7
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
                  "customer_id": 1189,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T16:24:31.674Z",
                  "first_name": "Pedro",
                  "last_name": "Vázquez",
                  "email": "elayne@haley.io",
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
            Api-Key: b22b147de6698a88819c6b3183df3325
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
            Api-Key: c1b0e3bb56dd9f92867fb5b3b4022ded
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
            Api-Key: 23e8bf622d81451b1abaa9c88d1fd508
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
            Api-Key: 37ceadb4f4149af17d38a546568a10d6
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
                "created_time": "2021-03-25T12:24:32.818-05:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: d2e34524de508669b4a7d0f90d4489c2
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999&internal_id=997dd550-c8d8-4bf7-ad98-a5ac4844a1ed&template_params[]=test+1&template_params[]=test+2&template_params[]=test+3&agent_id=896

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
                "created_time": "2021-03-25T12:24:32.866-05:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 8f395d51e922414611e0850ab41921ae
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
                "created_time": "2021-03-25T12:24:32.905-05:00",
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
            Api-Key: 0a169c58c2f196aace477af6adb0fd8a
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
                  "customer_id": 1191,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T21:24:31.854Z",
                  "first_name": "Clara",
                  "last_name": "Henríquez",
                  "email": "robertfisher@lang.name",
                  "phone": "+593789584759",
                  "agent_id": 874
                },
                {
                  "id": null,
                  "customer_id": 1192,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T16:24:31.838Z",
                  "first_name": "Jesús",
                  "last_name": "Lara",
                  "email": "regeniasmith@dickijenkins.io",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 1190,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T12:24:31.784Z",
                  "first_name": "Mariano",
                  "last_name": "Cotto",
                  "email": "arnulfobednar@lueilwitzjacobson.info",
                  "phone": "+593123458475",
                  "agent_id": 874
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 4399eabf5a61fc7c46979c04ff5d0913
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
                  "customer_id": 1195,
                  "message_count": 1,
                  "last_interaction": "2021-03-24T16:24:31.942Z",
                  "first_name": "Patricio",
                  "last_name": "Porras",
                  "email": "edwardokunde@mraztowne.biz",
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
            Api-Key: afd1d3119d197ea8ce615e285bcb2739
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
