import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:teavault/models/brew_profile.dart';
import 'package:teavault/models/tea_collection.dart';
import 'package:teavault/models/tea_production.dart';
import 'package:teavault/models/tea_production_collection.dart';

enum TeaFormFactor { cake, brick, tuo, mushroomtuo, looseleaf }

class Tea {
  String _id;
  int quantity;
  String _productionId;

  TeaProduction get production => teaProductionsCollection.getById(_productionId);
  List<BrewProfile> brewProfiles = [];

  String get id => this.production.id;

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
    return {
      'quantity': this.quantity,
      'production': this._productionId,
      'brew_profiles': this.brewProfiles.map((brewProfile) => brewProfile.asMap()).toList(),
    };
  }

  Tea(this.quantity, this._productionId, [this.brewProfiles = const []]) {
    this._id = 'PLACEHOLDER'; //TODO: Update this when teas_in_stash is extracted to root-level collection in schema
    if (this.brewProfiles.isEmpty) {
      this.brewProfiles = [];
    }
  }

  static Tea copyFrom(Tea tea) {
    return new Tea(tea.quantity, tea._productionId, tea.brewProfiles);
  }

  void validate() {
    if (teaProductionsCollection.getById(_productionId)==null) {
      throw Exception('No such TeaProduction $_productionId accessible in db by this user');
    }
  }

  static Tea fromDocumentSnapshot(DocumentSnapshot producerDocument) {
    final data = producerDocument.data;
    List<BrewProfile> brewProfiles = List.from(data['brew_profiles'].map((json) => BrewProfile.fromJson(json)));
    final newTea = Tea(data['quantity'], data['production'], brewProfiles);

    try {
      newTea.validate();
    } catch (err) {
      throw Exception('Could not validate tea with productionId: ${newTea._productionId}');
    }

    return newTea;
  }

  Future setBrewProfileAsFavorite(BrewProfile brewProfile) async {
    this.brewProfiles.forEach((existingBrewProfile) {
      existingBrewProfile.isFavorite = false;
    });

    brewProfile.isFavorite = true;
    sortBrewProfiles();
    await teasCollection.push(this);
  }

  Future removeBrewProfile(BrewProfile brewProfile) async {
    final newBrewProfiles = this.brewProfiles.where((existingBrewProfile) => existingBrewProfile != brewProfile).toList();
    if (brewProfile.isFavorite && newBrewProfiles.length > 0) {
      newBrewProfiles.first.isFavorite = true;
    }

    this.brewProfiles = newBrewProfiles;
    sortBrewProfiles();
    await teasCollection.push(this);
  }

  void sortBrewProfiles() {
    this.brewProfiles.sort(BrewProfile.compare);
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
