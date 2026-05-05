# thuchanh

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Seed Fruit Data

To load the fruit sample data into Firestore, run:

```bash
dart run tool/seed_fruit_firestore.dart --project-id=your-project-id --service-account=path/to/service-account.json
```

If you already have Application Default Credentials configured, you can omit
`--service-account` and just provide the project ID.
