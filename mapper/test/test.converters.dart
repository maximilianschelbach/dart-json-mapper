import 'dart:typed_data';

import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:test/test.dart';

import './model/index.dart';

@jsonSerializable
enum MyEnumA { first, second }

@jsonSerializable
enum MyEnumB { foo, bar }

@jsonSerializable
class MyClass {
  MyEnumA enumA;
  MyEnumB enumB;

  MyClass(this.enumA, this.enumB);
}

@jsonSerializable
class MyClassWoConstructor {
  MyEnumA? enumA;
  MyEnumB? enumB;
}

@jsonSerializable
enum NumericEnumTestColor {
  Red,
  Blue,
  Gray,
  GrayMetallic,
  Green,
  Brown,
  Yellow,
  Black,
  White
}

class Timestamp {
  num stamp;
  num i;
  Timestamp(this.stamp, this.i);
}

class CustomStringConverter implements ICustomConverter<String?> {
  const CustomStringConverter() : super();

  @override
  String? fromJSON(dynamic jsonValue, [DeserializationContext? context]) {
    return jsonValue;
  }

  @override
  dynamic toJSON(String? object, [SerializationContext? context]) {
    return '_${object}_';
  }
}

@jsonSerializable
class BinaryData {
  Uint8List data;

  BinaryData(this.data);
}

@jsonSerializable
class BigIntData {
  BigInt bigInt;

  BigIntData(this.bigInt);
}

@jsonSerializable
class Model {
  DateTime? data;
}

@jsonSerializable
class DurationModel {
  Duration? data;
}

@jsonSerializable
class NumericEnum {
  NumericEnumTestColor color;

  NumericEnum(this.color);
}

@jsonSerializable
class ListItem {}

@jsonSerializable
class CustomListContainer {
  List<ListItem> list = [];
  Set<ListItem> set = {};
}

@jsonSerializable
class InlineJsonContainer {
  Map<String, dynamic>? dataHash;
}

@jsonSerializable
enum MyEnum { valueA, valueB }

@jsonSerializable
class DateTimeContainer {
  DateTime? createdAt;
}

void testConverters() {
  group('[Verify converters]', () {
    test('Map<String, DateTime> converter', () {
      // given
      final map = {'createdAt': DateTime.now()};

      // when
      final target = JsonMapper.fromMap<DateTimeContainer>(map);

      // then
      expect(target, TypeMatcher<DateTimeContainer>());
      expect(target!.createdAt, TypeMatcher<DateTime>());
    });

    test('Map<String, dynamic> converter', () {
      // given
      final json = '{"a":"abc","b":3}';

      // when
      final target = JsonMapper.deserialize<Map<String, dynamic>>(json)!;

      // then
      expect(target, TypeMatcher<Map<String, dynamic>>());
      expect(target['a'], TypeMatcher<String>());
      expect(target['b'], TypeMatcher<num>());
    });

    test('Map converter - Inline JSON value', () {
      // given
      final json = r'''{
          "id": 15989,
      "title": "xxx",
      "body": "xxx",
      "type": "abc",
      "dataHash": "{\"id\":\"3098\",\"number\":1}"
    }''';

      // when
      final target = JsonMapper.deserialize<InlineJsonContainer>(json)!;

      // then
      expect(target, TypeMatcher<InlineJsonContainer>());
      expect(target.dataHash?['id'], '3098');
      expect(target.dataHash?['number'], 1);
    });

    test('DateConverter', () {
      // given
      final instance = Model();

      // when
      final json = JsonMapper.toJson(instance);
      final target = JsonMapper.fromJson<Model>(json)!;

      // then
      expect(target.data, instance.data);
    });

    test('DurationConverter', () {
      // given
      final instance = DurationModel();
      instance.data = Duration(days: 2, hours: 2, milliseconds: 200);

      // when
      final json = JsonMapper.toJson(instance);
      final target = JsonMapper.fromJson<DurationModel>(json)!;

      // then
      expect(target.data, instance.data);
    });

    test('RegExpConverter', () {
      // given
      final source = '\[[*>.]\]';
      final instance = RegExp(source);

      // when
      final json = JsonMapper.toJson(instance);
      final target = JsonMapper.fromJson<RegExp>(json)!;

      // then
      expect(json, '"$source"');
      expect(target.pattern, instance.pattern);
      expect(target, TypeMatcher<RegExp>());
      expect(target, instance);
    });

    test('UriConverter', () {
      // given
      final uri = 'https://github.com/k-paxian/dart-json-mapper';
      final instance = Uri.parse(uri);

      // when
      final json = JsonMapper.toJson(instance);
      final target = JsonMapper.fromJson<Uri>(json);

      // then
      expect(json, '"$uri"');
      expect(target, TypeMatcher<Uri>());
      expect(target, instance);
    });

    test('BigInt converter', () {
      // given
      final rawString = '1234567890000000012345678900';
      final json = '{"bigInt":"$rawString"}';

      // when
      final targetJson = JsonMapper.serialize(
          BigIntData(BigInt.parse(rawString)), compactOptions);
      // then
      expect(targetJson, json);

      // when
      final target = JsonMapper.deserialize<BigIntData>(json)!;
      // then
      expect(rawString, target.bigInt.toString());
    });

    test('Uint8List converter', () {
      // given
      final json = '{"data":"QmFzZTY0IGlzIHdvcmtpbmch"}';
      final rawString = r'Base64 is working!';

      // when
      final targetJson = JsonMapper.serialize(
          BinaryData(Uint8List.fromList(rawString.codeUnits)), compactOptions);
      // then
      expect(targetJson, json);

      // when
      final target = JsonMapper.deserialize<BinaryData>(json)!;
      // then
      expect(rawString, String.fromCharCodes(target.data));
    });

    test('Default Map<K, V> converter', () {
      // given
      final targetJson = '''{"bar":{"modelName":"Tesla S3","color":"Black"}}''';
      final foo = <String, Car>{};
      foo['bar'] = Car('Tesla S3', Color.Black);

      // when
      final json = JsonMapper.serialize(foo, compactOptions);

      // then
      expect(json, targetJson);
    });

    test('Map<String, bool>', () {
      // given
      final targetJson = '''{"foo":true,"bar":false,"bazz":true}''';
      final instance = <String, bool>{
        'foo': true,
        'bar': false,
        'bazz': true,
      };
      final adapter = JsonMapperAdapter(valueDecorators: {
        typeOf<Map<String, bool>>(): (value) => value.cast<String, bool>()
      });
      JsonMapper().useAdapter(adapter);

      // when
      final json = JsonMapper.serialize(instance, compactOptions);
      final target = JsonMapper.deserialize<Map<String, bool>>(json);

      // then
      expect(json, targetJson);
      expect(target, TypeMatcher<Map<String, bool>>());

      JsonMapper().removeAdapter(adapter);
    });

    test('Custom String converter', () {
      // given
      final json = '''{
 "id": 1,
 "name": "_Bob_",
 "car": {
  "modelName": "_Audi_",
  "color": "Green"
 }
}''';
      final adapter =
          JsonMapperAdapter(converters: {String: CustomStringConverter()});
      JsonMapper().useAdapter(adapter);

      final i = Immutable(1, 'Bob', Car('Audi', Color.Green));
      // when
      final target = JsonMapper.serialize(i);
      // then
      expect(target, json);

      JsonMapper().removeAdapter(adapter);
    });

    test('Custom Iterable converter', () {
      // given
      final json = '''{"list":[{}, {}],"set":[{}, {}]}''';

      // when
      final target = JsonMapper.deserialize<CustomListContainer>(json)!;

      // then
      expect(target.list, TypeMatcher<List<ListItem>>());
      expect(target.list.first, TypeMatcher<ListItem>());
      expect(target.list.length, 2);

      expect(target.set, TypeMatcher<Set<ListItem>>());
      expect(target.set.first, TypeMatcher<ListItem>());
      expect(target.set.length, 2);
    });

    test('Unknown types .fromMap', () {
      // given
      final json = <String, dynamic>{
        'model': 'Tesla',
        'DateFacturation': Timestamp(1568465485, 0),
      };

      // when
      final myModel = JsonMapper.fromMap<MyCarModel>(
          json, SerializationOptions(ignoreUnknownTypes: true))!;

      // then
      expect(myModel.model, 'Tesla');
    });

    test('Numeric Enum converter', () {
      // given
      final json = '''{"color":3}''';
      final adapter =
          JsonMapperAdapter(converters: {Enum: enumConverterNumeric});
      JsonMapper().useAdapter(adapter);

      final instance = NumericEnum(NumericEnumTestColor.GrayMetallic);
      // when
      final target = JsonMapper.serialize(instance, compactOptions);
      // then
      expect(target, json);

      // when
      final json2 = JsonMapper.serialize(MyEnum.valueA);
      final myEnum = JsonMapper.deserialize<MyEnum>(json2);
      // then
      expect(myEnum, MyEnum.valueA);

      // when
      final json3 = JsonMapper.serialize(MyClass(MyEnumA.first, MyEnumB.foo));
      final myEnumClass = JsonMapper.deserialize<MyClass>(json3)!;
      // then
      expect(myEnumClass.enumA, MyEnumA.first);
      expect(myEnumClass.enumB, MyEnumB.foo);

      // when
      final json4 = JsonMapper.serialize(MyClassWoConstructor());
      final myEnumEmptyClass =
          JsonMapper.deserialize<MyClassWoConstructor>(json4)!;
      // then
      expect(myEnumEmptyClass.enumA, null);
      expect(myEnumEmptyClass.enumB, null);

      JsonMapper().removeAdapter(adapter);
    });
  });
}
