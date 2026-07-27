import { ConnectorConfig, DataConnect, QueryRef, QueryPromise, ExecuteQueryOptions, MutationRef, MutationPromise, DataConnectSettings } from 'firebase/data-connect';

export const connectorConfig: ConnectorConfig;
export const dataConnectSettings: DataConnectSettings;

export type TimestampString = string;
export type UUIDString = string;
export type Int64String = string;
export type DateString = string;




export interface CreateDeliveryData {
  delivery_insert: Delivery_Key;
}

export interface CreateDeliveryVariables {
  orderId: UUIDString;
  status: string;
}

export interface CreateOrderData {
  order_insert: Order_Key;
}

export interface CreateOrderVariables {
  vendorId: UUIDString;
  status: string;
  totalAmount?: number | null;
}

export interface CreateProductData {
  product_insert: Product_Key;
}

export interface CreateProductVariables {
  vendorId: UUIDString;
  name: string;
  price: number;
}

export interface CreateUserData {
  user_insert: User_Key;
}

export interface CreateUserVariables {
  name: string;
  email: string;
  role: string;
}

export interface CreateVendorData {
  vendor_insert: Vendor_Key;
}

export interface CreateVendorVariables {
  name: string;
  address: string;
  category?: string | null;
}

export interface DeleteDeliveryData {
  delivery_delete?: Delivery_Key | null;
}

export interface DeleteDeliveryVariables {
  id: UUIDString;
}

export interface DeleteOrderData {
  order_delete?: Order_Key | null;
}

export interface DeleteOrderVariables {
  id: UUIDString;
}

export interface DeleteProductData {
  product_delete?: Product_Key | null;
}

export interface DeleteProductVariables {
  id: UUIDString;
}

export interface DeleteUserData {
  user_delete?: User_Key | null;
}

export interface DeleteVendorData {
  vendor_delete?: Vendor_Key | null;
}

export interface DeleteVendorVariables {
  id: UUIDString;
}

export interface Delivery_Key {
  id: UUIDString;
  __typename?: 'Delivery_Key';
}

export interface GetDeliveryData {
  delivery?: {
    status: string;
    estimatedArrival?: TimestampString | null;
    order: {
      id: UUIDString;
    } & Order_Key;
  };
}

export interface GetDeliveryVariables {
  id: UUIDString;
}

export interface GetOrderData {
  order?: {
    status: string;
    totalAmount?: number | null;
    vendor: {
      name: string;
    };
  };
}

export interface GetOrderVariables {
  id: UUIDString;
}

export interface GetProductData {
  product?: {
    name: string;
    price: number;
    vendor: {
      name: string;
    };
  };
}

export interface GetProductVariables {
  id: UUIDString;
}

export interface GetUserData {
  user?: {
    name: string;
    email: string;
    role: string;
  };
}

export interface GetVendorData {
  vendor?: {
    name: string;
    address: string;
    owner: {
      name: string;
    };
  };
}

export interface GetVendorVariables {
  id: UUIDString;
}

export interface ListDeliveriesData {
  deliveries: ({
    status: string;
    currentCoordinates?: string | null;
  })[];
}

export interface ListMyOrdersData {
  orders: ({
    status: string;
    totalAmount?: number | null;
  })[];
}

export interface ListProductsData {
  products: ({
    name: string;
    price: number;
  })[];
}

export interface ListUsersData {
  users: ({
    name: string;
    role: string;
  })[];
}

export interface ListVendorsData {
  vendors: ({
    name: string;
    category?: string | null;
  })[];
}

export interface Order_Key {
  id: UUIDString;
  __typename?: 'Order_Key';
}

export interface Product_Key {
  id: UUIDString;
  __typename?: 'Product_Key';
}

export interface UpdateDeliveryData {
  delivery_update?: Delivery_Key | null;
}

export interface UpdateDeliveryVariables {
  id: UUIDString;
  status: string;
}

export interface UpdateOrderData {
  order_update?: Order_Key | null;
}

export interface UpdateOrderVariables {
  id: UUIDString;
  status: string;
}

export interface UpdateProductData {
  product_update?: Product_Key | null;
}

export interface UpdateProductVariables {
  id: UUIDString;
  price: number;
}

export interface UpdateUserData {
  user_update?: User_Key | null;
}

export interface UpdateUserVariables {
  name?: string | null;
  phoneNumber?: string | null;
}

export interface UpdateVendorData {
  vendor_update?: Vendor_Key | null;
}

export interface UpdateVendorVariables {
  id: UUIDString;
  address?: string | null;
}

export interface User_Key {
  id: UUIDString;
  __typename?: 'User_Key';
}

export interface Vendor_Key {
  id: UUIDString;
  __typename?: 'Vendor_Key';
}

interface CreateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateUserVariables): MutationRef<CreateUserData, CreateUserVariables>;
  operationName: string;
}
export const createUserRef: CreateUserRef;

export function createUser(vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;
export function createUser(dc: DataConnect, vars: CreateUserVariables): MutationPromise<CreateUserData, CreateUserVariables>;

interface UpdateUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars?: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars?: UpdateUserVariables): MutationRef<UpdateUserData, UpdateUserVariables>;
  operationName: string;
}
export const updateUserRef: UpdateUserRef;

export function updateUser(vars?: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;
export function updateUser(dc: DataConnect, vars?: UpdateUserVariables): MutationPromise<UpdateUserData, UpdateUserVariables>;

interface DeleteUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (): MutationRef<DeleteUserData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): MutationRef<DeleteUserData, undefined>;
  operationName: string;
}
export const deleteUserRef: DeleteUserRef;

export function deleteUser(): MutationPromise<DeleteUserData, undefined>;
export function deleteUser(dc: DataConnect): MutationPromise<DeleteUserData, undefined>;

interface GetUserRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<GetUserData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<GetUserData, undefined>;
  operationName: string;
}
export const getUserRef: GetUserRef;

export function getUser(options?: ExecuteQueryOptions): QueryPromise<GetUserData, undefined>;
export function getUser(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<GetUserData, undefined>;

interface ListUsersRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListUsersData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListUsersData, undefined>;
  operationName: string;
}
export const listUsersRef: ListUsersRef;

export function listUsers(options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;
export function listUsers(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListUsersData, undefined>;

interface CreateVendorRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateVendorVariables): MutationRef<CreateVendorData, CreateVendorVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateVendorVariables): MutationRef<CreateVendorData, CreateVendorVariables>;
  operationName: string;
}
export const createVendorRef: CreateVendorRef;

export function createVendor(vars: CreateVendorVariables): MutationPromise<CreateVendorData, CreateVendorVariables>;
export function createVendor(dc: DataConnect, vars: CreateVendorVariables): MutationPromise<CreateVendorData, CreateVendorVariables>;

interface UpdateVendorRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateVendorVariables): MutationRef<UpdateVendorData, UpdateVendorVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateVendorVariables): MutationRef<UpdateVendorData, UpdateVendorVariables>;
  operationName: string;
}
export const updateVendorRef: UpdateVendorRef;

export function updateVendor(vars: UpdateVendorVariables): MutationPromise<UpdateVendorData, UpdateVendorVariables>;
export function updateVendor(dc: DataConnect, vars: UpdateVendorVariables): MutationPromise<UpdateVendorData, UpdateVendorVariables>;

interface DeleteVendorRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteVendorVariables): MutationRef<DeleteVendorData, DeleteVendorVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteVendorVariables): MutationRef<DeleteVendorData, DeleteVendorVariables>;
  operationName: string;
}
export const deleteVendorRef: DeleteVendorRef;

export function deleteVendor(vars: DeleteVendorVariables): MutationPromise<DeleteVendorData, DeleteVendorVariables>;
export function deleteVendor(dc: DataConnect, vars: DeleteVendorVariables): MutationPromise<DeleteVendorData, DeleteVendorVariables>;

interface GetVendorRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetVendorVariables): QueryRef<GetVendorData, GetVendorVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetVendorVariables): QueryRef<GetVendorData, GetVendorVariables>;
  operationName: string;
}
export const getVendorRef: GetVendorRef;

export function getVendor(vars: GetVendorVariables, options?: ExecuteQueryOptions): QueryPromise<GetVendorData, GetVendorVariables>;
export function getVendor(dc: DataConnect, vars: GetVendorVariables, options?: ExecuteQueryOptions): QueryPromise<GetVendorData, GetVendorVariables>;

interface ListVendorsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListVendorsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListVendorsData, undefined>;
  operationName: string;
}
export const listVendorsRef: ListVendorsRef;

export function listVendors(options?: ExecuteQueryOptions): QueryPromise<ListVendorsData, undefined>;
export function listVendors(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListVendorsData, undefined>;

interface CreateOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateOrderVariables): MutationRef<CreateOrderData, CreateOrderVariables>;
  operationName: string;
}
export const createOrderRef: CreateOrderRef;

export function createOrder(vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;
export function createOrder(dc: DataConnect, vars: CreateOrderVariables): MutationPromise<CreateOrderData, CreateOrderVariables>;

interface UpdateOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateOrderVariables): MutationRef<UpdateOrderData, UpdateOrderVariables>;
  operationName: string;
}
export const updateOrderRef: UpdateOrderRef;

export function updateOrder(vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;
export function updateOrder(dc: DataConnect, vars: UpdateOrderVariables): MutationPromise<UpdateOrderData, UpdateOrderVariables>;

interface DeleteOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteOrderVariables): MutationRef<DeleteOrderData, DeleteOrderVariables>;
  operationName: string;
}
export const deleteOrderRef: DeleteOrderRef;

export function deleteOrder(vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;
export function deleteOrder(dc: DataConnect, vars: DeleteOrderVariables): MutationPromise<DeleteOrderData, DeleteOrderVariables>;

interface GetOrderRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetOrderVariables): QueryRef<GetOrderData, GetOrderVariables>;
  operationName: string;
}
export const getOrderRef: GetOrderRef;

export function getOrder(vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;
export function getOrder(dc: DataConnect, vars: GetOrderVariables, options?: ExecuteQueryOptions): QueryPromise<GetOrderData, GetOrderVariables>;

interface ListMyOrdersRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListMyOrdersData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListMyOrdersData, undefined>;
  operationName: string;
}
export const listMyOrdersRef: ListMyOrdersRef;

export function listMyOrders(options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;
export function listMyOrders(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListMyOrdersData, undefined>;

interface CreateDeliveryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateDeliveryVariables): MutationRef<CreateDeliveryData, CreateDeliveryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateDeliveryVariables): MutationRef<CreateDeliveryData, CreateDeliveryVariables>;
  operationName: string;
}
export const createDeliveryRef: CreateDeliveryRef;

export function createDelivery(vars: CreateDeliveryVariables): MutationPromise<CreateDeliveryData, CreateDeliveryVariables>;
export function createDelivery(dc: DataConnect, vars: CreateDeliveryVariables): MutationPromise<CreateDeliveryData, CreateDeliveryVariables>;

interface UpdateDeliveryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateDeliveryVariables): MutationRef<UpdateDeliveryData, UpdateDeliveryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateDeliveryVariables): MutationRef<UpdateDeliveryData, UpdateDeliveryVariables>;
  operationName: string;
}
export const updateDeliveryRef: UpdateDeliveryRef;

export function updateDelivery(vars: UpdateDeliveryVariables): MutationPromise<UpdateDeliveryData, UpdateDeliveryVariables>;
export function updateDelivery(dc: DataConnect, vars: UpdateDeliveryVariables): MutationPromise<UpdateDeliveryData, UpdateDeliveryVariables>;

interface DeleteDeliveryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteDeliveryVariables): MutationRef<DeleteDeliveryData, DeleteDeliveryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteDeliveryVariables): MutationRef<DeleteDeliveryData, DeleteDeliveryVariables>;
  operationName: string;
}
export const deleteDeliveryRef: DeleteDeliveryRef;

export function deleteDelivery(vars: DeleteDeliveryVariables): MutationPromise<DeleteDeliveryData, DeleteDeliveryVariables>;
export function deleteDelivery(dc: DataConnect, vars: DeleteDeliveryVariables): MutationPromise<DeleteDeliveryData, DeleteDeliveryVariables>;

interface GetDeliveryRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetDeliveryVariables): QueryRef<GetDeliveryData, GetDeliveryVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetDeliveryVariables): QueryRef<GetDeliveryData, GetDeliveryVariables>;
  operationName: string;
}
export const getDeliveryRef: GetDeliveryRef;

export function getDelivery(vars: GetDeliveryVariables, options?: ExecuteQueryOptions): QueryPromise<GetDeliveryData, GetDeliveryVariables>;
export function getDelivery(dc: DataConnect, vars: GetDeliveryVariables, options?: ExecuteQueryOptions): QueryPromise<GetDeliveryData, GetDeliveryVariables>;

interface ListDeliveriesRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListDeliveriesData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListDeliveriesData, undefined>;
  operationName: string;
}
export const listDeliveriesRef: ListDeliveriesRef;

export function listDeliveries(options?: ExecuteQueryOptions): QueryPromise<ListDeliveriesData, undefined>;
export function listDeliveries(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListDeliveriesData, undefined>;

interface CreateProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: CreateProductVariables): MutationRef<CreateProductData, CreateProductVariables>;
  operationName: string;
}
export const createProductRef: CreateProductRef;

export function createProduct(vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;
export function createProduct(dc: DataConnect, vars: CreateProductVariables): MutationPromise<CreateProductData, CreateProductVariables>;

interface UpdateProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: UpdateProductVariables): MutationRef<UpdateProductData, UpdateProductVariables>;
  operationName: string;
}
export const updateProductRef: UpdateProductRef;

export function updateProduct(vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;
export function updateProduct(dc: DataConnect, vars: UpdateProductVariables): MutationPromise<UpdateProductData, UpdateProductVariables>;

interface DeleteProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: DeleteProductVariables): MutationRef<DeleteProductData, DeleteProductVariables>;
  operationName: string;
}
export const deleteProductRef: DeleteProductRef;

export function deleteProduct(vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;
export function deleteProduct(dc: DataConnect, vars: DeleteProductVariables): MutationPromise<DeleteProductData, DeleteProductVariables>;

interface GetProductRef {
  /* Allow users to create refs without passing in DataConnect */
  (vars: GetProductVariables): QueryRef<GetProductData, GetProductVariables>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect, vars: GetProductVariables): QueryRef<GetProductData, GetProductVariables>;
  operationName: string;
}
export const getProductRef: GetProductRef;

export function getProduct(vars: GetProductVariables, options?: ExecuteQueryOptions): QueryPromise<GetProductData, GetProductVariables>;
export function getProduct(dc: DataConnect, vars: GetProductVariables, options?: ExecuteQueryOptions): QueryPromise<GetProductData, GetProductVariables>;

interface ListProductsRef {
  /* Allow users to create refs without passing in DataConnect */
  (): QueryRef<ListProductsData, undefined>;
  /* Allow users to pass in custom DataConnect instances */
  (dc: DataConnect): QueryRef<ListProductsData, undefined>;
  operationName: string;
}
export const listProductsRef: ListProductsRef;

export function listProducts(options?: ExecuteQueryOptions): QueryPromise<ListProductsData, undefined>;
export function listProducts(dc: DataConnect, options?: ExecuteQueryOptions): QueryPromise<ListProductsData, undefined>;

