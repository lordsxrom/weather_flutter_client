import 'package:flutter/material.dart';
import 'package:divkit/divkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DataFetcher(),
    );
  }
}

class DataFetcher extends StatefulWidget {
  @override
  _DataFetcherState createState() => _DataFetcherState();
}

class _DataFetcherState extends State<DataFetcher> {
  bool isLoading = false;
  String? errorMessage;
  DefaultDivKitData? data;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      data = null;
    });

    String domain;
    // if (Platform.isAndroid) {
    //   domain = '10.0.2.2:8080';
    // } else {
      // domain = '127.0.0.1:8080';
    // }
    domain = '84.201.148.80:8080';
    final url = Uri.http(domain, '/launch');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          data = DefaultDivKitData.fromJson(responseData);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data with statusCode: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Error: $error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EDF7),
      body: SafeArea(
        child: Center(
          child: isLoading
              ? const CircularProgressIndicator()
              : errorMessage != null
                  ? ErrorWidget(errorMessage!)
                  : DivKitView(
                      data: data!,
                      //customHandler: MyCustomHandler(), // DivCustomHandler?
                      //actionHandler: MyCustomActionHandler(), // DivActionHandler?
                      variableStorage: DefaultDivVariableStorage(),
                    ),
        ),
      ),
    );
  }

  Widget ErrorWidget(String errorMessage) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(errorMessage),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: fetchData,
          child: const Text("Retry"),
        ),
      ],
    );
  }
}