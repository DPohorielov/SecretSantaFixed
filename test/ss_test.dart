// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:ss/participant.dart';
import 'package:ss/secret_santa.dart';

void main() {
  Map<Participant, Participant> _generatePredefinedSeq() {
    final Random r = Random();
    final int count = r.nextInt(Participant.values.length - 1);

    final Map<Participant, Participant> result = {};

    final List<Participant> givers = [...Participant.values];
    final List<Participant> recipients = [...Participant.values];

    for (int i = 0; i < count; i++) {
      final Participant giver = givers[r.nextInt(givers.length)];
      givers.remove(giver);
      late Participant recipient;

      do {
        recipient = recipients[r.nextInt(recipients.length)];
      } while (giver == recipient);
      recipients.remove(recipient);

      expect(giver == recipient, false);
      expect(result.containsKey(giver), false);
      expect(result.containsValue(recipient), false);

      result[giver] = recipient;
    }

    return result;
  }

  bool _contains(Map<Participant, Participant> map,
      MapEntry<Participant, Participant> me) {
    return map[me.key] == me.value;
  }

  void _checkValid(Map<Participant, Participant> result,
      Map<Participant, Participant> predefinedSeq) {
    final String reason = "Predefined $predefinedSeq \n Result $result";

    final Map predefined = {...predefinedSeq};
    final List<Participant> givers = [...Participant.values];
    final List<Participant> recipients = [...Participant.values];

    final Map<Participant, Participant> passed = {};

    for (final MapEntry<Participant, Participant> entry in result.entries) {
      expect(entry.value == entry.key, false, reason: reason);

      expect(givers.contains(entry.key), true, reason: reason);
      givers.remove(entry.key);

      expect(recipients.contains(entry.value), true, reason: reason);
      recipients.remove(entry.value);

      if(predefined.containsKey(entry.key)) {
        expect(predefined[entry.key] == entry.value, true, reason: reason);
        predefined.remove(entry.key);
      }

      expect(_contains(passed, entry), false, reason: reason);
      passed[entry.key] = entry.value;
    }

    expect(predefined.isEmpty, true, reason: reason);
    expect(givers.isEmpty, true, reason: reason);
    expect(recipients.isEmpty, true, reason: reason);

  }

  test('Test Secret Santa', () {
    for (int i = 0; i < 100000; i++) {
      final Map<Participant, Participant> predefinedSeq =
          _generatePredefinedSeq();

      final SecretSanta ss = SecretSanta(predefined: predefinedSeq);
      final Map<Participant, Participant> result = ss.process();
      _checkValid(result, predefinedSeq);
    }
  });
}
