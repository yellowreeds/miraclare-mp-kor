import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:goodeeps2/screens/bruxism_history.dart';
import 'package:goodeeps2/update_screen.dart';
import 'package:http/http.dart' as http;
import 'package:goodeeps2/screens/account_confirmation_page.dart';
import 'package:goodeeps2/screens/bluetooth_connection_page.dart';
import 'package:goodeeps2/screens/login_page.dart';
import 'dart:convert';
import 'dart:collection';
import 'package:get_ip_address/get_ip_address.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hex/hex.dart';
import 'package:goodeeps2/calibration_screen.dart';
import 'package:goodeeps2/vibration_setting.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:bluetooth_enable_fork/bluetooth_enable_fork.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:goodeeps2/utils/divider_shape.dart';

class MainPage extends StatefulWidget {
  final BluetoothDevice? connectedDevice;
  const MainPage({super.key, required this.connectedDevice});

  @override
  State<MainPage> createState() => _MainPageState(connectedDevice);
}

class _MainPageState extends State<MainPage> {
  BluetoothDevice? connectedDevice;
  _MainPageState(this.connectedDevice);
  double screenHeight = 0;
  double screenWidth = 0;
  int _selectedIndex = 2;
  String versionNumber = "";
  String leadStatus = "";
  String bruxismStatus = "";
  int batteryValue = 0;
  int batteryShowValue = 0;
  String fileName = "";
  String vibrationValue = "";
  String ampValue = "";
  String result = "";
  int offsetValue = 0;
  int vthValue = 0;
  int timeFrame = 250;
  double vibIntensity = 0;
  List<String?> extractedData = [];
  List<List<dynamic>> tempData = [];
  List<ScanResult> scanResults = [];
  List<String> dataList = [];
  bool saveToBin = false;
  List<List<dynamic>> bufferDataForExporting = [];
  List<String> bufferDataForExportingFull = [];
  RegExp pattern = RegExp(r'(a5.{32}5a)');
  Queue<String> dataBuffer = Queue<String>();
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  StreamSubscription<List<int>>? _subscription;
  StreamSubscription<BluetoothDeviceState>? deviceStateSubscription;
  StreamSubscription<List<ScanResult>>? scanSubscription;
  BluetoothCharacteristic? readCharacteristic;
  BluetoothCharacteristic? uartCharacteristic;
  bool isScanning = false;
  late SharedPreferences prefs;
  bool noDeviceAvailable = true;
  bool isSearching = false;
  late String deviceID;
  double q1Value = 0;
  String q2Value = "";
  String q3Value = "";
  TextEditingController otherCommentController = TextEditingController();
  bool isBrux = false;
  bool bluetoothStatus = false;
  bool permGranted = false;
  bool logOutStatus = false;
  bool showImage1 = true;
  bool showImage2 = false;
  bool showImage3 = false;
  bool resultImage = false;
  bool chargingStatus = false;
  double _value = 0.0;
  late String? resultImageName;
  late String? resultText;
  late Timer? _timer1;
  late Timer? _timerResult;
  late Timer? _timer2;
  late Timer? _timer3;
  late Timer? _timerNew;
  late String? custUsername;
  String custName = "";
  List<int> evaluationAnswer = List<int>.filled(3, 0);
  late dynamic data;
  late String? osVersion = "";
  bool manualTurnOff = false;
  int selectedButtonIndex = -1;
  int vasTotal = 0;
  double fillValue = 0;
  int qCounter = 1;
  int counter = 0;
  bool isHelpOverlayVisible = false;
  int currentPage = 0;
  bool isSwitched = false;
  late bool calibrationDone = false;
  String latestBrEpisode = "";
  String highestBrMax = "";
  String latestData = "";

  // list and functions for help.
  final List<String> helpImages = [
    'assets/images/help1.png',
    'assets/images/help2.png',
  ];

  void showHelpOverlay() {
    setState(() {
      isHelpOverlayVisible = true;
    });
  }

  void hideHelpOverlay() {
    setState(() {
      isHelpOverlayVisible = false;
    });
  }

  void nextPage() {
    if (currentPage < helpImages.length - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  // question list for tab 1 (evaluation)
  final List<String> questionList = [
    '오늘 아침에 느끼는 치아 혹은 턱관절\n통증의 정도가 어떻게 되십니까?',
    '진동자극의 세기가 어땠나요?\n그로 인해 불편함이 없었습니까?',
    '자는 동안 진동이 얼만큼 울렸나요?\n그로 인해 불편함이 없었습니까?',
  ];

  void selectButton(int index) {
    setState(() {
      selectedButtonIndex = index;
    });
  }

  // answer list for tab 1 (evaluation)
  final List<List<String>> choices = [
    [
      '통증 없음',
      '조금\n불편함',
      '불편함',
      '조금 아픔',
      '아픔',
      '많이 아픔',
      '매우 아픔',
      '극심함',
      '매우\n극심함',
      '참기 힘듦',
      '매우\n참기힘듦',
    ],
    ['매우 약했다', '약했다', '보통이다', '강했다', '매우 강했다'],
    ['매우 적었다', '적었다', '보통이다', '많았다', '매우 많았다'],
  ];

  void stopListening() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CalibrationSetting(connectedDevice: connectedDevice),
      ),
    );
  }

  // get user's sleep data result for tab 3 (information)
  Future<void> getSleepDataResult(
    BuildContext context,
    String custUsername, {
    String? fromDate,
    String? toDate,
  }) async {
    String formatDate(DateTime date) {
      String year = date.year.toString();
      String month = date.month.toString().padLeft(2, '0');
      String day = date.day.toString().padLeft(2, '0');
      return '$year-$month-$day';
    }

    if (fromDate == null || toDate == null) {
      final currentDate = DateTime.now();
      final defaultToDate = currentDate.subtract(Duration(days: 7));
      fromDate = formatDate(defaultToDate);
      toDate = formatDate(currentDate);
    }

    try {
      final apiUrl = 'http://3.21.156.190:3000/api/customers/sleepDataResult';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': custUsername,
          'fromDate': fromDate,
          'toDate': toDate,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          latestBrEpisode = jsonResponse['latest_br_episode'].toString();
          highestBrMax = jsonResponse['highest_br_max'].toString();
          latestData = jsonResponse['latest_data'].toString();
        });
      } else {
        if (response.statusCode == 400) {
          // Handle 400 Bad Request
          print(response.body);
        } else if (response.statusCode == 500) {
          // Handle 500 Internal Server Error
          print(response.body);
        } else {
          // Handle other status codes as needed
          print(response.body);
        }
      }
    } catch (error) {
      // Handle any network or other errors here
      print('Error: $error');
    }
  }

  // if start button is pressed, start saving EMG data locally
  Future<void> toogleBinSave() async {
    if (!saveToBin) {
      fileName =
          "${DateTime.now().year.toString().padLeft(4, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}_${DateTime.now().hour.toString().padLeft(2, '0')}${DateTime.now().minute.toString().padLeft(2, '0')}${DateTime.now().second.toString().padLeft(2, '0')}";
      prefs.setString("fileName",
          "${DateTime.now().year.toString().padLeft(4, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}");
    }
    saveToBin = !saveToBin;
    if (!saveToBin) {
      if (bufferDataForExportingFull.length > 0) {
        List<int> bytes = [];
        for (String data in bufferDataForExportingFull) {
          List<int> hexBytes = [];
          for (int i = 0; i < data.length; i += 2) {
            String hexByte = data.substring(i, i + 2);
            hexBytes.add(int.parse(hexByte, radix: 16));
          }
          bytes.addAll(hexBytes);
        }
        bufferDataForExportingFull.clear();
        final Directory? directory = Directory("storage/emulated/0/Download");
        final File file = File('${directory!.path}/${fileName}.bin');
        await file.writeAsBytes(bytes, mode: FileMode.append);
      }
      uploadFile(fileName, custUsername!);
      showSuccessDialog(context, "완료되었습니다.\n평가 페이지로 이동합니다.");
    }
  }

  // upload the local EMG data to server
  void uploadFile(String fileNameForUpload, String custName) async {
    final String url = 'http://3.21.156.190:3000/api/customers/binUpload';
    final Directory? directory = Directory("storage/emulated/0/Download");
    final File file = File('${directory!.path}/${fileNameForUpload}.bin');

    if (!file.existsSync()) {
      print('File does not exist.');
      return;
    }

    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);

    // Add the file to the request
    final multipartFile =
        await http.MultipartFile.fromPath('cust_file', file.path);
    request.files.add(multipartFile);

    // Add the custUsername to the request
    request.fields['custUsername'] = custName;

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = utf8.decode(responseData);
        print('File uploaded successfully: $responseString');
        if (custUsername!.trim() != "abismaw" &&
            custUsername!.trim() != "dhkim" &&
            custUsername!.trim() != "jsseo" &&
            custUsername!.trim() != "jhkim" &&
            custUsername!.trim() != "jhbyun" &&
            custUsername!.trim() != "gmstest") {
          await file.delete();
        }
        uploadSleepData(custUsername!, fileName);
      } else {
        print(
            'File upload failed with status code ${utf8.decode(await response.stream.toBytes())}');
      }
    } catch (error) {
      print('File upload error: $error');
    }
  }

  // upload sleep data to server
  Future<void> uploadSleepData(String custUsername, String fileName) async {
    if (custUsername.isEmpty || fileName.isEmpty) {
      // Handle empty fields
      return;
    }
    final Map<String, String> data = {
      'cust_username': custUsername,
      'fileName': "${fileName}.bin",
    };
    final Uri url = Uri.parse('http://3.21.156.190:3000/api/sleepDataProcess');

    try {
      final response = await http.post(
        url,
        body: data,
      );

      if (response.statusCode == 200) {
        // Success
        final responseData = json.decode(response.body);
        print(responseData);
      } else {
        // Handle error
        print('Error sleep data: ${response.body}');
      }
    } catch (e) {
      // Handle network error
      print('Network error: $e');
    }
  }

  // function for handling animation in tab 1 (evaluation)
  void _onItemTapped(int index) {
    setState(() {
      if (noDeviceAvailable ||
          scanResults.length > 0 ||
          connectedDevice == null) {
        if (index == 4) {
          _selectedIndex = index;
          showLogoutDialogue(context);
        } else if (index == 0) {
          _selectedIndex = index;
          fillValue = 0.333;
          selectedButtonIndex = -1;
          qCounter = 1;
          counter = 0;
          _value = 0.0;
          showImage1 = false;
          showImage2 = false;
          showImage3 = false;
          _timer1?.cancel();
          _timer2?.cancel();
          _timerResult?.cancel();
          _timer3?.cancel();
          _timerNew?.cancel();
          showFirstImage();
        } else if (index == 3) {
          _selectedIndex = index;
          getSleepDataResult(context, custUsername!);
        } else if (index == 2) {
          _selectedIndex = index;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                textScaleFactor: 0.95,
                '디바이스를 연결해주세요.',
                style: TextStyle(
                    fontFamily: 'Pretendart', fontSize: screenHeight * 0.020),
              ),
            ),
          );
        }
      } else {
        if (!saveToBin) {
          _selectedIndex = index;
          if (_selectedIndex == 2) {
            sendUARTCommand("SB+" + "start" + r"\" + "n");
          } else if (_selectedIndex != 4) {
            if (_selectedIndex == 0) {
              _selectedIndex = index;
              fillValue = 0.333;
              selectedButtonIndex = -1;
              qCounter = 1;
              counter = 0;
              _value = 0.0;
              showImage1 = false;
              showImage2 = false;
              showImage3 = false;
              _timer1?.cancel();
              _timer2?.cancel();
              _timerResult?.cancel();
              _timer3?.cancel();
              _timerNew?.cancel();
              showFirstImage();
            }
            if (_selectedIndex == 3) {
              getSleepDataResult(context, custUsername!);
            }
          } else {
            showLogoutDialogue(context);
          }
        }
      }
    });
  }

  void disconnectAllDevices() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    for (BluetoothDevice device in connectedDevices) {
      device.disconnect();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      var ipAddress = IpAddress(type: RequestType.json);
      dynamic data = await ipAddress.getIpAddress();
      final String apiUrl = 'http://3.21.156.190:3000/api/customers/logout';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': custUsername,
          'ipAddress': data['ip'],
        },
      );

      if (response.statusCode == 201) {
        disconnectAllDevices();
        Navigator.of(context).pop();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
        );
      } else {
        print("failed: ${response.body}");
      }
    } catch (error) {
      showSuccessDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
    }
  }

  // check if calibration is done
  Future<void> checkAlignProcess(BuildContext context) async {
    try {
      final String apiUrl =
          'http://3.21.156.190:3000/api/customers/checkAlignProcess';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': custUsername,
        },
      );
      if (response.statusCode == 200) {
        prefs.setBool('calibrationDone', true);
      } else if (response.statusCode == 404) {
        prefs.setBool('calibrationDone', false);
      } else {
        print("failed: ${response.body}");
      }
    } catch (error) {
      showSuccessDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
    }
  }

  @override
  void initState() {
    super.initState();
    // initiate screen height and width
    // get IP address
    // get os version for both iOS and Android
    // configure shared preferences
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MediaQueryData mediaQueryData = MediaQuery.of(context);
      if (mediaQueryData.orientation == Orientation.portrait) {
        setState(() {
          screenHeight = mediaQueryData.size.height;
          screenWidth = mediaQueryData.size.width;
        });
      } else {
        setState(() {
          screenHeight = mediaQueryData.size.width;
          screenWidth = mediaQueryData.size.height;
        });
      }
      var ipAddress = IpAddress(type: RequestType.json);
      if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        osVersion = androidInfo.version.release.toString();
      }

      if (Platform.isIOS) {
        var iosInfo = await DeviceInfoPlugin().iosInfo;
        osVersion = iosInfo.systemVersion.toString();
      }
      data = await ipAddress.getIpAddress();
      prefs = await SharedPreferences.getInstance();
      custUsername = await prefs.getString('custUsername');
      custName = await prefs.getString('custName') ?? "Jane";
      deviceID = await prefs.getString('deviceID') ?? "";
      vibIntensity = await prefs.getDouble('vibrationIntensity') ?? 0;
      calibrationDone = prefs.getBool('calibrationDone') ?? false;
      bluetoothStatus = await flutterBlue.isOn;
      _timer1 = Timer(Duration(seconds: 0), () {});
      _timer2 = Timer(Duration(seconds: 0), () {});
      _timerResult = Timer(Duration(seconds: 0), () {});
      _timer3 = Timer(Duration(seconds: 0), () {});
      _timerNew = Timer(Duration(seconds: 0), () {});
      // ask for permission
      bool permissionsGranted = prefs.getBool('permissions_granted') ?? false;
      if (!permissionsGranted) {
        Map<Permission, PermissionStatus> statuses = await [
          Permission.location,
          Permission.bluetoothScan,
          Permission.bluetoothAdvertise,
          Permission.bluetoothConnect
        ].request();
        if (statuses[Permission.location]!.isGranted &&
            statuses[Permission.bluetoothScan]!.isGranted &&
            statuses[Permission.bluetoothAdvertise]!.isGranted &&
            statuses[Permission.bluetoothConnect]!.isGranted) {
          setState(() {
            permGranted = true;
          });
          prefs.setBool('permissions_granted', true);
        }
      } else {
        setState(() {
          permGranted = true;
        });
      }
      // automatically turn on bluetooth if turn off (Android only)
      if (!bluetoothStatus) {
        BluetoothEnable.enableBluetooth;
      }
      if (deviceID == "") {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Center(
              child: CircularProgressIndicator(),
            );
          },
        );
        startScan();
      } else if (deviceID != "" && connectedDevice == null) {
        connectedDevice = BluetoothDevice.fromId(deviceID);
        connectToDevice(connectedDevice!);
        noDeviceAvailable = false;
      } else {
        noDeviceAvailable = false;
        sendUARTCommand("SB+" + "start" + r"\" + "n");
      }
      checkAlignProcess(context);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    scanSubscription?.cancel();
    _timer1?.cancel();
    _timer2?.cancel();
    _timerResult?.cancel();
    _timer3?.cancel();
    _timerNew?.cancel();
    super.dispose();
  }

  void connectToDevice(BluetoothDevice device) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    device
        .connect(autoConnect: false, timeout: const Duration(seconds: 10))
        .then((_) async {
      Navigator.pop(context);
      noDeviceAvailable = false;
      sendUARTCommand("SB+" + "start" + r"\" + "n");
      isSwitched = true;
      manualTurnOff = false;
    }).catchError((error) {
      setState(() {
        Navigator.pop(context);
        noDeviceAvailable = true;
      });
    });
  }

  void startScan() {
    String desiredDeviceName = "Goo";
    scanSubscription =
        flutterBlue.scanResults.listen((List<ScanResult> results) {
      List<ScanResult> filteredResults = results
          .where((result) => result.device.name.startsWith(desiredDeviceName))
          .toList();
      setState(() {
        scanResults = filteredResults;
      });
    });

    flutterBlue.startScan();
    setState(() {
      isScanning = true;
      isSearching = true;
    });

    Timer(Duration(seconds: 5), () {
      stopScan();
      setState(() {
        isScanning = false;
        isSearching = false;
        Navigator.pop(context);
      });
    });
  }

  void stopScan() {
    flutterBlue.stopScan();
    setState(() {
      isScanning = false;
    });
  }

  // send UART command to read EMG data from device
  void sendUARTCommand(String uartCommand) async {
    if (_subscription != null) {
      _subscription!.cancel();
    }
    if (deviceStateSubscription != null) {
      deviceStateSubscription!.cancel();
    }
    if (connectedDevice != null || !logOutStatus) {
      List<BluetoothService> services =
          await connectedDevice!.discoverServices();
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.write) {
            uartCharacteristic = characteristic;
            break;
          }
        }
      }
      for (BluetoothService service in services) {
        for (BluetoothCharacteristic characteristic
            in service.characteristics) {
          if (characteristic.properties.notify) {
            readCharacteristic = characteristic;
            break;
          }
        }
      }
      String command = uartCommand;
      List<int> commandBytes = utf8.encode(command);
      await uartCharacteristic?.write(commandBytes);
      if (readCharacteristic != null) {
        await readCharacteristic!.setNotifyValue(true);
        deviceStateSubscription = connectedDevice!.state.listen((state) {
          if (state == BluetoothDeviceState.disconnected) {
            if (_selectedIndex != 4) {
              if (!manualTurnOff) {
                disconnectAllDevices();
                _subscription!.cancel();
                showSuccessDialog(context,
                    "GooDeeps 연결이 해제되었습니다.\n모든 기능을 사용하기 원하시면\n다시 연결해 주세요");
                setState(() {
                  leadStatus = "";
                  connectedDevice = null;
                  isSwitched = false;
                });
                deviceStateSubscription!.cancel();
              }
            }
          } else {
            if (_subscription != null) {
              _subscription!.cancel();
            }
            _subscription = readCharacteristic!.value.listen(
              (value) async {
                if (!mounted) {
                  return;
                }

                // a5 00 38 0b d9 0b e2 0b 98 0a d7 08 00 3f 14 83 3b 5a
                if (result != "") {
                  if (result.length >= 36) {
                  } else {
                    result =
                        "a500380bd90be20b980ad708003f14833b5a"; // to avoid firmware upgrade error
                  }
                  if (result.endsWith("5a") &&
                      result.substring(
                              result.length - 36, result.length - 34) ==
                          "a5") {
                    result = "";
                  } else {
                    result = result.substring(result.length - 36);
                  }
                }
                result = result + HEX.encode(value);
                extractedData = pattern
                    .allMatches(result)
                    .map((match) => match.group(0))
                    .toList();
                dataBuffer.addAll(extractedData.whereType<String>());
                processDataFromBuffer();

                if (tempData.length > 5000) {
                  tempData.removeRange(0, 3000);
                }
              },
            );
          }
        });
      }
    }
  }

  void processDataFromBuffer() {
    const int batchSize = 15;

    for (int i = 0; i < batchSize; i++) {
      if (dataBuffer.isNotEmpty) {
        String dataPoint = dataBuffer.removeFirst();
        processSingleDataPoint(dataPoint);
      }
    }

    if (dataBuffer.isNotEmpty) {
      const Duration delay = Duration(milliseconds: 500);
      Future.delayed(delay, processDataFromBuffer);
    }
  }

  // read all specific data point
  void processSingleDataPoint(String dataPoint) async {
    // a5 05 16 0f 87 00 3a 00 d0 01 39 08 00 a6 23 04 3d 5a
    int hexToInt(String hex) => int.parse(hex, radix: 16);
    int chargingInfo = int.parse(
        int.parse(dataPoint.substring(32, 34), radix: 16)
            .toRadixString(2)
            .padLeft(8, '0')[0]);
    if (chargingInfo == 0) {
      batteryValue = hexToInt(dataPoint.substring(32, 34));
      chargingStatus = false;
    } else if (chargingInfo == 1) {
      chargingStatus = true;
    }
    // if override is required
    // batteryShowValue = 40;
    batteryShowValue = chargingStatus
        ? batteryValue
        : batteryShowValue - batteryValue != 1
            ? batteryValue
            : batteryShowValue;
    vibrationValue = "${hexToInt(dataPoint.toString()[30])}";
    vibIntensity = prefs.getDouble('vibrationIntensity') ?? 0;
    int length = hexToInt(dataPoint.substring(30, 32)).toRadixString(2).length;
    // leadStatus = "1";
    leadStatus =
        hexToInt(dataPoint.substring(30, 32)).toRadixString(2)[length - 2];
    bruxismStatus =
        hexToInt(dataPoint.substring(30, 32)).toRadixString(2)[length - 1];
    ampValue = "${hexToInt(dataPoint.substring(26, 28)) * 16}";
    int offsetHex = hexToInt(dataPoint.substring(22, 26));
    vthValue = (hexToInt(dataPoint.substring(28, 30)) * 16) + offsetHex;
    offsetValue = offsetHex;

    if (saveToBin) {
      bufferDataForExportingFull.add(dataPoint);
    }

    if (bufferDataForExportingFull.length > 5000) {
      List<int> bytes = [];
      for (String data in bufferDataForExportingFull) {
        List<int> hexBytes = [];
        for (int i = 0; i < data.length; i += 2) {
          String hexByte = data.substring(i, i + 2);
          hexBytes.add(int.parse(hexByte, radix: 16));
        }
        bytes.addAll(hexBytes);
      }
      bufferDataForExportingFull.clear();
      final Directory? directory = Directory("storage/emulated/0/Download");
      final File file = File('${directory!.path}/${fileName}.bin');
      await file.writeAsBytes(bytes, mode: FileMode.append);
    }
    setState(() {});
  }

  // functions for handling animations in tab 1 (evaluation)
  void showFirstImage() {
    setState(() {
      showImage1 = true;
    });
    _timer1 = Timer(Duration(seconds: 5), () {
      setState(() {
        showImage1 = false;
      });
    });
  }

  void showResultAndSecondImage() {
    if (vasTotal == 0) {
      resultImageName = 'assets/images/ani4.png';
      resultText = '최고에요!\n아주 좋은 현상 입니다!';
    } else if (vasTotal > 0 && vasTotal < 4) {
      resultImageName = 'assets/images/ani5.png';
      resultText = '대단해요! 좋아지고 있어요!';
    } else {
      resultImageName = 'assets/images/ani6.png';
      resultText = '괜찮아요, 좋아질거에요!';
    }

    setState(() {
      resultImage = true;
    });
    _timerResult = Timer(Duration(seconds: 3), () {
      setState(() {
        showImage2 = true;
        resultImage = false;
      });
    });
    _timer2 = Timer(Duration(seconds: 6), () {
      setState(() {
        showImage2 = false;
      });
    });
  }

  void showThirdImages() {
    setState(() {
      showImage3 = true;
    });

    _timer3 = Timer(Duration(seconds: 3), () {
      setState(() {
        showImage3 = false;
      });
    });
  }

  // submit the evaluation result
  Future<void> scoringSubmit(BuildContext context) async {
    try {
      final String apiUrl = 'http://3.21.156.190:3000/api/customers/scoring';
      String measurementDate = await prefs.getString('fileName') ??
          '${DateTime.now().year.toString().padLeft(4, '0')}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}';
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'cust_username': custUsername,
          'scor_msrt_date': measurementDate,
          'scor_trsm_date':
              '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}',
          'scor_vas_value': evaluationAnswer[0].toString().toString(),
          'scor_vib_inten': evaluationAnswer[1].toString().toString(),
          'scor_vib_freq': evaluationAnswer[2].toString().toString(),
        },
      );

      if (response.statusCode == 200) {
        showSuccessDialog(context, '제출되었습니다.');
      } else {
        print("Error: ${response.body}");
      }
    } catch (error) {
      showSuccessDialog(context, '서버에 연결할 수 없습니다. 네트워크 연결을 확인하십시오.');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      // TAB 1
      GestureDetector(
        onTap: () {
          if (showImage1) {
            setState(() {
              _timer1?.cancel();
              showImage1 = false;
            });
          } else if (resultImage) {
            setState(() {
              _timerResult?.cancel();
              _timer2?.cancel();
              resultImage = false;
              showImage2 = true;
              _timerNew = Timer(Duration(seconds: 5), () {
                setState(() {
                  showImage2 = false;
                });
              });
            });
          } else if (showImage2) {
            setState(() {
              _timerNew?.cancel();
              showImage2 = false;
            });
          } else if (showImage3) {
            setState(() {
              _timer3?.cancel();
              showImage3 = false;
            });
          }
        },
        child: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF110925), Color(0xFF2A0C54)],
            ),
          ),
          child: SingleChildScrollView(
            child: showImage1
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: screenHeight * 0.2,
                      ),
                      Text(
                        textScaleFactor: 0.95,
                        "${custName}님\n좋은 아침입니다!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenHeight * 0.04,
                          fontFamily: 'Pretendart',
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      Container(
                        width: screenHeight * 0.15,
                        child: Image.asset(
                          'assets/images/ani1.png',
                          fit: BoxFit.contain,
                        ),
                      )
                    ],
                  )
                : resultImage
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.2,
                          ),
                          Text(
                            textScaleFactor: 0.95,
                            resultText!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenHeight * 0.04,
                              fontFamily: 'Pretendart',
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                          Container(
                            width: resultImageName!.contains("ani6")
                                ? screenWidth * 0.5
                                : screenHeight * 0.15,
                            child: Image.asset(
                              resultImageName!,
                              fit: BoxFit.contain,
                            ),
                          )
                        ],
                      )
                    : showImage2
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: screenHeight * 0.2,
                              ),
                              Text(
                                textScaleFactor: 0.95,
                                "지난밤 불편은 없었나요?",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenHeight * 0.04,
                                  fontFamily: 'Pretendart',
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 0.05,
                              ),
                              Container(
                                width: screenHeight * 0.15,
                                child: Image.asset(
                                  'assets/images/ani2.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          )
                        : showImage3
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: screenHeight * 0.2,
                                  ),
                                  Text(
                                    textScaleFactor: 0.95,
                                    "오늘 하루도 화이팅!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenHeight * 0.04,
                                      fontFamily: 'Pretendart',
                                    ),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 0.05,
                                  ),
                                  Container(
                                    width: screenWidth * 0.8,
                                    child: Image.asset('assets/images/ani3.png',
                                        fit: BoxFit.contain),
                                  ),
                                ],
                              )
                            : Container(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: screenHeight * 0.015,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                              child: LinearProgressIndicator(
                                                value: fillValue,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(
                                                  Color(0xFFFFC71B),
                                                ),
                                                backgroundColor: Color.fromRGBO(
                                                    89, 93, 104, 1),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          textScaleFactor: 0.95,
                                          "0${qCounter}/03",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontFamily: 'Pretendart',
                                              fontSize: screenHeight * 0.025),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Center(
                                      child: Container(
                                        width: screenWidth,
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          textScaleFactor: 0.95,
                                          "${questionList[counter]}",
                                          style: TextStyle(
                                              fontSize: screenHeight * 0.025,
                                              fontFamily: 'Pretendart',
                                              color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    qCounter == 1
                                        ? SizedBox(
                                            height: screenHeight * 0.02,
                                          )
                                        : SizedBox(
                                            height: screenHeight * 0.00,
                                          ),
                                    qCounter == 1
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                height: screenHeight * 0.015,
                                                padding: EdgeInsets.only(
                                                    top: screenHeight * 0.007),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Color.fromRGBO(
                                                          111, 218, 49, 1),
                                                      Color.fromRGBO(
                                                          225, 223, 53, 1),
                                                      Color.fromRGBO(
                                                          254, 189, 68, 1),
                                                      Color.fromRGBO(
                                                          253, 123, 87, 1),
                                                      Color.fromRGBO(
                                                          254, 63, 43, 1),
                                                      Color.fromRGBO(
                                                          255, 6, 4, 1),
                                                    ],
                                                    stops: [
                                                      0.0,
                                                      0.2,
                                                      0.4,
                                                      0.6,
                                                      0.8,
                                                      1.0,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                ),
                                                child: MediaQuery(
                                                  data: const MediaQueryData(
                                                      textScaleFactor: 0.85),
                                                  child: SfSliderTheme(
                                                    data: SfSliderThemeData(
                                                      activeLabelStyle:
                                                          TextStyle(
                                                        color: Colors.white,
                                                        fontSize: screenHeight *
                                                            0.018,
                                                      ),
                                                      inactiveLabelStyle:
                                                          TextStyle(
                                                        color: Colors.white,
                                                        fontSize: screenHeight *
                                                            0.018,
                                                      ),
                                                      thumbColor: Colors.red,
                                                    ),
                                                    child: SfSlider(
                                                      min: 0.0,
                                                      max: 10.0,
                                                      value: _value,
                                                      interval: 1,
                                                      stepSize: 1.0,
                                                      labelFormatterCallback:
                                                          (dynamic actualValue,
                                                              String
                                                                  formattedText) {
                                                        return actualValue %
                                                                    2 ==
                                                                0
                                                            ? actualValue
                                                                .toInt()
                                                                .toString()
                                                            : '';
                                                      },
                                                      inactiveColor:
                                                          Colors.transparent,
                                                      activeColor:
                                                          Colors.transparent,
                                                      showDividers: true,
                                                      dividerShape:
                                                          DividerShape(),
                                                      thumbShape:
                                                          _SfThumbShape(),
                                                      showLabels: true,
                                                      onChanged:
                                                          (dynamic value) {
                                                        setState(() {
                                                          _value = value;
                                                          selectedButtonIndex =
                                                              _value.toInt();
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Text(textScaleFactor: 0.95, ""),
                                    qCounter != 1
                                        ? SizedBox(
                                            height: screenHeight * 0.00,
                                          )
                                        : SizedBox(
                                            height: screenHeight * 0.05,
                                          ),
                                    qCounter != 1
                                        ? Column(
                                            children: [
                                              for (int i = 0;
                                                  i < choices[counter].length;
                                                  i++)
                                                Column(
                                                  children: [
                                                    buildButton(
                                                        i,
                                                        '${choices[counter][i]}',
                                                        Color.fromRGBO(
                                                            64, 58, 88, 1)),
                                                    SizedBox(
                                                      height:
                                                          screenHeight * 0.012,
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          )
                                        : Container(
                                            child: Column(
                                              children: List.generate(
                                                (choices[counter].length / 3)
                                                    .ceil(),
                                                (rowIndex) {
                                                  return Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: List.generate(
                                                          3,
                                                          (colIndex) {
                                                            final index =
                                                                rowIndex * 3 +
                                                                    colIndex;
                                                            if (index <
                                                                choices[counter]
                                                                    .length) {
                                                              return SizedBox(
                                                                width:
                                                                    screenWidth *
                                                                        0.28,
                                                                child:
                                                                    buildButton(
                                                                  index,
                                                                  '${choices[counter][index]}',
                                                                  Color
                                                                      .fromRGBO(
                                                                          64,
                                                                          58,
                                                                          88,
                                                                          1),
                                                                ),
                                                              );
                                                            } else {
                                                              return SizedBox(
                                                                  width:
                                                                      screenWidth *
                                                                          0.28);
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: screenHeight *
                                                              0.01),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                    SizedBox(
                                      height: screenHeight * 0.04,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: screenWidth * 0.42,
                                          height: screenHeight * 0.07,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                if (counter > 0) {
                                                  counter -= 1;
                                                  if (fillValue > 0.333) {
                                                    setState(() {
                                                      selectedButtonIndex = -1;
                                                      qCounter -= 1;
                                                      fillValue -= 0.333;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _selectedIndex = 2;
                                                    });
                                                  }
                                                } else {
                                                  setState(() {
                                                    _selectedIndex = 2;
                                                  });
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF817C99),
                                            ),
                                            child: Text(
                                              textScaleFactor: 0.95,
                                              '이전',
                                              style: TextStyle(
                                                  fontSize: screenHeight * 0.02,
                                                  fontFamily: 'Pretendart',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.04,
                                        ),
                                        SizedBox(
                                          width: screenWidth * 0.42,
                                          height: screenHeight * 0.07,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              int currentVib =
                                                  (await prefs.getDouble(
                                                              "vibrationIntensity") ??
                                                          5)
                                                      .toInt();
                                              int currentVth = (await prefs
                                                          .getInt("vthValue") ??
                                                      320)
                                                  .toInt();
                                              int currentVibPatt =
                                                  (await prefs.getInt(
                                                              "vibrationPattern") ??
                                                          0)
                                                      .toInt();
                                              bool autoVibrate = (await prefs
                                                      .getBool('autoVibrate') ??
                                                  false);
                                              setState(() {
                                                if (counter < 2) {
                                                  if (selectedButtonIndex !=
                                                      -1) {
                                                    evaluationAnswer[counter] =
                                                        selectedButtonIndex;
                                                    counter += 1;
                                                    if (counter == 1) {
                                                      showResultAndSecondImage();
                                                    }
                                                    if (counter == 2) {
                                                      if (selectedButtonIndex ==
                                                          4) {
                                                        currentVib =
                                                            currentVib - 1 < 1
                                                                ? 1
                                                                : currentVib -
                                                                    1;
                                                      } else if (selectedButtonIndex ==
                                                          0) {
                                                        currentVib =
                                                            currentVib + 1 > 10
                                                                ? 10
                                                                : currentVib +
                                                                    1;
                                                      }
                                                      if (autoVibrate) {
                                                        sendUARTCommand("SB+" +
                                                            "pat=" +
                                                            (currentVibPatt)
                                                                .toString() +
                                                            "," +
                                                            (currentVib)
                                                                .toString() +
                                                            ",2,2" +
                                                            r"\" +
                                                            "n");
                                                        prefs.setDouble(
                                                            'vibrationIntensity',
                                                            currentVib
                                                                .toDouble());
                                                      }
                                                      showThirdImages();
                                                    }
                                                    if (fillValue < 1.0) {
                                                      setState(() {
                                                        selectedButtonIndex =
                                                            -1;
                                                        qCounter += 1;
                                                        fillValue += 0.333;
                                                      });
                                                    }
                                                  }
                                                } else {
                                                  if (selectedButtonIndex !=
                                                      -1) {
                                                    setState(() {
                                                      if (selectedButtonIndex ==
                                                          4) {
                                                        currentVth =
                                                            currentVth + 64 >
                                                                    2048
                                                                ? 2048
                                                                : currentVth +
                                                                    64;
                                                      } else if (selectedButtonIndex ==
                                                          0) {
                                                        currentVth =
                                                            currentVth - 64 < 0
                                                                ? 0
                                                                : currentVth -
                                                                    64;
                                                      }
                                                      if (autoVibrate) {
                                                        sendUARTCommand("SB+" +
                                                            "vth=${currentVth}" +
                                                            r"\" +
                                                            "n");
                                                        prefs.setInt('vthValue',
                                                            currentVth);
                                                      }
                                                      evaluationAnswer[
                                                              counter] =
                                                          selectedButtonIndex;
                                                      if (custUsername ==
                                                              "abismaw" ||
                                                          custUsername ==
                                                              "dhkim" ||
                                                          custUsername ==
                                                              "jsseo" ||
                                                          custUsername ==
                                                              "jhkim" ||
                                                          custUsername ==
                                                              "jhbyun" ||
                                                          custUsername ==
                                                              "gmstest") {
                                                        Uint8List bytes =
                                                            Uint8List.fromList(
                                                                evaluationAnswer);
                                                        final Directory?
                                                            directoryRaw =
                                                            Directory(
                                                                "storage/emulated/0/Download");
                                                        final File fileRaw = File(
                                                            '${directoryRaw!.path}/evlq${DateTime.now().millisecondsSinceEpoch}.bin');
                                                        fileRaw.writeAsBytes(
                                                            bytes,
                                                            mode: FileMode
                                                                .append);
                                                      }
                                                      scoringSubmit(context);
                                                      _selectedIndex = 2;
                                                    });
                                                  }
                                                }
                                              });
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFF714AC6),
                                            ),
                                            child: Text(
                                              textScaleFactor: 0.95,
                                              '다음',
                                              style: TextStyle(
                                                  fontFamily: 'Pretendart',
                                                  fontSize: screenHeight * 0.02,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
          ),
        ),
      ),

      // TAB 2
      Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Text(
                      textScaleFactor: 0.95,
                      "설정",
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.03,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Container(
                      color: Colors.transparent,
                      child: TextButton(
                        onPressed: () {
                          print("LeadStatus : $leadStatus");
                          if (leadStatus == "1") {
                            stopListening();
                          } else {
                            showSuccessDialog(context, "디바이스를 정확히 부착해주세요.");
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: screenHeight * 0.03,
                              child: Image.asset('assets/images/calicon.png'),
                            ),
                            SizedBox(
                              width: screenWidth * 0.01,
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.95,
                                "Align Process",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.022),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Color(0xFF4A4A5C),
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Container(
                      color: Colors.transparent,
                      child: TextButton(
                        onPressed: () {
                          _subscription?.cancel().then(
                            (_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VibrationSetting(
                                        connectedDevice: connectedDevice)),
                              );
                            },
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: screenHeight * 0.03,
                              child: Image.asset('assets/images/vibraicon.png'),
                            ),
                            SizedBox(
                              width: screenWidth * 0.01,
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.95,
                                "진동자극 조절",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.022),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Color(0xFF4A4A5C),
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Container(
                      color: Colors.transparent,
                      child: TextButton(
                        onPressed: () {
                          _subscription?.cancel().then(
                            (_) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        AccountConfirmation()),
                              );
                            },
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: screenHeight * 0.03,
                              child: Image.asset('assets/images/usericon.png'),
                            ),
                            SizedBox(
                              width: screenWidth * 0.01,
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.95,
                                "회원정보 수정",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.022),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Color(0xFF4A4A5C),
                    ),
                    Container(
                      color: Colors.transparent,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateScreen(
                                      connectedDevice: connectedDevice,
                                    )),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.update,
                              size: screenHeight * 0.03,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: screenWidth * 0.01,
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.95,
                                "업데이트",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: screenHeight * 0.022),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Divider(
                      thickness: 1.0,
                      color: Color(0xFF4A4A5C),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF464060),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Text(
                    textScaleFactor: 0.95,
                    "디바이스 초기화",
                    style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screenHeight * 0.02,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      showInitDialog(context,
                          "진동 세기, 진동 패턴,\n교정값 등이 초기화됩니다.\n초기화를 실행하시겠습니까?");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF170839),
                      minimumSize:
                          Size(screenWidth * 0.35, screenHeight * 0.055),
                    ),
                    child: Text(
                      textScaleFactor: 0.95,
                      '실행',
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.02,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                  Text(
                    textScaleFactor: 0.95,
                    "실행 버튼을 누르면,\n디바이스가 초기화 됩니다.\n안내 메시지를 확인해주세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screenHeight * 0.02,
                        color: Colors.white),
                  ),
                  SizedBox(
                    height: screenHeight * 0.02,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // TAB 3
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Center(
                child: Container(
                  width: screenWidth * 0.4,
                  child: Image.asset(
                    'assets/images/gdl.png',
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.05,
              ),
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: screenWidth * 0.75,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textScaleFactor: 0.95,
                            "${custName}님 반갑습니다.",
                            style: TextStyle(
                              fontFamily: 'Pretendart',
                              color: Colors.white,
                              fontSize: screenWidth * 0.7 * 0.07,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          showHelpOverlay();
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          elevation: 0,
                          backgroundColor: Color(0xFF403754),
                          fixedSize: Size(screenWidth, screenHeight * 0.04),
                        ),
                        child: Text(
                          textScaleFactor: 0.95,
                          '도움말',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize:
                                  (screenWidth - (screenWidth * 0.75)) * 0.15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromRGBO(107, 107, 121, 1),
                      Color.fromRGBO(93, 93, 108, 1),
                      Color.fromRGBO(85, 85, 100, 1),
                      Color.fromRGBO(81, 81, 96, 1),
                      Color.fromRGBO(77, 77, 93, 1),
                      Color.fromRGBO(73, 73, 90, 1),
                      Color.fromRGBO(74, 74, 91, 1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: screenHeight * 0.08,
                child: ElevatedButton(
                  onPressed: () {
                    if (connectedDevice == null || noDeviceAvailable) {
                      setState(() {
                        if (deviceID == "") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BluetoothConnection(),
                            ),
                          );
                        } else {
                          connectedDevice = BluetoothDevice.fromId(deviceID);
                          connectToDevice(connectedDevice!);
                          isSwitched = true;
                        }
                      });
                    } else {
                      disconnectAllDevices();
                      setState(() {
                        leadStatus = "";
                        manualTurnOff = true;
                        isSwitched = false;
                        connectedDevice = null;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.015,
                        vertical: screenHeight * 0.01),
                    elevation: 50,
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: noDeviceAvailable ||
                          scanResults.length < 0 ||
                          connectedDevice == null
                      ? Row(
                          children: [
                            Image.asset(
                              'assets/images/icon1v3off.png',
                              fit: BoxFit.cover,
                              height: screenHeight * 0.08 / 2,
                            ),
                            SizedBox(
                              width: screenWidth * 0.02,
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.95,
                                "디바이스 통신",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Color(0xFFA4A4BC),
                                    fontSize: (((screenWidth / 2) -
                                                screenWidth * 0.015 -
                                                screenWidth * 0.01) -
                                            (screenHeight * 0.02 * 3)) *
                                        0.1,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              textScaleFactor: 0.95,
                              "OFF",
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFA4A4BC),
                                fontSize: (((screenWidth / 2) -
                                            screenWidth * 0.015 -
                                            screenWidth * 0.01) -
                                        (screenHeight * 0.02 * 3)) *
                                    0.1,
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.01,
                            ),
                            CupertinoSwitch(
                              value: false,
                              onChanged: (value) {
                                setState(() {
                                  isSwitched = value;
                                  if (isSwitched) {
                                    if (deviceID == "") {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              BluetoothConnection(),
                                        ),
                                      );
                                    } else {
                                      connectedDevice =
                                          BluetoothDevice.fromId(deviceID);
                                      connectToDevice(connectedDevice!);
                                      isSwitched = true;
                                    }
                                  } else {
                                    disconnectAllDevices();
                                    setState(() {
                                      leadStatus = "";
                                      manualTurnOff = true;
                                      connectedDevice = null;
                                    });
                                  }
                                });
                              },
                              activeColor: CupertinoColors.activeGreen,
                            )
                          ],
                        )
                      : Row(
                          children: [
                            Image.asset(
                              'assets/images/icon1v3.png',
                              fit: BoxFit.cover,
                              height: screenHeight * 0.08 / 2,
                            ),
                            SizedBox(
                              width: screenWidth * 0.02,
                            ),
                            Expanded(
                              child: Text(
                                textScaleFactor: 0.95,
                                "디바이스 통신",
                                style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    color: Colors.white,
                                    fontSize: (((screenWidth / 2) -
                                                screenWidth * 0.015 -
                                                screenWidth * 0.01) -
                                            (screenHeight * 0.02 * 3)) *
                                        0.1,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              textScaleFactor: 0.95,
                              "ON",
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: (((screenWidth / 2) -
                                            screenWidth * 0.015 -
                                            screenWidth * 0.01) -
                                        (screenHeight * 0.02 * 3)) *
                                    0.1,
                              ),
                            ),
                            SizedBox(
                              width: screenWidth * 0.01,
                            ),
                            CupertinoSwitch(
                              value: true,
                              onChanged: (value) {
                                setState(() {
                                  isSwitched = value;
                                  if (isSwitched) {
                                    connectedDevice =
                                        BluetoothDevice.fromId(deviceID);
                                    connectToDevice(connectedDevice!);
                                  } else {
                                    disconnectAllDevices();
                                    setState(() {
                                      leadStatus = "";
                                      connectedDevice = null;
                                      manualTurnOff = true;
                                    });
                                  }
                                });
                              },
                              activeColor: CupertinoColors.activeGreen,
                            )
                          ],
                        ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Container(
                width: screenWidth,
                height: screenHeight * 0.225,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        leadStatus == "0" && connectedDevice != null
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.015,
                                    vertical: screenHeight * 0.01),
                                height: (screenHeight * 0.225 / 2) -
                                    screenHeight * 0.005,
                                width: (screenWidth / 2) -
                                    screenWidth * 0.015 -
                                    screenWidth * 0.01,
                                decoration: BoxDecoration(
                                  color: Color(0xFF403754),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset('assets/images/icon2v3off.png',
                                        fit: BoxFit.cover,
                                        height: (((screenHeight * 0.225 / 2) -
                                                    screenHeight * 0.005) -
                                                (screenHeight * 0.01 * 2)) *
                                            0.45),
                                    SizedBox(
                                      height: screenHeight * 0.01,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          textScaleFactor: 0.95,
                                          "디바이스 부착",
                                          style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFA4A4BC),
                                            fontSize: (((screenWidth / 2) -
                                                        screenWidth * 0.015 -
                                                        screenWidth * 0.01) -
                                                    (screenHeight * 0.02 * 3)) *
                                                0.085,
                                          ),
                                        ),
                                        Text(
                                          textScaleFactor: 0.95,
                                          "OFF",
                                          style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFA4A4BC),
                                            fontSize: (((screenWidth / 2) -
                                                        screenWidth * 0.015 -
                                                        screenWidth * 0.01) -
                                                    (screenHeight * 0.02 * 3)) *
                                                0.085,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : noDeviceAvailable ||
                                    scanResults.length > 0 ||
                                    connectedDevice == null
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.015,
                                        vertical: screenHeight * 0.01),
                                    width: (screenWidth / 2) -
                                        screenWidth * 0.015 -
                                        screenWidth * 0.01,
                                    height: (screenHeight * 0.225 / 2) -
                                        screenHeight * 0.005,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF403754),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset(
                                            'assets/images/icon2v3off.png',
                                            fit: BoxFit.cover,
                                            height: (((screenHeight *
                                                            0.225 /
                                                            2) -
                                                        screenHeight * 0.005) -
                                                    (screenHeight * 0.01 * 2)) *
                                                0.45),
                                        SizedBox(
                                          height: screenHeight * 0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              textScaleFactor: 0.95,
                                              "디바이스 부착",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFA4A4BC),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.085,
                                              ),
                                            ),
                                            Text(
                                              textScaleFactor: 0.95,
                                              "N/A",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFA4A4BC),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.085,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.015,
                                        vertical: screenHeight * 0.01),
                                    width: (screenWidth / 2) -
                                        screenWidth * 0.015 -
                                        screenWidth * 0.01,
                                    height: (screenHeight * 0.225 / 2) -
                                        screenHeight * 0.005,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF403754),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Image.asset('assets/images/icon2v3.png',
                                            fit: BoxFit.cover,
                                            height: (((screenHeight *
                                                            0.225 /
                                                            2) -
                                                        screenHeight * 0.005) -
                                                    (screenHeight * 0.01 * 2)) *
                                                0.45),
                                        SizedBox(
                                          height: screenHeight * 0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              textScaleFactor: 0.95,
                                              "디바이스 부착",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.085,
                                              ),
                                            ),
                                            Text(
                                              textScaleFactor: 0.95,
                                              "ON",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.085,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                        noDeviceAvailable ||
                                scanResults.length > 0 ||
                                connectedDevice == null
                            ? Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.015,
                                    vertical: screenHeight * 0.01),
                                width: (screenWidth / 2) -
                                    screenWidth * 0.015 -
                                    screenWidth * 0.01,
                                height: (screenHeight * 0.225 / 2) -
                                    screenHeight * 0.005,
                                decoration: BoxDecoration(
                                  color: Color(0xFF403754),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset('assets/images/icon3v3off.png',
                                        fit: BoxFit.cover,
                                        height: (((screenHeight * 0.225 / 2) -
                                                    screenHeight * 0.005) -
                                                (screenHeight * 0.01 * 2)) *
                                            0.45),
                                    SizedBox(
                                      height: screenHeight * 0.02,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          textScaleFactor: 0.95,
                                          "디바이스 작동",
                                          style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFA4A4BC),
                                            fontSize: (((screenWidth / 2) -
                                                        screenWidth * 0.015 -
                                                        screenWidth * 0.01) -
                                                    (screenHeight * 0.02 * 3)) *
                                                0.085,
                                          ),
                                        ),
                                        Text(
                                          textScaleFactor: 0.95,
                                          "N/A",
                                          style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFA4A4BC),
                                            fontSize: (((screenWidth / 2) -
                                                        screenWidth * 0.015 -
                                                        screenWidth * 0.01) -
                                                    (screenHeight * 0.02 * 3)) *
                                                0.085,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              )
                            : !saveToBin
                                ? Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.015,
                                        vertical: screenHeight * 0.01),
                                    width: (screenWidth / 2) -
                                        screenWidth * 0.015 -
                                        screenWidth * 0.01,
                                    height: (screenHeight * 0.225 / 2) -
                                        screenHeight * 0.005,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF403754),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                            'assets/images/icon3v3off.png',
                                            fit: BoxFit.cover,
                                            height: (((screenHeight *
                                                            0.225 /
                                                            2) -
                                                        screenHeight * 0.005) -
                                                    (screenHeight * 0.01 * 2)) *
                                                0.45),
                                        SizedBox(
                                          height: screenHeight * 0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              textScaleFactor: 0.95,
                                              "디바이스 작동",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFA4A4BC),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.085,
                                              ),
                                            ),
                                            Text(
                                              textScaleFactor: 0.95,
                                              "OFF",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFA4A4BC),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.085,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.015,
                                        vertical: screenHeight * 0.01),
                                    width: (screenWidth / 2) -
                                        screenWidth * 0.015 -
                                        screenWidth * 0.01,
                                    height: (screenHeight * 0.225 / 2) -
                                        screenHeight * 0.005,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF403754),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Image.asset('assets/images/icon3v3.png',
                                            fit: BoxFit.cover,
                                            height: (((screenHeight *
                                                            0.225 /
                                                            2) -
                                                        screenHeight * 0.005) -
                                                    (screenHeight * 0.01 * 2)) *
                                                0.45),
                                        SizedBox(
                                          height: screenHeight * 0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              textScaleFactor: 0.95,
                                              "디바이스 작동",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.1,
                                              ),
                                            ),
                                            Text(
                                              textScaleFactor: 0.95,
                                              "ON",
                                              style: TextStyle(
                                                fontFamily: 'Pretendart',
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFFFFFFF),
                                                fontSize: (((screenWidth / 2) -
                                                            screenWidth *
                                                                0.015 -
                                                            screenWidth *
                                                                0.01) -
                                                        (screenHeight *
                                                            0.02 *
                                                            3)) *
                                                    0.1,
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                      ],
                    ),
                    noDeviceAvailable ||
                            scanResults.length < 0 ||
                            connectedDevice == null
                        ? Container(
                            padding: EdgeInsets.all(15),
                            width: (screenWidth / 2) -
                                screenWidth * 0.015 -
                                screenWidth * 0.01,
                            decoration: BoxDecoration(
                              color: Color(0xFF403754),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/btr190.png',
                                  height: screenHeight * 0.12,
                                ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Text(
                                  textScaleFactor: 0.95,
                                  "배터리 N/A",
                                  style: TextStyle(
                                    fontFamily: 'Pretendart',
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFFFFF),
                                    fontSize: (((screenWidth / 2) -
                                                screenWidth * 0.015 -
                                                screenWidth * 0.01) -
                                            (screenHeight * 0.02 * 3)) *
                                        0.1,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            padding: EdgeInsets.all(15),
                            width: (screenWidth / 2) -
                                screenWidth * 0.015 -
                                screenWidth * 0.01,
                            decoration: BoxDecoration(
                              color: Color(0xFF403754),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                chargingStatus
                                    ? Image.asset(
                                        'assets/images/battery.gif',
                                        height: screenHeight * 0.12,
                                      )
                                    : batteryShowValue <= 100 &&
                                            batteryShowValue >= 86
                                        ? Image.asset(
                                            'assets/images/btr10086.png',
                                            height: screenHeight * 0.12,
                                          )
                                        : batteryShowValue <= 85 &&
                                                batteryShowValue >= 51
                                            ? Image.asset(
                                                'assets/images/btr8551.png',
                                                height: screenHeight * 0.12,
                                              )
                                            : batteryShowValue <= 50 &&
                                                    batteryShowValue >= 20
                                                ? Image.asset(
                                                    'assets/images/btr5020.png',
                                                    height: screenHeight * 0.12,
                                                  )
                                                : Image.asset(
                                                    'assets/images/btr190.png',
                                                    height: screenHeight * 0.12,
                                                  ),
                                SizedBox(
                                  height: screenHeight * 0.02,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      textScaleFactor: 0.95,
                                      chargingStatus
                                          ? "배터리 충전중"
                                          : batteryShowValue <= 100
                                              ? "배터리 ${batteryShowValue}%"
                                              : "로딩중",
                                      style: TextStyle(
                                        fontFamily: 'Pretendart',
                                        fontWeight: FontWeight.bold,
                                        color: chargingStatus
                                            ? Color(0xFF06EF7F)
                                            : batteryShowValue <= 100 &&
                                                    batteryShowValue >= 86
                                                ? Color(0xFF06EF7F)
                                                : batteryShowValue <= 85 &&
                                                        batteryShowValue >= 51
                                                    ? Color(0xFFFFC700)
                                                    : batteryShowValue <= 50 &&
                                                            batteryShowValue >=
                                                                20
                                                        ? Color(0xFFFF8329)
                                                        : Color(0xFFED4645),
                                        fontSize: (((screenWidth / 2) -
                                                    screenWidth * 0.015 -
                                                    screenWidth * 0.01) -
                                                (screenHeight * 0.02 * 3)) *
                                            0.1,
                                      ),
                                    ),
                                    chargingStatus
                                        ? Text(textScaleFactor: 0.95, "")
                                        : batteryShowValue < 51
                                            ? Icon(
                                                Icons.error,
                                                color: batteryShowValue <= 50 &&
                                                        batteryShowValue >= 20
                                                    ? Color(0xFFFF8329)
                                                    : Color(0xFFED4645),
                                              )
                                            : Text(textScaleFactor: 0.95, ""),
                                  ],
                                ),
                              ],
                            ),
                          )
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 0.06,
              ),
              saveToBin
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color.fromRGBO(133, 95, 225, 1),
                            Color.fromRGBO(158, 125, 222, 1),
                            Color.fromRGBO(166, 107, 211, 1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            toogleBinSave();
                            _onItemTapped(0);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0.0,
                          padding: EdgeInsets.all(0),
                          minimumSize:
                              Size(screenWidth * 0.43, screenHeight * 0.1),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            textScaleFactor: 0.95,
                            "동작 완료",
                            style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: screenWidth,
                      height: screenHeight * 0.1,
                      decoration: connectedDevice == null ||
                              leadStatus == "" ||
                              leadStatus == "0" ||
                              batteryShowValue < 50
                          ? BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color.fromRGBO(103, 94, 108, 1),
                                  Color.fromRGBO(75, 63, 79, 1),
                                  Color.fromRGBO(72, 60, 77, 1),
                                  Color.fromRGBO(72, 60, 77, 1),
                                  Color.fromRGBO(72, 60, 77, 1),
                                  Color.fromRGBO(72, 60, 77, 1),
                                  Color.fromRGBO(72, 60, 77, 1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            )
                          : BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color.fromRGBO(133, 95, 225, 1),
                                  Color.fromRGBO(158, 125, 222, 1),
                                  Color.fromRGBO(166, 107, 211, 1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (connectedDevice == null) {
                            showSuccessDialog(context, '디바이스를 연결해주세요.');
                          } else if (leadStatus == "" || leadStatus == "0") {
                            showSuccessDialog(context, '디바이스를 정확히 부착해주세요.');
                          } else if (await prefs.getBool('calibrationDone') ==
                              false) {
                            showSuccessDialog(
                                context, '최초 신호입력은 Align Process에서\n실행해주세요.');
                          } else if (batteryShowValue < 85 &&
                              batteryShowValue > 50) {
                            setState(() {
                              toogleBinSave();
                            });
                            showSuccessDialog(context, '디바이스 배터리를 충전해주세요.');
                          } else if (batteryShowValue < 50) {
                            showSuccessDialog(context, '디바이스 배터리를 충전해주세요.');
                          } else {
                            setState(() {
                              toogleBinSave();
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                          padding: EdgeInsets.all(0),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(10),
                          child: Text(
                            textScaleFactor: 0.95,
                            "동작 시작",
                            style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              connectedDevice == null ||
                      leadStatus == "" ||
                      leadStatus == "0" ||
                      batteryShowValue < 50
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error,
                          color: Color(0xFFED4645),
                          size: screenHeight * 0.02,
                        ),
                        SizedBox(
                          width: screenWidth * 0.01,
                        ),
                        Text(
                          textScaleFactor: 0.95,
                          "디바이스 상태를 확인해주세요.",
                          style: TextStyle(
                            fontFamily: 'Pretendart',
                            fontSize: screenHeight * 0.02,
                            color: Colors.white,
                          ),
                        )
                      ],
                    )
                  : saveToBin
                      ? Text(
                          textScaleFactor: 0.95,
                          "동작중입니다.",
                          style: TextStyle(
                            fontFamily: 'Pretendart',
                            fontSize: screenHeight * 0.02,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          textScaleFactor: 0.95,
                          "동작 시작을 놀러주세요.",
                          style: TextStyle(
                            fontFamily: 'Pretendart',
                            fontSize: screenHeight * 0.02,
                            color: Colors.white,
                          ),
                        )
            ],
          ),
        ),
      ),

      // TAB 4
      SingleChildScrollView(
        child: Container(
          height: screenHeight,
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.05,
                    ),
                    Text(
                      textScaleFactor: 0.95,
                      "정보",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: screenWidth,
                        child: Text(
                          textScaleFactor: 0.95,
                          "히스토리",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: (screenWidth * 0.9),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 1.2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "해당일 이갈이 횟수",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "$latestBrEpisode",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 1.2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "해당주간 최대 횟수",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "$highestBrMax",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 1.7,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "최근 정보 조회일",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: latestData == ""
                                    ? Text(
                                        textScaleFactor: 0.95,
                                        "선택일 기록 없음",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      )
                                    : Text(
                                        textScaleFactor: 0.95,
                                        "$latestData",
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontFamily: 'Pretendart',
                                            fontSize: screenHeight * 0.02,
                                            color: Color(0xFFB6B7BA)),
                                      ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BruxismHistory()));
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 144, 122, 197),
                              minimumSize: Size(
                                  screenWidth * 0.35, screenHeight * 0.055),
                            ),
                            child: Text(
                              textScaleFactor: 0.95,
                              'Details',
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: screenWidth,
                        child: Text(
                          textScaleFactor: 0.95,
                          "Information",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: screenHeight * 0.025,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: screenWidth * 0.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "Device",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "GooDeeps",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "Android",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "${osVersion!}",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "Certificate Key",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "TBD",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "App",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "GooDeeps V1.0",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "Firmware",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "V2.10.7",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.01,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: screenWidth,
                        child: Text(
                          textScaleFactor: 0.95,
                          "Contact Us",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontFamily: 'Pretendart',
                              fontSize: screenHeight * 0.022,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 0.02,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: screenWidth * 0.9,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "Company",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "(주)미라클레어",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenHeight * 0.02,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: (screenWidth * 0.9) / 2,
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "Homepage",
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  textScaleFactor: 0.95,
                                  "www.miraclare.com",
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                      fontFamily: 'Pretendart',
                                      fontSize: screenHeight * 0.02,
                                      color: Color(0xFFB6B7BA)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: screenHeight * 0.065,
                child: Image.asset('assets/images/logotransparent.png'),
              ),
              SizedBox(
                height: screenHeight * 0.015,
              ),
              Container(
                height: screenHeight * 0.025,
                child: Image.asset('assets/images/certificate.png'),
              ),
              SizedBox(
                height: screenHeight * 0.015,
              ),
              Text(
                textScaleFactor: 0.95,
                "Copyright © 2023 Miraclare Co., Ltd.\nAll rights reserved.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Pretendart',
                    fontSize: screenHeight * 0.018,
                    color: Color(0xFFB6B7BA)),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
            ],
          ),
        ),
      ),

      // TAB 5
      Container(
        height: screenHeight,
        width: screenWidth,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF110925), Color(0xFF2A0C54)],
          ),
        ),
      ),
    ];
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex == 2) {
          return await showDialog(
            context: context,
            barrierDismissible: true,
            builder: (BuildContext context) {
              return AlertDialog(
                contentPadding: EdgeInsets.zero,
                content: Container(
                  width: screenWidth,
                  padding: EdgeInsets.only(
                    top: 50,
                    left: 30,
                    right: 30,
                    bottom: 5,
                  ),
                  color: Colors.black,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Center(
                        child: Text(
                          textScaleFactor: 0.95,
                          "로그아웃하고 디바이스를\n연결 해제하시겠습니까?",
                          style: TextStyle(
                            fontFamily: 'Pretendart',
                            color: Colors.white,
                            fontSize: screenHeight * 0.02,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.05,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: () {
                              logout(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                            child: Text(
                              textScaleFactor: 0.95,
                              '확인',
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              setState(() {
                                _selectedIndex = _selectedIndex;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                            child: Text(
                              textScaleFactor: 0.95,
                              '취소',
                              style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.02,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else {
          setState(() {
            _selectedIndex = 2;
          });
          return false;
        }
      },
      child: Scaffold(
        appBar: _selectedIndex == 0
            ? AppBar(
                title: Text(
                  textScaleFactor: 0.95,
                  "평가",
                ),
                backgroundColor: Color(0xFF0F0D2B),
                centerTitle: true,
                elevation: 0,
                automaticallyImplyLeading: false,
              )
            : null,
        body: Stack(
          children: [
            Container(
              height: screenHeight,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF110925), Color(0xFF2A0C54)],
                ),
              ),
              child: Container(
                margin: _selectedIndex == 0 ? null : EdgeInsets.only(top: 10),
                child: _widgetOptions.elementAt(_selectedIndex),
              ),
            ),
            if (isHelpOverlayVisible)
              GestureDetector(
                onTap: hideHelpOverlay,
                child: Stack(
                  children: [
                    PageView.builder(
                      itemCount: helpImages.length,
                      onPageChanged: (int page) {
                        setState(() {
                          currentPage = page;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.black.withOpacity(0.8),
                          child: Center(
                            child: Image.asset(
                              helpImages[index],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 40,
                      right: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              hideHelpOverlay();
                              currentPage = 0;
                            },
                            child: Row(
                              children: [
                                Text(
                                  textScaleFactor: 0.95,
                                  "닫기",
                                  style: TextStyle(
                                    color: Color(0xFFFFE55B),
                                    fontSize: screenHeight * 0.025,
                                  ),
                                ),
                                SizedBox(
                                  width: screenWidth * 0.005,
                                ),
                                Icon(
                                  Icons.cancel,
                                  color: Color(0xFFFFE55B),
                                  size: screenHeight * 0.025,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          helpImages.length,
                          (index) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 5),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == currentPage
                                    ? Color(0xFFFFE55B)
                                    : Color(0xFFFFFFFF),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF231B3D),
          selectedItemColor: Colors.white,
          unselectedItemColor: Color(0xFF817C99),
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: '평가',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: '설정',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: '메인',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.info),
              label: '정보',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: '로그아웃',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  Widget buildButton(int index, String label, Color color) {
    return Container(
      height: screenHeight * 0.08,
      width: screenWidth,
      child: ElevatedButton(
        onPressed: () {
          selectButton(index);
          setState(() {
            if (qCounter == 1) {
              _value = index.toDouble();
              vasTotal = index;
            }
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selectedButtonIndex == index ? Color(0xFF714AC6) : color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
        child: Container(
          padding: EdgeInsets.only(left: 2),
          child: Align(
            alignment: qCounter == 1 ? Alignment.center : Alignment.centerLeft,
            child: Text(
              textScaleFactor: 0.95,
              label,
              style: qCounter == 1
                  ? TextStyle(
                      color: Colors.white, fontSize: screenHeight * 0.0195)
                  : TextStyle(
                      color: Colors.white, fontSize: screenHeight * 0.022),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // show success dialog
  Future<void> showSuccessDialog(BuildContext context, String status) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: screenWidth,
            padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    textScaleFactor: 0.95,
                    status,
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                ElevatedButton(
                  onPressed: () {
                    if (status.contains("Align")) {
                      _subscription?.cancel().then(
                        (_) {
                          setState(() {
                            _selectedIndex = 1;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CalibrationSetting(
                                    connectedDevice: connectedDevice),
                              ),
                            );
                          });
                        },
                      );
                      Navigator.pop(context);
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                  child: Text(
                    textScaleFactor: 0.95,
                    '확인',
                    style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screenHeight * 0.02),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // show reset dialog
  Future<void> showInitDialog(BuildContext context, String status) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: screenWidth,
            padding: EdgeInsets.only(top: 50, left: 30, right: 30, bottom: 5),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    textScaleFactor: 0.95,
                    status,
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        sendUARTCommand("SB+" + "init" + r"\" + "n");
                        prefs.setInt('vibrationPattern', 0);
                        prefs.setDouble('vibrationIntensity', 5);
                        prefs.setString('vibPatternName', "Night");
                        prefs.setInt('vthValue', 320);
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              textScaleFactor: 0.95,
                              '디바이스가 초기화되었습니다.',
                              style: TextStyle(
                                  fontFamily: 'Pretendart',
                                  fontSize: screenHeight * 0.020),
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        textScaleFactor: 0.95,
                        '확인',
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.02,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        textScaleFactor: 0.95,
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.02,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // show logout dialog
  Future<void> showLogoutDialogue(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: screenWidth,
            padding: EdgeInsets.only(
              top: 50,
              left: 30,
              right: 30,
              bottom: 5,
            ),
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Text(
                    textScaleFactor: 0.95,
                    "로그아웃하고 디바이스를\n연결 해제하시겠습니까?",
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      color: Colors.white,
                      fontSize: screenHeight * 0.02,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: screenHeight * 0.05,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        textScaleFactor: 0.95,
                        '확인',
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.02,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                      child: Text(
                        textScaleFactor: 0.95,
                        '취소',
                        style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.02,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// class for function in tab 1 (evaluation)
class _SfThumbShape extends SfThumbShape {
  @override
  void paint(PaintingContext context, Offset center,
      {required RenderBox parentBox,
      required RenderBox? child,
      required SfSliderThemeData themeData,
      SfRangeValues? currentValues,
      dynamic currentValue,
      required Paint? paint,
      required Animation<double> enableAnimation,
      required TextDirection textDirection,
      required SfThumb? thumb}) {
    final Path path = Path();

    path.moveTo(center.dx, center.dy);
    path.lineTo(center.dx + 10, center.dy - 15);
    path.lineTo(center.dx - 10, center.dy - 15);
    path.close();
    context.canvas.drawPath(path, Paint()..color = Color(0xFFFFC71B));
  }
}
