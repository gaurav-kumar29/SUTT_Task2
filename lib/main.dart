import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:flutter/services.dart';

import 'package:weather_app_mod/widgets/Weather.dart';
import 'package:weather_app_mod/widgets/WeatherItem.dart';
import 'package:weather_app_mod/models/WeatherData.dart';
import 'package:weather_app_mod/models/ForecastData.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Weather App',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MyHomePageState();
  }
}

class MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;
  Location _location = new Location();
  String error;
  var _textController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    loadWeather();
  }

  @override
  Widget build(BuildContext context) {
      return new Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            centerTitle: true,
            title: Text('Weather App'),
          ),
          body: Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: <Widget>[
                    new ListTile(
                      title: new TextField(
                        decoration: new InputDecoration.collapsed(
                            hintText: 'Enter the City'
                        ),
                        controller: _textController,
                      ),
                    ),
                    new ListTile(
                      title: new RaisedButton(
                        child: new Text("Search"),
                        onPressed: () {
                          var route = new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new NextPage(city: _textController.text),
                          );
                          Navigator.of(context).push(route);
                        },
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: weatherData != null ? Weather(weather: weatherData) : Container(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isLoading ? CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: new AlwaysStoppedAnimation(Colors.white),
                            ) : IconButton(
                              icon: new Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              onPressed: loadWeather,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 200.0,
                          child: forecastData != null ? ListView.builder(
                              itemCount: forecastData.list.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => WeatherItem(weather: forecastData.list.elementAt(index))
                          ) : Container(),
                        ),
                      ),
                    )

                  ]

              )
          )

      );

  }

  loadWeather() async {
    setState(() {
      isLoading = true;
    });

    LocationData location;

    try {
      location = (await _location.getLocation()); //as Map<String, double>;

      error = null;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'Permission denied - please ask the user to enable it from the app settings';
      }

      location = null;
    }

    if (location != null) {
      final lat = location.latitude;
      final lon = location.longitude;

      final weatherResponse = await http.get(
          'https://api.openweathermap.org/data/2.5/weather?APPID=fb6aa90384e0dcfba8149fc7dac999b1&lat=${lat
              .toString()}&lon=${lon.toString()}');
      final forecastResponse = await http.get(
          'https://api.openweathermap.org/data/2.5/forecast?APPID=fb6aa90384e0dcfba8149fc7dac999b1&lat=${lat
              .toString()}&lon=${lon.toString()}');

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        return setState(() {
          weatherData =
          new WeatherData.fromJson(jsonDecode(weatherResponse.body));
          forecastData =
          new ForecastData.fromJson(jsonDecode(forecastResponse.body));
          isLoading = false;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}

class NextPage extends StatefulWidget {
  final String city;


  NextPage({Key key, this.city}) : super(key: key);

  @override
  _NextPageState createState() => new _NextPageState();
}

class _NextPageState extends State<NextPage> {
  bool isLoading = false;
  WeatherData weatherData;
  ForecastData forecastData;


  @override
  void initState() {
    super.initState();

    cityloadWeather();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            centerTitle: true,
            title: Text('Weather App'),
          ),
          body: Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: weatherData != null ? Weather(weather: weatherData) : Container(),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: isLoading ? CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: new AlwaysStoppedAnimation(Colors.white),
                            ) : IconButton(
                              icon: new Icon(Icons.refresh),
                              tooltip: 'Refresh',
                              onPressed: cityloadWeather,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: 200.0,
                          child: forecastData != null ? ListView.builder(
                              itemCount: forecastData.list.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => WeatherItem(weather: forecastData.list.elementAt(index))
                          ) : Container(),
                        ),
                      ),
                    )
                  ]
              )
          )
      ),
    );
  }

  cityloadWeather() async {
    setState(() {
      isLoading = true;
    });


      final weatherResponse = await http.get(
          'https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&APPID=fb6aa90384e0dcfba8149fc7dac999b1');
      final forecastResponse = await http.get(
          'https://api.openweathermap.org/data/2.5/forecast?q=${widget.city}&APPID=fb6aa90384e0dcfba8149fc7dac999b1');

      if (weatherResponse.statusCode == 200 &&
          forecastResponse.statusCode == 200) {
        return setState(() {
          weatherData =
          new WeatherData.fromJson(jsonDecode(weatherResponse.body));
          forecastData =
          new ForecastData.fromJson(jsonDecode(forecastResponse.body));
          isLoading = false;
        });
      }


    setState(() {
      isLoading = false;
    });
  }
}