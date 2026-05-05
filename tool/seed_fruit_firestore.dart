import 'dart:io';

import 'package:firebase_admin_sdk/firebase_admin_sdk.dart';
import 'package:thuc_hanh/data/sample_data/fruit_seed_data.dart';

Future<void> main(List<String> args) async {
  final projectId = _readArg(args, '--project-id') ??
      Platform.environment['GOOGLE_CLOUD_PROJECT'] ??
      Platform.environment['FIREBASE_PROJECT_ID'];

  if (projectId == null || projectId.isEmpty) {
    stderr.writeln(
      'Missing project id. Pass --project-id=<id> or set GOOGLE_CLOUD_PROJECT.',
    );
    exitCode = 64;
    return;
  }

  final serviceAccountPath = _readArg(args, '--service-account') ??
      Platform.environment['GOOGLE_APPLICATION_CREDENTIALS'];

  final app = _createApp(projectId: projectId, serviceAccountPath: serviceAccountPath);
  final firestore = app.firestore();

  try {
    stdout.writeln('Seeding Firestore project: $projectId');

    await _writeCollection(firestore, 'categories', fruitCategories);
    await _writeCollection(firestore, 'brands', fruitBrands);
    await _writeCollection(firestore, 'brand_categories', fruitBrandCategories);
    await _writeCollection(firestore, 'products', fruitProducts);

    stdout.writeln('Seed completed successfully.');
  } catch (e, stackTrace) {
    stderr.writeln('Seed failed: $e');
    stderr.writeln(stackTrace);
    exitCode = 1;
  } finally {
    await app.close();
  }
}

FirebaseApp _createApp({
  required String projectId,
  String? serviceAccountPath,
}) {
  if (serviceAccountPath != null && serviceAccountPath.isNotEmpty) {
    final file = File(serviceAccountPath);
    if (!file.existsSync()) {
      throw ArgumentError('Service account file not found: $serviceAccountPath');
    }

    return FirebaseApp.initializeApp(
      options: AppOptions(
        projectId: projectId,
        credential: Credential.fromServiceAccount(file),
      ),
      name: 'fruit-seed-app',
    );
  }

  return FirebaseApp.initializeApp(
    options: AppOptions(
      projectId: projectId,
      credential: Credential.fromApplicationDefaultCredentials(),
    ),
    name: 'fruit-seed-app',
  );
}

Future<void> _writeCollection(
  dynamic firestore,
  String collectionName,
  List<Map<String, dynamic>> records,
) async {
  final collectionRef = firestore.collection(collectionName);

  for (final record in records) {
    final idRaw = record['id'];
    final data = Map<String, dynamic>.from(record)..remove('id');

    if (idRaw is String && idRaw.isNotEmpty) {
      await collectionRef.doc(idRaw).set(data);
    } else {
      final docRef = await collectionRef.add(data);
      stdout.writeln('Created doc ${docRef.id} in $collectionName');
    }
  }

  stdout.writeln('Wrote ${records.length} docs to $collectionName');
}

String? _readArg(List<String> args, String name) {
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];

    if (arg.startsWith('$name=')) {
      return arg.substring(name.length + 1);
    }

    if (arg == name) {
      // Support `--flag value` form. Return next arg if it exists and
      // doesn't look like another flag.
      if (i + 1 < args.length && !args[i + 1].startsWith('--')) {
        return args[i + 1];
      }
      return null;
    }
  }

  return null;
}