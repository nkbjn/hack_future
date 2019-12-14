import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensors/sensors.dart';
import "acceralation.dart" as acc;
import 'package:http/http.dart' as http;
import 'post.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math'as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:vibration/vibration.dart';



int step_sum = 0;
int step_now = 0;
String name = '';
double _direction;

double North = 45.0;
double West = 135.0;
double South = 225.0;
double East = 315.0;


//TODO サーバからはお宝があった場合true,お宝がなかった場合false
//TODO trueの場合のファンクションを考える


class MapPage extends StatefulWidget {

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {

  int distance = 0;
  bool get = false;

  acc.Acceralation acceralation;
  List<acc.Acceralation> acceralation_list = [];

  List<double> _gyroscopeValues;

  List<StreamSubscription<dynamic>> _streamSubscriptions = <StreamSubscription<dynamic>>[];

  //x,y,z xは縦軸，yは横軸，zは奥行き
  //gyro : デバイスの回転を示す

  AnimationController _controller;
  int _radioValue;

  @override
  void initState() {
    super.initState();
    print("init start");
    getacceralation();
    Timer.periodic(const Duration(milliseconds: 500), getData);
    Timer.periodic(const Duration(milliseconds: 500), UserStepRequest);
  }

  @override
  Widget build(BuildContext context) {
    final List<String> gyroscopemeter = _gyroscopeValues?.map((double v) =>
        v.toStringAsFixed(1))?.toList();
    final String gyro_x = _gyroscopeValues[0].toStringAsFixed(2);
    final String gyro_y = _gyroscopeValues[1].toStringAsFixed(2);

    return MaterialApp(
        debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
              children: <Widget>[

                Container(
                    width: 300.0,
                    height: 300.0,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://media.qikeru.me/wp-content/uploads/2015/01/zahyou2.png"),
                        fit: BoxFit.cover,
                      ),
                    )
                ),

                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(30)),

                    Container(
                        width: 140.0,
                        height: 140.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(
                                "https://www.silhouette-illust.com/wp-content/uploads/2016/07/4515-300x300.jpg"),
                            fit: BoxFit.cover,
                          ),
                        )
                    ),

                    Padding(padding: EdgeInsets.all(10)),

                    Text("歩数 : ${step_sum}",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),

                
                Padding(padding: EdgeInsets.all(10)),

                Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(30)),

                    Container(
                      child: Image.asset("lib/images/tresure.jpg",
                    height: 100,
                    width: 100,
                    fit: BoxFit.fitWidth,)
                    ),

                    Padding(padding: EdgeInsets.all(10)),

                    Text("お宝までの距離 : ${distance}",
                    style: TextStyle(fontSize: 20),)
                  ],
                ),
              ],
            ),
        ),
      )
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  void getacceralation(){
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        acceralation = acc.Acceralation(event.x, event.y, event.z);
        acceralation_list.add(acceralation);
      });
    }));
    _streamSubscriptions.add(gyroscopeEvents.listen((GyroscopeEvent event) {
      setState(() {
        _gyroscopeValues = <double>[event.x, event.y, event.z];
      });
    }));
    _streamSubscriptions.add(FlutterCompass.events.listen((double direction){
      setState(() {
        _direction = direction;
        print(_direction);
      });
    }));
  }


  void getData(Timer timer){
    step_now = acc.getStep(acceralation_list);
    step_sum += step_now;
    acceralation_list.clear();
  }
}


Future<Post> fetchPost() async {
  final response =
  await http.get('https://jsonplaceholder.typicode.com/posts/1');

  if (response.statusCode == 200) {
    // If server returns an OK response, parse the JSON.
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that response was not OK, throw an error.
    throw Exception('Failed to load post');
  }
}

//TODO ngrokは更新される

void UserRegistRequest() async {
  String url = "http://d11f9a85.ngrok.io/location/update";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({'name':'user_1','x':3,'y':4,'step':1});
  http.Response resp = await http.post(url, headers: headers, body: body);

  if (resp.statusCode != 200) {
    return;
  }
//  print(json.decode(resp.body));
//  print(resp.body);
}


//これでサーバにデータを送信
void UserStepRequest(Timer timer) async {
  String url = "http://e739fe18.ngrok.io/location/update";
  Map<String, String> headers = {'content-type': 'application/json'};
  String body = json.encode({'name':name,'step':step_now, 'direction':getDirection(_direction)});
  http.Response resp = await http.post(url, headers: headers, body: body);
  if (resp.statusCode != 200) {
    return;
  }
  print(json.decode(resp.body));
//  print(resp.body);
}

void SetUserNameInMap(String username){
  name = username;
  print('User name is set ${name} in Map');
}

String getDirection(double dir){
  if(North <= dir && dir < West) return 'n';
  else if(West <= dir && dir < South) return 'w';
  else if(South <= dir && dir < East) return 's';
  else return 'e';
}
