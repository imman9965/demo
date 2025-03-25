import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../models/auth_response.dart';
import '../models/student.dart';
import '../models/track.dart';
import '../services/api_services.dart';
import '../services/secure_storage.dart';

class Controller extends GetxController {
  final SecureStorage secureStorage = SecureStorage();
  final ApiService apiService = ApiService();

  var isLoading = false.obs;
  var authResponse = Rxn<Auth>();
  var student = Rxn<Student>();
  var select = <Stat>[].obs;
  var selectedId = Rxn<int>();

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await apiService.login(email, password);

      if (response != null) {
        authResponse.value = response;
        await secureStorage.add('token', response.stok);
        await secureStorage.add('uid', response.uid.toString());
        // await secureStorage.add('id', response.uid.toString());
        await secureStorage.add('name', response.roles[0].name.toString());
        await secureStorage.add('id', response.roles[0].id.toString());





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
      var k = await secureStorage.get('name');
      print(k.toString()+"nskj");



      if (patient != null) {
        student.value = patient;
        selectedId.value = int.tryParse(patient.state);
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
      select.value = await apiService.getStates(token);
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

  Future<bool> updatePatientData(Student patient) async {
    try {
      isLoading.value = true;
      final token = await secureStorage.get('token');
      final success = await apiService.updatePatientData(patient, token);

      if (success) {
        student.value = patient;
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
    student.value = null;
    select.clear();
    selectedId.value = null;
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
      final name = await secureStorage.get('name');
      final id = await secureStorage.get('id');


      if (token.isNotEmpty && uid.isNotEmpty) {
        final isValidToken = await apiService.validateToken(token,uid);
        if (isValidToken) {
          authResponse.value = Auth(
            auth: true,
            stok: token,
            uid: int.parse(uid),
            roles: [Role(id: int.parse(id), name: name)],
            passwordReset: false,
            message: 'Auto-login successful',
          );
          await getPatientData();
          if (student.value != null) {
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