# Basic Usage

Always prioritize using a supported framework over using the generated SDK
directly. Supported frameworks simplify the developer experience and help ensure
best practices are followed.





## Advanced Usage
If a user is not using a supported framework, they can use the generated SDK directly.

Here's an example of how to use it with the first 5 operations:

```js
import { createUser, updateUser, deleteUser, getUser, listUsers, createVendor, updateVendor, deleteVendor, getVendor, listVendors } from '@dataconnect/generated';


// Operation CreateUser:  For variables, look at type CreateUserVars in ../index.d.ts
const { data } = await CreateUser(dataConnect, createUserVars);

// Operation UpdateUser:  For variables, look at type UpdateUserVars in ../index.d.ts
const { data } = await UpdateUser(dataConnect, updateUserVars);

// Operation DeleteUser: 
const { data } = await DeleteUser(dataConnect);

// Operation GetUser: 
const { data } = await GetUser(dataConnect);

// Operation ListUsers: 
const { data } = await ListUsers(dataConnect);

// Operation CreateVendor:  For variables, look at type CreateVendorVars in ../index.d.ts
const { data } = await CreateVendor(dataConnect, createVendorVars);

// Operation UpdateVendor:  For variables, look at type UpdateVendorVars in ../index.d.ts
const { data } = await UpdateVendor(dataConnect, updateVendorVars);

// Operation DeleteVendor:  For variables, look at type DeleteVendorVars in ../index.d.ts
const { data } = await DeleteVendor(dataConnect, deleteVendorVars);

// Operation GetVendor:  For variables, look at type GetVendorVars in ../index.d.ts
const { data } = await GetVendor(dataConnect, getVendorVars);

// Operation ListVendors: 
const { data } = await ListVendors(dataConnect);


```