import 'package:goodeeps2/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';

enum FileType {
  sleepAnalysis,
  alignProcess;
}

class LocalFileManager {
  static final LocalFileManager _instance = LocalFileManager._internal();

  LocalFileManager._internal();

  static LocalFileManager get instance => _instance;

  // String? fileName = null;
  String? sleepAnalysisFilePath = null;
  String? alignProcessFilePath = null;

  Future<void> writeFile(List<int> bytes, FileType type) async {
    try {
      final Directory directory = await getTemporaryDirectory();

      switch (type) {
        case FileType.sleepAnalysis:
          if (sleepAnalysisFilePath == null) {
            final fileName = createFileName();
            sleepAnalysisFilePath = '${directory.path}/${fileName}.bin';
          }
          break;
        case FileType.alignProcess:
          if (alignProcessFilePath == null) {
            final fileName = createFileName();
            alignProcessFilePath = '${directory.path}/${fileName}.bin';
          }
          break;
      }

      final path = (type == FileType.sleepAnalysis)
          ? sleepAnalysisFilePath!
          : alignProcessFilePath!;

      final File file = File(path);

      await file.writeAsBytes(bytes, mode: FileMode.append);
    } catch (error) {
      logger.e("Error saving file:$error");
    }
  }

  // Future<void> writeAlignProcessFile(List<int> bytes) async {
  //   try {
  //     final Directory directory = await getTemporaryDirectory();
  //     if (alignProcessFilePath == null) {
  //       final fileName = createFileName();
  //       alignProcessFilePath = '${directory.path}/${fileName}.bin';
  //     }
  //     // final Directory directory = Directory("storage/emulated/0/Download");
  //
  //     final File file = File(alignProcessFilePath!);
  //     await file.writeAsBytes(bytes, mode: FileMode.append);
  //   } catch (error) {
  //     logger.e("Error saving file:$error");
  //   }
  // }

  String createFileName() {
    DateTime now = DateTime.now();
    // "yyyyMMdd_HHmmss" 형태로 포맷
    String formatted = DateFormat("yyyyMMdd_HHmmss").format(now);
    return formatted;
  }
}
