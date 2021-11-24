// Class for api tags
class Apis {
  static const String _prodID = '4142611';
  static const String _prodSEC = '82afcdd4b99abce2591a7e685afe7f06';
  static const String _sndID = '425359';
  static const String _sndSEC = '42d8e74e6a0215331158b69911865a9f';
  static const String _pubID = '145227';
  static const String _pubSEC = '12f071174cb7eb79d4aac5bc2f07563f';

  static const String auth =
      'pl/standard/user/oauth/authorize?grant_type=client_credentials&client_id=$_sndID&client_secret=$_sndSEC';
  static const String methods = 'api/v2_1/paymethods/';
  static const String order = 'api/v2_1/orders/';
}

// class Apis {
//   static const String users = '/users';
// }
