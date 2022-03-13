class Album {
  final String access_token;
  final String token_type;

  Album({required this.access_token, required this.token_type});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      access_token: json['access_token'],
      token_type: json['token_type'],
    );
  }
}

class Address {
  final String redirectUri;
  final String orderID;

  Address({required this.redirectUri, required this.orderID});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      redirectUri: json['redirectUri'],
      orderID: json['orderID'],
    );
  }
}
