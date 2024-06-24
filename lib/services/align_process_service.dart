import 'package:goodeeps2/models/align_process_model.dart';
import 'package:goodeeps2/models/evaluation_response_model.dart';
import 'package:goodeeps2/services/api_request.dart';

class AlignProcessService {
  Future saveAlignProcess(AlignProcessModel item) async {
    RequestBody body = {
      BodyParam.meanRaw: item.meanRaw,
      BodyParam.stdRaw: item.stdRaw,
      BodyParam.meanEmg: item.meanEmg,
      BodyParam.max: item.max,
      BodyParam.min: item.min,
      BodyParam.stdEmg: item.stdEmg,
      BodyParam.maa: item.maa
    };

    final responseModel =
        await APIRequest.request<AlignProcessModel>(
            method: HTTPMethod.post,
            path: APIPath.alignProcess,
            headers: [HTTPHeader.authorization],
            body: body,
            fromJsonT: (json) =>
                AlignProcessModel.fromJson(json as Map<String, dynamic>));
    if (responseModel != null) {
      return;
    }
  }
}
