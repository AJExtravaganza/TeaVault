import 'package:cloud_firestore/cloud_firestore.dart';

class TeaProducer {
  String id;
  String name;
  String shortName;

  String asString() => "${this.name}";

  Map<String, String> asMap() => {'name': this.name, 'short_name': this.shortName};

  TeaProducer(this.name, this.shortName, [this.id]);

  static TeaProducer fromDocumentSnapshot(DocumentSnapshot producerDocument) {
    final data = producerDocument.data;
    return TeaProducer(data['name'], data['short_name'], producerDocument.documentID);
  }

  bool operator ==(dynamic other) => other is TeaProducer && this.name == other.name;
}
