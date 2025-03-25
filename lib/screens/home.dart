import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controller.dart';
import '../models/track.dart';
import '../widget/custom_button.dart';
import '../models/student.dart';
import '../widget/CustomTextField.dart';
import '../widget/custom_dropdown.dart';
import '../widget/date_field.dart';
import 'about_us_screen.dart';

class HomeScreen extends StatelessWidget {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Controller>(
      builder: (ctrl) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Profile'),
            actions: [
              IconButton(
                icon: const Icon(Icons.record_voice_over),
                onPressed: () => Get.to(const AboutUsScreen()),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: ctrl.logout,
              ),
            ],
          ),
          body: Obx(
            () =>
                ctrl.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ctrl.student.value == null
                    ? const Center(child: Text('No patient data'))
                    : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Initialize controllers with patient data
                          initializeControllers(ctrl),
                          CustomTextField(
                            controller: firstNameController,
                            labelText: 'First Name',
                          ),
                          CustomTextField(
                            controller: lastNameController,
                            labelText: 'Last Name',
                          ),
                          DatePickerField(
                            controller: dobController,
                            labelText: 'Date of Birth (YYYY-MM-DD)',
                          ),
                          CustomTextField(
                            controller: cityController,
                            labelText: 'City',
                          ),
                          CustomDropdown(
                            states: ctrl.select,
                            selectedStateId: ctrl.selectedId,
                            onChanged:
                                (value) => ctrl.selectedId.value = value,
                          ),
                          const SizedBox(height: 8),
                          CustomTextField(
                            controller: contactController,
                            labelText: 'Contact Number',
                            keyboardType: TextInputType.phone,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Email: ${ctrl.student.value!.emailId}',
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            text: 'Save Changes',
                            onPressed: () => saveChanges(ctrl),
                          ),
                        ],
                      ),
                    ),
          ),
        );
      },
    );
  }

  // Helper method to initialize controllers
  Widget initializeControllers(Controller ctrl) {
    firstNameController.text = ctrl.student.value!.firstName;
    lastNameController.text = ctrl.student.value!.lastName;
    cityController.text = ctrl.student.value!.cityN;
    contactController.text = ctrl.student.value!.contactNo;
    dobController.text = ctrl.student.value!.dob.split('T')[0];
    return const SizedBox.shrink();
  }

  // Helper method to save changes
  Future<void> saveChanges(Controller ctrl) async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      Get.snackbar('Error', 'Name fields cannot be empty');
      return;
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dobController.text)) {
      Get.snackbar('Error', 'Invalid date format (use YYYY-MM-DD)');
      return;
    }
    if (ctrl.selectedId.value == null) {
      Get.snackbar('Error', 'Please select a state');
      return;
    }

    final updatedPatient = Student(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      dob: dobController.text,
      cityN: cityController.text,
      state: ctrl.selectedId.value.toString(),
      contactNo: contactController.text,
      emailId: ctrl.student.value!.emailId,
      pid: ctrl.student.value!.pid,
      gender: ctrl.student.value!.gender,
      universalId: ctrl.student.value!.universalId,
      bloodGroup: ctrl.student.value!.bloodGroup,
    );

    await ctrl.updatePatientData(updatedPatient);
  }
}
