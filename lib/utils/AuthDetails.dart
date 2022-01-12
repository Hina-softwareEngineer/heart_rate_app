class AuthDetails {
  String? sId;
  String? username;
  String? email;
  String? phone;
  String? createdAt;
  String? accessToken;
  String? tokenType;

  AuthDetails(
      {this.sId,
      this.username,
      this.email,
      this.phone,
      this.createdAt,
      this.accessToken,
      this.tokenType});

  AuthDetails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    username = json['username'];
    email = json['email'];
    phone = json['phone'];
    createdAt = json['created_at'];
    accessToken = json['access_token'];
    tokenType = json['token_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['username'] = this.username;
    data['email'] = this.email;
    data['phone'] = this.phone;
    data['created_at'] = this.createdAt;
    data['access_token'] = this.accessToken;
    data['token_type'] = this.tokenType;
    return data;
  }
}
