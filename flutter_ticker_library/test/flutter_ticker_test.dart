import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ticker/ticker.dart';

void main() {
  group('TickerUtils Tests', () {
    test('provideNumberList returns correct characters', () {
      final numbers = TickerUtils.provideNumberList();
      expect(numbers, '0123456789');
    });

    test('provideAlphabeticalList returns correct characters', () {
      final alphabet = TickerUtils.provideAlphabeticalList();
      expect(alphabet, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ');
    });
  });

  group('TickerCharacterList Tests', () {
    test('constructor initializes correctly', () {
      final characterList = TickerCharacterList('0123456789');
      expect(characterList.numOriginalCharacters, 10);
      expect(characterList.characterList.length, 21); // EMPTY_CHAR + list + list
    });

    test('getSupportedCharacters returns correct set', () {
      final characterList = TickerCharacterList('abc');
      final supported = characterList.getSupportedCharacters();
      expect(supported, {'a', 'b', 'c'});
    });

    test('getCharacterIndices returns correct indices for upward scrolling', () {
      final characterList = TickerCharacterList('0123456789');
      final indices = characterList.getCharacterIndices(
        '3', '1', ScrollingDirection.up
      );
      expect(indices?.startIndex, greaterThan(indices?.endIndex ?? 0));
    });

    test('getCharacterIndices returns correct indices for downward scrolling', () {
      final characterList = TickerCharacterList('0123456789');
      final indices = characterList.getCharacterIndices(
        '1', '3', ScrollingDirection.down
      );
      expect(indices?.startIndex, lessThan(indices?.endIndex ?? 0));
    });
  });

  testWidgets('TickerWidget initializes with correct text', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TickerWidget(
            text: '123',
            textSize: 20,
            characterLists: [TickerUtils.provideNumberList()],
          ),
        ),
      ),
    );

    // Verify that the widget renders
    expect(find.byType(TickerWidget), findsOneWidget);
  });
}
