

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: e7b1ee628d69e53edef8f935b624a518
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 1092,
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
            Api-Key: 6b5a2665c9329935817e9b7afe0fdb16
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
                  "id": "3194ivhup2634",
                  "first_name": "Felipe",
                  "last_name": "Uribe",
                  "email": "major@beattybashirian.biz",
                  "phone": "+593660746946",
                  "meli_customer_id": null,
                  "meli_nickname": null,
                  "id_type": "ruc",
                  "id_number": "575-59-6000",
                  "address": "Entrada Adela, 9 Puerta 537",
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
                      "web_id": "3194btjqm80"
                    }
                  ],
                  "custom_fields": [
                    {
                      "field_name": "illum",
                      "field_content:": "Test Field"
                    }
                  ]
                }
              ]
            }

### Get a customer [GET /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `3195jxqwy2635` (string, required)

+ Request returns a customer
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/3195jxqwy2635`

    + Headers

            Slug: test-connection
            Api-Key: fc16a60a4fae52e10e912c7e72d1e5d2
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer found successfully",
              "customer": {
                "id": "3195jxqwy2635",
                "first_name": "Manuel",
                "last_name": "Herrera",
                "email": "bethannlangosh@farrellshanahan.info",
                "phone": "+593640918479",
                "meli_customer_id": null,
                "meli_nickname": null,
                "id_type": "ruc",
                "id_number": "571-26-6038",
                "address": "Monte Alfonso Polanco, 26 Puerta 397",
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

### Create a customer [POST /retailers/api/v1/customers]


+ Request creates a customer
**POST**&nbsp;&nbsp;`/retailers/api/v1/customers`

    + Headers

            Slug: test-connection
            Api-Key: ec1cdbbe5fee1602d5baff449e8adce6
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "customer": {
                "first_name": "Juan",
                "last_name": "Campos",
                "email": "juan@email.com",
                "phone": "+12036534789",
                "notes": "New notes",
                "address": "Calle 5",
                "city": "Fort Worth",
                "state": "TX",
                "zip_code": "76106",
                "tags": [
                  {
                    "name": "Test tag",
                    "value": true
                  }
                ]
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer created successfully",
              "customer": {
                "id": "3196gwpdl2636",
                "first_name": "Juan",
                "last_name": "Campos",
                "email": "juan@email.com",
                "phone": "+12036534789",
                "meli_customer_id": null,
                "meli_nickname": null,
                "id_type": null,
                "id_number": null,
                "address": "Calle 5",
                "city": "Fort Worth",
                "state": "TX",
                "zip_code": "76106",
                "country_id": null,
                "notes": "New notes",
                "whatsapp_opt_in": false,
                "whatsapp_name": null,
                "tags": [
                  {
                    "tag": "Test tag",
                    "web_id": "3196cntkm81"
                  }
                ],
                "custom_fields": [
            
                ]
              }
            }

### Update a customer [PUT /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `3197htgsc2637` (string, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/3197htgsc2637`

    + Headers

            Slug: test-connection
            Api-Key: e3ce8446c398924efe9d880d1c72e469
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "customer": {
                "first_name": "Juan",
                "last_name": "Campos",
                "email": "juan@email.com",
                "phone": "+12036534789",
                "notes": "New notes",
                "address": "Calle 5",
                "city": "Fort Worth",
                "state": "TX",
                "zip_code": "76106"
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer updated successfully"
            }

+ Request assigns the customer to an agent
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/3198wfgsi2638`

    + Headers

            Slug: test-connection
            Api-Key: 582fe98d882afb833b7f9b1a470efdae
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "customer": {
                "first_name": "Juan",
                "last_name": "Campos",
                "email": "juan@email.com",
                "phone": "+12036534789",
                "notes": "New notes",
                "address": "Calle 5",
                "city": "Fort Worth",
                "state": "TX",
                "zip_code": "76106",
                "agent_id": 1085
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer updated successfully"
            }

+ Request assigns the customer a tag
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/3199pxnvl2639`

    + Headers

            Slug: test-connection
            Api-Key: 07db77da7c934e711b59c06e46d31973
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "customer": {
                "first_name": "Juan",
                "last_name": "Campos",
                "email": "juan@email.com",
                "phone": "+12036534789",
                "notes": "New notes",
                "address": "Calle 5",
                "city": "Fort Worth",
                "state": "TX",
                "zip_code": "76106",
                "agent_id": 1086,
                "tags": [
                  {
                    "name": "Test Tag",
                    "value": true
                  }
                ]
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer updated successfully"
            }

+ Request remove tag from customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/3200tdeai2640`

    + Headers

            Slug: test-connection
            Api-Key: 8adf92b1494b2413069cd113ccf2d5a4
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "customer": {
                "first_name": "Juan",
                "last_name": "Campos",
                "email": "juan@email.com",
                "phone": "+12036534789",
                "notes": "New notes",
                "address": "Calle 5",
                "city": "Fort Worth",
                "state": "TX",
                "zip_code": "76106",
                "agent_id": 1087,
                "tags": [
                  {
                    "name": "Test Tag 2",
                    "value": false
                  }
                ]
              }
            }

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
            Api-Key: d835dcf611fb3198aabdbb7e671d6bef
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
                  "customer_id": 2642,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T18:18:16.719Z",
                  "first_name": "Emilio",
                  "last_name": "Olivera",
                  "email": "santiago@hyatt.org",
                  "agent_id": 1088
                },
                {
                  "id": null,
                  "customer_id": 2643,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T13:18:16.661Z",
                  "first_name": "Clemente",
                  "last_name": "Mendoza",
                  "email": "donaldhane@grimes.com",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 2641,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T09:18:16.517Z",
                  "first_name": "Ariadna",
                  "last_name": "Camarillo",
                  "email": "maurice@breitenberggerlach.info",
                  "agent_id": 1088
                }
              ]
            }

+ Request returns all unassigned messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: c845da3c0ea00d78de654bd9c97982e1
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
                  "customer_id": 2646,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T13:18:17.013Z",
                  "first_name": "María Luisa",
                  "last_name": "Valdés",
                  "email": "ana@boyle.co",
                  "agent_id": null
                }
              ]
            }

### Get customer Messenger conversations [GET /retailers/api/v1/customers/{id}/messenger_conversations]

+ Parameters
    + id: `3203podgt2647` (string, required)

+ Request returns customer Messenger conversations
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/3203podgt2647/messenger_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: 5459624b93d3ea1928ba1cf247b6c256
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "messenger_conversations": [
                {
                  "text": "Quas fugiat iste. Aut quaerat aliquam. Unde ut perspiciatis.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-13T09:18:17.333Z"
                },
                {
                  "text": "Neque odio ex. Ex totam neque. Et nesciunt mollitia.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-13T09:18:17.333Z"
                },
                {
                  "text": "Hic consequatur veniam. Sit voluptatum voluptatibus. Ipsam est quia.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-13T09:18:17.333Z"
                },
                {
                  "text": "Earum pariatur saepe. Numquam eligendi nulla. Quo quasi hic.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-13T09:18:17.333Z"
                },
                {
                  "text": "Velit autem vero. Qui at ut. Qui quia dignissimos.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-13T09:18:17.333Z"
                }
              ],
              "total_pages": 1
            }

+ Request returns 404
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/not_found/messenger_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: 43f8ca7eebbcb522baedaa76bc985d3c
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 404

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Not found"
            }

# Group Notifications


## Notifications [/retailers/api/v1/whatsapp/send_notification_by_id]
Documentation of notifications resources

### Send a notification by ID [POST /retailers/api/v1/whatsapp/send_notification_by_id]


+ Request returns 400 - Bad Request
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 51ec1e57f657ed42dc4f2f3c10d581c2
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "internal_id": "997dd550-c8d8-4bf7-ad98-a5ac4844a1ed"
            }

+ Response 400

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Error: Missing phone number",
              "info": {
                "data": {
                }
              }
            }

+ Request returns 400 - Bad Request
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: fd99c885cb295d96e469e797879037a4
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "phone_number": "+593999999999"
            }

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
            Api-Key: 485db5fc7b382788eed39429a492e487
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "phone_number": "+593999999999",
              "internal_id": "xxxxxxxxxxxxxxx"
            }

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
            Api-Key: a4aff442a32d6c05fb1c1fc0b9f995ab
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "phone_number": "+593999999999",
              "internal_id": "997dd550-c8d8-4bf7-ad98-a5ac4844a1ed",
              "template_params": [
                "test 1",
                "test 2"
              ]
            }

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
            Api-Key: 1e28283a717160935322102fba09702d
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "phone_number": "+593999999999",
              "internal_id": "997dd550-c8d8-4bf7-ad98-a5ac4844a1ed",
              "template_params": [
                "test 1",
                "test 2",
                "test 3"
              ]
            }

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
                "created_time": "2021-06-14T09:18:21.120-05:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 3a549465627cdcd32f2cb3a67714168e
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "phone_number": "+593999999999",
              "internal_id": "997dd550-c8d8-4bf7-ad98-a5ac4844a1ed",
              "template_params": [
                "test 1",
                "test 2",
                "test 3"
              ],
              "agent_id": 1116
            }

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
                "created_time": "2021-06-14T09:18:21.249-05:00",
                "error": null
              }
            }

+ Request sends the notification and include tags
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: c02569a7fb40986bfbc17b43ec3382c7
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "phone_number": "+593999999999",
              "internal_id": "997dd550-c8d8-4bf7-ad98-a5ac4844a1ed",
              "template_params": [
                "test 1",
                "test 2",
                "test 3"
              ],
              "agent_id": 1118,
              "tags": [
                {
                  "name": "voluptatem",
                  "value": true
                }
              ]
            }

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
                "created_time": "2021-06-14T09:18:21.397-05:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 44e8411e9aa5ce614679f144189740c8
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "phone_number": "+593999999999",
              "internal_id": "997dd550-c8d8-4bf7-ad98-a5ac4844a1ed",
              "template_params": [
                "test 1",
                "test 2",
                "test 3"
              ],
              "first_name": "First Name",
              "last_name": "Last Name",
              "email": "email@email.com",
              "address": "Customer address",
              "city": "Customer city",
              "state": "Customer state",
              "zip_code": "12345",
              "notes": "Notes related to the customer"
            }

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
                "created_time": "2021-06-14T09:18:21.536-05:00",
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
            Api-Key: 080a88145ed94ad62f3d012b277cc477
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
                  "customer_id": 2652,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T18:18:18.023Z",
                  "first_name": "Jorge Luis",
                  "last_name": "Deleón",
                  "email": "katrinakerluke@danielstehr.co",
                  "phone": "+593789584759",
                  "agent_id": 1093
                },
                {
                  "id": null,
                  "customer_id": 2653,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T13:18:17.966Z",
                  "first_name": "Alicia",
                  "last_name": "Cervántez",
                  "email": "lenardwatsica@nikolaupinka.biz",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 2651,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T09:18:17.830Z",
                  "first_name": "Homero",
                  "last_name": "Alcántar",
                  "email": "marcellus@douglasebert.io",
                  "phone": "+593123458475",
                  "agent_id": 1093
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: f5fcb7d65086cab6d749fb74132453dc
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
                  "customer_id": 2656,
                  "message_count": 1,
                  "last_interaction": "2021-06-13T13:18:18.270Z",
                  "first_name": "Maricarmen",
                  "last_name": "Rocha",
                  "email": "meghan@cartwright.io",
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
            Api-Key: 72d536eee6a70a0ee160d9ec1385a3a2
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
