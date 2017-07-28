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
| External Id | Text(255,unique)  | | | Unique External Id (BR Name) |
| Description  | Text(255)  | | | Short Description of Business Role |
| Entry Logic  | LongTextArea(31k)  | | | Entry Logic e.g. AND, OR, {0} AND {2} AND NOT({3}) |
| Is Active?  | Checkbox  | | :heavy_check_mark: | Determines if BR is active or not |


### Business Role Entry

| Field | Type  | Required | Default | Description  |
|------|------|---|---|--------|
| Name  | Text(80,unique)  | :heavy_check_mark:  | | Short Name of BR Entry |
| Business Role  | Master-Detail(Business Role)  | :heavy_check_mark:  | | |
| Key | Text(255,unique)  | :heavy_check_mark: | | Name of User Field or Custom Handler |
| Type | Picklist  | :heavy_check_mark: | Field | Values: 'Field', 'ApexHandler' |
| Operator | Picklist | :heavy_check_mark: | '=' | Values: '=', '*=', '^=', '$=', '>', '>=', '<', '<='|
| Value | LongTextArea(31k) | | | Entry value |

### Business Role Assignment

| Field | Type  | Required | Default | Description  |
|------|------|---|---|--------|
| Name  | Text(80)  | :heavy_check_mark:  | | API Name of Assigned Record e.g. Permission Set API Name |
| External Id | Text(255,unique)  | | | Unique External Id (BR Name + '_' + Type + '_' + Name) |
| Business Role  | Master-Detail(Business Role)  | :heavy_check_mark:  | | |
| Type | Picklist  | :heavy_check_mark: | PermissionSet | Values: 'PermissionSet', 'Queue', 'Group', 'UserRole', 'Profile' |
| Is Active?  | Checkbox  | | :heavy_check_mark: | Determines if BR Assignment is active or not |

### User Business Role Assignment (BR and User junction object)

| Field | Type  | Required | Default | Description  |
|------|------|---|---|--------|
| User | Master-Detail(User)  | :heavy_check_mark:  | | |
| Business Role | Master-Detail(Business Role)  | :heavy_check_mark: | | |
| External Id | Text(255,unique)  | | | Unique External Id (User Id + '_' + BR Name) |
| Is Manual?  | Checkbox  | | :heavy_check_mark: | Determines if BR was assigned manuall or automatically |
| Is Active?  | Checkbox  | | :heavy_check_mark: | Determines if BR is active for given user (manuall managed) |

## Features

### Define Business Role

### User Auto-Assignment

### Business Roles Tab