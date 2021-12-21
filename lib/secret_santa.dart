import 'dart:collection';
import 'dart:math';

import 'package:ss/participant.dart';

class SecretSanta {
  final Map<Participant, Participant> predefined;

  SecretSanta({this.predefined = const {}});

  Map<Participant, Participant> process() {

    final Iterable<Participant> givers =
        Participant.values.where((e) => !predefined.containsKey(e));
    final Iterable<Participant> recipients =
        Participant.values.where((e) => !predefined.containsValue(e));

    final Map<Participant, List<Participant>> brutLinks = _buildBrutLinks(
      givers: givers,
      recipients: recipients,
    );

    final Map<Participant, Participant> result = {...predefined};

    final Random r = Random();

    for (final Participant giver in givers) {
      List<Participant> giverRecipients = brutLinks[giver]!;
      brutLinks.remove(giver);

      late Participant recipient;

      do {
        recipient = giverRecipients[r.nextInt(giverRecipients.length)];
      } while (!_recipientAllowed(recipient, brutLinks));

      result[giver] = recipient;
      for (final List<Participant> list in brutLinks.values) {
        list.remove(recipient);
      }
    }

    return result;
  }

  static Map<Participant, List<Participant>> _buildBrutLinks(
      {required Iterable<Participant> givers,
      required Iterable<Participant> recipients}) {
    final Map<Participant, List<Participant>> map = HashMap();

    for (final Participant giver in givers) {
      map[giver] = recipients.where((recipient) => recipient != giver).toList();
    }

    return map;
  }

  static bool _recipientAllowed(
      Participant recipient, Map<Participant, List<Participant>> brutLinks) {
    for (final List<Participant> list in brutLinks.values) {
      if (list.length == 1 && list.first == recipient) {
        return false;
      }
    }

    return true;
  }
}
