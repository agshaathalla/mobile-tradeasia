import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'dart:convert';
import 'dart:developer';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late String imageUrl;
  late String casNumber;
  late String hsCode;
  late String formula;
  late var description;
  late String iupacName;
  late String productName;
  late String packaging;
  late String industry1;
  late String industry2;
  late String briefOverview;
  late String manufacturingProcess;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    log('Memulai pengambilan data...');
    final response = await http.get(Uri.parse('https://tradeasia.sg//en/dipentene'));
    log('Response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      log("data: $data");
      final detailProduct = data['detail_product'];
      final List<dynamic> industries = data['list-industry'];
      final String description = data['detail_product']['description'];
      final document = parser.parse(description);
      final dom.Element? h2Elements = document.querySelector('h2');

      if (h2Elements != null) {
        dom.Element? strongElement = h2Elements.querySelector('strong');
        if (strongElement != null) {
          String briefOverview = strongElement.text;
          log('Brief Overview: $briefOverview');
        }
      }

        log("detailProduct: $detailProduct");

      setState(() {
        casNumber = detailProduct['cas_number'] ?? '';
        hsCode = detailProduct['hs_code'] ?? '';
        formula = detailProduct['formula'] ?? '';
        iupacName = detailProduct['iupac_name'] ?? '';
        productName = detailProduct['productname'] ?? '';
        packaging = detailProduct['packaging_name'] ?? '';
        imageUrl = 'https://tradeasia.sg' + (detailProduct['productimage'] ?? '');
        industry1 = industries[0]['industry_name'] ?? '';
        industry2 = industries[1]['industry_name'] ?? '';
        briefOverview = '';
        manufacturingProcess = '';

        final briefOverviewIndex = description.indexOf('<h2>Brief Overview</h2>');
        String briefOverviewText = '';
        if (briefOverviewIndex != -1) {
          final endOfBriefOverview = description.indexOf('<h3>', briefOverviewIndex);
          briefOverviewText = description.substring(
            briefOverviewIndex + '<h2>Brief Overview</h2>'.length,
            endOfBriefOverview != -1 ? endOfBriefOverview : description.length,
          );
        }
        log("briefOverviewText: $briefOverviewText");

        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load data');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: _isLoading ? Center(child: CircularProgressIndicator()) : buildBody(),
      ),
    );
  }

  Widget buildBody() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          imageUrl.isNotEmpty
              ? Image.network(
            'https://chemtradea.chemtradeasia.com//images/product/dipentene.webp',
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          )
              : Container(),
          SizedBox(height: 20),
          Text(
            'CAS Number: $casNumber',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'HS Code: $hsCode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Formula: $formula',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Tambahkan logika untuk tombol di sini
                },
                child: Text('Download TDS'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Tambahkan logika untuk tombol di sini
                },
                child: Text('Download MSDS'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          buildInfoRow('IUPAC Name', iupacName),
          buildInfoRow('Appearance', 'Clear Liquid'),
          buildInfoRow('Common Name', productName),
          buildInfoRow('Packaging', packaging),
          SizedBox(height: 20),
          Text(
            'Industry',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(industry1),
          Text(industry2),
          SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Brief Overview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(briefOverview, style: TextStyle(fontSize: 20)),
          Text(
            'Manufacturing Process',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(manufacturingProcess, style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Tambahkan logika untuk tombol di sini
                },
                child: Text('Send Inquiry'),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label : ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
