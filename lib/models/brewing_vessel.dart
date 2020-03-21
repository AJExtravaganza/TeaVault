class BrewingVessel {
  int volumeMilliliters;
  ClayType material;
  VesselForm form;

  BrewingVessel(this.volumeMilliliters, this.material, this.form);

  String asString() => '${this.volumeMilliliters}ml ${this.material} ${this.form.asString}';
}

enum VesselForm { gaiwan, shuiping, xishi }

extension VesselFormExtension on VesselForm {
  String get asString {
    switch (this) {
      case VesselForm.gaiwan:
        return 'Gaiwan';
      case VesselForm.shuiping:
        return 'Shuiping';
      case VesselForm.xishi:
        return 'Xishi';
    }
  }
}

enum ClayType { yixing, thinlazeware, thickglazeware }

extension ClayTypeExtension on ClayType {
  String get asString {
    switch (this) {
      case ClayType.thickglazeware:
        return 'Glazed';
      case ClayType.thinlazeware:
        return 'Glazed';
      case ClayType.yixing:
        return 'Yixing';
    }
  }
}

List<BrewingVessel> getSampleVesselList() {
  return [
    BrewingVessel(90, ClayType.yixing, VesselForm.shuiping),
    BrewingVessel(80, ClayType.thinlazeware, VesselForm.gaiwan),
    BrewingVessel(150, ClayType.yixing, VesselForm.shuiping)
  ];
}
