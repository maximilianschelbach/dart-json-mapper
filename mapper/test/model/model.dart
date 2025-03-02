import 'package:dart_json_mapper/dart_json_mapper.dart';

final compactOptions = SerializationOptions(indent: '');

@jsonSerializable
enum Color { Red, Blue, Gray, GrayMetallic, Green, Brown, Yellow, Black, White }

@jsonSerializable
class Car {
  @JsonProperty(name: 'modelName')
  String? model;

  Color? color;

  @JsonProperty(ignoreIfNull: true)
  Car? replacement;

  Car(this.model, this.color);
}

extension TitledCar on Car {
  String get title => '$model-$color';
}

@jsonSerializable
class Person {
  List<String> skills = ['Go', 'Dart', 'Flutter'];

  List<DateTime> specialDates = [
    DateTime(2013, 02, 28),
    DateTime(2023, 02, 28),
    DateTime(2003, 02, 28)
  ];

  @JsonProperty(
      name: 'last_promotion_date',
      converterParams: {'format': 'MM-dd-yyyy H:m:s'})
  DateTime lastPromotionDate = DateTime(2008, 05, 13, 22, 33, 44);

  @JsonProperty(name: 'hire_date', converterParams: {'format': 'MM/dd/yyyy'})
  DateTime hireDate = DateTime(2003, 02, 28);

  @JsonProperty(ignore: true)
  bool married = true;

  bool active = true;

  String name = 'Forest';

  @JsonProperty(converterParams: {'format': '##.##'})
  num salary = 1200000.246;
  num? dob;
  num age = 36;

  var lastName = 'Gump';

  dynamic dyn = 'dyn';
  dynamic dynNum = 9;
  dynamic dynBool = false;

  Map properties = {'first': 'partridge', 'cash': 23000, 'required': true};

  Map<String, dynamic> map = {
    'first': 'partridge',
    'cash': 23000,
    'required': true
  };

  Symbol sym = Symbol('foo');

  List<Color> favouriteColours = [Color.Black, Color.White];

  @JsonProperty(name: 'eye_color')
  Color eyeColor = Color.Blue;

  @JsonProperty(converter: enumConverterNumeric)
  Color hairColor = Color.Brown;

  List<Car> vehicles = [Car('Tesla', Color.Black), Car('BMW', Color.Red)];

  String get fullName => '$name $lastName';

  Person();
}

@jsonSerializable
class GettersOnly {
  int _nextId = 0;
  String get nextCatId => 'c${_nextId++}';
  String get nextDogId => 'h${_nextId++}';
}
