import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/new_task_controller.dart';

class NewTaskView extends GetView<NewTaskController> {
  const NewTaskView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NewTaskView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'NewTaskView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
