import 'package:flutter/material.dart';
import 'package:divkit/divkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DataFetcher(),
    );
  }
}

class DataFetcher extends StatefulWidget {
  const DataFetcher({super.key});

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

    try {
      final response = await http.get(
        Uri.http('84.201.148.80:8080', '/launch'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

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
                  ? errorWidget(errorMessage!)
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

  Widget errorWidget(String errorMessage) {
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
