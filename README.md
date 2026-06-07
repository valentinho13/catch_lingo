# CatchLingo

CatchLingo is a Flutter language learning app that turns real-world objects into vocabulary using camera-based recognition, flashcards and quiz-based training.

The long-term idea is simple:

> See something. Catch the word. Learn it.

## Vision

CatchLingo should help users build vocabulary from their real environment.

Instead of manually searching for words, the app will eventually use the camera to detect objects in the live view and suggest vocabulary based on what the user sees.

Example:

- The camera detects a bottle.
- CatchLingo suggests the word.
- The user saves it to their vocabulary.
- The word becomes part of flashcards and quiz training.

## Current Features

The current version is an early Flutter prototype.

Implemented so far:

- Start screen with CatchLingo themed background
- Shared vocabulary state
- Word list
- Add new words
- Delete words with confirmation
- Quiz-style training
- Randomized answer order
- Score tracking
- Training result screen

## Planned Features

Planned next steps:

- Flashcard mode
- Persistent local storage
- Camera live view
- Object recognition
- Automatic vocabulary suggestions
- Learning queue for detected words
- Progress tracking
- Better app icon and branding
- Improved UI animations

## Tech Stack

- Flutter
- Dart
- Android support
- Git / GitHub

## Project Status

This project is currently in early development.

The current focus is building the core vocabulary and training flow before adding camera-based object recognition.

## Screens

Screens currently implemented:

- Home screen
- Word list screen
- Add word screen
- Training screen
- Result screen

## Development Notes

This repository started as a Flutter prototype and is being developed step by step.

The current architecture uses a simple in-memory app state. Persistent storage and camera features will be added later.