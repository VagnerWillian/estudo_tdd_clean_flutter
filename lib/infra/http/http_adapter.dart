import 'dart:convert';
import 'package:http/http.dart';

import '../../data/http/http_client.dart';
import '../../helpers/helpers.exports.dart';

class HttpAdapter implements HttpClient{
  final Client client;
  HttpAdapter(this.client);

  @override
  Future<Map<String, dynamic>?> request({required String url, required String method, Map? body})async{
    final headers = {
      "content-type": "application/json",
      "accept": "application/json",
    };
    var response = Response('', 500);
    if(method=='post'){
      response = await client.post(Uri.parse(url), headers: headers, body: body);
    }
    return _handleResponse(response);
  }

  Map<String, dynamic>? _handleResponse(Response response){
    if(response.statusCode==200){
      return response.body.isEmpty ? null : json.decode(response.body);
    }else if(response.statusCode==204){
      return null;
    }else if(response.statusCode==400){
      throw HttpError.badRequest;
    }else if(response.statusCode==401){
      throw HttpError.unauthorized;
    }else if(response.statusCode==403){
      throw HttpError.forbidden;
    }else if(response.statusCode==404){
      throw HttpError.notFound;
    }else{
      throw HttpError.serverError;
    }
  }
}