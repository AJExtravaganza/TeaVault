import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/models/tea_producer_collection.dart';

class TeaProduction {
  String id;
  String name;
  int nominalWeightGrams;
  TeaProducer producer;
  int productionYear;

  String asString() => "${this.productionYear} ${this.producer.shortName} ${this.name}";

  Map<String, dynamic> asMap() => {
        'name': this.name,
        'nominal_weight_grams': this.nominalWeightGrams,
        'producer': this.producer.id,
        'production_year': this.productionYear
      };

  TeaProduction(this.name, this.nominalWeightGrams, this.producer, this.productionYear, [this.id]);

  bool operator ==(other) =>
      other is TeaProduction &&
      other.name == name &&
      other.nominalWeightGrams == nominalWeightGrams &&
      other.producer == producer &&
      other.productionYear == productionYear;

  static TeaProduction fromDocumentSnapshot(DocumentSnapshot productionDocument, TeaProducerCollectionModel producers) {
    final data = productionDocument.data;
    return TeaProduction(data['name'], data['nominal_weight_grams'], producers.getById(data['producer']),
        data['production_year'], productionDocument.documentID);
  }
}
