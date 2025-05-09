# Flutter Ticker Project

A clean architecture implementation of a Flutter text animation library with smooth scrolling transitions.

## Project Structure

This repository contains two main components:

### 1. Flutter Ticker Library (`flutter_ticker_library`)

A pure Flutter library that provides a customizable ticker widget for animated text transitions. The library follows clean architecture principles with clear separation of concerns:

- **State Management Layer**: Manages data storage and retrieval
  - `ticker_column_manager.dart`: Coordinates multiple ticker columns
  - `ticker_draw_metrics.dart`: Handles drawing metrics calculations

- **Business Logic Layer**: Implements core business logic
  - `ticker_character_list.dart`: Manages character animations
  - `ticker_column.dart`: Handles individual column animations
  - `levenshtein_utils.dart`: Implements optimal transition algorithms

- **Presentation Layer**: Provides user interface components
  - `ticker_widget.dart`: The main widget for displaying animated text

### 2. Flutter Ticker Sample App (`flutter_ticker_sample`)

A comprehensive sample application that demonstrates how to use the Flutter Ticker library in various scenarios:

- **Basic Demo**: Shows different ticker configurations
- **Performance Demo**: Tests multiple tickers in a scrollable list
- **Slide Direction Demo**: Demonstrates different scrolling directions

## Getting Started

### Using the Library

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_ticker:
    path: path/to/flutter_ticker_library
```

### Running the Sample App

```bash
cd flutter_ticker_sample
flutter pub get
flutter run
```

## Clean Architecture Implementation

This project strictly follows clean architecture principles:

1. **Layer Separation**: Each layer has a specific responsibility and communicates through well-defined interfaces
2. **Dependency Rule**: Dependencies only point inward, with the domain layer having no dependencies on outer layers
3. **Domain Objects**: Core business concepts are represented as pure data structures
4. **Testability**: Each component can be tested in isolation

## License

This project is licensed under the Apache License, Version 2.0 - see the LICENSE file for details.

## Attribution

This project is based on the original [Ticker](https://github.com/robinhood/ticker) implementation by Robinhood Markets, Inc. and has been rewritten ground up into a Flutter library with clean architecture by Narayan Babu, though its conceptually based on the original Ticker implementation.

The implementation strictly follows clean architecture principles with clear separation between State Management, Business Logic, and Presentation layers.
