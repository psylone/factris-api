# Business assumptions

## Contracts endpoint

- Each contract considered unique in terms of attributes: `number`, `start_date` and `end_date`

- If there is surrounding existing contract, then a new contract becomes inactive. It can be easily changed to something other, for example to return an error in this case

## Fees endpoint

- For fetching contract two invoice dates considered: `issue_date` and `due_date`

- If there are a few suitable contracts the contract with the latest `end_date` (or without `end_date`) will be fetched

- Not sure about invoices, where do they come from and whether they stored. So decided to keep all incoming invoices because it's often better to store data than not. It alse can be used for analytical purposes

- Decided to use `Invoice` model only as data object. In other words, all calculations take place in `Fees::CalculateService`. If there will be need for improving performance, we can use caching or additional data layer

# Architecture

The main idea of the project architecture is to keep independent layers of abstraction. It's very convenient, easy to read code and write tests

All responses conforms [JSON:API](jsonapi.org/) specification.

Main layers of abstraction are:

- Controllers (`app/controllers`)

- Parameters validation contracts (`app/contracts`). Technically these contracts can be used anywhere with the help of `Validations` concern

- Services (`app/services`). Service is a callable object with strict interface defined in `BasicService` module. It also utilizes `dry-initializer` for convenient and more safe service object initialization

- Serializers (`app/serializers`)

- Models (`app/models`). Mostly models are used as just data objects. All business logic goes to Services

There is also `ApiErrors` concern for central error handling in controllers. This module uses `ErrorSerializer` which helps to render JSON:API compatible errors from the array of messages or from the model object

# API

## Contracts

Create a new contract:

`POST /api/v1/contracts`

Payload:

- `number [String]` required
- `start_date [Date]` required
- `fixed_fee [Numeric]` required
- `days_included [Integer]` required
- `additional_fee [Numeric]` required
- `active [Boolean]` optional
- `end_date [Date]` optional

Example:

```
curl -X POST 'localhost:3000/api/v1/contracts' -H 'Content-Type: application/json' -d '{
  "number": "A11",
  "start_date": "2020-02-18",
  "fixed_fee": 0.02,
  "days_included": 14,
  "additional_fee": 0.001
}'
```

Response:

```json
{
  "data": {
    "id": "4",
    "type": "contract",
    "attributes": {
      "number": "A11",
      "active": true,
      "start_date": "2020-02-17",
      "end_date": null,
      "fixed_fee": "0.02",
      "days_included": 14,
      "additional_fee": "0.001"
    }
  }
}
```

## Fees

Calculate fees:

`POST /api/v1/fees`

Payload:

- `number [String]` required
- `issue_date [Date]` required
- `due_date [Date]` required
- `purchase_date [Date]` required
- `amount [Numeric]` required
- `paid_date [Date]` optional

Example:

```
curl -X POST 'localhost:3000/api/v1/fees' -H 'Content-Type: application/json' -d '{
  "number": "A10",
  "issue_date": "2019-01-01",
  "due_date": "2019-01-15",
  "paid_date": "2019-01-20",
  "purchase_date": "2019-01-05",
  "amount": 1000.00
}'
```

Response:

```json
{ "meta": { "fee": 22.0 } }
```
