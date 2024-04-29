// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:goodeeps2/pages/home/main_page.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class BluetoothConnection extends StatefulWidget {
//   const BluetoothConnection({super.key});
//
//   @override
//   State<BluetoothConnection> createState() => _BluetoothConnectionState();
// }
//
// class _BluetoothConnectionState extends State<BluetoothConnection> {
//   double screen = 0;
//   // FlutterBluePlus flutterBlue = FlutterBluePlus
//   List<ScanResult> scanResults = [];
//   bool permGranted = true;
//   bool isScanning = false;
//   late SharedPreferences prefs;
//   bool isSearching = false;
//   String deviceID = "";
//
//   @override
//   void initState() {
//     super.initState();
//     initializePreferences();
//   }
//
//   // initialize shared preferences
//   void initializePreferences() async {
//     prefs = await SharedPreferences.getInstance();
//     checkPermissionsAndStartScan();
//   }
//
//   void checkPermissionsAndStartScan() async {
//     var status = await Permission.location.status;
//     if (status.isDenied) {
//       // Handle permission denied case
//     } else {
//       // Handle permission granted case
//       disconnectAllDevices();
//       deviceID = prefs.getString('deviceID') ?? "";
//       if (deviceID == "") {
//         startScan();
//       } else {
//         disconnectAllDevices();
//         BluetoothDevice device = BluetoothDevice.fromId(deviceID);
//         connectToDevice(device);
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     stopScan();
//     super.dispose();
//   }
//
//   void startScan() {
//     String desiredDeviceName = "Goo"; // only search for device starts with Goo
//     FlutterBluePlus.scanResults.listen((List<ScanResult> results) {
//       List<ScanResult> filteredResults = results
//           .where((result) => result.device.name.startsWith(desiredDeviceName))
//           .toList();
//       setState(() {
//         scanResults = filteredResults;
//       });
//     });
//
//     FlutterBluePlus.startScan();
//     setState(() {
//       isScanning = true;
//       isSearching = true;
//     });
//
//     Timer(Duration(seconds: 5), () {
//       stopScan();
//       setState(() {
//         isScanning = false;
//         isSearching = false;
//       });
//     });
//   }
//
//   void stopScan() {
//     FlutterBluePlus.stopScan();
//     setState(() {
//       isScanning = false;
//     });
//   }
//
//   void refreshDevices() {
//     if (!isScanning) {
//       setState(() {
//         scanResults.clear();
//       });
//       startScan();
//     }
//   }
//
//   void disconnectAllDevices() async {
//     List<BluetoothDevice> connectedDevices = await FlutterBluePlus.connectedDevices;
//     for (BluetoothDevice device in connectedDevices) {
//       device.disconnect();
//     }
//   }
//
//   void connectToDevice(BluetoothDevice device) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return Center(
//           child: CircularProgressIndicator(),
//         );
//       },
//     );
//
//     device
//         .connect(autoConnect: false, timeout: const Duration(seconds: 10))
//         .then((_) async {
//       prefs.setString('deviceID', device.id.toString());
//
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => MainPage(
//             connectedDevice: device,
//           ),
//         ),
//       );
//     }).catchError((error) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//         content:
//             Text(textScaleFactor: 0.8, 'Connecting fail. Please try again!'),
//       ));
//       print("error: $error");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     MediaQueryData mediaQueryData = MediaQuery.of(context);
//     if (mediaQueryData.orientation == Orientation.portrait) {
//       screen = MediaQuery.of(context).size.height;
//     } else {
//       screen = MediaQuery.of(context).size.width;
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(textScaleFactor: 0.8, "Device Connection"),
//         actions: [
//           if (isSearching)
//             Padding(
//               padding: EdgeInsets.all(10.0),
//               child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             )
//           else
//             IconButton(
//               icon: Icon(Icons.refresh),
//               onPressed: refreshDevices,
//             ),
//         ],
//       ),
//       body: Container(
//         padding: EdgeInsets.all(5),
//         child: ListView.builder(
//           itemCount: scanResults.length,
//           itemBuilder: (BuildContext context, int index) {
//             ScanResult scanResult = scanResults[index];
//             return ListTile(
//               title: Text(
//                 textScaleFactor: 0.8,
//                 scanResult.device.name,
//                 style: TextStyle(fontSize: screen * 0.02),
//               ),
//               subtitle: Text(
//                 textScaleFactor: 0.8,
//                 'Device ID: ${scanResult.device.id.toString()}',
//                 style: TextStyle(fontSize: screen * 0.015),
//               ),
//               onTap: () {
//                 connectToDevice(scanResult.device);
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
