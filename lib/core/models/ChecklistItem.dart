import "package:flutter/material.dart";

class ChecklistItem {
  TextEditingController titleController;
  TextEditingController descriptionController;
  bool isRequired;
  bool isCompleted;

  ChecklistItem({
    required this.titleController,
    required this.descriptionController,
    this.isRequired = false,
    this.isCompleted = false,
  });
}
