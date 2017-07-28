# Business Role Management

## Intro

Business Role Management automates Salesforce User Access to Salesforce Platform. It is designed to configure assignments to:

* Queues
* Permission Set
* Profile
* Role
* Public Groups
* Chatter Groups
* Manager

## Data Model

### Business Role

| Field | Type  | Required | Default | Description  |
|------|------|---|---|--------|
| Name  | Text(80,unique)  | :heavy_check_mark:  | | Name of Business Rule |
| Entry Logic  | LongTextArea(31k)  | | | Entry Logic e.g. AND, OR, {0} AND {2} AND NOT({3}) |


### Business Role Entry

| Field | Type  | Required | Default | Description  |
|------|------|---|---|--------|
| Name  | Text(80,unique)  | :heavy_check_mark:  | | Short Name of BR Entry |
| Key | Text(255,unique)  | :heavy_check_mark: | | Name of User Field or Custom Handler |
| Type | Picklist  | :heavy_check_mark: | Field | Values: 'Field', 'ApexHandler' |
| Operator | Picklist | :heavy_check_mark: | '=' | Values: '=', '*=', '^=', '$=', '>', '>=', '<', '<='|
| Value | LongTextArea(31k) | | | Entry value |

### Business Role Assignment

## Features

### Define Business Role

### User Auto-Assignment

### Business Roles Tab