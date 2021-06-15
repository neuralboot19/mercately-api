

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: 9365af02626c742e8eeacf05192daff0
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 2830,
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
            Api-Key: cbfd019677c1ae4cd0bfaf60bcc07ceb
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
                  "id": "5036bsneh4170",
                  "first_name": "Ángela",
                  "last_name": "Terán",
                  "email": "barrie@baileybrekke.biz",
                  "phone": "+593672.496.698",
                  "meli_customer_id": null,
                  "meli_nickname": null,
                  "id_type": "ruc",
                  "id_number": "437-67-5241",
                  "address": "Apartamento Jorge s/n. Esc. 201",
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
                      "web_id": "5036wnjkf235"
                    }
                  ],
                  "custom_fields": [
                    {
                      "field_name": "voluptas",
                      "field_content:": "Test Field"
                    }
                  ]
                }
              ]
            }

### Get a customer [GET /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `5037inybz4171` (string, required)

+ Request returns a customer
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/5037inybz4171`

    + Headers

            Slug: test-connection
            Api-Key: ab89904765b2486d97d1c16c7b0634e4
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer found successfully",
              "customer": {
                "id": "5037inybz4171",
                "first_name": "Roberto",
                "last_name": "Concepción",
                "email": "joeyhaley@jastkihn.net",
                "phone": "+593697.376.642",
                "meli_customer_id": null,
                "meli_nickname": null,
                "id_type": "ruc",
                "id_number": "640-46-3844",
                "address": "Colegio Jorge Jiménez, 73 Puerta 518",
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
            Api-Key: acfc7a10820a3ee0478dc9bb6864d3f0
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
                "id": "5038fncdv4172",
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
                    "web_id": "5038jniqb236"
                  }
                ],
                "custom_fields": [
            
                ]
              }
            }

### Update a customer [PUT /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `5039xmzho4173` (string, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/5039xmzho4173`

    + Headers

            Slug: test-connection
            Api-Key: 5adf1cded3820fc06dfc268253461d8a
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/5040erbkn4174`

    + Headers

            Slug: test-connection
            Api-Key: 519260d47e4b49b23242e0bc8aa680fa
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
                "agent_id": 2823
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/5041qwjan4175`

    + Headers

            Slug: test-connection
            Api-Key: 61f8645d2cb20467a5dae52ebe3b52fa
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
                "agent_id": 2824,
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/5042vhauy4176`

    + Headers

            Slug: test-connection
            Api-Key: 3271e808b864c9863a50090c55f93b13
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
                "agent_id": 2825,
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
            Api-Key: cf61aae5dac1cb53a811dec2a9eb4a83
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
                  "customer_id": 4178,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T21:06:47.552Z",
                  "first_name": "Ester",
                  "last_name": "López",
                  "email": "numbers@graham.net",
                  "agent_id": 2826
                },
                {
                  "id": null,
                  "customer_id": 4179,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T16:06:47.512Z",
                  "first_name": "José",
                  "last_name": "Valdivia",
                  "email": "brittanygreenfelder@carter.com",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 4177,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T12:06:47.385Z",
                  "first_name": "Diego",
                  "last_name": "Lara",
                  "email": "lesleyemmerich@prosaccofritsch.org",
                  "agent_id": 2826
                }
              ]
            }

+ Request returns all unassigned messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 066450571a8fe87352e843442f882684
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
                  "customer_id": 4182,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T16:06:47.751Z",
                  "first_name": "Enrique",
                  "last_name": "Esparza",
                  "email": "janette@senger.name",
                  "agent_id": null
                }
              ]
            }

### Get customer Messenger conversations [GET /retailers/api/v1/customers/{id}/messenger_conversations]

+ Parameters
    + id: `5045nkiav4183` (string, required)

+ Request returns customer Messenger conversations
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/5045nkiav4183/messenger_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: 68bd448bebfccdb51da4ddf0b13e59a6
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "messenger_conversations": [
                {
                  "text": "Ea quia sit. Eaque nulla voluptates. Temporibus enim sint.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-14T12:06:47.988Z"
                },
                {
                  "text": "Praesentium eos quo. Dolore alias ducimus. Id saepe voluptatem.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-14T12:06:47.988Z"
                },
                {
                  "text": "Eum deserunt non. Tempore quis in. Est nostrum culpa.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-14T12:06:47.988Z"
                },
                {
                  "text": "Quibusdam eveniet optio. Dolorum eligendi illo. Et corrupti enim.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-14T12:06:47.988Z"
                },
                {
                  "text": "Ducimus autem aut. Molestiae sed accusantium. Vel et quia.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "url": null,
                  "date_read": null,
                  "created_at": "2021-06-14T12:06:47.988Z"
                }
              ],
              "total_pages": 1
            }

+ Request returns 404
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/not_found/messenger_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: d67b1a76c66bc6a8b0cc1d7ed7a1c6b2
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
            Api-Key: 9128f99d59f2dd7655dd11fef103bd10
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
            Api-Key: d3d77afa79b1661575afbd9eafc1a58b
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
            Api-Key: 5f6996a6548fa9bcf8a5f14bcb146fdf
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
            Api-Key: 66a39824ab431f6f82bf5646acbd8652
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
            Api-Key: f19065432406ba1bde853121ad491369
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
                "created_time": "2021-06-15T13:06:51.334-04:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: d86530a8e3a95968f7752810928c5d87
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
              "agent_id": 2856
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
                "created_time": "2021-06-15T13:06:51.450-04:00",
                "error": null
              }
            }

+ Request sends the notification and include tags
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: b4869bd8b9e1ddec4e8dfae1a2935dee
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
              "agent_id": 2858,
              "tags": [
                {
                  "name": "pariatur",
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
                "created_time": "2021-06-15T13:06:51.581-04:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: aade23f3688458eabdcf9218173514da
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
                "created_time": "2021-06-15T13:06:51.682-04:00",
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
            Api-Key: 95c70e15112938ef3030196050fc6086
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
                  "customer_id": 4188,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T21:06:48.518Z",
                  "first_name": "Ramón",
                  "last_name": "Duarte",
                  "email": "rita@spinkaernser.org",
                  "phone": "+593789584759",
                  "agent_id": 2831
                },
                {
                  "id": null,
                  "customer_id": 4189,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T16:06:48.482Z",
                  "first_name": "Teresa",
                  "last_name": "Carrera",
                  "email": "ruell@gulgowski.info",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 4187,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T12:06:48.361Z",
                  "first_name": "Isabela",
                  "last_name": "Mendoza",
                  "email": "carter@hermanrosenbaum.org",
                  "phone": "+593123458475",
                  "agent_id": 2831
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 0548b63ac52a9aee5d690cb5917cdebf
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
                  "customer_id": 4192,
                  "message_count": 1,
                  "last_interaction": "2021-06-14T16:06:48.690Z",
                  "first_name": "Juan Carlos",
                  "last_name": "Rentería",
                  "email": "hermelinda@larkinmedhurst.org",
                  "phone": "+593452365897",
                  "agent_id": null
                }
              ]
            }

### Get customer WhatsApp conversations [GET /retailers/api/v1/customers/{id}/whatsapp_conversations]

+ Parameters
    + id: `5050slygk4193` (string, required)

+ Request returns customer whatsapp conversations
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/5050slygk4193/whatsapp_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: a96929a58794ab6afefb9c6ed9cfecb0
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "whatsapp_conversations": [
                {
                  "id": "MyString",
                  "status": "submitted",
                  "direction": "inbound",
                  "channel": "MyString",
                  "message_type": "conversation",
                  "message_identifier": null,
                  "created_time": "2021-06-14T12:06:48.912Z",
                  "replied_message": null,
                  "filename": "",
                  "content_type": "text",
                  "content_text": "Hola TEST",
                  "content_media_url": "",
                  "content_media_caption": "",
                  "content_media_type": "",
                  "content_location_longitude": "",
                  "content_location_latitude": "",
                  "content_location_label": "",
                  "content_location_address": "",
                  "account_uid": "MyString",
                  "contacts_information": [
            
                  ],
                  "error_code": "",
                  "error_message": ""
                },
                {
                  "id": "MyString",
                  "status": "submitted",
                  "direction": "inbound",
                  "channel": "MyString",
                  "message_type": "conversation",
                  "message_identifier": null,
                  "created_time": "2021-06-14T12:06:48.912Z",
                  "replied_message": null,
                  "filename": "",
                  "content_type": "text",
                  "content_text": "Hola TEST",
                  "content_media_url": "",
                  "content_media_caption": "",
                  "content_media_type": "",
                  "content_location_longitude": "",
                  "content_location_latitude": "",
                  "content_location_label": "",
                  "content_location_address": "",
                  "account_uid": "MyString",
                  "contacts_information": [
            
                  ],
                  "error_code": "",
                  "error_message": ""
                },
                {
                  "id": "MyString",
                  "status": "submitted",
                  "direction": "inbound",
                  "channel": "MyString",
                  "message_type": "conversation",
                  "message_identifier": null,
                  "created_time": "2021-06-14T12:06:48.912Z",
                  "replied_message": null,
                  "filename": "",
                  "content_type": "text",
                  "content_text": "Hola TEST",
                  "content_media_url": "",
                  "content_media_caption": "",
                  "content_media_type": "",
                  "content_location_longitude": "",
                  "content_location_latitude": "",
                  "content_location_label": "",
                  "content_location_address": "",
                  "account_uid": "MyString",
                  "contacts_information": [
            
                  ],
                  "error_code": "",
                  "error_message": ""
                },
                {
                  "id": "MyString",
                  "status": "submitted",
                  "direction": "inbound",
                  "channel": "MyString",
                  "message_type": "conversation",
                  "message_identifier": null,
                  "created_time": "2021-06-14T12:06:48.912Z",
                  "replied_message": null,
                  "filename": "",
                  "content_type": "text",
                  "content_text": "Hola TEST",
                  "content_media_url": "",
                  "content_media_caption": "",
                  "content_media_type": "",
                  "content_location_longitude": "",
                  "content_location_latitude": "",
                  "content_location_label": "",
                  "content_location_address": "",
                  "account_uid": "MyString",
                  "contacts_information": [
            
                  ],
                  "error_code": "",
                  "error_message": ""
                },
                {
                  "id": "MyString",
                  "status": "submitted",
                  "direction": "inbound",
                  "channel": "MyString",
                  "message_type": "conversation",
                  "message_identifier": null,
                  "created_time": "2021-06-14T12:06:48.912Z",
                  "replied_message": null,
                  "filename": "",
                  "content_type": "text",
                  "content_text": "Hola TEST",
                  "content_media_url": "",
                  "content_media_caption": "",
                  "content_media_type": "",
                  "content_location_longitude": "",
                  "content_location_latitude": "",
                  "content_location_label": "",
                  "content_location_address": "",
                  "account_uid": "MyString",
                  "contacts_information": [
            
                  ],
                  "error_code": "",
                  "error_message": ""
                }
              ],
              "total_pages": 1
            }

+ Request returns 404
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/not_found/whatsapp_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: e44aaeaeee87cb9d8dead0e80eb7f521
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 404

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Not found"
            }

# Group WhatsApp Templates


## WhatsApp Templates [/retailers/api/v1/whatsapp_templates]
Documentation of whatsapp templates resources

### Get WhatsApp templates [GET /retailers/api/v1/whatsapp_templates]


+ Request returns a list of whatsapp templates
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_templates`

    + Headers

            Slug: test-connection
            Api-Key: 2e34c2e9acc9c8afff3506444194f629
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
