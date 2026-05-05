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
  final batch = firestore.batch();

  for (final record in records) {
    final id = record['id'] as String;
    final data = Map<String, dynamic>.from(record)..remove('id');
    batch.set(firestore.collection(collectionName).doc(id), data);
  }

  await batch.commit();
  stdout.writeln('Wrote ${records.length} docs to $collectionName');
}

String? _readArg(List<String> args, String name) {
  for (final arg in args) {
    if (arg == name) {
      return '';
    }
    if (arg.startsWith('$name=')) {
      return arg.substring(name.length + 1);
    }
  }
  return null;
}