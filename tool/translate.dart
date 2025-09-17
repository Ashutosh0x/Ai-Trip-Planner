import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

void printUsage() {
  stdout.writeln(
    'Usage: dart run tool/translate.dart --source=<path> --output=<dir> --languages=<codes>',
  );
  stdout.writeln('Env: GOOGLE_TRANSLATE_API_KEY must be set');
  stdout.writeln('--source:    Source en.json file path');
  stdout.writeln('--output:    Output directory for translated JSONs');
  stdout.writeln(
    '--languages: Comma-separated list of target language codes (e.g., hi,es,fr)',
  );
}

Future<void> main(List<String> args) async {
  if (args.contains('--help') || args.contains('-h')) {
    printUsage();
    return;
  }

  final Map<String, String> argMap = {
    for (final String arg in args)
      if (arg.startsWith('--') && arg.contains('='))
        arg.substring(2, arg.indexOf('=')): arg.substring(arg.indexOf('=') + 1),
  };

  final String? sourcePath = argMap['source'];
  final String? outputDir = argMap['output'];
  final String? languagesRaw = argMap['languages'];
  final String? apiKey = Platform.environment['GOOGLE_TRANSLATE_API_KEY'];

  if (sourcePath == null || outputDir == null || languagesRaw == null) {
    printUsage();
    exitCode = 2;
    return;
  }

  if (apiKey == null || apiKey.trim().isEmpty) {
    stderr.writeln('GOOGLE_TRANSLATE_API_KEY is not set.');
    exitCode = 3;
    return;
  }

  final File sourceFile = File(sourcePath);
  if (!await sourceFile.exists()) {
    stderr.writeln('Source file not found: $sourcePath');
    exitCode = 4;
    return;
  }

  final Directory outDir = Directory(outputDir);
  if (!await outDir.exists()) {
    await outDir.create(recursive: true);
  }

  final List<String> targetLanguages = languagesRaw
      .split(',')
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty && e.toLowerCase() != 'en')
      .toList();

  final String sourceContent = await sourceFile.readAsString();
  final dynamic decoded = json.decode(sourceContent);
  if (decoded is! Map<String, dynamic>) {
    stderr.writeln('Expected a JSON object at the root of $sourcePath');
    exitCode = 5;
    return;
  }
  final Map<String, dynamic> sourceJson = decoded;

  final Map<String, String> flat = <String, String>{};
  _flattenJson(sourceJson, '', flat);

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'https://translation.googleapis.com',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  for (final String lang in targetLanguages) {
    stdout.writeln('Translating -> $lang');
    final Map<String, String> translatedFlat = await _translateFlatMap(
      dio,
      apiKey,
      flat,
      lang,
    );
    final Map<String, dynamic> rebuilt = _unflattenJson(translatedFlat);
    final File outFile = File('${outDir.path}/$lang.json');
    await outFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(rebuilt),
    );
  }

  stdout.writeln(
    'Done. Generated: ${targetLanguages.length} files in $outputDir',
  );
}

void _flattenJson(dynamic node, String prefix, Map<String, String> out) {
  if (node is Map<String, dynamic>) {
    node.forEach((key, value) {
      final String newPrefix = prefix.isEmpty ? key : '$prefix.$key';
      _flattenJson(value, newPrefix, out);
    });
  } else if (node is List) {
    for (int i = 0; i < node.length; i++) {
      final String newPrefix = '$prefix[$i]';
      _flattenJson(node[i], newPrefix, out);
    }
  } else if (node is String) {
    out[prefix] = node;
  } else {
    // For numbers, bools, null, leave as is by storing their string form
    out[prefix] = node?.toString() ?? '';
  }
}

Map<String, dynamic> _unflattenJson(Map<String, String> flat) {
  final Map<String, dynamic> root = <String, dynamic>{};
  for (final MapEntry<String, String> entry in flat.entries) {
    _assignPath(root, entry.key, entry.value);
  }
  return root;
}

void _assignPath(Map<String, dynamic> root, String path, String value) {
  final RegExp arrayIndex = RegExp(r"\\[(\\d+)\\]");
  List<String> parts = path.split('.');
  dynamic current = root;
  for (int i = 0; i < parts.length; i++) {
    final String part = parts[i];
    final Iterable<RegExpMatch> matches = arrayIndex.allMatches(part);
    String key = part.split('[').first;

    final bool isLast = i == parts.length - 1;
    // If this is the last segment and there are no array indices,
    // assign directly instead of creating an intermediate map.
    if (isLast && matches.isEmpty && key.isNotEmpty) {
      (current as Map<String, dynamic>)[key] = value;
      return;
    }
    if (key.isNotEmpty) {
      current = (current as Map<String, dynamic>).putIfAbsent(
        key,
        () => <String, dynamic>{},
      );
    }

    dynamic container = current;
    for (final RegExpMatch m in matches) {
      final int idx = int.parse(m.group(1)!);
      if (container is Map<String, dynamic>) {
        // Convert map to list if array index expected
        container = (container[key] ?? <dynamic>[]) as List<dynamic>;
        (current as Map<String, dynamic>)[key] = container;
      }
      while ((container as List).length <= idx) {
        container.add(<String, dynamic>{});
      }
      current = container[idx];
      container = current;
    }

    if (isLast) {
      if (container is Map<String, dynamic> && key.isNotEmpty) {
        (container)[key] = value;
      } else if (current is Map<String, dynamic>) {
        current[key] = value;
      } else if (current is List) {
        // Last part was an array index
        // Find last index
        final Match? last = arrayIndex.allMatches(part).isNotEmpty
            ? arrayIndex.allMatches(part).last
            : null;
        if (last != null) {
          final int idx = int.parse(last.group(1)!);
          (current as List)[idx] = value;
        }
      }
    }
  }
}

Future<Map<String, String>> _translateFlatMap(
  Dio dio,
  String apiKey,
  Map<String, String> flat,
  String targetLang,
) async {
  final Map<String, String> result = <String, String>{};
  final List<MapEntry<String, String>> entries = flat.entries.toList();
  const int batchSize = 100; // Google v2 supports many q params per request
  for (int i = 0; i < entries.length; i += batchSize) {
    final List<MapEntry<String, String>> batch = entries.sublist(
      i,
      i + batchSize > entries.length ? entries.length : i + batchSize,
    );
    final Response response = await dio.post(
      '/language/translate/v2',
      queryParameters: <String, dynamic>{'key': apiKey},
      data: FormData.fromMap(<String, dynamic>{
        'q': batch.map((e) => e.value).toList(),
        'target': targetLang,
        'source': 'en',
        'format': 'text',
      }),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    final dynamic data = response.data;
    final List translations = data['data']['translations'] as List;
    for (int j = 0; j < batch.length; j++) {
      result[batch[j].key] = translations[j]['translatedText'] as String;
    }
  }
  return result;
}
