import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
// import 'package:tasktodo/screens/todopage.dart';

class AddTodo extends StatefulWidget {
  final Map? todoItem;
  const AddTodo({super.key, this.todoItem});

  @override
  State<AddTodo> createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  bool isLoading = false;
  bool isEdited = false;
  final titleController = TextEditingController();
  final descController = TextEditingController();

  Future<void> submitData() async {
    setState(() {
      isLoading = true;
    });
    if (titleController.text.isNotEmpty && descController.text.isNotEmpty) {
      const url = 'https://api.nstack.in/v1/todos';
      final uri = Uri.parse(url);
      final body = {
        "title": titleController.text,
        "description": descController.text,
        "is_completed": false
      };
      final response = await http.post(
        uri,
        body: jsonEncode(body),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 201) {
        titleController.text = '';
        descController.text = '';
        showSuccessMessage('Submitted successfully');
      }
    } else {
      showErrorMessage('Fields are required');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> updateData() async {
    final todo = widget.todoItem;
    if (todo == null) {
      // print("You cannot call updated with todo data");
      return;
    }
    final id = todo['_id'];
    final title = titleController.text;
    final description = descController.text;

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final body = {
      "title": title,
      "description": description,
      "is_completed": false
    };
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      showSuccessMessage('Updated successfully');
    } else {
      showErrorMessage('Faild to update');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  @override
  void initState() {
    super.initState();
    final todo = widget.todoItem;
    if (todo != null) {
      isEdited = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title:
            isEdited == true ? const Text('Edit Taks') : const Text("Add Task"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descController,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: 'Decoration',
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            isLoading == true
                ? const CircularProgressIndicator(
                    color: Colors.green,
                    strokeWidth: 1,
                  )
                : ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: isEdited ? updateData : submitData,
                    child: Text(isEdited ? 'Update' : 'Submit'),
                  ),
          ],
        ),
      ),
    );
  }
}
