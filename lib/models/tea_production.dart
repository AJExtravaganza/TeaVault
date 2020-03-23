import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/models/tea_producer_collection.dart';

class TeaProduction {
  String id;
  String name;
  int nominalWeightGrams;
  String _producerId;

  TeaProducer get producer => teaProducersCollection.getById(this._producerId);
  int productionYear;

  String asString() => "${this.productionYear} ${this.producer.shortName} ${this.name}";

  Map<String, dynamic> asMap() => {
        'name': this.name,
        'nominal_weight_grams': this.nominalWeightGrams,
        'producer': this.producer.id,
        'production_year': this.productionYear
      };

  TeaProduction(this.name, this.nominalWeightGrams, this._producerId, this.productionYear, [this.id]);

  bool operator ==(other) =>
      other is TeaProduction &&
      other.name == name &&
      other.nominalWeightGrams == nominalWeightGrams &&
      other.producer == producer &&
      other.productionYear == productionYear;

  static TeaProduction fromDocumentSnapshot(DocumentSnapshot productionDocument) {
    final data = productionDocument.data;
    return TeaProduction(data['name'], data['nominal_weight_grams'], data['producer'], data['production_year'],
        productionDocument.documentID);
  }
}
