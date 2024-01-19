import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: TodoList(),
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  List<Todo> todos = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sukalaper Note'),
      ),
      body: ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final Todo item = todos.removeAt(oldIndex);
            todos.insert(newIndex, item);
          });
        },
        children: todos.map((todo) {
          return buildTodoCard(todo);
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildTodoCard(Todo todo) {
    return Card(
      key: Key('${todo.title}'),
      color: todo.isCompleted ? Color(0xFF7FC7D9) : const Color(0xFF647D87),
      child: ListTile(
        title: Text(
          todo.title,
          style: TextStyle(
            color: todo.isCompleted ? Colors.white : Colors.white,
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Isi Tugas:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            for (String activity in todo.activities)
              Text(
                '- $activity',
                style: TextStyle(
                  color: Colors.white,
                  decoration:
                      todo.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            if (todo.deadline != null)
              Row(
                children: [
                  Text(
                    'Tenggat Waktu: ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight
                          .bold, 
                    ),
                  ),
                  Text(
                    DateFormat('dd-MM-yyyy').format(todo.deadline!),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
        onTap: () {
          setState(() {
            todo.isCompleted = !todo.isCompleted;
          });
        },
        onLongPress: () {
          editTodoDialog(todo);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Colors.white,
              onPressed: () {
                editTodoDialog(todo);
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.white,
              onPressed: () {
                deleteTodoDialog(todo);
              },
            ),
          ],
        ),
      ),
    );
  }

  void showAddDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController activityController = TextEditingController();
    List<String> activities = [];
    DateTime selectedDate =
        DateTime.now(); 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return buildAddDialog(
            titleController, activityController, activities, selectedDate);
      },
    );
  }

  AlertDialog buildAddDialog(
    TextEditingController titleController,
    TextEditingController activityController,
    List<String> activities,
    DateTime selectedDate,
  ) {
    return AlertDialog(
      title: Text('Tambah TODO'),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      content: SizedBox(
        height: MediaQuery.of(context).size.height *
            0.6, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Judul Tugas'),
            ),
            TextField(
              controller: activityController,
              decoration: InputDecoration(labelText: 'Isi Tugas'),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              onChanged: (value) {
                setState(() {
                  activities = value
                      .split('\n')
                      .where((element) => element.isNotEmpty)
                      .toList();
                });
              },
            ),
            ListTile(
              title: Text('Tenggat Waktu'),
              subtitle: Text(DateFormat('dd-MM-yyyy').format(selectedDate)),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
            ),
            for (String activity in activities) Text('- $activity'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isNotEmpty && activities.isNotEmpty) {
              setState(() {
                todos.add(
                  Todo(
                    title: titleController.text,
                    activities: List.from(activities),
                    deadline: selectedDate,
                  ),
                );
              });
              Navigator.pop(context);
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }

  void editTodoDialog(Todo todo) {
    TextEditingController titleController =
        TextEditingController(text: todo.title);
    TextEditingController activityController =
        TextEditingController(text: todo.activities.join('\n'));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return buildEditTodoDialog(todo, titleController, activityController);
      },
    );
  }

  AlertDialog buildEditTodoDialog(
    Todo todo,
    TextEditingController titleController,
    TextEditingController activityController,
  ) {
    return AlertDialog(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Edit TODO'),
          ),
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: 'Judul Tugas'),
          ),
          TextField(
            controller: activityController,
            decoration:
                InputDecoration(labelText: 'Isi Tugas (pisahkan dengan baris)'),
            maxLines: null,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Batal'),
        ),
        TextButton(
          onPressed: () {
            if (titleController.text.isNotEmpty) {
              setState(() {
                List<String> updatedActivities =
                    activityController.text.split('\n');
                todo.title = titleController.text;
                todo.activities = updatedActivities;
              });
              Navigator.pop(context);
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }

  void deleteTodoDialog(Todo todo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus TODO'),
          content: Text('Apakah Anda yakin ingin menghapus "${todo.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  todos.remove(todo);
                });
                Navigator.pop(context);
              },
              child: Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}

class Todo {
  String title;
  List<String> activities;
  bool isCompleted;
  DateTime?
    deadline; 

  Todo({
    required this.title,
    required this.activities,
    this.isCompleted = false,
    this.deadline, 
  });
}
