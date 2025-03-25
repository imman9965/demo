import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.labelText,
  });

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ),
      ),
    );
  }
}