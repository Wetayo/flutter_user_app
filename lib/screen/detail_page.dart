import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wetayo_app/model/bus_arrival.dart';
import 'package:wetayo_app/model/bus_route.dart';
import 'package:wetayo_app/model/station_routes.dart';
import 'dart:convert';
import 'package:xml2json/xml2json.dart';
import '../api/arrival_api.dart' as arrival_api;
//import '../api/route_api.dart' as route_api;
import '../api/stationRoute_api.dart' as route_api;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class DetailPage extends StatefulWidget {
  final String item;
  DetailPage({Key key, this.item}) : super(key: key);
  _DetailPage createState() => _DetailPage();
}

class _DetailPage extends State<DetailPage> {
  final CarouselController _controller = CarouselController();
  final Xml2Json xml2Json = Xml2Json();

  List<busArrival> _data = [];
  List<stationRoutes> _routesData = [];

  bool _isLoading = false;
  String routeName = '조회를 실패했습니다.';

  int checkError = 0;

  @override
  void initState() {
    super.initState();
    _getRoutesList();
    _getArrivalList();
    setState(() {
      checkError = 0;
    });
  }

  ///////////////////////////////////////////////////
  /*          routeId를 비교해 노선 정보 합치기          */
  ///////////////////////////////////////////////////
  String matchRoute(String _routeId) {
    for (var item in _routesData) {
      //print('plz>>${item.routeId}, prefix>>$_routeId');
      if (item.routeId.compareTo(_routeId) == 0) {
        //print('compare>>${item.routeId}, ${_routeId}');
        return item.routeName;
      }
    }
    print('end');
    return 'error';
  }

  ///////////////////////////////////////////////////
  /*               도착버스 조회 함수                  */
  ///////////////////////////////////////////////////
  _getArrivalList() async {
    String result = 'null';
    setState(() => _isLoading = true);

    //String station = _stationController.text;
    var response = await http.get(arrival_api.buildUrl(widget.item));
    String responseBody = response.body;
    xml2Json.parse(responseBody);
    var jsonString = xml2Json.toParker();
    //print('res >> $jsonString');

    var json = jsonDecode(jsonString);
    print(json);
    Map<String, dynamic> errorMessage = json['response']['msgHeader'];

    print('errorcode >> ${errorMessage['resultCode']}');
    if (errorMessage['resultCode'] != arrival_api.STATUS_OK) {
      setState(() {
        final String errMessage = errorMessage['resultMessage'];
        print('error >> $errMessage');

        _data = const [];
        _isLoading = false;
      });
      return;
    }

    List<dynamic> busArrivalList =
        json['response']['msgBody']['busArrivalList'];
    final int cnt = busArrivalList.length;
    print('cnt >> $cnt');

    List<busArrival> list = List.generate(cnt, (int i) {
      Map<String, dynamic> item = busArrivalList[i];
      print('check>>> ${busArrivalList[i]['routeId']}');
      result = matchRoute(busArrivalList[i]['routeId']);
      return busArrival(
        item['flag'],
        item['locationNo1'],
        item['locationNo2'],
        item['lowPlate1'],
        item['lowPlate2'],
        item['plateNo1'],
        item['plateNo2'],
        item['predictTime1'],
        item['predictTime2'],
        item['remainSeatCnt1'],
        item['remainSeatCnt2'],
        item['routeId'],
        item['staOrder'],
        item['stationId'],
        item['routeName'] = result,
      );
    });

    print('list >>> ${list[0].locationNo1}');

    setState(() {
      _data = list;
      _isLoading = false;

      //matchRoute();
      print(_data[0].routeName);
    });
  }

  ///////////////////////////////////////////////////
  /*                노선 리스트 조회                   */
  ///////////////////////////////////////////////////
  _getRoutesList() async {
    setState(() => _isLoading = true);

    //String station = _stationController.text;
    print('widget item >> ${widget.item}');
    var response = await http.get(route_api.buildUrl(widget.item));
    String responseBody = response.body;
    xml2Json.parse(responseBody);
    var jsonString = xml2Json.toParker();
    //print('res >> $jsonString');

    var json = jsonDecode(jsonString);
    print(json);
    Map<String, dynamic> errorMessage = json['response']['msgHeader'];

    print('errorcode >> ${errorMessage['resultCode']}');
    if (errorMessage['resultCode'] != arrival_api.STATUS_OK) {
      setState(() {
        final String errMessage = errorMessage['resultMessage'];
        print('error >> $errMessage');

        _data = const [];
        _isLoading = false;
      });
      return;
    }

    List<dynamic> stationRoutesList =
        json['response']['msgBody']['busRouteList'];
    final int cnt = stationRoutesList.length;
    print('route_cnt >> $cnt');

    List<stationRoutes> list = List.generate(cnt, (int i) {
      Map<String, dynamic> item = stationRoutesList[i];
      return stationRoutes(
        item['districtCd'],
        item['regionName'],
        item['routeId'],
        item['routeName'],
        item['routeTypeCd'],
        item['routeTypeName'],
        item['staOrder'],
      );
    });

    print('route_list >>> ${list[0].routeName}');

    setState(() {
      _routesData = list;
      print('routeTest >>>> $_routesData');
      _isLoading = false;
    });
  }

  ///////////////////////////////////////////////////
  /*                도착버스 Count                   */
  ///////////////////////////////////////////////////
  Widget countArriverBus(int index) {
    if (_data.length <= 0) {
      return Text('도착 정보가 없어요ㅠㅠ');
    } else {
      return Text(_data[index].routeName);
      Text(_data[index].predictTime1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Container(
                child: SafeArea(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Positioned(
                            child: AppBar(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                      Container(
                          child: CarouselSlider.builder(
                        itemCount: _data.length,
                        options: CarouselOptions(
                            aspectRatio: 1.2,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.vertical,
                            autoPlay: false),
                        carouselController: _controller,
                        itemBuilder: (context, index, idx) {
                          return GestureDetector(
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  //countArriverBus(index),
                                  if (_data.length > 0)
                                    Text(
                                      _data[index].routeName,
                                      style: TextStyle(
                                          fontSize: 65.0,
                                          fontWeight: FontWeight.bold),
                                      semanticsLabel:
                                          '${_data[index].routeName} 번 버스',
                                    ),
                                  if (_data.length > 0)
                                    Text(
                                      '도착까지 ${_data[index].predictTime1} 분',
                                      style: TextStyle(
                                          fontSize: 50.0,
                                          fontWeight: FontWeight.bold),
                                      semanticsLabel:
                                          '도착까지 ${_data[index].predictTime1} 분 남았습니다.',
                                    )
                                  else
                                    Text('도착 버스 정보가 없습니다.')
                                ],
                              ),
                            ),
                            onTap: () => print('tap test'),
                          );
                        },
                      )),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.08,
                            padding: EdgeInsets.all(10.0),
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9.0)),
                                onPressed: () => _controller.previousPage(),
                                child: Text(
                                  '<-',
                                  semanticsLabel: "이전",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold),
                                ),
                                color: Color(0xff184C88)),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10.0),
                            width: MediaQuery.of(context).size.width * 0.5,
                            height: MediaQuery.of(context).size.height * 0.08,
                            padding: EdgeInsets.all(10.0),
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9.0)),
                              onPressed: () => _controller.nextPage(),
                              child: Text('->',
                                  semanticsLabel: "다음",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold)),
                              color: Color(0xff184C88),
                            ),
                          )
                        ],
                      ),
                      Mutation(
                        options: MutationOptions(
                            document: gql(
                                """mutation CreateRide(\$stationId : Int!, \$routeId : Int!){
                      createRide(stationId : \$stationId, routeId : \$routeId){
                        stationId
                        routeId
                      }
                    }"""),
                            update:
                                (GraphQLDataProxy cache, QueryResult result) {
                              return cache;
                            },
                            onError: (OperationException error) {
                              setState(() {
                                checkError = 1;
                              });
                              _simpleAlert(context, error);
                            },
                            onCompleted: (dynamic resultData) {
                              _simpleAlert2(context, "000");
                            }
                            //Navigator.of(context).pop(),
                            ),
                        builder: (
                          RunMutation runMutation,
                          QueryResult result,
                        ) {
                          return Container(
                            margin: EdgeInsets.only(
                                left: 20.0, right: 20.0, top: 15.0),
                            width: double.infinity,
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                ),
                                onPressed: () {
                                  if (_data[_controller.getIndex()].routeName ==
                                      null) {
                                    print('error');
                                  }
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (BuildContext context) {
                                        return Semantics(
                                          child: AlertDialog(
                                            semanticLabel:
                                                '탑승 예약 알림창   ${_data[_controller.getIndex()].routeName}번 버스를 탑승 하시겠습니까?     탑승을 희망하시면 확인을 눌러주세요.',
                                            title: Text('탑승 예약'),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  Text(
                                                      '${_data[_controller.getIndex()].routeName}번 버스를 탑승 하시겠습니까?'),
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[
                                              FlatButton(
                                                  child: Text('확인'),
                                                  onPressed: () => {
                                                        runMutation(
                                                          {
                                                            'stationId':
                                                                999999999,
                                                            'routeId':
                                                                999999999,
                                                          },
                                                        ),
                                                        if (checkError == 1)
                                                          {
                                                            Navigator.popUntil(
                                                                context,
                                                                ModalRoute
                                                                    .withName(
                                                                        '/'))
                                                          }
                                                        else
                                                          {
                                                            // Navigator.of(context)
                                                            //     .pop()
                                                          }
                                                      }),
                                              FlatButton(
                                                child: Text('취소'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ],
                                          ),
                                        );
                                      });
                                },
                                child: Container(
                                  child: Text(
                                    '탑승 예약',
                                    style: TextStyle(
                                        fontSize: 55.0,
                                        fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                color: Color(0xff184C88)),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ));
  }
}

void _simpleAlert(BuildContext context, OperationException error) =>
    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        Map<String, dynamic> errorcode = error.graphqlErrors.single.extensions;
        print(errorcode['errorCode'].toString());
        print(error.graphqlErrors);
        return Semantics(
          child: AlertDialog(
            semanticLabel: MutationError(errorcode['errorCode'].toString()) +
                '확인 버튼을 눌러주세요.',
            title: Text(MutationError(errorcode['errorCode'].toString())),
            actions: <Widget>[
              SimpleDialogOption(
                child: const Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.popUntil(context, ModalRoute.withName('/'));
                },
              )
            ],
          ),
        );
      },
    );

void _simpleAlert2(BuildContext context, String error) =>
    showDialog<AlertDialog>(
      context: context,
      builder: (BuildContext context) {
        //Map<String, dynamic> errorcode = error.graphqlErrors.single.extensions;
        //print(errorcode['errorCode'].toString());
        //print(error.graphqlErrors);
        return AlertDialog(
          semanticLabel: MutationError(error) + '확인 버튼을 눌러주세요.',
          title: Text(MutationError(error)),
          actions: <Widget>[
            SimpleDialogOption(
              child: const Text('확인'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.popUntil(context, ModalRoute.withName('/'));
              },
            )
          ],
        );
      },
    );

String MutationError(String errorCode) {
  if (errorCode == '430') {
    return "이미 승차예약이 있어요.";
  }
  if (errorCode == '000') {
    return "예약에 성공했어요.";
  } else {
    return "접근이 거부되었습니다.";
  }
}
