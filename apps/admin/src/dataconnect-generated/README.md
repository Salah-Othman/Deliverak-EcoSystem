# Generated TypeScript README
This README will guide you through the process of using the generated JavaScript SDK package for the connector `example`. It will also provide examples on how to use your generated SDK to call your Data Connect queries and mutations.

***NOTE:** This README is generated alongside the generated SDK. If you make changes to this file, they will be overwritten when the SDK is regenerated.*

# Table of Contents
- [**Overview**](#generated-javascript-readme)
- [**Accessing the connector**](#accessing-the-connector)
  - [*Connecting to the local Emulator*](#connecting-to-the-local-emulator)
- [**Queries**](#queries)
  - [*GetUser*](#getuser)
  - [*ListUsers*](#listusers)
  - [*GetVendor*](#getvendor)
  - [*ListVendors*](#listvendors)
  - [*GetOrder*](#getorder)
  - [*ListMyOrders*](#listmyorders)
  - [*GetDelivery*](#getdelivery)
  - [*ListDeliveries*](#listdeliveries)
  - [*GetProduct*](#getproduct)
  - [*ListProducts*](#listproducts)
- [**Mutations**](#mutations)
  - [*CreateUser*](#createuser)
  - [*UpdateUser*](#updateuser)
  - [*DeleteUser*](#deleteuser)
  - [*CreateVendor*](#createvendor)
  - [*UpdateVendor*](#updatevendor)
  - [*DeleteVendor*](#deletevendor)
  - [*CreateOrder*](#createorder)
  - [*UpdateOrder*](#updateorder)
  - [*DeleteOrder*](#deleteorder)
  - [*CreateDelivery*](#createdelivery)
  - [*UpdateDelivery*](#updatedelivery)
  - [*DeleteDelivery*](#deletedelivery)
  - [*CreateProduct*](#createproduct)
  - [*UpdateProduct*](#updateproduct)
  - [*DeleteProduct*](#deleteproduct)

# Accessing the connector
A connector is a collection of Queries and Mutations. One SDK is generated for each connector - this SDK is generated for the connector `example`. You can find more information about connectors in the [Data Connect documentation](https://firebase.google.com/docs/data-connect#how-does).

You can use this generated SDK by importing from the package `@dataconnect/generated` as shown below. Both CommonJS and ESM imports are supported.

You can also follow the instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#set-client).

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
```

## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code.
You can also follow the emulator instructions from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#instrument-clients).

```typescript
import { connectDataConnectEmulator, getDataConnect } from 'firebase/data-connect';
import { connectorConfig } from '@dataconnect/generated';

const dataConnect = getDataConnect(connectorConfig);
connectDataConnectEmulator(dataConnect, 'localhost', 9399);
```

After it's initialized, you can call your Data Connect [queries](#queries) and [mutations](#mutations) from your generated SDK.

# Queries

There are two ways to execute a Data Connect Query using the generated Web SDK:
- Using a Query Reference function, which returns a `QueryRef`
  - The `QueryRef` can be used as an argument to `executeQuery()`, which will execute the Query and return a `QueryPromise`
- Using an action shortcut function, which returns a `QueryPromise`
  - Calling the action shortcut function will execute the Query and return a `QueryPromise`

The following is true for both the action shortcut function and the `QueryRef` function:
- The `QueryPromise` returned will resolve to the result of the Query once it has finished executing
- If the Query accepts arguments, both the action shortcut function and the `QueryRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Query
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each query. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-queries).

## GetUser
You can execute the `GetUser` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getUser(options?: ExecuteQueryOptions): QueryPromise<GetUserData, undefined>;

interface GetUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetUserData, undefined>;
}
export const getUserRef: GetUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getUser(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<GetUserData, undefined>;

interface GetUserRef {
  ...
  (dc: DataConnect): QueryRef<GetUserData, undefined>;
}
export const getUserRef: GetUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getUserRef:
```typescript
const name = getUserRef.operationName;
console.log(name);
```

### Variables
The `GetUser` query has no variables.
### Return Type
Recall that executing the `GetUser` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetUserData {
  user?: {
    name: string;
    email: string;
    role: string;
  };
}
```
### Using `GetUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getUser } from '@dataconnect/generated';


// Call the `getUser()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getUser();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getUser(dataConnect);

console.log(data.user);

// Or, you can use the `Promise` API.
getUser().then((response) => {
  const data = response.data;
  console.log(data.user);
});
```

### Using `GetUser`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getUserRef } from '@dataconnect/generated';


// Call the `getUserRef()` function to get a reference to the query.
const ref = getUserRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getUserRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.user);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.user);
});
```

## ListUsers
You can execute the `ListUsers` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listUsers(options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;

interface ListUsersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListUsersData, undefined>;
}
export const listUsersRef: ListUsersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listUsers(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;

interface ListUsersRef {
  ...
  (dc: DataConnect): QueryRef<ListUsersData, undefined>;
}
export const listUsersRef: ListUsersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listUsersRef:
```typescript
const name = listUsersRef.operationName;
console.log(name);
```

### Variables
The `ListUsers` query has no variables.
### Return Type
Recall that executing the `ListUsers` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListUsersData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListUsersData {
  users: ({
    name: string;
    role: string;
  })[];
}
```
### Using `ListUsers`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listUsers } from '@dataconnect/generated';


// Call the `listUsers()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listUsers();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listUsers(dataConnect);

console.log(data.users);

// Or, you can use the `Promise` API.
listUsers().then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

### Using `ListUsers`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listUsersRef } from '@dataconnect/generated';


// Call the `listUsersRef()` function to get a reference to the query.
const ref = listUsersRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listUsersRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.users);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.users);
});
```

## GetVendor
You can execute the `GetVendor` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getVendor(vars: GetVendorVariables, options?: ExecuteQueryOptions): QueryPromise<GetVendorData, GetVendorVariables>;

interface GetVendorRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetVendorVariables): QueryRef<GetVendorData, GetVendorVariables>;
}
export const getVendorRef: GetVendorRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getVendor(dc: DataConnect, vars: GetVendorVariables, options?: ExecuteQueryOptions): QueryPromise<GetVendorData, GetVendorVariables>;

interface GetVendorRef {
  ...
  (dc: DataConnect, vars: GetVendorVariables): QueryRef<GetVendorData, GetVendorVariables>;
}
export const getVendorRef: GetVendorRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getVendorRef:
```typescript
const name = getVendorRef.operationName;
console.log(name);
```

### Variables
The `GetVendor` query requires an argument of type `GetVendorVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetVendorVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetVendor` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetVendorData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetVendorData {
  vendor?: {
    name: string;
    address: string;
    owner: {
      name: string;
    };
  };
}
```
### Using `GetVendor`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getVendor, GetVendorVariables } from '@dataconnect/generated';

// The `GetVendor` query requires an argument of type `GetVendorVariables`:
const getVendorVars: GetVendorVariables = {
  id: ..., 
};

// Call the `getVendor()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getVendor(getVendorVars);
// Variables can be defined inline as well.
const { data } = await getVendor({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getVendor(dataConnect, getVendorVars);

console.log(data.vendor);

// Or, you can use the `Promise` API.
getVendor(getVendorVars).then((response) => {
  const data = response.data;
  console.log(data.vendor);
});
```

### Using `GetVendor`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getVendorRef, GetVendorVariables } from '@dataconnect/generated';

// The `GetVendor` query requires an argument of type `GetVendorVariables`:
const getVendorVars: GetVendorVariables = {
  id: ..., 
};

// Call the `getVendorRef()` function to get a reference to the query.
const ref = getVendorRef(getVendorVars);
// Variables can be defined inline as well.
const ref = getVendorRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getVendorRef(dataConnect, getVendorVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.vendor);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.vendor);
});
```

## ListVendors
You can execute the `ListVendors` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listVendors(options?: ExecuteQueryOptions): QueryPromise<ListVendorsData, undefined>;

interface ListVendorsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListVendorsData, undefined>;
}
export const listVendorsRef: ListVendorsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listVendors(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListVendorsData, undefined>;

interface ListVendorsRef {
  ...
  (dc: DataConnect): QueryRef<ListVendorsData, undefined>;
}
export const listVendorsRef: ListVendorsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listVendorsRef:
```typescript
const name = listVendorsRef.operationName;
console.log(name);
```

### Variables
The `ListVendors` query has no variables.
### Return Type
Recall that executing the `ListVendors` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListVendorsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListVendorsData {
  vendors: ({
    name: string;
    category?: string | null;
  })[];
}
```
### Using `ListVendors`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listVendors } from '@dataconnect/generated';


// Call the `listVendors()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listVendors();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listVendors(dataConnect);

console.log(data.vendors);

// Or, you can use the `Promise` API.
listVendors().then((response) => {
  const data = response.data;
  console.log(data.vendors);
});
```

### Using `ListVendors`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listVendorsRef } from '@dataconnect/generated';


// Call the `listVendorsRef()` function to get a reference to the query.
const ref = listVendorsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listVendorsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.vendors);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.vendors);
});
```

## GetOrder
You can execute the `GetOrder` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getOrder(vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;

interface GetOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
}
export const getOrderRef: GetOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getOrder(dc: DataConnect, vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;

interface GetOrderRef {
  ...
  (dc: DataConnect, vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
}
export const getOrderRef: GetOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getOrderRef:
```typescript
const name = getOrderRef.operationName;
console.log(name);
```

### Variables
The `GetOrder` query requires an argument of type `GetOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetOrderVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetOrder` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetOrderData {
  order?: {
    status: string;
    totalAmount?: number | null;
    vendor: {
      name: string;
    };
  };
}
```
### Using `GetOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getOrder, GetOrderVariables } from '@dataconnect/generated';

// The `GetOrder` query requires an argument of type `GetOrderVariables`:
const getOrderVars: GetOrderVariables = {
  id: ..., 
};

// Call the `getOrder()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getOrder(getOrderVars);
// Variables can be defined inline as well.
const { data } = await getOrder({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getOrder(dataConnect, getOrderVars);

console.log(data.order);

// Or, you can use the `Promise` API.
getOrder(getOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order);
});
```

### Using `GetOrder`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getOrderRef, GetOrderVariables } from '@dataconnect/generated';

// The `GetOrder` query requires an argument of type `GetOrderVariables`:
const getOrderVars: GetOrderVariables = {
  id: ..., 
};

// Call the `getOrderRef()` function to get a reference to the query.
const ref = getOrderRef(getOrderVars);
// Variables can be defined inline as well.
const ref = getOrderRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getOrderRef(dataConnect, getOrderVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.order);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.order);
});
```

## ListMyOrders
You can execute the `ListMyOrders` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listMyOrders(options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;

interface ListMyOrdersRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyOrdersData, undefined>;
}
export const listMyOrdersRef: ListMyOrdersRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listMyOrders(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;

interface ListMyOrdersRef {
  ...
  (dc: DataConnect): QueryRef<ListMyOrdersData, undefined>;
}
export const listMyOrdersRef: ListMyOrdersRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listMyOrdersRef:
```typescript
const name = listMyOrdersRef.operationName;
console.log(name);
```

### Variables
The `ListMyOrders` query has no variables.
### Return Type
Recall that executing the `ListMyOrders` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListMyOrdersData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListMyOrdersData {
  orders: ({
    status: string;
    totalAmount?: number | null;
  })[];
}
```
### Using `ListMyOrders`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listMyOrders } from '@dataconnect/generated';


// Call the `listMyOrders()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listMyOrders();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listMyOrders(dataConnect);

console.log(data.orders);

// Or, you can use the `Promise` API.
listMyOrders().then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

### Using `ListMyOrders`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listMyOrdersRef } from '@dataconnect/generated';


// Call the `listMyOrdersRef()` function to get a reference to the query.
const ref = listMyOrdersRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listMyOrdersRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.orders);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.orders);
});
```

## GetDelivery
You can execute the `GetDelivery` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getDelivery(vars: GetDeliveryVariables, options?: ExecuteQueryOptions): QueryPromise<GetDeliveryData, GetDeliveryVariables>;

interface GetDeliveryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetDeliveryVariables): QueryRef<GetDeliveryData, GetDeliveryVariables>;
}
export const getDeliveryRef: GetDeliveryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getDelivery(dc: DataConnect, vars: GetDeliveryVariables, options?: ExecuteQueryOptions): QueryPromise<GetDeliveryData, GetDeliveryVariables>;

interface GetDeliveryRef {
  ...
  (dc: DataConnect, vars: GetDeliveryVariables): QueryRef<GetDeliveryData, GetDeliveryVariables>;
}
export const getDeliveryRef: GetDeliveryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getDeliveryRef:
```typescript
const name = getDeliveryRef.operationName;
console.log(name);
```

### Variables
The `GetDelivery` query requires an argument of type `GetDeliveryVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetDeliveryVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetDelivery` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetDeliveryData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetDeliveryData {
  delivery?: {
    status: string;
    estimatedArrival?: TimestampString | null;
    order: {
      id: UUIDString;
    } & Order_Key;
  };
}
```
### Using `GetDelivery`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getDelivery, GetDeliveryVariables } from '@dataconnect/generated';

// The `GetDelivery` query requires an argument of type `GetDeliveryVariables`:
const getDeliveryVars: GetDeliveryVariables = {
  id: ..., 
};

// Call the `getDelivery()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getDelivery(getDeliveryVars);
// Variables can be defined inline as well.
const { data } = await getDelivery({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getDelivery(dataConnect, getDeliveryVars);

console.log(data.delivery);

// Or, you can use the `Promise` API.
getDelivery(getDeliveryVars).then((response) => {
  const data = response.data;
  console.log(data.delivery);
});
```

### Using `GetDelivery`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getDeliveryRef, GetDeliveryVariables } from '@dataconnect/generated';

// The `GetDelivery` query requires an argument of type `GetDeliveryVariables`:
const getDeliveryVars: GetDeliveryVariables = {
  id: ..., 
};

// Call the `getDeliveryRef()` function to get a reference to the query.
const ref = getDeliveryRef(getDeliveryVars);
// Variables can be defined inline as well.
const ref = getDeliveryRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getDeliveryRef(dataConnect, getDeliveryVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.delivery);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.delivery);
});
```

## ListDeliveries
You can execute the `ListDeliveries` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listDeliveries(options?: ExecuteQueryOptions): QueryPromise<ListDeliveriesData, undefined>;

interface ListDeliveriesRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListDeliveriesData, undefined>;
}
export const listDeliveriesRef: ListDeliveriesRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listDeliveries(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListDeliveriesData, undefined>;

interface ListDeliveriesRef {
  ...
  (dc: DataConnect): QueryRef<ListDeliveriesData, undefined>;
}
export const listDeliveriesRef: ListDeliveriesRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listDeliveriesRef:
```typescript
const name = listDeliveriesRef.operationName;
console.log(name);
```

### Variables
The `ListDeliveries` query has no variables.
### Return Type
Recall that executing the `ListDeliveries` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListDeliveriesData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListDeliveriesData {
  deliveries: ({
    status: string;
    currentCoordinates?: string | null;
  })[];
}
```
### Using `ListDeliveries`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listDeliveries } from '@dataconnect/generated';


// Call the `listDeliveries()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listDeliveries();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listDeliveries(dataConnect);

console.log(data.deliveries);

// Or, you can use the `Promise` API.
listDeliveries().then((response) => {
  const data = response.data;
  console.log(data.deliveries);
});
```

### Using `ListDeliveries`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listDeliveriesRef } from '@dataconnect/generated';


// Call the `listDeliveriesRef()` function to get a reference to the query.
const ref = listDeliveriesRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listDeliveriesRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.deliveries);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.deliveries);
});
```

## GetProduct
You can execute the `GetProduct` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
getProduct(vars: GetProductVariables, options?: ExecuteQueryOptions): QueryPromise<GetProductData, GetProductVariables>;

interface GetProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductVariables): QueryRef<GetProductData, GetProductVariables>;
}
export const getProductRef: GetProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
getProduct(dc: DataConnect, vars: GetProductVariables, options?: ExecuteQueryOptions): QueryPromise<GetProductData, GetProductVariables>;

interface GetProductRef {
  ...
  (dc: DataConnect, vars: GetProductVariables): QueryRef<GetProductData, GetProductVariables>;
}
export const getProductRef: GetProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the getProductRef:
```typescript
const name = getProductRef.operationName;
console.log(name);
```

### Variables
The `GetProduct` query requires an argument of type `GetProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface GetProductVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `GetProduct` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `GetProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface GetProductData {
  product?: {
    name: string;
    price: number;
    vendor: {
      name: string;
    };
  };
}
```
### Using `GetProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, getProduct, GetProductVariables } from '@dataconnect/generated';

// The `GetProduct` query requires an argument of type `GetProductVariables`:
const getProductVars: GetProductVariables = {
  id: ..., 
};

// Call the `getProduct()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await getProduct(getProductVars);
// Variables can be defined inline as well.
const { data } = await getProduct({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await getProduct(dataConnect, getProductVars);

console.log(data.product);

// Or, you can use the `Promise` API.
getProduct(getProductVars).then((response) => {
  const data = response.data;
  console.log(data.product);
});
```

### Using `GetProduct`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, getProductRef, GetProductVariables } from '@dataconnect/generated';

// The `GetProduct` query requires an argument of type `GetProductVariables`:
const getProductVars: GetProductVariables = {
  id: ..., 
};

// Call the `getProductRef()` function to get a reference to the query.
const ref = getProductRef(getProductVars);
// Variables can be defined inline as well.
const ref = getProductRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = getProductRef(dataConnect, getProductVars);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.product);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.product);
});
```

## ListProducts
You can execute the `ListProducts` query using the following action shortcut function, or by calling `executeQuery()` after calling the following `QueryRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
listProducts(options?: ExecuteQueryOptions): QueryPromise<ListProductsData, undefined>;

interface ListProductsRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListProductsData, undefined>;
}
export const listProductsRef: ListProductsRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `QueryRef` function.
```typescript
listProducts(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListProductsData, undefined>;

interface ListProductsRef {
  ...
  (dc: DataConnect): QueryRef<ListProductsData, undefined>;
}
export const listProductsRef: ListProductsRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the listProductsRef:
```typescript
const name = listProductsRef.operationName;
console.log(name);
```

### Variables
The `ListProducts` query has no variables.
### Return Type
Recall that executing the `ListProducts` query returns a `QueryPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `ListProductsData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface ListProductsData {
  products: ({
    name: string;
    price: number;
  })[];
}
```
### Using `ListProducts`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, listProducts } from '@dataconnect/generated';


// Call the `listProducts()` function to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await listProducts();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await listProducts(dataConnect);

console.log(data.products);

// Or, you can use the `Promise` API.
listProducts().then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

### Using `ListProducts`'s `QueryRef` function

```typescript
import { getDataConnect, executeQuery } from 'firebase/data-connect';
import { connectorConfig, listProductsRef } from '@dataconnect/generated';


// Call the `listProductsRef()` function to get a reference to the query.
const ref = listProductsRef();

// You can also pass in a `DataConnect` instance to the `QueryRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = listProductsRef(dataConnect);

// Call `executeQuery()` on the reference to execute the query.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeQuery(ref);

console.log(data.products);

// Or, you can use the `Promise` API.
executeQuery(ref).then((response) => {
  const data = response.data;
  console.log(data.products);
});
```

# Mutations

There are two ways to execute a Data Connect Mutation using the generated Web SDK:
- Using a Mutation Reference function, which returns a `MutationRef`
  - The `MutationRef` can be used as an argument to `executeMutation()`, which will execute the Mutation and return a `MutationPromise`
- Using an action shortcut function, which returns a `MutationPromise`
  - Calling the action shortcut function will execute the Mutation and return a `MutationPromise`

The following is true for both the action shortcut function and the `MutationRef` function:
- The `MutationPromise` returned will resolve to the result of the Mutation once it has finished executing
- If the Mutation accepts arguments, both the action shortcut function and the `MutationRef` function accept a single argument: an object that contains all the required variables (and the optional variables) for the Mutation
- Both functions can be called with or without passing in a `DataConnect` instance as an argument. If no `DataConnect` argument is passed in, then the generated SDK will call `getDataConnect(connectorConfig)` behind the scenes for you.

Below are examples of how to use the `example` connector's generated functions to execute each mutation. You can also follow the examples from the [Data Connect documentation](https://firebase.google.com/docs/data-connect/web-sdk#using-mutations).

## CreateUser
You can execute the `CreateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface CreateUserRef {
  ...
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
}
export const createUserRef: CreateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createUserRef:
```typescript
const name = createUserRef.operationName;
console.log(name);
```

### Variables
The `CreateUser` mutation requires an argument of type `CreateUserVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateUserVariables {
  name: string;
  email: string;
  role: string;
}
```
### Return Type
Recall that executing the `CreateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateUserData {
  user_insert: User_Key;
}
```
### Using `CreateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createUser, CreateUserVariables } from '@dataconnect/generated';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  name: ..., 
  email: ..., 
  role: ..., 
};

// Call the `createUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createUser(createUserVars);
// Variables can be defined inline as well.
const { data } = await createUser({ name: ..., email: ..., role: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createUser(dataConnect, createUserVars);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
createUser(createUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

### Using `CreateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createUserRef, CreateUserVariables } from '@dataconnect/generated';

// The `CreateUser` mutation requires an argument of type `CreateUserVariables`:
const createUserVars: CreateUserVariables = {
  name: ..., 
  email: ..., 
  role: ..., 
};

// Call the `createUserRef()` function to get a reference to the mutation.
const ref = createUserRef(createUserVars);
// Variables can be defined inline as well.
const ref = createUserRef({ name: ..., email: ..., role: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createUserRef(dataConnect, createUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_insert);
});
```

## UpdateUser
You can execute the `UpdateUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateUser(vars?: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars?: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateUser(dc: DataConnect, vars?: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface UpdateUserRef {
  ...
  (dc: DataConnect, vars?: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
}
export const updateUserRef: UpdateUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateUserRef:
```typescript
const name = updateUserRef.operationName;
console.log(name);
```

### Variables
The `UpdateUser` mutation has an optional argument of type `UpdateUserVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateUserVariables {
  name?: string | null;
  phoneNumber?: string | null;
}
```
### Return Type
Recall that executing the `UpdateUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateUserData {
  user_update?: User_Key | null;
}
```
### Using `UpdateUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateUser, UpdateUserVariables } from '@dataconnect/generated';

// The `UpdateUser` mutation has an optional argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  name: ..., // optional
  phoneNumber: ..., // optional
};

// Call the `updateUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateUser(updateUserVars);
// Variables can be defined inline as well.
const { data } = await updateUser({ name: ..., phoneNumber: ..., });
// Since all variables are optional for this mutation, you can omit the `UpdateUserVariables` argument.
const { data } = await updateUser();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateUser(dataConnect, updateUserVars);

console.log(data.user_update);

// Or, you can use the `Promise` API.
updateUser(updateUserVars).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

### Using `UpdateUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateUserRef, UpdateUserVariables } from '@dataconnect/generated';

// The `UpdateUser` mutation has an optional argument of type `UpdateUserVariables`:
const updateUserVars: UpdateUserVariables = {
  name: ..., // optional
  phoneNumber: ..., // optional
};

// Call the `updateUserRef()` function to get a reference to the mutation.
const ref = updateUserRef(updateUserVars);
// Variables can be defined inline as well.
const ref = updateUserRef({ name: ..., phoneNumber: ..., });
// Since all variables are optional for this mutation, you can omit the `UpdateUserVariables` argument.
const ref = updateUserRef();

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateUserRef(dataConnect, updateUserVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_update);
});
```

## DeleteUser
You can execute the `DeleteUser` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteUser(): MutationPromise<DeleteUserData, undefined>;

interface DeleteUserRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (): MutationRef<DeleteUserData, undefined>;
}
export const deleteUserRef: DeleteUserRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteUser(dc: DataConnect): MutationPromise<DeleteUserData, undefined>;

interface DeleteUserRef {
  ...
  (dc: DataConnect): MutationRef<DeleteUserData, undefined>;
}
export const deleteUserRef: DeleteUserRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteUserRef:
```typescript
const name = deleteUserRef.operationName;
console.log(name);
```

### Variables
The `DeleteUser` mutation has no variables.
### Return Type
Recall that executing the `DeleteUser` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteUserData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteUserData {
  user_delete?: User_Key | null;
}
```
### Using `DeleteUser`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteUser } from '@dataconnect/generated';


// Call the `deleteUser()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteUser();

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteUser(dataConnect);

console.log(data.user_delete);

// Or, you can use the `Promise` API.
deleteUser().then((response) => {
  const data = response.data;
  console.log(data.user_delete);
});
```

### Using `DeleteUser`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteUserRef } from '@dataconnect/generated';


// Call the `deleteUserRef()` function to get a reference to the mutation.
const ref = deleteUserRef();

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteUserRef(dataConnect);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.user_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.user_delete);
});
```

## CreateVendor
You can execute the `CreateVendor` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createVendor(vars: CreateVendorVariables): MutationPromise<CreateVendorData, CreateVendorVariables>;

interface CreateVendorRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateVendorVariables): MutationRef<CreateVendorData, CreateVendorVariables>;
}
export const createVendorRef: CreateVendorRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createVendor(dc: DataConnect, vars: CreateVendorVariables): MutationPromise<CreateVendorData, CreateVendorVariables>;

interface CreateVendorRef {
  ...
  (dc: DataConnect, vars: CreateVendorVariables): MutationRef<CreateVendorData, CreateVendorVariables>;
}
export const createVendorRef: CreateVendorRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createVendorRef:
```typescript
const name = createVendorRef.operationName;
console.log(name);
```

### Variables
The `CreateVendor` mutation requires an argument of type `CreateVendorVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateVendorVariables {
  name: string;
  address: string;
  category?: string | null;
}
```
### Return Type
Recall that executing the `CreateVendor` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateVendorData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateVendorData {
  vendor_insert: Vendor_Key;
}
```
### Using `CreateVendor`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createVendor, CreateVendorVariables } from '@dataconnect/generated';

// The `CreateVendor` mutation requires an argument of type `CreateVendorVariables`:
const createVendorVars: CreateVendorVariables = {
  name: ..., 
  address: ..., 
  category: ..., // optional
};

// Call the `createVendor()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createVendor(createVendorVars);
// Variables can be defined inline as well.
const { data } = await createVendor({ name: ..., address: ..., category: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createVendor(dataConnect, createVendorVars);

console.log(data.vendor_insert);

// Or, you can use the `Promise` API.
createVendor(createVendorVars).then((response) => {
  const data = response.data;
  console.log(data.vendor_insert);
});
```

### Using `CreateVendor`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createVendorRef, CreateVendorVariables } from '@dataconnect/generated';

// The `CreateVendor` mutation requires an argument of type `CreateVendorVariables`:
const createVendorVars: CreateVendorVariables = {
  name: ..., 
  address: ..., 
  category: ..., // optional
};

// Call the `createVendorRef()` function to get a reference to the mutation.
const ref = createVendorRef(createVendorVars);
// Variables can be defined inline as well.
const ref = createVendorRef({ name: ..., address: ..., category: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createVendorRef(dataConnect, createVendorVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.vendor_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.vendor_insert);
});
```

## UpdateVendor
You can execute the `UpdateVendor` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateVendor(vars: UpdateVendorVariables): MutationPromise<UpdateVendorData, UpdateVendorVariables>;

interface UpdateVendorRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateVendorVariables): MutationRef<UpdateVendorData, UpdateVendorVariables>;
}
export const updateVendorRef: UpdateVendorRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateVendor(dc: DataConnect, vars: UpdateVendorVariables): MutationPromise<UpdateVendorData, UpdateVendorVariables>;

interface UpdateVendorRef {
  ...
  (dc: DataConnect, vars: UpdateVendorVariables): MutationRef<UpdateVendorData, UpdateVendorVariables>;
}
export const updateVendorRef: UpdateVendorRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateVendorRef:
```typescript
const name = updateVendorRef.operationName;
console.log(name);
```

### Variables
The `UpdateVendor` mutation requires an argument of type `UpdateVendorVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateVendorVariables {
  id: UUIDString;
  address?: string | null;
}
```
### Return Type
Recall that executing the `UpdateVendor` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateVendorData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateVendorData {
  vendor_update?: Vendor_Key | null;
}
```
### Using `UpdateVendor`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateVendor, UpdateVendorVariables } from '@dataconnect/generated';

// The `UpdateVendor` mutation requires an argument of type `UpdateVendorVariables`:
const updateVendorVars: UpdateVendorVariables = {
  id: ..., 
  address: ..., // optional
};

// Call the `updateVendor()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateVendor(updateVendorVars);
// Variables can be defined inline as well.
const { data } = await updateVendor({ id: ..., address: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateVendor(dataConnect, updateVendorVars);

console.log(data.vendor_update);

// Or, you can use the `Promise` API.
updateVendor(updateVendorVars).then((response) => {
  const data = response.data;
  console.log(data.vendor_update);
});
```

### Using `UpdateVendor`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateVendorRef, UpdateVendorVariables } from '@dataconnect/generated';

// The `UpdateVendor` mutation requires an argument of type `UpdateVendorVariables`:
const updateVendorVars: UpdateVendorVariables = {
  id: ..., 
  address: ..., // optional
};

// Call the `updateVendorRef()` function to get a reference to the mutation.
const ref = updateVendorRef(updateVendorVars);
// Variables can be defined inline as well.
const ref = updateVendorRef({ id: ..., address: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateVendorRef(dataConnect, updateVendorVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.vendor_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.vendor_update);
});
```

## DeleteVendor
You can execute the `DeleteVendor` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteVendor(vars: DeleteVendorVariables): MutationPromise<DeleteVendorData, DeleteVendorVariables>;

interface DeleteVendorRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteVendorVariables): MutationRef<DeleteVendorData, DeleteVendorVariables>;
}
export const deleteVendorRef: DeleteVendorRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteVendor(dc: DataConnect, vars: DeleteVendorVariables): MutationPromise<DeleteVendorData, DeleteVendorVariables>;

interface DeleteVendorRef {
  ...
  (dc: DataConnect, vars: DeleteVendorVariables): MutationRef<DeleteVendorData, DeleteVendorVariables>;
}
export const deleteVendorRef: DeleteVendorRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteVendorRef:
```typescript
const name = deleteVendorRef.operationName;
console.log(name);
```

### Variables
The `DeleteVendor` mutation requires an argument of type `DeleteVendorVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteVendorVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteVendor` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteVendorData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteVendorData {
  vendor_delete?: Vendor_Key | null;
}
```
### Using `DeleteVendor`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteVendor, DeleteVendorVariables } from '@dataconnect/generated';

// The `DeleteVendor` mutation requires an argument of type `DeleteVendorVariables`:
const deleteVendorVars: DeleteVendorVariables = {
  id: ..., 
};

// Call the `deleteVendor()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteVendor(deleteVendorVars);
// Variables can be defined inline as well.
const { data } = await deleteVendor({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteVendor(dataConnect, deleteVendorVars);

console.log(data.vendor_delete);

// Or, you can use the `Promise` API.
deleteVendor(deleteVendorVars).then((response) => {
  const data = response.data;
  console.log(data.vendor_delete);
});
```

### Using `DeleteVendor`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteVendorRef, DeleteVendorVariables } from '@dataconnect/generated';

// The `DeleteVendor` mutation requires an argument of type `DeleteVendorVariables`:
const deleteVendorVars: DeleteVendorVariables = {
  id: ..., 
};

// Call the `deleteVendorRef()` function to get a reference to the mutation.
const ref = deleteVendorRef(deleteVendorVars);
// Variables can be defined inline as well.
const ref = deleteVendorRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteVendorRef(dataConnect, deleteVendorVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.vendor_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.vendor_delete);
});
```

## CreateOrder
You can execute the `CreateOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface CreateOrderRef {
  ...
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
}
export const createOrderRef: CreateOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createOrderRef:
```typescript
const name = createOrderRef.operationName;
console.log(name);
```

### Variables
The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateOrderVariables {
  vendorId: UUIDString;
  status: string;
  totalAmount?: number | null;
}
```
### Return Type
Recall that executing the `CreateOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateOrderData {
  order_insert: Order_Key;
}
```
### Using `CreateOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createOrder, CreateOrderVariables } from '@dataconnect/generated';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  vendorId: ..., 
  status: ..., 
  totalAmount: ..., // optional
};

// Call the `createOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createOrder(createOrderVars);
// Variables can be defined inline as well.
const { data } = await createOrder({ vendorId: ..., status: ..., totalAmount: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createOrder(dataConnect, createOrderVars);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
createOrder(createOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

### Using `CreateOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createOrderRef, CreateOrderVariables } from '@dataconnect/generated';

// The `CreateOrder` mutation requires an argument of type `CreateOrderVariables`:
const createOrderVars: CreateOrderVariables = {
  vendorId: ..., 
  status: ..., 
  totalAmount: ..., // optional
};

// Call the `createOrderRef()` function to get a reference to the mutation.
const ref = createOrderRef(createOrderVars);
// Variables can be defined inline as well.
const ref = createOrderRef({ vendorId: ..., status: ..., totalAmount: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createOrderRef(dataConnect, createOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_insert);
});
```

## UpdateOrder
You can execute the `UpdateOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateOrder(vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;

interface UpdateOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
}
export const updateOrderRef: UpdateOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateOrder(dc: DataConnect, vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;

interface UpdateOrderRef {
  ...
  (dc: DataConnect, vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
}
export const updateOrderRef: UpdateOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateOrderRef:
```typescript
const name = updateOrderRef.operationName;
console.log(name);
```

### Variables
The `UpdateOrder` mutation requires an argument of type `UpdateOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateOrderVariables {
  id: UUIDString;
  status: string;
}
```
### Return Type
Recall that executing the `UpdateOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateOrderData {
  order_update?: Order_Key | null;
}
```
### Using `UpdateOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateOrder, UpdateOrderVariables } from '@dataconnect/generated';

// The `UpdateOrder` mutation requires an argument of type `UpdateOrderVariables`:
const updateOrderVars: UpdateOrderVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateOrder(updateOrderVars);
// Variables can be defined inline as well.
const { data } = await updateOrder({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateOrder(dataConnect, updateOrderVars);

console.log(data.order_update);

// Or, you can use the `Promise` API.
updateOrder(updateOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

### Using `UpdateOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateOrderRef, UpdateOrderVariables } from '@dataconnect/generated';

// The `UpdateOrder` mutation requires an argument of type `UpdateOrderVariables`:
const updateOrderVars: UpdateOrderVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateOrderRef()` function to get a reference to the mutation.
const ref = updateOrderRef(updateOrderVars);
// Variables can be defined inline as well.
const ref = updateOrderRef({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateOrderRef(dataConnect, updateOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_update);
});
```

## DeleteOrder
You can execute the `DeleteOrder` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteOrder(vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;

interface DeleteOrderRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
}
export const deleteOrderRef: DeleteOrderRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteOrder(dc: DataConnect, vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;

interface DeleteOrderRef {
  ...
  (dc: DataConnect, vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
}
export const deleteOrderRef: DeleteOrderRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteOrderRef:
```typescript
const name = deleteOrderRef.operationName;
console.log(name);
```

### Variables
The `DeleteOrder` mutation requires an argument of type `DeleteOrderVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteOrderVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteOrder` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteOrderData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteOrderData {
  order_delete?: Order_Key | null;
}
```
### Using `DeleteOrder`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteOrder, DeleteOrderVariables } from '@dataconnect/generated';

// The `DeleteOrder` mutation requires an argument of type `DeleteOrderVariables`:
const deleteOrderVars: DeleteOrderVariables = {
  id: ..., 
};

// Call the `deleteOrder()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteOrder(deleteOrderVars);
// Variables can be defined inline as well.
const { data } = await deleteOrder({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteOrder(dataConnect, deleteOrderVars);

console.log(data.order_delete);

// Or, you can use the `Promise` API.
deleteOrder(deleteOrderVars).then((response) => {
  const data = response.data;
  console.log(data.order_delete);
});
```

### Using `DeleteOrder`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteOrderRef, DeleteOrderVariables } from '@dataconnect/generated';

// The `DeleteOrder` mutation requires an argument of type `DeleteOrderVariables`:
const deleteOrderVars: DeleteOrderVariables = {
  id: ..., 
};

// Call the `deleteOrderRef()` function to get a reference to the mutation.
const ref = deleteOrderRef(deleteOrderVars);
// Variables can be defined inline as well.
const ref = deleteOrderRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteOrderRef(dataConnect, deleteOrderVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.order_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.order_delete);
});
```

## CreateDelivery
You can execute the `CreateDelivery` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createDelivery(vars: CreateDeliveryVariables): MutationPromise<CreateDeliveryData, CreateDeliveryVariables>;

interface CreateDeliveryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateDeliveryVariables): MutationRef<CreateDeliveryData, CreateDeliveryVariables>;
}
export const createDeliveryRef: CreateDeliveryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createDelivery(dc: DataConnect, vars: CreateDeliveryVariables): MutationPromise<CreateDeliveryData, CreateDeliveryVariables>;

interface CreateDeliveryRef {
  ...
  (dc: DataConnect, vars: CreateDeliveryVariables): MutationRef<CreateDeliveryData, CreateDeliveryVariables>;
}
export const createDeliveryRef: CreateDeliveryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createDeliveryRef:
```typescript
const name = createDeliveryRef.operationName;
console.log(name);
```

### Variables
The `CreateDelivery` mutation requires an argument of type `CreateDeliveryVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateDeliveryVariables {
  orderId: UUIDString;
  status: string;
}
```
### Return Type
Recall that executing the `CreateDelivery` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateDeliveryData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateDeliveryData {
  delivery_insert: Delivery_Key;
}
```
### Using `CreateDelivery`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createDelivery, CreateDeliveryVariables } from '@dataconnect/generated';

// The `CreateDelivery` mutation requires an argument of type `CreateDeliveryVariables`:
const createDeliveryVars: CreateDeliveryVariables = {
  orderId: ..., 
  status: ..., 
};

// Call the `createDelivery()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createDelivery(createDeliveryVars);
// Variables can be defined inline as well.
const { data } = await createDelivery({ orderId: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createDelivery(dataConnect, createDeliveryVars);

console.log(data.delivery_insert);

// Or, you can use the `Promise` API.
createDelivery(createDeliveryVars).then((response) => {
  const data = response.data;
  console.log(data.delivery_insert);
});
```

### Using `CreateDelivery`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createDeliveryRef, CreateDeliveryVariables } from '@dataconnect/generated';

// The `CreateDelivery` mutation requires an argument of type `CreateDeliveryVariables`:
const createDeliveryVars: CreateDeliveryVariables = {
  orderId: ..., 
  status: ..., 
};

// Call the `createDeliveryRef()` function to get a reference to the mutation.
const ref = createDeliveryRef(createDeliveryVars);
// Variables can be defined inline as well.
const ref = createDeliveryRef({ orderId: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createDeliveryRef(dataConnect, createDeliveryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.delivery_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.delivery_insert);
});
```

## UpdateDelivery
You can execute the `UpdateDelivery` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateDelivery(vars: UpdateDeliveryVariables): MutationPromise<UpdateDeliveryData, UpdateDeliveryVariables>;

interface UpdateDeliveryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateDeliveryVariables): MutationRef<UpdateDeliveryData, UpdateDeliveryVariables>;
}
export const updateDeliveryRef: UpdateDeliveryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateDelivery(dc: DataConnect, vars: UpdateDeliveryVariables): MutationPromise<UpdateDeliveryData, UpdateDeliveryVariables>;

interface UpdateDeliveryRef {
  ...
  (dc: DataConnect, vars: UpdateDeliveryVariables): MutationRef<UpdateDeliveryData, UpdateDeliveryVariables>;
}
export const updateDeliveryRef: UpdateDeliveryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateDeliveryRef:
```typescript
const name = updateDeliveryRef.operationName;
console.log(name);
```

### Variables
The `UpdateDelivery` mutation requires an argument of type `UpdateDeliveryVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateDeliveryVariables {
  id: UUIDString;
  status: string;
}
```
### Return Type
Recall that executing the `UpdateDelivery` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateDeliveryData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateDeliveryData {
  delivery_update?: Delivery_Key | null;
}
```
### Using `UpdateDelivery`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateDelivery, UpdateDeliveryVariables } from '@dataconnect/generated';

// The `UpdateDelivery` mutation requires an argument of type `UpdateDeliveryVariables`:
const updateDeliveryVars: UpdateDeliveryVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateDelivery()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateDelivery(updateDeliveryVars);
// Variables can be defined inline as well.
const { data } = await updateDelivery({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateDelivery(dataConnect, updateDeliveryVars);

console.log(data.delivery_update);

// Or, you can use the `Promise` API.
updateDelivery(updateDeliveryVars).then((response) => {
  const data = response.data;
  console.log(data.delivery_update);
});
```

### Using `UpdateDelivery`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateDeliveryRef, UpdateDeliveryVariables } from '@dataconnect/generated';

// The `UpdateDelivery` mutation requires an argument of type `UpdateDeliveryVariables`:
const updateDeliveryVars: UpdateDeliveryVariables = {
  id: ..., 
  status: ..., 
};

// Call the `updateDeliveryRef()` function to get a reference to the mutation.
const ref = updateDeliveryRef(updateDeliveryVars);
// Variables can be defined inline as well.
const ref = updateDeliveryRef({ id: ..., status: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateDeliveryRef(dataConnect, updateDeliveryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.delivery_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.delivery_update);
});
```

## DeleteDelivery
You can execute the `DeleteDelivery` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteDelivery(vars: DeleteDeliveryVariables): MutationPromise<DeleteDeliveryData, DeleteDeliveryVariables>;

interface DeleteDeliveryRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteDeliveryVariables): MutationRef<DeleteDeliveryData, DeleteDeliveryVariables>;
}
export const deleteDeliveryRef: DeleteDeliveryRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteDelivery(dc: DataConnect, vars: DeleteDeliveryVariables): MutationPromise<DeleteDeliveryData, DeleteDeliveryVariables>;

interface DeleteDeliveryRef {
  ...
  (dc: DataConnect, vars: DeleteDeliveryVariables): MutationRef<DeleteDeliveryData, DeleteDeliveryVariables>;
}
export const deleteDeliveryRef: DeleteDeliveryRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteDeliveryRef:
```typescript
const name = deleteDeliveryRef.operationName;
console.log(name);
```

### Variables
The `DeleteDelivery` mutation requires an argument of type `DeleteDeliveryVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteDeliveryVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteDelivery` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteDeliveryData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteDeliveryData {
  delivery_delete?: Delivery_Key | null;
}
```
### Using `DeleteDelivery`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteDelivery, DeleteDeliveryVariables } from '@dataconnect/generated';

// The `DeleteDelivery` mutation requires an argument of type `DeleteDeliveryVariables`:
const deleteDeliveryVars: DeleteDeliveryVariables = {
  id: ..., 
};

// Call the `deleteDelivery()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteDelivery(deleteDeliveryVars);
// Variables can be defined inline as well.
const { data } = await deleteDelivery({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteDelivery(dataConnect, deleteDeliveryVars);

console.log(data.delivery_delete);

// Or, you can use the `Promise` API.
deleteDelivery(deleteDeliveryVars).then((response) => {
  const data = response.data;
  console.log(data.delivery_delete);
});
```

### Using `DeleteDelivery`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteDeliveryRef, DeleteDeliveryVariables } from '@dataconnect/generated';

// The `DeleteDelivery` mutation requires an argument of type `DeleteDeliveryVariables`:
const deleteDeliveryVars: DeleteDeliveryVariables = {
  id: ..., 
};

// Call the `deleteDeliveryRef()` function to get a reference to the mutation.
const ref = deleteDeliveryRef(deleteDeliveryVars);
// Variables can be defined inline as well.
const ref = deleteDeliveryRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteDeliveryRef(dataConnect, deleteDeliveryVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.delivery_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.delivery_delete);
});
```

## CreateProduct
You can execute the `CreateProduct` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
createProduct(vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;

interface CreateProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
}
export const createProductRef: CreateProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
createProduct(dc: DataConnect, vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;

interface CreateProductRef {
  ...
  (dc: DataConnect, vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
}
export const createProductRef: CreateProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the createProductRef:
```typescript
const name = createProductRef.operationName;
console.log(name);
```

### Variables
The `CreateProduct` mutation requires an argument of type `CreateProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface CreateProductVariables {
  vendorId: UUIDString;
  name: string;
  price: number;
}
```
### Return Type
Recall that executing the `CreateProduct` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `CreateProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface CreateProductData {
  product_insert: Product_Key;
}
```
### Using `CreateProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, createProduct, CreateProductVariables } from '@dataconnect/generated';

// The `CreateProduct` mutation requires an argument of type `CreateProductVariables`:
const createProductVars: CreateProductVariables = {
  vendorId: ..., 
  name: ..., 
  price: ..., 
};

// Call the `createProduct()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await createProduct(createProductVars);
// Variables can be defined inline as well.
const { data } = await createProduct({ vendorId: ..., name: ..., price: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await createProduct(dataConnect, createProductVars);

console.log(data.product_insert);

// Or, you can use the `Promise` API.
createProduct(createProductVars).then((response) => {
  const data = response.data;
  console.log(data.product_insert);
});
```

### Using `CreateProduct`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, createProductRef, CreateProductVariables } from '@dataconnect/generated';

// The `CreateProduct` mutation requires an argument of type `CreateProductVariables`:
const createProductVars: CreateProductVariables = {
  vendorId: ..., 
  name: ..., 
  price: ..., 
};

// Call the `createProductRef()` function to get a reference to the mutation.
const ref = createProductRef(createProductVars);
// Variables can be defined inline as well.
const ref = createProductRef({ vendorId: ..., name: ..., price: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = createProductRef(dataConnect, createProductVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.product_insert);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.product_insert);
});
```

## UpdateProduct
You can execute the `UpdateProduct` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
updateProduct(vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;

interface UpdateProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
}
export const updateProductRef: UpdateProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
updateProduct(dc: DataConnect, vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;

interface UpdateProductRef {
  ...
  (dc: DataConnect, vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
}
export const updateProductRef: UpdateProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the updateProductRef:
```typescript
const name = updateProductRef.operationName;
console.log(name);
```

### Variables
The `UpdateProduct` mutation requires an argument of type `UpdateProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface UpdateProductVariables {
  id: UUIDString;
  price: number;
}
```
### Return Type
Recall that executing the `UpdateProduct` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `UpdateProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface UpdateProductData {
  product_update?: Product_Key | null;
}
```
### Using `UpdateProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, updateProduct, UpdateProductVariables } from '@dataconnect/generated';

// The `UpdateProduct` mutation requires an argument of type `UpdateProductVariables`:
const updateProductVars: UpdateProductVariables = {
  id: ..., 
  price: ..., 
};

// Call the `updateProduct()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await updateProduct(updateProductVars);
// Variables can be defined inline as well.
const { data } = await updateProduct({ id: ..., price: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await updateProduct(dataConnect, updateProductVars);

console.log(data.product_update);

// Or, you can use the `Promise` API.
updateProduct(updateProductVars).then((response) => {
  const data = response.data;
  console.log(data.product_update);
});
```

### Using `UpdateProduct`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, updateProductRef, UpdateProductVariables } from '@dataconnect/generated';

// The `UpdateProduct` mutation requires an argument of type `UpdateProductVariables`:
const updateProductVars: UpdateProductVariables = {
  id: ..., 
  price: ..., 
};

// Call the `updateProductRef()` function to get a reference to the mutation.
const ref = updateProductRef(updateProductVars);
// Variables can be defined inline as well.
const ref = updateProductRef({ id: ..., price: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = updateProductRef(dataConnect, updateProductVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.product_update);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.product_update);
});
```

## DeleteProduct
You can execute the `DeleteProduct` mutation using the following action shortcut function, or by calling `executeMutation()` after calling the following `MutationRef` function, both of which are defined in [dataconnect-generated/index.d.ts](./index.d.ts):
```typescript
deleteProduct(vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;

interface DeleteProductRef {
  ...
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
}
export const deleteProductRef: DeleteProductRef;
```
You can also pass in a `DataConnect` instance to the action shortcut function or `MutationRef` function.
```typescript
deleteProduct(dc: DataConnect, vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;

interface DeleteProductRef {
  ...
  (dc: DataConnect, vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
}
export const deleteProductRef: DeleteProductRef;
```

If you need the name of the operation without creating a ref, you can retrieve the operation name by calling the `operationName` property on the deleteProductRef:
```typescript
const name = deleteProductRef.operationName;
console.log(name);
```

### Variables
The `DeleteProduct` mutation requires an argument of type `DeleteProductVariables`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:

```typescript
export interface DeleteProductVariables {
  id: UUIDString;
}
```
### Return Type
Recall that executing the `DeleteProduct` mutation returns a `MutationPromise` that resolves to an object with a `data` property.

The `data` property is an object of type `DeleteProductData`, which is defined in [dataconnect-generated/index.d.ts](./index.d.ts). It has the following fields:
```typescript
export interface DeleteProductData {
  product_delete?: Product_Key | null;
}
```
### Using `DeleteProduct`'s action shortcut function

```typescript
import { getDataConnect } from 'firebase/data-connect';
import { connectorConfig, deleteProduct, DeleteProductVariables } from '@dataconnect/generated';

// The `DeleteProduct` mutation requires an argument of type `DeleteProductVariables`:
const deleteProductVars: DeleteProductVariables = {
  id: ..., 
};

// Call the `deleteProduct()` function to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await deleteProduct(deleteProductVars);
// Variables can be defined inline as well.
const { data } = await deleteProduct({ id: ..., });

// You can also pass in a `DataConnect` instance to the action shortcut function.
const dataConnect = getDataConnect(connectorConfig);
const { data } = await deleteProduct(dataConnect, deleteProductVars);

console.log(data.product_delete);

// Or, you can use the `Promise` API.
deleteProduct(deleteProductVars).then((response) => {
  const data = response.data;
  console.log(data.product_delete);
});
```

### Using `DeleteProduct`'s `MutationRef` function

```typescript
import { getDataConnect, executeMutation } from 'firebase/data-connect';
import { connectorConfig, deleteProductRef, DeleteProductVariables } from '@dataconnect/generated';

// The `DeleteProduct` mutation requires an argument of type `DeleteProductVariables`:
const deleteProductVars: DeleteProductVariables = {
  id: ..., 
};

// Call the `deleteProductRef()` function to get a reference to the mutation.
const ref = deleteProductRef(deleteProductVars);
// Variables can be defined inline as well.
const ref = deleteProductRef({ id: ..., });

// You can also pass in a `DataConnect` instance to the `MutationRef` function.
const dataConnect = getDataConnect(connectorConfig);
const ref = deleteProductRef(dataConnect, deleteProductVars);

// Call `executeMutation()` on the reference to execute the mutation.
// You can use the `await` keyword to wait for the promise to resolve.
const { data } = await executeMutation(ref);

console.log(data.product_delete);

// Or, you can use the `Promise` API.
executeMutation(ref).then((response) => {
  const data = response.data;
  console.log(data.product_delete);
});
```

