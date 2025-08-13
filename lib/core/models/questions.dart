// lib/core/models/questions.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'medium_type.dart';

enum QuestionType {
  truefalse,
  multiple,  // Nel DB è 'multiplechoice' ma manteniamo 'multiple' per compatibilità
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
  final String text;  // Testo principale (useremo statement/question per multilingua)
  final MediumType medium;
  final String? opera;  // NUOVO: opera specifica (es: "dragon_quest_8")
  final QuestionDifficulty difficulty;
  final QuestionType type;
  final dynamic correctAnswer;
  final List<dynamic> options;
  final String? imageUrl;
  final String? hint;
  final String? explanation;  // NUOVO: spiegazione della risposta
  final Map<String, dynamic> metadata;

  // NUOVO: Campi multilingua
  final Map<String, String>? statement;  // Per true/false
  final Map<String, String>? question;   // Per multiple choice
  final List<Map<String, String>>? localizedOptions;  // Opzioni multilingua per multiple

  Question({
    required this.id,
    required this.text,
    required this.medium,
    this.opera,
    required this.difficulty,
    required this.type,
    required this.correctAnswer,
    required this.options,
    this.imageUrl,
    this.hint,
    this.explanation,
    required this.metadata,
    this.statement,
    this.question,
    this.localizedOptions,
  });

  // Factory constructor from Firestore document
  factory Question.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Determina il tipo di domanda
    final type = _parseQuestionType(data['type']);

    // Estrai il testo principale basato sul tipo e lingua
    String mainText = '';
    Map<String, String>? statement;
    Map<String, String>? question;
    List<Map<String, String>>? localizedOptions;

    if (type == QuestionType.truefalse) {
      // Per true/false, usa 'statement'
      if (data['statement'] != null) {
        statement = Map<String, String>.from(data['statement']);
        // Usa italiano come default, poi inglese come fallback
        mainText = statement['it'] ?? statement['en'] ?? 'Domanda non disponibile';
      }
    } else if (type == QuestionType.multiple) {
      // Per multiple choice, usa 'question'
      if (data['question'] != null) {
        question = Map<String, String>.from(data['question']);
        mainText = question['it'] ?? question['en'] ?? 'Domanda non disponibile';
      }

      // Estrai opzioni localizzate
      if (data['options'] != null && data['options'] is List) {
        localizedOptions = [];
        for (var option in data['options']) {
          if (option is Map) {
            localizedOptions.add(Map<String, String>.from(option));
          }
        }
      }
    }

    // Fallback al campo 'text' se presente
    if (mainText.isEmpty && data['text'] != null) {
      mainText = data['text'];
    }

    // Estrai le opzioni per la visualizzazione
    List<dynamic> options = [];
    if (type == QuestionType.truefalse) {
      options = [true, false];
    } else if (localizedOptions != null) {
      // Usa italiano come lingua di default per le opzioni
      options = localizedOptions.map((opt) =>
      opt['it'] ?? opt['en'] ?? 'Opzione non disponibile'
      ).toList();
    } else if (data['options'] != null) {
      options = List<dynamic>.from(data['options']);
    }

    return Question(
      id: doc.id,
      text: mainText,
      medium: _parseMedium(data['medium']),
      opera: data['opera'],
      difficulty: _parseDifficulty(data['difficulty'] ?? 3),
      type: type,
      correctAnswer: data['correctAnswer'],
      options: options,
      imageUrl: data['imageUrl'],
      hint: data['hint'],
      explanation: data['explanation'],
      metadata: data['metadata'] ?? {},
      statement: statement,
      question: question,
      localizedOptions: localizedOptions,
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> firestoreData = {
      'medium': medium.name,
      'difficulty': difficulty.value,
      'type': type == QuestionType.truefalse ? 'truefalse' :
      type == QuestionType.multiple ? 'multiplechoice' :
      type.name,
      'correctAnswer': correctAnswer,
      'metadata': {
        ...metadata,
        'createdAt': metadata['createdAt'] ?? FieldValue.serverTimestamp(),
        'isActive': metadata['isActive'] ?? true,
        'version': metadata['version'] ?? '1.0',
      },
    };

    // Aggiungi campi opzionali
    if (opera != null) firestoreData['opera'] = opera;
    if (imageUrl != null) firestoreData['imageUrl'] = imageUrl;
    if (hint != null) firestoreData['hint'] = hint;
    if (explanation != null) firestoreData['explanation'] = explanation;

    // Aggiungi campi specifici per tipo
    if (type == QuestionType.truefalse && statement != null) {
      firestoreData['statement'] = statement;
    } else if (type == QuestionType.multiple) {
      if (question != null) firestoreData['question'] = question;
      if (localizedOptions != null) firestoreData['options'] = localizedOptions;
    } else {
      firestoreData['text'] = text;
      firestoreData['options'] = options;
    }

    return firestoreData;
  }

  // Ottieni il testo della domanda nella lingua specificata
  String getLocalizedText(String languageCode) {
    if (type == QuestionType.truefalse && statement != null) {
      return statement![languageCode] ?? statement!['it'] ?? statement!['en'] ?? text;
    } else if (type == QuestionType.multiple && question != null) {
      return question![languageCode] ?? question!['it'] ?? question!['en'] ?? text;
    }
    return text;
  }

  // Ottieni le opzioni nella lingua specificata
  List<String> getLocalizedOptions(String languageCode) {
    if (type == QuestionType.truefalse) {
      return ['Vero', 'Falso'];  // Questi potrebbero essere localizzati anche
    } else if (localizedOptions != null) {
      return localizedOptions!.map((opt) =>
      opt[languageCode] ?? opt['it'] ?? opt['en'] ?? 'Opzione non disponibile'
      ).toList();
    }
    return options.map((o) => o.toString()).toList();
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

  static QuestionDifficulty _parseDifficulty(dynamic difficulty) {
    // Il database usa direttamente 1, 2, 3 come numeri
    int diffValue = 3;  // Default medio

    if (difficulty is int) {
      diffValue = difficulty;
    } else if (difficulty is String) {
      diffValue = int.tryParse(difficulty) ?? 3;
    }

    switch (diffValue) {
      case 1:
        return QuestionDifficulty.easy;
      case 2:
        return QuestionDifficulty.medium;
      case 3:
        return QuestionDifficulty.hard;
      default:
        return QuestionDifficulty.medium;
    }
  }

  static QuestionType _parseQuestionType(String? type) {
    if (type == null) return QuestionType.multiple;

    switch (type.toLowerCase()) {
      case 'truefalse':
        return QuestionType.truefalse;
      case 'multiplechoice':
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
        return 0.8;
      case QuestionDifficulty.easy:
        return 1.0;
      case QuestionDifficulty.medium:
        return 1.2;
      case QuestionDifficulty.hard:
        return 1.5;
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

  // Ottieni il nome del tipo come nel database
  String get dbName {
    switch (this) {
      case QuestionType.truefalse:
        return 'truefalse';
      case QuestionType.multiple:
        return 'multiplechoice';
      case QuestionType.uglyImages:
        return 'uglyimages';
      case QuestionType.misleading:
        return 'misleading';
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

  // Restituisce il valore numerico per il database (1-3 o 1-5)
  int get value {
    switch (this) {
      case QuestionDifficulty.veryEasy:
        return 1;
      case QuestionDifficulty.easy:
        return 1;
      case QuestionDifficulty.medium:
        return 2;
      case QuestionDifficulty.hard:
        return 3;
      case QuestionDifficulty.veryHard:
        return 3;
    }
  }
}