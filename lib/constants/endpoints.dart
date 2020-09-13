class Endpoints {
  static const FIREBASE = 'https://flutter-provider-8b77c.firebaseio.com';
  static const PRODUTCS = '${Endpoints.FIREBASE}/products';
  static const ORDERS = '${Endpoints.FIREBASE}/orders';
}

class EndpointUrlBuilder {
  // TODO: incorporate headers, query params
  // Products
  static String createProduct() => '${Endpoints.PRODUTCS}.json';
  static String readProducts() => '${Endpoints.PRODUTCS}.json';
  static String updateProduct(String id) => '${Endpoints.PRODUTCS}/$id.json';
  static String deleteProduct(String id) => '${Endpoints.PRODUTCS}/$id.json';
  // Orders
  static String createOrder() => '${Endpoints.ORDERS}.json';
  static String readOrders() => '${Endpoints.ORDERS}.json';
}