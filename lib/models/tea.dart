import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:teavault/models/tea_production_collection.dart';

enum TeaFormFactor { cake, brick, tuo, mushroomtuo, looseleaf }

class Tea {
  int quantity;
  TeaProduction production;
  List<BrewProfile> brewProfiles = [];

  String get id => production.id;

  BrewProfile get defaultBrewProfile {
    if (brewProfiles.length == 0) {
      return BrewProfile.getDefault();
    } else {
      return brewProfiles.firstWhere((brewProfile) => (brewProfile.isFavorite == true));
    }
  }

  bool get hasCustomBrewProfiles => brewProfiles.length > 0;

  String asString() =>
      "${this.production.producer.shortName} ${this.production.productionYear} ${this.production.name}";

  Map<String, dynamic> asMap() {
    final brewProfileList =
        this.brewProfiles != null ? this.brewProfiles.map((brewProfile) => brewProfile.asMap()).toList() : [];
    return {
      'quantity': this.quantity,
      'production': production.id,
      'brew_profiles': brewProfileList,
    };
  }

  Tea(this.quantity, this.production, [this.brewProfiles = const []]) {
    if (this.brewProfiles.isEmpty) {
      this.brewProfiles = [];
    }
  }

  static Tea fromDocumentSnapshot(DocumentSnapshot producerDocument, TeaProductionCollectionModel productions) {
    final data = producerDocument.data;
    List<BrewProfile> brewProfiles =
    List.from(data['brew_profiles'].map((json) => BrewProfile.fromJson(json))); //TODO: Implement
    return Tea(data['quantity'], productions.getById(data['production']), brewProfiles);
  }

  bool operator ==(dynamic other) {
    return this.production.productionYear == other.production.year &&
        this.production.producer == other.production.producer &&
        this.production.name == other.production.name;
  }
}

class Terroir {
  // Implement later
}
