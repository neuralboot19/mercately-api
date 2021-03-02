

# Group Agents


## Agents [/retailers/api/v1/agents]
Documentation of agents resources

### Get agents [GET /retailers/api/v1/agents]


+ Request returns a list of agents
**GET**&nbsp;&nbsp;`/retailers/api/v1/agents`

    + Headers

            Slug: test-connection
            Api-Key: 582bc7b42f1d8eb99c350495b23fa17c
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "agents": [
                {
                  "id": 7165,
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
    + id: `10126` (number, required)

+ Request updates a customer
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/10126`

    + Headers

            Slug: test-connection
            Api-Key: 1a2f408a79958759989a9e160514ff72
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
**PUT**&nbsp;&nbsp;`/retailers/api/v1/customers/10127`

    + Headers

            Slug: test-connection
            Api-Key: fcfcfc717f778ad50fad3589142502e3
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            customer[first_name]=Juan&customer[last_name]=Campos&customer[email]=juan%40email.com&customer[phone]=%2B12036534789&customer[notes]=New+notes&customer[address]=Calle+5&customer[city]=Fort+Worth&customer[state]=TX&customer[zip_code]=76106&customer[agent_id]=7164

+ Response 200

    + Headers

            Content-Type: application/json; charset=utf-8

    + Body

            {
              "message": "Customer updated successfully"
            }

# Group Notifications


## Notifications [/retailers/api/v1/whatsapp/send_notification_by_id]
Documentation of notifications resources

### Send a notification by ID [POST /retailers/api/v1/whatsapp/send_notification_by_id]


+ Request returns 400 - Bad Request
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: 3140e4822cf27e898878f6b9024aff84
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
            Api-Key: 6426b1f0db332c8ae49866fd78b0efab
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
            Api-Key: d541e2b17f2e6ab0d0f6af0d17a52871
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
            Api-Key: 0a9159e9b76f4147a9197cc185fd18ca
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
                "created_time": "2021-03-02T15:33:07.742-04:00",
                "error": null
              }
            }

+ Request sends the notification, assigning the customer to the agent
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: fc27573d0b2cf93a44d3e4a7c9c6be0c
            Accept: text/xml,application/xml,application/xhtml+xml,text/html;q=0.9,text/plain;q=0.8,image/png,*/*;q=0.5
            Content-Type: application/x-www-form-urlencoded

    + Body

            phone_number=%2B593999999999&internal_id=997dd550-c8d8-4bf7-ad98-a5ac4844a1ed&template_params[]=test+1&template_params[]=test+2&template_params[]=test+3&agent_id=7188

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
                "created_time": "2021-03-02T15:33:07.854-04:00",
                "error": null
              }
            }

+ Request sends the notification, updating the customer info
**POST**&nbsp;&nbsp;`/retailers/api/v1/whatsapp/send_notification_by_id`

    + Headers

            Slug: test-connection
            Api-Key: fc4329ead3c17f3469c11939b88fa71f
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
                "created_time": "2021-03-02T15:33:07.955-04:00",
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
            Api-Key: c6c962eb8cc962d6189bf85629e11934
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
                  "customer_id": 10129,
                  "message_count": 1,
                  "last_interaction": "2021-03-01T23:33:05.599Z",
                  "first_name": "Marilu",
                  "last_name": "Espinal",
                  "email": "donald@ruel.com",
                  "phone": "+593789584759",
                  "agent_id": 7166
                },
                {
                  "id": null,
                  "customer_id": 10130,
                  "message_count": 1,
                  "last_interaction": "2021-03-01T18:33:05.562Z",
                  "first_name": "Rosalia",
                  "last_name": "Longoria",
                  "email": "sanford@jacobskuhlman.org",
                  "phone": "+593452365897",
                  "agent_id": null
                },
                {
                  "id": null,
                  "customer_id": 10128,
                  "message_count": 1,
                  "last_interaction": "2021-03-01T14:33:05.435Z",
                  "first_name": "Joaquín",
                  "last_name": "Quiñónez",
                  "email": "seasonemard@pricechamplin.biz",
                  "phone": "+593123458475",
                  "agent_id": 7166
                }
              ]
            }

+ Request returns all unassigned whatsapp conversations from retailer
**GET**&nbsp;&nbsp;`/retailers/api/v1/whatsapp_conversations?page=1&results_per_page=100&unassigned=true`

    + Headers

            Slug: test-connection
            Api-Key: 24a4291e5c8779f2f4cab51db1b625dc
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
                  "customer_id": 10133,
                  "message_count": 1,
                  "last_interaction": "2021-03-01T18:33:05.768Z",
                  "first_name": "Rosalia",
                  "last_name": "Quiroz",
                  "email": "unajacobs@hodkiewiczpagac.biz",
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
            Api-Key: c39e4c1961a692797faefb49f7b5feca
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
