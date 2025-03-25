import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controllers/controller.dart';
import '../widget/custom_button.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Controller>(builder: (ctrl) {
      return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: Obx(() =>
        ctrl.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Login',
                onPressed: () async {
                  bool success = await ctrl.login(
                    emailController.text,
                    passwordController.text,
                  );
                  if (success) {
                    Get.offAllNamed('/home');
                  }
                },
              ),
            ],
          ),
        )),
      );
    });
  }
}