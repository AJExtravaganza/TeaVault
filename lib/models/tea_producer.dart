import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/services/auth.dart';

class TeaProducer {
  String id;
  String name;
  String shortName;
  bool isUserSubmitted = true;

  String asString() => "${this.name}";

  Map<String, String> asMap() => {
        'name': this.name,
        'short_name': this.shortName,
        'submitted_by_user_with_profile_id': this.isUserSubmitted ? authService.lastKnownUserProfileId : null
      };

  TeaProducer(this.name, this.shortName, [submittedByUserWithProfileId, this.id]) {
    this.isUserSubmitted = (submittedByUserWithProfileId != null);
  }

  static TeaProducer fromDocumentSnapshot(DocumentSnapshot producerDocument) {
    final data = producerDocument.data;
    return TeaProducer(
      data['name'],
      data['short_name'],
      data['submitted_by_user_with_profile_id'],
      producerDocument.documentID,
    );
  }

  bool operator ==(dynamic other) => other is TeaProducer && this.name == other.name;
}
