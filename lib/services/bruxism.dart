import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Bruxism {
  Future<Map<String, dynamic>?> getSleepDataResult(
    BuildContext context,
    String custUsername, {
    String? fromDate,
    String? toDate,
  }) async {
    // if no date is specified, get the last 7 days of data from current time
    if (fromDate == null || toDate == null) {
      final currentDate = DateTime.now();
      final defaultToDate = currentDate.subtract(Duration(days: 6));
      fromDate = DateFormat('yyyy-MM-dd').format(defaultToDate);
      toDate = DateFormat('yyyy-MM-dd').format(currentDate);
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
        return jsonResponse['data'];
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
}
