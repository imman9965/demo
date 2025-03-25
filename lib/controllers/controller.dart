import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/auth_response.dart';
import '../models/patients_response.dart';
import '../models/patient_model.dart';
import '../services/api_services.dart';
import '../services/secure_storage.dart';

class Controller extends GetxController {
  final SecureStorage secureStorage = SecureStorage();
  final ApiService apiService = ApiService();

  var isLoading = false.obs;
  var authResponse = Rxn<Auth>();
  var patientData = Rxn<patients>();
  var states = <Stat>[].obs;
  var selectedStateId = Rxn<int>();

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await apiService.login(email, password);

      if (response != null) {
        authResponse.value = response;
        await secureStorage.add('token', response.stok);
        await secureStorage.add('uid', response.uid.toString());
        await getPatientData();
        await getStates();
        Get.offAllNamed('/home');
        debugPrint('Login successful');
        return true;
      }
      Get.snackbar('Error', 'Invalid credentials');
      return false;
    } catch (e) {
      debugPrint('Login error: $e');
      Get.snackbar('Error', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPatientData() async {
    try {
      if (authResponse.value == null) return;

      isLoading.value = true;
      final token = await secureStorage.get('token');
      final patient = await apiService.getPatientData(authResponse.value!.uid, token);

      if (patient != null) {
        patientData.value = patient;
        selectedStateId.value = int.tryParse(patient.state);
      } else {
        debugPrint('No patient data received');
      }
    } catch (e) {
      debugPrint('Get patient data error: $e');
      if (e.toString().contains('Token expired')) {
        Get.snackbar('Session Expired', 'Your session has expired. Please log in again.');
        logout();
      } else {
        Get.snackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getStates() async {
    try {
      isLoading.value = true;
      final token = await secureStorage.get('token');
      states.value = await apiService.getStates(token);
    } catch (e) {
      debugPrint('Get states error: $e');
      if (e.toString().contains('Token expired')) {
        Get.snackbar('Session Expired', 'Your session has expired. Please log in again.');
        logout();
      } else {
        Get.snackbar('Error', e.toString());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePatientData(patients patient) async {
    try {
      isLoading.value = true;
      final token = await secureStorage.get('token');
      final success = await apiService.updatePatientData(patient, token);

      if (success) {
        patientData.value = patient;
        Get.snackbar('Success', 'Profile updated successfully');
        return true;
      }
      Get.snackbar('Error', 'Failed to update profile');
      return false;
    } catch (e) {
      debugPrint('Update patient data error: $e');
      if (e.toString().contains('Token expired')) {
        Get.snackbar('Session Expired', 'Your session has expired. Please log in again.');
        logout();
      } else {
        Get.snackbar('Error', e.toString());
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    authResponse.value = null;
    patientData.value = null;
    states.clear();
    selectedStateId.value = null;
    secureStorage.delete('token');
    secureStorage.delete('uid');
    Get.offAllNamed('/login');
    debugPrint('User logged out');
  }

  @override
  void onInit() {
    super.onInit();
    checkExistingSession();
  }

  Future<void> checkExistingSession() async {
    try {
      isLoading.value = true;
      final token = await secureStorage.get('token');
      final uid = await secureStorage.get('uid');
      if (token.isNotEmpty && uid.isNotEmpty) {
        final isValidToken = await apiService.validateToken(token,uid);
        if (isValidToken) {
          authResponse.value = Auth(
            auth: true,
            stok: token,
            uid: int.parse(uid),
            roles: [Role(id: 4, name: 'patient')],
            passwordReset: false,
            message: 'Auto-login successful',
          );
          await getPatientData();
          if (patientData.value != null) {
            await getStates();
            Get.offAllNamed('/home');
            debugPrint('Auto-login successful, navigated to home');
          } else {
            logout();
            debugPrint('No patient data, logged out');
          }
        } else {
          logout();
          debugPrint('Invalid token, logged out');
        }
      } else {
        // Only navigate to login if not already there
        if (Get.currentRoute != '/login') {
          Get.offAllNamed('/login');
        }
        debugPrint('No token or UID found, staying on login or redirecting');
      }
    } catch (e) {
      debugPrint('Check existing session error: $e');
      Get.snackbar('Error', 'Session check failed: $e');
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    } finally {
      isLoading.value = false;
    }
  }
}