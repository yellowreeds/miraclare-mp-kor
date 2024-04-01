import 'package:flutter/material.dart';
import 'package:goodeeps2/screens/member_registration_page.dart';

class TermsAgreement extends StatefulWidget {
  const TermsAgreement({super.key});

  @override
  State<TermsAgreement> createState() => _TermsAgreementState();
}

class _TermsAgreementState extends State<TermsAgreement> {
  double screenHeight = 0;
  double screenWidth = 0;
  bool PITCGAgree = false;
  bool IODCAUgree = false;
  bool allAgree = false;

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    if (mediaQueryData.orientation == Orientation.portrait) {
      screenHeight = MediaQuery.of(context).size.height;
      screenWidth = MediaQuery.of(context).size.width;
    } else {
      screenWidth = MediaQuery.of(context).size.height;
      screenHeight = MediaQuery.of(context).size.width;
    }
    final String termsAndConditions =
        '''GooDeeps에 오신 것을 환영합니다! 본 개인정보 이용 약관 안내서("안내서")는 앱을 사용하는 동안 귀하의 개인정보가 어떻게 수집, 사용, 공개, 보호되는지에 대해 설명합니다. 앱을 사용함으로써 귀하는 이 안내서에 기재된 약관에 동의합니다. 귀하의 개인정보가 어떻게 처리되는지 자세히 이해하시려면 주의 깊게 읽어주세요.
\n1. 수집하는 정보
1.1. 개인정보: 귀하가 앱을 사용하는 동안 이름, 이메일 주소, 전화번호 및 앱을 사용하는 동안 제출하는 기타 정보와 같은 일부 개인식별 정보를 자발적으로 제공할 수 있습니다.
1.2. 사용자 데이터: 앱과의 상호작용에 관한 비개인식별 정보인 기기 정보, IP 주소, 브라우징 활동 및 기타 사용 데이터를 수집할 수도 있습니다.

\n2. 정보 이용 방법
2.1. 서비스 제공: 개인정보를 사용하여 서비스를 제공하고 개선하며, 귀하의 경험을 개인화하며, 문의 사항과 피드백에 대응합니다.
2.2. 커뮤니케이션: 이메일 주소를 사용하여 앱과 관련된 중요한 업데이트, 프로모션 자료 또는 기타 정보를 전송할 수 있습니다. 언제든지 이러한 커뮤니케이션 수신을 거부할 수 있습니다.
2.3. 분석: 사용 데이터를 분석하고 집계하여 앱 사용 동향을 파악하고 서비스를 개선할 수 있습니다.

\n3. 정보 공유 및 제공
3.1. 제3자 서비스 제공자: 우리는 앱 운영과 서비스 제공을 돕는 신뢰할 수 있는 제3자 서비스 제공자와 귀하의 개인정보를 공유할 수 있습니다. 이러한 제공자는 비밀유지 계약에 따라 귀하의 정보를 우리를 돕는 목적 외에는 사용하지 않습니다.
3.2. 법적 준수: 귀하의 정보를 법률에 따라 또는 우리의 권리, 재산 또는 안전, 또는 다른 사람들의 권리, 재산 또는 안전을 보호하기 위해 공개할 수 있습니다.

\n4. 보안
4.1. 데이터 보안: 귀하의 개인정보를 무단 접근, 손실, 오용 또는 변경으로부터 보호하기 위해 합리적인 조치를 취합니다. 그러나 인터넷을 통한 전송 방법이나 전자 저장 방법은 100% 안전하지 않으며 절대적인 보안을 보장할 수 없습니다.

\n5. 귀하는 다음과 같은 선택권이 있습니다
5.1. 개인정보 업데이트: 앱 설정 내에서 개인정보를 검토 및 업데이트하거나 지원팀에 문의할 수 있습니다.
5.2. 데이터 삭제: 계정 및 관련 개인정보를 삭제하려면 저희에게 연락하시면 신속히 처리해드리겠습니다.

\n6. 어린이의 개인정보보호
6.1. 우리의 앱은 13세 미만의 어린이를 대상으로 하지 않습니다. 우리는 의도적으로 13세 미만 어린이로부터 개인정보를 수집하지 않습니다. 만약 귀하가 부모 또는 후견인이고 귀하의 자녀가 개인정보를 제공한 것으로 판단되면 저희에게 연락하시면 해당 정보를 삭제하도록 조치하겠습니다.

\n7. 안내서 변경 사항
7.1. 우리는 필요한 경우 본 안내서를 업데이트할 수 있습니다. 가장 최신 버전은 앱 내에서 게시됩니다. 변경 사항이 발생한 후에도 앱을 계속 사용함으로써 수정된 약관에 동의하는 것으로 간주됩니다.

\n8. 연락처 정보
이 안내서 또는 개인정보 처리에 관한 궁금한 사항이나 우려사항이 있으시면 다음으로 연락해주시기 바랍니다:
jhbyun@miraclare.com

GooDeeps를 이용해주셔서 감사합니다!
Miraclare Co. Ltd.''';

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: screenHeight,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/bg2.png'),
              fit: BoxFit.fill,
            ),
            color: Color.fromRGBO(255, 255, 255, 0.1),
          ),
          padding: EdgeInsets.all(15),
          child: Column(
            children: [
              SizedBox(
                height: screenHeight * 0.08,
              ),
              Center(
                child: Container(
                  width: screenWidth,
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  child: Text(
                    textScaleFactor: 0.8,
                    "회원가입 이용약관",
                    style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screenHeight * 0.03,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.02,
              ),
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(5),
                child: Text(
                  textScaleFactor: 0.8,
                  "개인정보 이용약관 안내",
                  style: TextStyle(
                      fontFamily: 'Pretendart',
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Center(
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.2,
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      textScaleFactor: 0.8,
                      termsAndConditions,
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.020,
                          color: Colors.black),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor:
                          PITCGAgree ? Colors.white : Colors.grey,
                    ),
                    child: Radio(
                      value: true,
                      groupValue: PITCGAgree,
                      focusColor: PITCGAgree ? Colors.white : Colors.grey,
                      activeColor: PITCGAgree ? Colors.white : Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          PITCGAgree = value!;
                        });
                      },
                    ),
                  ),
                  Text(
                    textScaleFactor: 0.8,
                    '동의',
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      fontSize: screenHeight * 0.020,
                      color: PITCGAgree ? Colors.white : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 20),
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor:
                          !PITCGAgree ? Colors.white : Colors.grey,
                    ),
                    child: Radio(
                      value: false,
                      groupValue: PITCGAgree,
                      focusColor: !PITCGAgree ? Colors.white : Colors.grey,
                      activeColor: !PITCGAgree ? Colors.white : Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          PITCGAgree = value!;
                          allAgree = false;
                        });
                      },
                    ),
                  ),
                  Text(
                    textScaleFactor: 0.8,
                    '동의하지 않음',
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      fontSize: screenHeight * 0.020,
                      color: !PITCGAgree ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
              Container(
                width: screenWidth,
                padding: EdgeInsets.all(5),
                child: Text(
                  textScaleFactor: 0.8,
                  "데이터 수집 이용 안내",
                  style: TextStyle(
                      fontFamily: 'Pretendart',
                      fontSize: screenHeight * 0.022,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.01,
              ),
              Center(
                child: Container(
                  width: screenWidth,
                  height: screenHeight * 0.2,
                  padding: EdgeInsets.all(5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(5),
                    child: Text(
                      textScaleFactor: 0.8,
                      termsAndConditions,
                      style: TextStyle(
                          fontFamily: 'Pretendart',
                          fontSize: screenHeight * 0.020,
                          color: Colors.black),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor:
                          IODCAUgree ? Colors.white : Colors.grey,
                    ),
                    child: Radio(
                      value: true,
                      groupValue: IODCAUgree,
                      focusColor: IODCAUgree ? Colors.white : Colors.grey,
                      activeColor: IODCAUgree ? Colors.white : Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          IODCAUgree = value!;
                        });
                      },
                    ),
                  ),
                  Text(
                    textScaleFactor: 0.8,
                    '동의',
                    style: TextStyle(
                      fontFamily: 'Pretendart',
                      fontSize: screenHeight * 0.020,
                      color: IODCAUgree ? Colors.white : Colors.grey,
                    ),
                  ),
                  SizedBox(width: 20),
                  Theme(
                    data: ThemeData(
                      unselectedWidgetColor:
                          !IODCAUgree ? Colors.white : Colors.grey,
                    ),
                    child: Radio(
                      value: false,
                      groupValue: IODCAUgree,
                      activeColor: !IODCAUgree ? Colors.white : Colors.grey,
                      focusColor: !IODCAUgree ? Colors.white : Colors.grey,
                      onChanged: (value) {
                        setState(() {
                          IODCAUgree = value!;
                          allAgree = false;
                        });
                      },
                    ),
                  ),
                  Text(
                    textScaleFactor: 0.8,
                    '동의하지 않음',
                    style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screenHeight * 0.020,
                        color: !IODCAUgree ? Colors.white : Colors.grey),
                  ),
                ],
              ),
              SizedBox(
                height: screenHeight * 0.04,
              ),
              SizedBox(
                width: screenWidth,
                height: screenHeight * 0.07,
                child: ElevatedButton(
                  onPressed: () {
                    if (IODCAUgree && PITCGAgree) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MemberRegistration()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            textScaleFactor: 0.8,
                            '모든 약관에 동의해야 합니다.',
                            style: TextStyle(
                                fontFamily: 'Pretendart',
                                fontSize: screenHeight * 0.020),
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(113, 74, 198, 1)),
                  child: Text(
                    textScaleFactor: 0.8,
                    '다음',
                    style: TextStyle(
                        fontFamily: 'Pretendart',
                        fontSize: screenHeight * 0.020),
                  ),
                ),
              ),
              SizedBox(
                height: screenHeight * 0.03,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
