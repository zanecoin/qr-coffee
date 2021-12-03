import 'package:qr_coffee/api/retrofit/api_client.dart';
import 'package:dio/dio.dart';

launchGateway() async {
  final client =
      await ApiClient(Dio(BaseOptions(contentType: "application/json")));
  final response = await client.getToken();

  print(response.code);
  print(response.meta);
  // final response = await client.getToken();
  // final access = await response.code;
  // print(access);
}
