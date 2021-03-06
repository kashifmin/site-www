// ignore_for_file: unused_import
import 'dart:io';
// #docregion import
// Importing core libraries
import 'dart:async';
import 'dart:math';

// Importing libraries from external packages
import 'package:test/test.dart';

// Importing files
import 'package:dartlang_examples_util/print_matcher.dart' as m;
import '../lib/samples/spacecraft.dart';
// #enddocregion import

Iterable flatten(Iterable it) => it.expand((e) => e is Iterable ? e : [e]);

void main() {
  // oneSecond is shown in the code excerpts as 1 second, but we don't need
  // to delay the actual test execution, so we set the delay to 0.
  const oneSecond = const Duration(seconds: 0);
  final someDate = new DateTime(1999);

  test('hello world', () {
    // #docregion hello-world
    void main() {
      print('Hello, World!');
    }

    // #enddocregion hello-world
    expect(main, prints('Hello, World!\n'));
  });

  group('Voyager I', () {
    // #docregion var
    var name = 'Voyager I';
    var year = 1977;
    var antennaDiameter = 3.7;
    var flybyObjects = ['Jupiter', 'Saturn', 'Uranus', 'Neptune'];
    var image = {
      'tags': ['saturn'],
      'url': '//path/to/saturn.jpg'
    };
    // #enddocregion var

    test('var', () {
      expect(flybyObjects, new isInstanceOf<List>());
      expect(image, new isInstanceOf<Map>());
      expect(
          name.length > antennaDiameter, isTrue); // avoid unused_local_variable
    });

    test('Control flow', () {
      void _test() {
        // #docregion control-flow
        if (year >= 2001) {
          print('21st century');
        } else if (year >= 1901) {
          print('20th century');
        }

        for (var object in flybyObjects) {
          print(object);
        }

        for (int month = 1; month <= 12; month++) {
          print(month);
        }

        while (year < 2016) {
          year += 1;
        }
        // #enddocregion control-flow
      }

      expect(
          _test,
          m.prints(flatten([
            '20th century',
            flybyObjects,
            [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
          ])));
    });

    test('fat arrow', () {
      _test() {
        // #docregion fat-arrow
        flybyObjects.where((name) => name.contains('turn')).forEach(print);
        // #enddocregion fat-arrow
      }

      expect(_test, m.prints('Saturn'));
    });
  });

  test('functions', () {
    // #docregion functions
    int fibonacci(int n) {
      if (n == 0 || n == 1) return n;
      return fibonacci(n - 1) + fibonacci(n - 2);
    }

    var result = fibonacci(20);
    // #enddocregion functions
    expect(result, 6765);
  });

  test('use class', () {
    _test() {
      // #docregion use-class
      var voyager = new Spacecraft('Voyager I', new DateTime(1977, 9, 5));
      voyager.describe();

      var voyager3 = new Spacecraft.unlaunched('Voyager III');
      voyager3.describe();
      // #enddocregion use-class
    }

    expect(
        _test,
        m.prints([
          'Spacecraft: Voyager I',
          'Launched: 1977 (40 years ago)',
          'Spacecraft: Voyager III',
          'Unlaunched'
        ]));
  });

  test('extends', () {
    final o = new Orbiter('O', someDate, 42);
    expect(o.launchYear, someDate.year);
  });

  test('mixin', () {
    final o = new PilotedCraft('shuttle', someDate);
    expect(o.launchYear, someDate.year);
    expect(o.astronauts, 1);
  });

  test('implements', () {
    final o = new MockSpaceship('Enterprise');
    expect(o.describe, m.prints('Enterprise'));
  });

  {
    // Show declaration on first use.
    // #docregion async
    const oneSecond = const Duration(seconds: 1);
    // #enddocregion async
    assert(oneSecond.inSeconds == 1);
  }

  test('async', () {
    // #docregion async
    Future<Null> printWithDelay(String message) async {
      await new Future.delayed(oneSecond);
      print(message);
    }
    // #enddocregion async

    expect(() => printWithDelay('Hi'), prints('Hi\n'));
  });

  test('Future.then', () {
    // #docregion Future-then
    Future<Null> printWithDelay(String message) {
      return new Future.delayed(oneSecond).then((_) {
        print(message);
      });
    }

    // #enddocregion Future-then
    expect(() => printWithDelay('Hi'), prints('Hi\n'));
  });

  group('await:', () {
    final testFileBase = 'test_data/fileCreationTest';
    final testFile = new File('$testFileBase.txt');

    void safeDeleteTestFile() {
      if (testFile.existsSync()) testFile.deleteSync();
    }

    setUp(safeDeleteTestFile);
    tearDown(safeDeleteTestFile);

    test('await', () {
      // #docregion await
      Future<Null> createDescriptions(Iterable<String> objects) async {
        for (var object in objects) {
          try {
            var file = new File('$object.txt');
            if (await file.exists()) {
              var modified = await file.lastModified();
              print(
                  'File for $object already exists. It was modified on $modified.');
              continue;
            }
            await file.create();
            await file.writeAsString('Start describing $object in this file.');
          } on IOException catch (e) {
            print('Cannot create description for $object: $e');
          }
        }
      }
      // #enddocregion await

      _test() async {
        final objects = ['test_data/config', testFileBase];
        await createDescriptions(objects);
        expect(testFile.existsSync(), isTrue);
      }

      expect(
          _test,
          prints(
            contains('File for test_data/config already exists.'),
          ));
    });
  });

  test('async*', () async {
    var voyager = new Spacecraft('Voyager I', new DateTime(1977, 9, 5));
    var flybyObjects = ['Jupiter', 'Saturn', 'Uranus', 'Neptune'];

    // #docregion async-
    Stream<String> report(Spacecraft craft, Iterable<String> objects) async* {
      for (var object in objects) {
        await new Future.delayed(oneSecond);
        yield '${craft.name} flies by $object';
      }
    }
    // #enddocregion async-

    final messages = flybyObjects.map((o) => 'Voyager I flies by $o');
    expect(await report(voyager, flybyObjects).toList(), messages);
  });

  void throwTest(int astronauts) {
    // #docregion throw
    if (astronauts == 0) {
      throw new StateError('No astronauts.');
    }
    // #enddocregion throw
  }

  test('throw', () {
    expect(() => throwTest(0), throwsStateError);
  });

  test('try', () {
    _test() async {
      final flybyObjects = ['Moon'];
      // #docregion try
      try {
        for (var object in flybyObjects) {
          var description = await new File('$object.txt').readAsString();
          print(description);
        }
      } on IOException catch (e) {
        print('Could not describe object: $e');
      } finally {
        flybyObjects.clear();
      }
      // #enddocregion try
    }

    expect(_test, prints(startsWith('Could not describe object:')));
  });
}
