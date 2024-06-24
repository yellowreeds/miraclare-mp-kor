import 'package:hex/hex.dart';

class ProcessHelper {
  static List<String> toHexStringListWithPattenA55A(List<int> data) {
    final hex = HEX.encode(data);
    final List<String> chunks = RegExp(r'(a5.{32}5a)')
        .allMatches(hex)
        .map((match) => match.group(0))
        .whereType<String>() // null 값을 제거하고 String 타입만 남김
        .toList();
    return chunks;
  }

  static List<int> toBytes(List<String> hexDataList) {
    final List<int> filteredRawData = hexDataList
        .map((hexData) => toSingleRawData(hexData))
        .expand((x) => x)
        .toList();
    return filteredRawData;
  }

  static List<int> toSingleRawData(String chunk) {
    List<int> filteredRawData = [];
    for (int i = 0; i < chunk.length; i += 2) {
      String part = chunk.substring(i, i + 2);
      filteredRawData.add(int.parse(part, radix: 16));
    }
    return filteredRawData;
  }

  static List<int> extractRawEMGDataList(String hexData) {
    int startIndex = 6;
    int endIndex = 10;
    int mask = 0xFFFF;

    List<int> emgData = [];

    for (int j = 0; j < 4; j++) {
      int parsedEMGData =
          int.parse(hexData.substring(startIndex, endIndex), radix: 16) & mask;
      emgData.add(parsedEMGData); // Add parsed data to the array
      startIndex += 4;
      endIndex += 4;
    }

    return emgData;
  }
}
