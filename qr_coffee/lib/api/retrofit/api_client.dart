import 'package:dio/dio.dart';
import 'package:qr_coffee/api/model/data.dart';
import 'package:qr_coffee/api/retrofit/apis.dart';
import 'package:retrofit/http.dart';
part 'api_client.g.dart';

@RestApi(baseUrl: "https://secure.snd.payu.com/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  @POST(Apis.auth)
  Future<ResponseData> getToken();

  // @GET(Apis.methods)
  // Future<ResponseData> getMethods();

  // @POST(Apis.order)
  // Future<ResponseData> createOrder();
}

// @RestApi(baseUrl: "https://gorest.co.in/public-api/")
// abstract class ApiClient {
//   factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

//   @GET(Apis.users)
//   Future<ResponseData> getUsers();
// }
