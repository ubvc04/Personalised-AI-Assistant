import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class SmartCalculator extends StatefulWidget {
  const SmartCalculator({super.key});

  @override
  State<SmartCalculator> createState() => _SmartCalculatorState();
}

class _SmartCalculatorState extends State<SmartCalculator> {
  String _display = '0';
  String _expression = '';
  double _result = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Calculator')),
      body: Column(
        children: [
          // Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: Colors.black87,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_expression, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                Text(_display, style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
          // Buttons
          Expanded(
            child: GridView.count(
              crossAxisCount: 4,
              children: [
                _buildButton('C', Colors.orange),
                _buildButton('±', Colors.grey),
                _buildButton('%', Colors.grey),
                _buildButton('÷', Colors.orange),
                _buildButton('7', Colors.grey[300]!),
                _buildButton('8', Colors.grey[300]!),
                _buildButton('9', Colors.grey[300]!),
                _buildButton('×', Colors.orange),
                _buildButton('4', Colors.grey[300]!),
                _buildButton('5', Colors.grey[300]!),
                _buildButton('6', Colors.grey[300]!),
                _buildButton('-', Colors.orange),
                _buildButton('1', Colors.grey[300]!),
                _buildButton('2', Colors.grey[300]!),
                _buildButton('3', Colors.grey[300]!),
                _buildButton('+', Colors.orange),
                _buildButton('0', Colors.grey[300]!, flex: 2),
                _buildButton('.', Colors.grey[300]!),
                _buildButton('=', Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        margin: const EdgeInsets.all(1),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
          ),
          onPressed: () => _onButtonPressed(text),
          child: Text(text, style: const TextStyle(fontSize: 24, color: Colors.black)),
        ),
      ),
    );
  }

  void _onButtonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _display = '0';
        _expression = '';
        _result = 0;
      } else if (buttonText == '=') {
        try {
          _result = _evaluateExpression(_expression);
          _display = _result.toString();
          _expression = '';
        } catch (e) {
          _display = 'Error';
        }
      } else {
        if (_display == '0' && buttonText != '.') {
          _display = buttonText;
        } else {
          _display += buttonText;
        }
        _expression += buttonText;
      }
    });
  }

  double _evaluateExpression(String expression) {
    // Simple expression evaluation
    return 0; // Placeholder
  }
}

class WeatherWidget extends StatefulWidget {
  const WeatherWidget({super.key});

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wb_sunny, size: 100, color: Colors.orange),
            SizedBox(height: 20),
            Text('25°C', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            Text('Sunny', style: TextStyle(fontSize: 24)),
            Text('New York', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class QRScannerWidget extends StatefulWidget {
  const QRScannerWidget({super.key});

  @override
  State<QRScannerWidget> createState() => _QRScannerWidgetState();
}

class _QRScannerWidgetState extends State<QRScannerWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QR Scanner')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 100),
            SizedBox(height: 20),
            Text('QR Scanner Ready', style: TextStyle(fontSize: 24)),
            Text('Point camera at QR code', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  final List<Task> _tasks = [
    Task('Complete AI Assistant project', false),
    Task('Review code documentation', true),
    Task('Test voice features', false),
    Task('Deploy to app store', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            onPressed: _addTask,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                setState(() {
                  task.isCompleted = value ?? false;
                });
              },
            ),
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : null,
              ),
            ),
            trailing: IconButton(
              onPressed: () => _deleteTask(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
          );
        },
      ),
    );
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        String newTask = '';
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            onChanged: (value) => newTask = value,
            decoration: const InputDecoration(hintText: 'Enter task'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newTask.isNotEmpty) {
                  setState(() {
                    _tasks.add(Task(newTask, false));
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }
}

class Task {
  String title;
  bool isCompleted;

  Task(this.title, this.isCompleted);
}

class MediaPlayer extends StatefulWidget {
  const MediaPlayer({super.key});

  @override
  State<MediaPlayer> createState() => _MediaPlayerState();
}

class _MediaPlayerState extends State<MediaPlayer> {
  bool _isPlaying = false;
  double _progress = 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Player')),
      body: Column(
        children: [
          // Album Art
          Container(
            width: 300,
            height: 300,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Colors.purple, Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.music_note, size: 100, color: Colors.white),
          ),
          
          // Song Info
          const Text('Beautiful Song', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Amazing Artist', style: TextStyle(fontSize: 18, color: Colors.grey)),
          
          const SizedBox(height: 30),
          
          // Progress Bar
          Slider(
            value: _progress,
            onChanged: (value) => setState(() => _progress = value),
          ),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_previous),
                iconSize: 40,
              ),
              IconButton(
                onPressed: () => setState(() => _isPlaying = !_isPlaying),
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 60,
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.skip_next),
                iconSize: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ContactsManager extends StatefulWidget {
  const ContactsManager({super.key});

  @override
  State<ContactsManager> createState() => _ContactsManagerState();
}

class _ContactsManagerState extends State<ContactsManager> {
  final List<Contact> _contacts = [
    Contact('Alice Johnson', '+1 234 567 8901', 'alice@example.com'),
    Contact('Bob Smith', '+1 234 567 8902', 'bob@example.com'),
    Contact('Carol Davis', '+1 234 567 8903', 'carol@example.com'),
    Contact('David Wilson', '+1 234 567 8904', 'david@example.com'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(
            onPressed: _addContact,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _contacts.length,
        itemBuilder: (context, index) {
          final contact = _contacts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(contact.name[0]),
            ),
            title: Text(contact.name),
            subtitle: Text(contact.phone),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _callContact(contact),
                  icon: const Icon(Icons.call, color: Colors.green),
                ),
                IconButton(
                  onPressed: () => _messageContact(contact),
                  icon: const Icon(Icons.message, color: Colors.blue),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addContact() {
    // Add contact implementation
  }

  void _callContact(Contact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calling ${contact.name}...')),
    );
  }

  void _messageContact(Contact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Messaging ${contact.name}...')),
    );
  }
}

class Contact {
  String name;
  String phone;
  String email;

  Contact(this.name, this.phone, this.email);
}