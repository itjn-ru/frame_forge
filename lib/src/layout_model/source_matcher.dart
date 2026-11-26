/// Word-level matching between legacy `source` texts and typed
/// `sourceV2` variable names.
///
/// The legacy `source` property holds a human text like
/// `Двигатель тягача {радиокнопка}` while variables are named
/// `ТягачДвигательСостояние` (CamelCase) or
/// `Состояние кабины тягача {комментарий}` (spaces). Matching splits both
/// into lowercase words — CamelCase names split on uppercase boundaries —
/// and counts how many text words are represented in a variable name.
/// A text word matches a variable word when they are equal or one is a
/// prefix of the other (case endings: `тягач` matches `тягача`), with a
/// minimum prefix length to avoid false positives.
library;

/// Minimum number of characters for a prefix-style word match. Case
/// endings are short (а/ы/ов…), so four characters keep the match
/// meaningful (`тягач` ↔ `тягача`) without short-noise hits (`тяг`).
const int kSourceMatchMinPrefixLength = 4;

/// Splits a variable name or legacy source text into lowercase words.
///
/// `ТягачДвигательСостояние` -> `[тягач, двигатель, состояние]`
/// `Состояние кабины тягача {комментарий}` ->
/// `[состояние, кабины, тягача, комментарий]`
List<String> sourceTextWords(String value) {
  final List<String> words = <String>[];
  final StringBuffer current = StringBuffer();

  void flush() {
    if (current.isNotEmpty) {
      words.add(current.toString().toLowerCase());
      current.clear();
    }
  }

  for (int i = 0; i < value.length; i++) {
    final String ch = value[i];
    final bool isUpper = ch.toUpperCase() == ch && ch.toLowerCase() != ch;
    if (isUpper && current.isNotEmpty) {
      // CamelCase boundary: `ТягачДвигатель` splits before `Д`.
      flush();
    }
    if (_isWordCharacter(ch)) {
      current.write(ch);
    } else {
      flush();
    }
  }
  flush();
  return words;
}

bool _isWordCharacter(String ch) {
  final String lower = ch.toLowerCase();
  final bool isLetter = lower != ch.toUpperCase();
  final bool isDigit = ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;
  return isLetter || isDigit;
}

/// Whether a legacy text word matches a variable name word.
///
/// Equal words always match; otherwise one word must be a prefix of the
/// other with at least [kSourceMatchMinPrefixLength] characters so that
/// case endings (`тягач` ↔ `тягача`) count but short noise does not.
bool sourceWordsMatch(String textWord, String variableWord) {
  if (textWord == variableWord) return true;
  if (textWord.length < kSourceMatchMinPrefixLength ||
      variableWord.length < kSourceMatchMinPrefixLength) {
    return false;
  }
  if (variableWord.startsWith(textWord)) return true;
  if (textWord.startsWith(variableWord)) return true;
  return false;
}

/// How many of [textWords] are represented in [variableWords].
int countSourceWordMatches(
  List<String> textWords,
  List<String> variableWords,
) {
  int matched = 0;
  for (final String textWord in textWords) {
    final bool hits = variableWords.any(
      (String variableWord) => sourceWordsMatch(textWord, variableWord),
    );
    if (hits) matched++;
  }
  return matched;
}

/// Strips `{…}` segments from a legacy source text.
///
/// The braces hold a widget hint (`Двигатель тягача {радиокнопка}`) and
/// must not participate in word matching or the match threshold.
String stripBraceSegments(String text) {
  final RegExp pattern = RegExp(r'\{[^}]*\}');
  return text.replaceAll(pattern, ' ');
}

/// Widget-hint synonyms: a `{hint}` in the legacy source text points at
/// the field word that ends the variable name.
///
/// Example: `Состояние кабины тягача {радиокнопка}` binds to
/// `ТягачСостояниеКабиныСостояние`, `{вложение}` binds to a `…Файл`
/// variable. Keys and values are lowercase; host apps may extend the map
/// with their own hints.
final Map<String, String> sourceHintWordSynonyms = <String, String>{
  'радиокнопка': 'состояние',
  'вложение': 'файл',
  'комментарий': 'комментарий',
};

/// Preference words for the `{…}` hints of a legacy text: every hint word
/// itself plus its synonyms from [sourceHintWordSynonyms].
List<String> sourceHintPreferenceWords(String normalizedText) {
  final List<String> preference = <String>[];
  for (final RegExpMatch match
      in RegExp(r'\{([^}]*)\}').allMatches(normalizedText)) {
    for (final String word in sourceTextWords(match.group(1) ?? '')) {
      preference.add(word);
      final String? synonym = sourceHintWordSynonyms[word];
      if (synonym != null) preference.add(synonym.toLowerCase());
    }
  }
  return preference;
}

/// Finds the best matching variable name for a legacy source text.
///
/// - An exact (trim + case-insensitive) full match always wins.
/// - Otherwise the `{…}` hint segments are stripped and **every**
///   remaining word of the text must be represented in the variable name
///   (the threshold equals the number of words: `source.split(' ').length`).
///   Word order is irrelevant, so vehicle-first names
///   (`ТягачСостояниеКабиныСостояние` for `Состояние кабины тягача`)
///   match naturally.
/// - Candidates that also match the `{hint}` word — via
///   [sourceHintWordSynonyms] — against their **last** word win over
///   candidates that do not: `…{радиокнопка}` prefers `…Состояние`,
///   `…{вложение}` prefers `…Файл`, `…{комментарий}` prefers
///   `…Комментарий`. Remaining ties keep the first candidate.
/// - Returns null when no candidate covers all the words.
String? findBestSourceVariableMatch(
  String legacyText,
  Iterable<String> variableNames,
) {
  final String normalizedText = legacyText.trim();
  if (normalizedText.isEmpty) return null;

  final List<String> textWords = sourceTextWords(
    stripBraceSegments(normalizedText),
  );
  // A text that carries no matchable words (only a `{hint}`) never binds.
  if (textWords.isEmpty) return null;
  final List<String> hintWords = sourceHintPreferenceWords(normalizedText);

  String? firstCovering;
  String? bestHint;
  int bestHintHits = 0;
  for (final String variableName in variableNames) {
    if (variableName.trim().toLowerCase() ==
        normalizedText.toLowerCase()) {
      return variableName;
    }
    final List<String> variableWords = sourceTextWords(variableName);
    if (countSourceWordMatches(textWords, variableWords) < textWords.length) {
      continue; // Must cover every word of the text.
    }
    firstCovering ??= variableName;
    if (hintWords.isEmpty || variableWords.isEmpty) continue;
    int hintHits = 0;
    for (final String hint in hintWords) {
      if (sourceWordsMatch(hint, variableWords.last)) hintHits++;
    }
    if (hintHits > bestHintHits) {
      bestHint = variableName;
      bestHintHits = hintHits;
    }
  }
  return bestHint ?? firstCovering;
}
