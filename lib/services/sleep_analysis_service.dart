import 'dart:io';

import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/models/evaluation_response_model.dart';
import 'package:goodeeps2/models/sleep_analysis_model.dart';
import 'package:goodeeps2/services/api_request.dart';

class SleepAnalysisService {
  Future uploadSleepAnalysis(File file) async {
    final responseModel = await APIRequest.uploadFile<SleepAnalysisModel>(
        path: APIPath.sleepAnalysis,
        file: file,
        fromJsonT: (json) =>
            SleepAnalysisModel.fromJson(json as Map<String, dynamic>));

    if (responseModel != null) {
      logger.i(responseModel);

    }
  }
}
