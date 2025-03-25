import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/patient_model.dart';
import '../models/patient_model.dart';


class CustomDropdown extends StatelessWidget {
  final RxList<Stat> states;
  final Rxn<int> selectedStateId;
  final String label;
  final void Function(int?)? onChanged;

  const CustomDropdown({
    Key? key,
    required this.states,
    required this.selectedStateId,
    required this.onChanged,
    this.label = 'Select State',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() => DropdownButtonFormField<int>(
      value: selectedStateId.value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
      items: states.map((state) {
        return DropdownMenuItem<int>(
          value: state.id,
          child: Text(state.name),
        );
      }).toList(),
      onChanged: onChanged,
    ));
  }
}
