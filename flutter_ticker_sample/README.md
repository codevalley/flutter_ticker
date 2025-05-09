# Flutter Ticker Sample

A sample application demonstrating the Flutter Ticker library. This app showcases various features and use cases of the Flutter Ticker widget following clean architecture principles.

## Overview

This sample app demonstrates how to use the Flutter Ticker library in different scenarios. It includes multiple demo screens that showcase different features of the ticker widget. The app is structured to demonstrate best practices for using the Flutter Ticker library in real-world applications.

## Architecture

This sample app follows clean architecture principles with clear separation of concerns:

- **Presentation Layer**: UI components and screens that demonstrate the ticker widget
- **Business Logic**: Implemented in the base demo screen classes that handle state updates
- **State Management**: Uses Flutter's built-in state management with StatefulWidget

## Demo Screens

### Basic Demo

Demonstrates three different ticker configurations:
- A numerical ticker with downward scrolling
- A currency ticker with upward scrolling
- An alphabetical ticker with automatic (shortest path) scrolling

Values update randomly at regular intervals to showcase the animation effects.

### Performance Demo

Demonstrates the performance of the Flutter Ticker widget by displaying multiple tickers in a scrollable list. This screen is useful for testing how well the ticker performs when many instances are active simultaneously.

### Slide Direction Demo

Demonstrates the different scrolling direction options available in the Flutter Ticker widget:
- Upward scrolling
- Downward scrolling
- Automatic (shortest path) scrolling

## Getting Started

1. Ensure you have Flutter installed on your machine
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app on your device

## Attribution

This sample app uses the Flutter Ticker library, which is based on the original [Ticker](https://github.com/robinhood/ticker) implementation by Robinhood Markets, Inc. and has been refactored into a Flutter library with clean architecture by Narayan Babu.

## License

This project is licensed under the Apache License, Version 2.0 - see the LICENSE file for details.

## Implementation Details

The sample app follows clean architecture principles with proper separation of concerns:

- **Domain Layer**: Utilizes the core domain entities from the Flutter Ticker library
- **Presentation Layer**: Implements various screens to showcase different features
- **Base Classes**: Includes a base demo screen class that handles common functionality like scheduling updates

## Getting Started

1. Make sure you have Flutter installed and set up
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Dependencies

- Flutter SDK
- Flutter Ticker library (local path dependency)
