enum SurveyType {
  height,
  weight,
  usedSplint,
  usedBotox,
  sleepSymptoms,
  bruxismDuration,
  painLocation,
  painTime,
  painIntensity,
  openMouthEase,
  jawLock,
  jawDeviation,
  headacheAfterSleep,
  fatigueAfterSleep,
  teethGumPainAfterSleep,
  teethSensitivityAfterSleep,
  stressLevel,
  smoking,
  drinking;

  String get title {
    switch (this) {
      case SurveyType.height:
        return '당신의 키는 몇 cm 입니까?';
      case SurveyType.weight:
        return '당신의 몸무게는 몇 kg 입니까?';
      case SurveyType.usedSplint:
        return '당신은 이갈이 완화를 위해 스플린트를\n사용해본 경험이 있습니까?';
      case SurveyType.usedBotox:
        return '당신은 이갈이 완화를 위해\n보톡스 치료를 하신 경험이 있습니까?';
      case SurveyType.sleepSymptoms:
        return '수면에 관하여 어떤 증상이 있습니까?';
      case SurveyType.bruxismDuration:
        return '수면 이갈이를 앓은 지 얼마나 되셨습니까?';
      case SurveyType.painLocation:
        return '턱이나 치아의 통증이 있다면 어느쪽이 아픕니까?';
      case SurveyType.painTime:
        return '턱이나 치아의 통증이 있다면 언제 불편하십니까?';
      case SurveyType.painIntensity:
        return '턱이나 치아의 통증이 있다면 어느정도 아픕니까?';
      case SurveyType.openMouthEase:
        return '기상 후 입이 잘 벌어지십니까?';
      case SurveyType.jawLock:
        return '기상 후 입을 벌릴 때 자주 턱이 걸립니까?';
      case SurveyType.jawDeviation:
        return '입을 벌릴 때 틀어지십니까?';
      case SurveyType.headacheAfterSleep:
        return '기상 후 두통이 있습니까?';
      case SurveyType.fatigueAfterSleep:
        return '기상 후 피로감을 많이 느낍니까?';
      case SurveyType.teethGumPainAfterSleep:
        return '기상 후 치아 혹은 잇몸 통증을 느낍니까?';
      case SurveyType.teethSensitivityAfterSleep:
        return '기상 후 이 시림 증상을 느낍니까?';
      case SurveyType.stressLevel:
        return '당신이 느끼는 스트레스는 어느정도 입니까?';
      case SurveyType.smoking:
        return '당신은 흡연을 하고 있습니까?';
      case SurveyType.drinking:
        return '당신은 음주를 하고 있습니까?';
    }
  }

  List<String> get options {
    switch (this) {
      case SurveyType.height:
        return [
          "150cm 미만",
          "150cm - 160cm 미만",
          "160cm - 170cm 미만",
          "170cm - 180cm 미만",
          "180cm 이상"
        ];
      case SurveyType.weight:
        return [
          "50kg 미만",
          "50kg - 60kg 미만",
          "60kg - 70kg 미만",
          "70kg - 80kg 미만",
          "80kg 이상"
        ];
      case SurveyType.usedSplint:
        return ["있다", "없다"];
      case SurveyType.usedBotox:
        return ["있다", "없다"];
      case SurveyType.sleepSymptoms:
        return ["이갈기", "이악물기", "코골이", "불면증", "잘 모르겠다"];
      case SurveyType.bruxismDuration:
        return ["1개월 미만", "1~3개월 미만", "3~6개월 미만", "6개월~1년 미만", "1년 이상"];
      case SurveyType.painLocation:
        return ['왼쪽', '오른쪽', '양쪽', "잘 모르겠다"];
      case SurveyType.painTime:
        return ["기상후", '아침', "일과중", '밤', '수시로'];
      case SurveyType.painIntensity:
        return [
          "통증 없음",
          "조금 불편함",
          "불편함",
          "조금 아픔",
          "아픔",
          "많이 아픔",
          "매우 아픔",
          "극심함",
          "매우 극심함",
          "참기 힘듬",
          "매우 참기 힘듬"
        ];
      case SurveyType.openMouthEase:
        return ["매우 그렇지 않다", "그렇지 않다", "잘 모르겠다", "그렇다", "매우 그렇다"];
      case SurveyType.jawLock:
        return ["매우 그렇지 않다", "그렇지 않다", "잘 모르겠다", "그렇다", "매우 그렇다"];
      case SurveyType.jawDeviation:
        return ["매우 그렇지 않다", "그렇지 않다", "잘 모르겠다", "그렇다", "매우 그렇다"];
      case SurveyType.headacheAfterSleep:
        return ["전혀 없다", "드물다", "보통", "종종 있다", "빈번 하다"];
      case SurveyType.fatigueAfterSleep:
        return ["전혀 없다", "드물다", "보통", "종종 있다", "빈번 하다"];
      case SurveyType.teethGumPainAfterSleep:
        return ["전혀 없다", "드물다", "보통", "종종 있다", "빈번 하다"];
      case SurveyType.teethSensitivityAfterSleep:
        return ["전혀 없다", "드물다", "보통", "종종 있다", "빈번 하다"];
      case SurveyType.stressLevel:
        return ["매우 낮다", "낮다", "보통 이다", "높다", "매우 높다"];
      case SurveyType.smoking:
        return ["비흡연", "흡연 (주 1갑 미만)", "흡연 (주 2갑 이상)", "금연"];
      case SurveyType.drinking:
        return ["비음주", "음주 (주 1~2회)", "음주(주 3회 이상)", "금주"];
    }
  }
}
