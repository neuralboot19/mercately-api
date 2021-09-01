

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: 98854ddd2157446d01c8df80a6d48b9c
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 997,
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
            Api-Key: eac120bffc9dd6847f53272c239a5245
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
                  "id": "1724kvwms1409",
                  "first_name": "Ramón",
                  "last_name": "Villareal",
                  "email": "darennolan@gleichner.org",
                  "phone": "+593645-626-854",
                  "meli_customer_id": null,
                  "meli_nickname": null,
                  "id_type": "ruc",
                  "id_number": "760-35-1858",
                  "address": "Conjunto Jorge Naranjo 49 Puerta 994",
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
                      "web_id": "1724imdkh79"
                    }
                  ],
                  "custom_fields": [
                    {
                      "field_name": "porro",
                      "field_content:": "Test Field"
                    }
                  ]
                }
              ]
            }

### Get a customer [GET /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `1725xebpm1410` (string, required)

+ Request returns a customer
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/1725xebpm1410`

    + Headers

            Slug: test-connection
            Api-Key: c6f740d08d4fe82563ec025fa1cc4140
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer found successfully",
              "customer": {
                "id": "1725xebpm1410",
                "first_name": "Víctor",
                "last_name": "Cisneros",
                "email": "bradford@lakinkozey.biz",
                "phone": "+593677 233 590",
                "meli_customer_id": null,
                "meli_nickname": null,
                "id_type": "ruc",
                "id_number": "574-90-1563",
                "address": "Cuesta Susana Valencia 16",
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
            Api-Key: 6a92ed1fdcc0328618f29c93a12ca2ab
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
                "id": "1726aiudm1411",
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
                    "web_id": "1726glnfu80"
                  }
                ],
                "custom_fields": [
            
                ]
              }
            }

### Update a customer [PUT /retailers/api/v1/customers/{id}]

+ Parameters
    + id: `1727wmehy1412` (string, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/1727wmehy1412`

    + Headers

            Slug: test-connection
            Api-Key: fed7411b392bc8cd4bdeaac491c3edf3
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/1728donkp1413`

    + Headers

            Slug: test-connection
            Api-Key: 65794f013826dce612c3a73e28b973be
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
                "agent_id": 982
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/1729pwknx1414`

    + Headers

            Slug: test-connection
            Api-Key: d9a660b52e1b91058d1dcda63d712101
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
                "agent_id": 983,
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/1730jtxdz1415`

    + Headers

            Slug: test-connection
            Api-Key: 5f92e102204bd47dd421f4105e7d54f3
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
                "agent_id": 984,
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
            Api-Key: 5d64a3517c196845bcdfacae7bb29c20
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
                  "customer_id": 1417,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T23:05:51.578Z",
                  "first_name": "Daniel",
                  "last_name": "Viera",
                  "email": "rachelsmith@gusikowskioconner.net",
                  "agent_id": 985
                },
                {
                  "id": null,
                  "customer_id": 1418,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T18:05:51.482Z",
                  "first_name": "Alejandra",
                  "last_name": "Rivero",
                  "email": "leighgusikowski@herzogfranecki.biz",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 1416,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T14:05:51.312Z",
                  "first_name": "Gustavo",
                  "last_name": "Lira",
                  "email": "corazonkuhlman@ankunding.io",
                  "agent_id": 985
                }
              ]
            }

+ Request returns all unassigned messenger conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/messenger_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 7efd59e51cb102aaa9048ed6dd92e1b4
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
                  "customer_id": 1421,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T18:05:51.800Z",
                  "first_name": "Beatriz",
                  "last_name": "Jurado",
                  "email": "cleotillman@kling.biz",
                  "agent_id": null
                }
              ]
            }

### Get customer Messenger conversations [GET /retailers/api/v1/customers/{id}/messenger_conversations]

+ Parameters
    + id: `1733voxtq1422` (string, required)

+ Request returns customer Messenger conversations
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/1733voxtq1422/messenger_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: 2ef037df7237e57fc1f3500e854ecffb
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "messenger_conversations": [
                {
                  "text": "Rerum culpa tempora. Autem quaerat voluptate. Accusamus non ut.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "message_identifier": null,
                  "date_read": null,
                  "created_at": "2021-08-30T14:05:52.085Z",
                  "url": null
                },
                {
                  "text": "Voluptatem atque ut. Porro suscipit maiores. Iure laudantium et.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "message_identifier": null,
                  "date_read": null,
                  "created_at": "2021-08-30T14:05:52.085Z",
                  "url": null
                },
                {
                  "text": "Debitis dolorum non. Odio numquam ducimus. Eos quam inventore.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "message_identifier": null,
                  "date_read": null,
                  "created_at": "2021-08-30T14:05:52.085Z",
                  "url": null
                },
                {
                  "text": "Sit qui magnam. Recusandae et nemo. Est atque sed.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "message_identifier": null,
                  "date_read": null,
                  "created_at": "2021-08-30T14:05:52.085Z",
                  "url": null
                },
                {
                  "text": "Minus aut mollitia. Fuga asperiores voluptatum. Cumque et laborum.",
                  "sent_by_retailer": false,
                  "file_type": null,
                  "filename": null,
                  "sent_from_mercately": false,
                  "message_identifier": null,
                  "date_read": null,
                  "created_at": "2021-08-30T14:05:52.085Z",
                  "url": null
                }
              ],
              "total_pages": 1
            }

+ Request returns 404
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/not_found/messenger_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: b3409458be2a87fa270efb7f13aef6aa
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
            Api-Key: b55b0c394fc9c6b222379b9e32aea7dc
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
            Api-Key: b02a9a0f1ac79b2794f69e3d92653d79
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
            Api-Key: 13f64d0d1c339302385160005ed2d5c4
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
            Api-Key: c39d1bab2cfe407616e847f8468cae4b
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
            Api-Key: 246a752fcb793bd3faa85d92badce9da
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
                "created_time": "2021-08-31T15:05:56.687-04:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: bb849e44575f5667bbb51b665e979b33
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
              "agent_id": 1023
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
                "created_time": "2021-08-31T15:05:56.812-04:00",
                "error": null
              }
            }

+ Request sends the notification and include tags
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 960176a4347f94c8901257a09431be13
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
              "agent_id": 1025,
              "tags": [
                {
                  "name": "earum",
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
                "created_time": "2021-08-31T15:05:56.952-04:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: de1816e205e87225aae735ed52b3b551
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
                "created_time": "2021-08-31T15:05:57.057-04:00",
                "error": null
              }
            }

# Group Products


## Products [/retailers/api/v1/products/:id]
Documentation of product resources

### Get all products [GET /retailers/api/v1/products]


+ Request returns all products
**GET**&nbsp;&nbsp;`/retailers/api/v1/products?page=1`

    + Headers

            Slug: test-connection
            Api-Key: fc6d415da0db85a88a7368ae6c0e2115
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "total": 2,
              "total_pages": 1,
              "products": [
                {
                  "id": "1735qfudb327",
                  "title": "Product 2",
                  "price": "5.0",
                  "url": null,
                  "available_quantity": 2,
                  "description": "Product description 2",
                  "status": "active"
                },
                {
                  "id": "1735kfivg326",
                  "title": "Product 1",
                  "price": "10.5",
                  "url": null,
                  "available_quantity": 5,
                  "description": "Product description 1",
                  "status": "archived"
                }
              ]
            }

### Get a product [GET /retailers/api/v1/products/{id}]

+ Parameters
    + id: `1736fpevm328` (string, required)

+ Request returns a product
**GET**&nbsp;&nbsp;`/retailers/api/v1/products/1736fpevm328`

    + Headers

            Slug: test-connection
            Api-Key: 5f409c61d8d080da0eefbf9c1a14e58a
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Product found successfully",
              "product": {
                "id": "1736fpevm328",
                "title": "Product 1",
                "price": "10.5",
                "url": null,
                "available_quantity": 5,
                "description": "Product description 1",
                "status": "active"
              }
            }

### Create a product [POST /retailers/api/v1/products]


+ Request returns 422 - Unprocessable Entity
**POST**&nbsp;&nbsp;`/retailers/api/v1/products`

    + Headers

            Slug: test-connection
            Api-Key: 5a0be29f76ab0607caae80d45517cf28
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "product": {
                "title": "Product title",
                "available_quantity": 5
              }
            }

+ Response 422

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Error creating product",
              "errors": [
                "Price no puede estar vacío"
              ]
            }

+ Request returns 400 - Bad Request
**POST**&nbsp;&nbsp;`/retailers/api/v1/products`

    + Headers

            Slug: test-connection
            Api-Key: 98e93266523b4ffcff87ddaa94f1c83b
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "product": {
                "title": "Product title",
                "price": 100,
                "available_quantity": 5,
                "image_urls": [
                  "https://mercately.com/images/example.jpg",
                  "https://mercately.com/images/example2.png",
                  "https://mercately.com/images/example3.jpg",
                  "https://mercately.com/images/example4.png"
                ]
              }
            }

+ Response 400

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Maximum three (3) images allowed"
            }

+ Request creates the product successfully
**POST**&nbsp;&nbsp;`/retailers/api/v1/products`

    + Headers

            Slug: test-connection
            Api-Key: 359579bc095f4bf060dddbcd672552ca
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "product": {
                "title": "Product title",
                "price": 100,
                "available_quantity": 5,
                "url": "https://mercately.com/products/product_example",
                "description": "Description example",
                "image_urls": [
                  "https://mercately.com/images/example.jpg",
                  "https://mercately.com/images/example2.png"
                ]
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Product created successfully",
              "product": {
                "id": "1739blukt329",
                "title": "Product title",
                "price": "100.0",
                "url": "https://mercately.com/products/product_example",
                "available_quantity": 5,
                "description": "Description example",
                "status": "active"
              }
            }

### Update a product [PUT /retailers/api/v1/products/{id}]

+ Parameters
    + id: `1740agipw330` (string, required)

+ Request updates the product successfully
**PUT**&nbsp;&nbsp;`/retailers/api/v1/products/1740agipw330`

    + Headers

            Slug: test-connection
            Api-Key: efce519c74a237bbd514833c14f867e6
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "product": {
                "title": "Product title",
                "price": 100,
                "available_quantity": 7,
                "url": "https://mercately.com/products/product_example",
                "description": "Description example"
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Product updated successfully",
              "product": {
                "id": "1740agipw330",
                "title": "Product title",
                "price": "100.0",
                "url": "https://mercately.com/products/product_example",
                "available_quantity": 7,
                "description": "Description example",
                "status": "active"
              }
            }

+ Request archives the product
**PUT**&nbsp;&nbsp;`/retailers/api/v1/products/1741oxgdf331`

    + Headers

            Slug: test-connection
            Api-Key: 5a87e86136b8b7bae9223e0fcd73c0b0
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "product": {
                "status": "archived"
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Product updated successfully",
              "product": {
                "id": "1741oxgdf331",
                "title": "Product 1",
                "price": "10.5",
                "url": null,
                "available_quantity": 5,
                "description": "Product description 1",
                "status": "archived"
              }
            }

+ Request activates the product
**PUT**&nbsp;&nbsp;`/retailers/api/v1/products/1742gtunb332`

    + Headers

            Slug: test-connection
            Api-Key: 1881099789b0c1422d1b3655a1c94b3e
            Accept: application/json
            Content-Type: application/json

    + Body

            {
              "product": {
                "status": "active"
              }
            }

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Product updated successfully",
              "product": {
                "id": "1742gtunb332",
                "title": "Product 1",
                "price": "10.5",
                "url": null,
                "available_quantity": 5,
                "description": "Product description 1",
                "status": "active"
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
            Api-Key: c5d1480662d9f8d81e3a675500ac499e
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
                  "customer_id": 1427,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T23:05:53.545Z",
                  "first_name": "Rosario",
                  "last_name": "Puente",
                  "email": "antonia@marvin.info",
                  "phone": "+593789584759",
                  "agent_id": 998
                },
                {
                  "id": null,
                  "customer_id": 1428,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T18:05:53.504Z",
                  "first_name": "María Cristina",
                  "last_name": "Elizondo",
                  "email": "lowell@bradtke.name",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 1426,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T14:05:53.406Z",
                  "first_name": "Ana María",
                  "last_name": "Quesada",
                  "email": "mack@townegleichner.com",
                  "phone": "+593123458475",
                  "agent_id": 998
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: b12d13d6e9107b32ad1f59708d40c556
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
                  "customer_id": 1431,
                  "message_count": 1,
                  "last_interaction": "2021-08-30T18:05:53.746Z",
                  "first_name": "Ana",
                  "last_name": "Fernández",
                  "email": "sydney@pollichlueilwitz.com",
                  "phone": "+593452365897",
                  "agent_id": null
                }
              ]
            }

### Get customer WhatsApp conversations [GET /retailers/api/v1/customers/{id}/whatsapp_conversations]

+ Parameters
    + id: `1746obmdn1432` (string, required)

+ Request returns customer whatsapp conversations
**GET**&nbsp;&nbsp;`/retailers/api/v1/customers/1746obmdn1432/whatsapp_conversations?page=1`

    + Headers

            Slug: test-connection
            Api-Key: 536141262a4f95e7f14222201cf55ed9
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
                  "created_time": "2021-08-30T14:05:54.018Z",
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
                  "created_time": "2021-08-30T14:05:54.018Z",
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
                  "created_time": "2021-08-30T14:05:54.018Z",
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
                  "created_time": "2021-08-30T14:05:54.018Z",
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
                  "created_time": "2021-08-30T14:05:54.018Z",
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
            Api-Key: 4d92b729329faf04b66530720f616aeb
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
            Api-Key: 06515c8c7f7bde2bc26efd8f11853af7
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
