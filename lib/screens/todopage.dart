import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tasktodo/screens/add_todo.dart';
import 'package:http/http.dart' as http;

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List items = [];
  bool isLoding = true;
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // setState(() {
    //   isLoding = true;
    // });
    const url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoding = false;
    });
  }

  Future<void> deleteItem(String id) async {
    //delete the item
    setState(() {
      isLoding = true;
    });
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);

    if (response.statusCode == 200) {
      final filteredItem =
          items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filteredItem;
      });
    } else {}
    setState(() {
      isLoding = false;
    });
  }

  Future<void> naviateEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => AddTodo(todoItem: item),
    );
    setState(() {
      isLoding = true;
    });
    await Navigator.push(context, route);
    fetchData();
  }

  Future<void> navigatePage() async {
    final route = MaterialPageRoute(
      builder: (context) => const AddTodo(),
    );
    setState(() {
      isLoding = true;
    });
    await Navigator.push(context, route);
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        title: const Text("My Task"),
        centerTitle: true,
      ),
      body: Visibility(
        visible: isLoding,
        replacement: RefreshIndicator(
          onRefresh: fetchData,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map;
              final title = item['title'];
              final description = item['description'];
              final id = item['_id'] as String;
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.black,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                  title: Text(title),
                  subtitle: Text(description),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'edit') {
                        naviateEditPage(item);
                      } else if (value == 'delete') {
                        deleteItem(id);
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        )
                      ];
                    },
                  ),
                ),
              );
            },
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.green,
            strokeWidth: 1,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: navigatePage,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }
}
