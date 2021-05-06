import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphqlService {
  static final HttpLink httpLink = HttpLink("https://api.wetayo.club/wetayo",
      defaultHeaders: <String, String>{
        'api_key': '662e0b9c-2786-42a4-b306-c17034d959a7'
      });
  final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(link: httpLink as Link, cache: GraphQLCache()));
}

final graphqlService = GraphqlService();
