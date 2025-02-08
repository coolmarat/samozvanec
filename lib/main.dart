import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(ImpostorSyndromeApp());
}

class ImpostorSyndromeApp extends StatelessWidget {
  const ImpostorSyndromeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuestionsScreen(),
    );
  }
}

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  List<Map<String, String>> questions = [];
  Map<String, int> answers = {};
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final String jsonString =
        await rootBundle.loadString('assets/questions.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      questions = jsonData.map((q) => Map<String, String>.from(q)).toList();
      for (var question in questions) {
        answers[question['type']!] = 0;
      }
    });
  }

  void answerQuestion(bool isYes) {
    if (isYes) {
      final String currentType = questions[currentIndex]['type']!;
      setState(() {
        answers[currentType] = answers[currentType]! + 1;
      });
    }

    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(answers: answers),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Загрузка...')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Анкета')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  questions[currentIndex]['question']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => answerQuestion(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[100],
                    ),
                    child: Text('Да'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => answerQuestion(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[50],
                    ),
                    child: Text('Нет'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ResultsScreen extends StatelessWidget {
  final Map<String, int> answers;

  const ResultsScreen({super.key, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Результаты')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var entry in answers.entries)
              Text(
                'Тип ${entry.key}: ${entry.value}',
                style: TextStyle(fontSize: 18),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionsScreen(),
                  ),
                );
              },
              child: Text('Вернуться'),
            ),
          ],
        ),
      ),
    );
  }
}
