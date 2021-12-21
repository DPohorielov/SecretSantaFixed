import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:ss/single_select_field.dart';
import 'package:ss/participant.dart';
import 'package:ss/secret_santa.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secret Santa',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Map<Participant, SingleSelectController<Participant>> _controllersMap = {};
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  void initState() {
    for (final Participant participant in Participant.values) {
      _controllersMap[participant] = SingleSelectController()
        ..addListener(() => _formKey.currentState?.validate());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _buildForm()),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _calculateSecretSanta,
            child: const Icon(Icons.done),
          ),
          const SizedBox(height: 30),
          FloatingActionButton(
            onPressed: _refresh,
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _controllersMap.keys
            .map(
              (key) => Padding(
                padding: const EdgeInsets.all(5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text("${key.name} gives to"),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 200,
                      child: _buildDropdownField(key),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> _calculateSecretSanta() async {
    if (_formKey.currentState?.validate() ?? false) {
      final Map<Participant, Participant> predefined = {};
      for (final MapEntry<Participant, SingleSelectController<Participant>> entry
          in _controllersMap.entries) {
        final Participant? recipient = entry.value.value;
        if (recipient != null) {
          predefined[entry.key] = recipient;
        }
      }

      Map<Participant, Participant> result =
          SecretSanta(predefined: predefined).process();

      setState(() {
        for (final MapEntry<Participant, Participant> entry in result.entries) {
          _controllersMap[entry.key]!.value = entry.value;
        }
      });
    }
  }

  void _refresh() {
    setState(() {
      for (final SingleSelectController controller in _controllersMap.values) {
        controller.value = null;
      }
    });
  }

  @override
  void dispose() {
    for (final SingleSelectController controller in _controllersMap.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildDropdownField(Participant giver) {
    final SingleSelectController<Participant> controller = _controllersMap[giver]!;

    return SingleSelectField<Participant>(
      controller: controller,
      items: Participant.values.where((element) => element != giver).toList(),
      stringify: (val) => val.name,
      validator: (val) {
        return _controllersMap.values.firstWhereOrNull((element) =>
                    controller != element &&
                    controller.value != null &&
                    controller.value == element.value) ==
                null
            ? null
            : 'non unique recipient';
      },
    );
  }
}
