import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

class GraphqlService {
  static final HttpLink httpLink = HttpLink(DotEnv.env['GQL_URL'],
      defaultHeaders: <String, String>{'api-key': DotEnv.env['GQL_HEADER']});
  final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(link: httpLink as Link, cache: GraphQLCache()));
}

final graphqlService = GraphqlService();
