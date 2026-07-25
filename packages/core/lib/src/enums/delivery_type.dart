enum DeliveryType {
  food,
  grocery,
  medicine,
  package;

  String get displayName {
    switch (this) {
      case DeliveryType.food:
        return 'Food';
      case DeliveryType.grocery:
        return 'Grocery';
      case DeliveryType.medicine:
        return 'Medicine';
      case DeliveryType.package:
        return 'Package';
    }
  }
}
