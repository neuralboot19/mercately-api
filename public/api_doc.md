

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: cfdb8cb146794831163a69ce917efddd
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 17417,
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
            Api-Key: 0bee40f9a3fb07eaa526a7ed5d067877
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
                  "id": "31717hkcyo25742",
                  "first_name": "Mariano",
                  "last_name": "Carmona",
                  "email": "tristaschroeder@raynor.info",
                  "phone": "+593614 769 633",
                  "meli_customer_id": null,
                  "meli_nickname": null,
                  "id_type": "ruc",
                  "id_number": "188-94-9852",
                  "address": "Urbanización Lorena Peres, 3 Esc. 276",
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
                      "web_id": "31717ncihj1496"
                    }
                  ],
                  "custom_fields": [
                    {
                      "field_name": "et",
                      "field_content:": "Test Field"
                    }
                  ]
                }
              ]
            }

### Get a customer [GET /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `31718imokl25743` (string, required)

+ Request returns a customer
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/31718imokl25743`

    + Headers

            Slug: test-connection
            Api-Key: 539e8b0e50ab15b3bed7e9a51524d067
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer found successfully",
              "customer": {
                "id": "31718imokl25743",
                "first_name": "Victoria",
                "last_name": "Girón",
                "email": "jovita@torp.co",
                "phone": "+593670-741-326",
                "meli_customer_id": null,
                "meli_nickname": null,
                "id_type": "ruc",
                "id_number": "773-85-3321",
                "address": "Cuesta Marisol 36 Esc. 478",
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
            Api-Key: 23a806258496af97ba54dfe91bda361d
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
                "id": "31719sxmly25744",
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
                    "web_id": "31719mxvuo1497"
                  }
                ],
                "custom_fields": [
            
                ]
              }
            }

### Update a customer [PUT /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `31720kjhec25745` (string, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/31720kjhec25745`

    + Headers

            Slug: test-connection
            Api-Key: 49242c965e966723e7c53a8e0f7c9a80
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/31721sdevg25746`

    + Headers

            Slug: test-connection
            Api-Key: c78cc3dc81ace7709dcbb2928b6e50f5
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
                "agent_id": 17412
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/31722xkyfh25747`

    + Headers

            Slug: test-connection
            Api-Key: 7d747d1136d1ba06f96e1a35f259a917
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
                "agent_id": 17413,
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/31723zsqxw25748`

    + Headers

            Slug: test-connection
            Api-Key: ef05f2f7b1460494b66d66af433d7ad1
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
                "agent_id": 17414,
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
            Api-Key: e3e17a064559e0734c4e069f98ee48f6
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
                  "customer_id": 25750,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T22:17:14.192Z",
                  "first_name": "Lorenzo",
                  "last_name": "Rincón",
                  "email": "georgiannewhite@boyle.name",
                  "agent_id": 17415
                },
                {
                  "id": null,
                  "customer_id": 25751,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T17:17:14.149Z",
                  "first_name": "César",
                  "last_name": "Prieto",
                  "email": "lorettehermann@oconnellmiller.co",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 25749,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T13:17:14.035Z",
                  "first_name": "David",
                  "last_name": "Ponce",
                  "email": "scottymurphy@connelly.com",
                  "agent_id": 17415
                }
              ]
            }

+ Request returns all unassigned messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: af0c0a9a7287dde73ae9201086e9ab83
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
                  "customer_id": 25754,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T17:17:14.484Z",
                  "first_name": "Pablo",
                  "last_name": "Trejo",
                  "email": "koryrunolfon@daugherty.net",
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
            Api-Key: 0d8fc03e053968d83134fded907dc787
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
            Api-Key: 24ab1dd78a5794c17bee15b6b9a830d0
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
            Api-Key: 27524e161f4bef95642eba6ded05d10c
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
            Api-Key: 26ea275ba8776bd7af3f312f61e12ba7
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
            Api-Key: f5b7c740ff32c23e0c4a70c56677932a
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
                "created_time": "2021-05-24T14:17:17.698-04:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 98b3353295c7af4b44a14c884085666a
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
              "agent_id": 17441
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
                "created_time": "2021-05-24T14:17:17.812-04:00",
                "error": null
              }
            }

+ Request sends the notification and include tags
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: ca10eb1e3aad73b25470243284b048a1
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
              "agent_id": 17443,
              "tags": [
                {
                  "name": "in",
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
                "created_time": "2021-05-24T14:17:17.961-04:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 245dcd3950c76120df7f750490859f4c
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
                "created_time": "2021-05-24T14:17:18.058-04:00",
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
            Api-Key: 0c8dd059019bc38a1ce3271d59b144de
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
                  "customer_id": 25756,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T22:17:15.098Z",
                  "first_name": "Gerardo",
                  "last_name": "Delatorre",
                  "email": "hank@mayer.org",
                  "phone": "+593789584759",
                  "agent_id": 17418
                },
                {
                  "id": null,
                  "customer_id": 25757,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T17:17:15.059Z",
                  "first_name": "Beatriz",
                  "last_name": "Atencio",
                  "email": "gail@dicki.io",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 25755,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T13:17:14.899Z",
                  "first_name": "Miguel Ángel",
                  "last_name": "Córdova",
                  "email": "colby@stokes.name",
                  "phone": "+593123458475",
                  "agent_id": 17418
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 54c999a6b24ee3e9970606e030874031
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
                  "customer_id": 25760,
                  "message_count": 1,
                  "last_interaction": "2021-05-23T17:17:15.280Z",
                  "first_name": "Benito",
                  "last_name": "Márquez",
                  "email": "giovannapfeffer@quigley.co",
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
            Api-Key: a2f5d9c34e3f3e6c78883fa7cd9dacd1
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
