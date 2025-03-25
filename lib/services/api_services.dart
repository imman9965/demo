import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../models/auth_response.dart';
import '../models/track.dart';
import '../models/student.dart';
import 'api_endpoint.dart';

class ApiService {
  Future<Auth?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginUrl}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'account_type': 'patient',
          'email_id': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return Auth.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<Student?> getPatientData(int uid, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.patientUrl}/$uid'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Student.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch patient data: $e');
    }
  }

  Future<bool> updatePatientData(Student patient, String token) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.patientUrl}/${patient.pid}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(patient.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to update patient: $e');
    }
  }

  Future<List<Stat>> getStates(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.statesUrl}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Stat.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch states: $e');
    }
  }

  Future<bool> validateToken(String token, String uid) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.patientUrl}/$uid'), // Dummy ID for validation
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        return false; // Token expired
      }
      return false;
    } catch (e) {
      debugPrint('Token validation failed: $e');
      return false;
    }
  }
}