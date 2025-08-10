// lib/core/models/questions.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'medium_type.dart';

enum QuestionType {
  truefalse,
  multiple,
  uglyImages,
  misleading,
}

enum QuestionDifficulty {
  veryEasy,
  easy,
  medium,
  hard,
  veryHard,
}

class Question {
  final String id;
  final String text;
  final MediumType medium;
  final QuestionDifficulty difficulty;
  final QuestionType type;
  final dynamic correctAnswer;
  final List<dynamic> options;
  final String? imageUrl;
  final String? hint;
  final Map<String, dynamic> metadata;

  Question({
    required this.id,
    required this.text,
    required this.medium,
    required this.difficulty,
    required this.type,
    required this.correctAnswer,
    required this.options,
    this.imageUrl,
    this.hint,
    required this.metadata,
  });

  // Factory constructor from Firestore document
  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Question(
      id: doc.id,
      text: data['text'] ?? '',
      medium: _parseMedium(data['medium']),
      difficulty: _parseDifficulty(data['difficulty'] ?? 3),
      type: _parseQuestionType(data['type']),
      correctAnswer: data['correctAnswer'],
      options: List<dynamic>.from(data['options'] ?? []),
      imageUrl: data['imageUrl'],
      hint: data['hint'],
      metadata: data['metadata'] ?? {},
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'medium': medium.name,
      'difficulty': difficulty.index + 1, // 1-5 in database
      'type': type.name,
      'correctAnswer': correctAnswer,
      'options': options,
      'imageUrl': imageUrl,
      'hint': hint,
      'metadata': {
        ...metadata,
        'createdAt': metadata['createdAt'] ?? FieldValue.serverTimestamp(),
        'language': metadata['language'] ?? 'it',
      },
    };
  }

  // Helper methods for parsing
  static MediumType _parseMedium(String? medium) {
    if (medium == null) return MediumType.videogames;

    switch (medium.toLowerCase()) {
      case 'videogames':
        return MediumType.videogames;
      case 'books':
        return MediumType.books;
      case 'comics':
        return MediumType.comics;
      case 'manga':
        return MediumType.manga;
      case 'anime':
        return MediumType.anime;
      case 'tvseries':
        return MediumType.tvSeries;
      case 'movies':
        return MediumType.movies;
      default:
        return MediumType.videogames;
    }
  }

  static QuestionDifficulty _parseDifficulty(int difficulty) {
    switch (difficulty) {
      case 1:
        return QuestionDifficulty.veryEasy;
      case 2:
        return QuestionDifficulty.easy;
      case 3:
        return QuestionDifficulty.medium;
      case 4:
        return QuestionDifficulty.hard;
      case 5:
        return QuestionDifficulty.veryHard;
      default:
        return QuestionDifficulty.medium;
    }
  }

  static QuestionType _parseQuestionType(String? type) {
    if (type == null) return QuestionType.multiple;

    switch (type.toLowerCase()) {
      case 'truefalse':
        return QuestionType.truefalse;
      case 'multiple':
        return QuestionType.multiple;
      case 'ugly_images':
      case 'uglyimages':
        return QuestionType.uglyImages;
      case 'misleading':
        return QuestionType.misleading;
      default:
        return QuestionType.multiple;
    }
  }

  // Get timer duration based on question type (in seconds)
  int get timerDuration {
    switch (type) {
      case QuestionType.truefalse:
        return 15;
      case QuestionType.multiple:
        return 20;
      case QuestionType.uglyImages:
        return 25;
      case QuestionType.misleading:
        return 30;
    }
  }

  // Get base XP for this question
  int get baseXP {
    switch (type) {
      case QuestionType.truefalse:
        return 10;
      case QuestionType.multiple:
        return 15;
      case QuestionType.uglyImages:
        return 20;
      case QuestionType.misleading:
        return 25;
    }
  }

  // Get difficulty multiplier for XP calculation
  double get difficultyMultiplier {
    switch (difficulty) {
      case QuestionDifficulty.veryEasy:
        return 1.0;
      case QuestionDifficulty.easy:
        return 1.2;
      case QuestionDifficulty.medium:
        return 1.5;
      case QuestionDifficulty.hard:
        return 1.8;
      case QuestionDifficulty.veryHard:
        return 2.0;
    }
  }
}

// Extension for QuestionType display names
extension QuestionTypeExtension on QuestionType {
  String get displayName {
    switch (this) {
      case QuestionType.truefalse:
        return 'Vero o Falso';
      case QuestionType.multiple:
        return 'Scelta Multipla';
      case QuestionType.uglyImages:
        return 'Immagini Brutte';
      case QuestionType.misleading:
        return 'Descrizioni Fuorvianti';
    }
  }
}

// Extension for QuestionDifficulty display
extension QuestionDifficultyExtension on QuestionDifficulty {
  String get displayName {
    switch (this) {
      case QuestionDifficulty.veryEasy:
        return 'Molto Facile';
      case QuestionDifficulty.easy:
        return 'Facile';
      case QuestionDifficulty.medium:
        return 'Medio';
      case QuestionDifficulty.hard:
        return 'Difficile';
      case QuestionDifficulty.veryHard:
        return 'Molto Difficile';
    }
  }

  int get value => index + 1; // Returns 1-5
}