

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: 34c3251acdad485b4187baf5c0f35e07
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 2763,
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
            Api-Key: 69920553cbb8104c38876c251c79534a
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
                  "id": "4880vesdc3873",
                  "first_name": "Pablo",
                  "last_name": "Domínguez",
                  "email": "slyvia@thompson.net",
                  "phone": "+593667 357 821",
                  "meli_customer_id": null,
                  "meli_nickname": null,
                  "id_type": "ruc",
                  "id_number": "293-07-3863",
                  "address": "Muelle Cristobal s/n.",
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
                      "web_id": "4880epqur256"
                    }
                  ],
                  "custom_fields": [
                    {
                      "field_name": "ullam",
                      "field_content:": "Test Field"
                    }
                  ]
                }
              ]
            }

### Get a customer [GET /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `4881ljusi3874` (string, required)

+ Request returns a customer
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/4881ljusi3874`

    + Headers

            Slug: test-connection
            Api-Key: bd00d2c547e53f344cb0075ee2bb63ca
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer found successfully",
              "customer": {
                "id": "4881ljusi3874",
                "first_name": "Víctor",
                "last_name": "Alcántar",
                "email": "hattiegreenfelder@welchebert.biz",
                "phone": "+593634063868",
                "meli_customer_id": null,
                "meli_nickname": null,
                "id_type": "ruc",
                "id_number": "329-82-3866",
                "address": "Polígono José María Rojo s/n.",
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
            Api-Key: 74edd3439e99d95f5c73dca8dfaf7136
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
                "id": "4882chfxj3875",
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
                    "web_id": "4882yeopc257"
                  }
                ],
                "custom_fields": [
            
                ]
              }
            }

### Update a customer [PUT /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `4883xnwlq3876` (string, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/4883xnwlq3876`

    + Headers

            Slug: test-connection
            Api-Key: 7d6e0f40a9807fb5bb672ae109317fb2
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/4884oheqn3877`

    + Headers

            Slug: test-connection
            Api-Key: b7aaf91d848f739d4718b4be2fe1cc3e
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
                "agent_id": 2758
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/4885lezrn3878`

    + Headers

            Slug: test-connection
            Api-Key: 7c7c3e4dca6e2e783ff55d484119e070
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
                "agent_id": 2759,
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/4886fndot3879`

    + Headers

            Slug: test-connection
            Api-Key: e6ef93550fbf50d37644e7efd0dd2d54
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
                "agent_id": 2760,
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
            Api-Key: 2beacd2bbdf6b1977595b2ed532e0926
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
                  "customer_id": 3881,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T23:17:42.014Z",
                  "first_name": "Isabela",
                  "last_name": "Olivo",
                  "email": "kriy@considinekub.info",
                  "agent_id": 2761
                },
                {
                  "id": null,
                  "customer_id": 3882,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T18:17:41.983Z",
                  "first_name": "Juan Carlos",
                  "last_name": "Iglesias",
                  "email": "glen@lueilwitz.biz",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 3880,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T14:17:41.897Z",
                  "first_name": "Homero",
                  "last_name": "Jasso",
                  "email": "roseannedaugherty@schmeler.io",
                  "agent_id": 2761
                }
              ]
            }

+ Request returns all unassigned messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 412a1d0667ccc16f961abd7973e7f4d6
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
                  "customer_id": 3885,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T18:17:42.181Z",
                  "first_name": "María Soledad",
                  "last_name": "Juárez",
                  "email": "martin@johnstoneffertz.io",
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
            Api-Key: d02ea512a7e4e458f139c4ed1c1cb41c
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
            Api-Key: f3d0134416f1f7e26198f8daa7d11c78
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
            Api-Key: ab8016506510019e8fbfba0e4f8a04ac
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
            Api-Key: 5cb99349568dfe207e796d7edcf0b11d
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
                "created_time": "2021-03-31T15:17:44.706-04:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 0a65887a17058b475b33c81d87d1cd30
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
              "agent_id": 2786
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
                "created_time": "2021-03-31T15:17:44.819-04:00",
                "error": null
              }
            }

+ Request sends the notification and include tags
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: baf2aa29ad90bf8a1cb125e51594e52a
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
              "agent_id": 2788,
              "tags": [
                {
                  "name": "repellat",
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
                "created_time": "2021-03-31T15:17:44.994-04:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: ba5747ce5dbc6070c6be0e029d0db6ff
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
                "created_time": "2021-03-31T15:17:45.081-04:00",
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
            Api-Key: 6bfb64ba2d9375d0d5ed7eb7e5b53cd2
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
                  "customer_id": 3887,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T23:17:42.560Z",
                  "first_name": "Raquel",
                  "last_name": "Pérez",
                  "email": "benedictstreich@von.name",
                  "phone": "+593789584759",
                  "agent_id": 2764
                },
                {
                  "id": null,
                  "customer_id": 3888,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T18:17:42.525Z",
                  "first_name": "Carlos",
                  "last_name": "Leiva",
                  "email": "maribethwalsh@gottlieb.co",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 3886,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T14:17:42.410Z",
                  "first_name": "Gabriel",
                  "last_name": "Hernández",
                  "email": "samual@schimmel.com",
                  "phone": "+593123458475",
                  "agent_id": 2764
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 352487c902d0c7eb8d6e2e20c87bd316
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
                  "customer_id": 3891,
                  "message_count": 1,
                  "last_interaction": "2021-03-30T18:17:42.736Z",
                  "first_name": "Juana",
                  "last_name": "Alarcón",
                  "email": "tijuanachamplin@von.name",
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
            Api-Key: f511717e68bd41b2d05e372c6aeb37c5
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
