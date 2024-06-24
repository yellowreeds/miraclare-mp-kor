import 'package:goodeeps2/constants.dart';
import 'package:goodeeps2/models/evaluation_request_model.dart';
import 'package:goodeeps2/models/evaluation_response_model.dart';
import 'package:goodeeps2/services/api_request.dart';

class EvaluationService {
  Future saveEvaluation(EvaluationRequestModel item) async {
    RequestBody body = {
      BodyParam.userId: item.userId,
      BodyParam.painIntensity: item.painIntensity,
      BodyParam.vibrationItensity: item.vibrationIntensity,
      BodyParam.vibrationFrequency: item.vibrationFrequency
    };

    final evaluationResponseModel =
        await APIRequest.request<EvaluationResponseModel>(
            method: HTTPMethod.post,
            path: APIPath.evaluation,
            headers: [HTTPHeader.authorization],
            body: body,
            fromJsonT: (json) =>
                EvaluationResponseModel.fromJson(json as Map<String, dynamic>));
    if (evaluationResponseModel != null) {
      return;
    }
  }
}
