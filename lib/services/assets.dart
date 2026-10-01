import 'package:flutter/services.dart';

Future<List<String>> loadFaces() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest
      .listAssets()
      .where(
        (path) =>
            path.startsWith('assets/cards/') &&
            RegExp(
              r'\.(png|jpe?g|webp|gif)$',
              caseSensitive: false,
            ).hasMatch(path),
      )
      .toList()
    ..sort();
}
