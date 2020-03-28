import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/models/tea_producer.dart';
import 'package:teavault/models/tea_producer_collection.dart';

class TeaProduction {
  String id;
  String name;
  int nominalWeightGrams;
  String _producerId;
  String submittedByUserWithProfileId;

  TeaProducer get producer => teaProducersCollection.getById(this._producerId);
  int productionYear;

  String asString() => "${this.productionYear} ${this.producer.shortName} ${this.name}";

  Map<String, dynamic> asMap() => {
        'name': this.name,
        'nominal_weight_grams': this.nominalWeightGrams,
        'producer': this.producer.id,
        'production_year': this.productionYear,
        'submitted_by_user_with_profile_id': this.submittedByUserWithProfileId
      };

  TeaProduction(this.name, this.nominalWeightGrams, this._producerId, this.productionYear,
      [this.submittedByUserWithProfileId, this.id]);

  bool operator ==(other) =>
      other is TeaProduction &&
      other.name == name &&
      other.nominalWeightGrams == nominalWeightGrams &&
      other.producer == producer &&
      other.productionYear == productionYear;

  void validate() {
    if (teaProducersCollection.getById(_producerId) == null) {
      throw Exception('No such TeaProduction $_producerId accessible in db by this user');
    }
    ;
  }

  static TeaProduction fromDocumentSnapshot(DocumentSnapshot productionDocument) {
    final data = productionDocument.data;
    final newProduction = TeaProduction(data['name'], data['nominal_weight_grams'], data['producer'],
        data['production_year'], data['submitted_by_user_with_profile_id'], productionDocument.documentID);
    newProduction.validate();
    return newProduction;
  }
}
