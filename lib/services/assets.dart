import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/content.dart';

Future<List<String>> loadFaces({AssetBundle? bundle}) async {
  final assets = bundle ?? rootBundle;
  final manifest = await AssetManifest.loadFromAssetBundle(assets);
  final candidates =
      manifest
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
  final valid = <String>[];
  for (final path in candidates) {
    ui.Codec? codec;
    ui.Image? image;
    try {
      final data = await assets.load(path);
      codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      image = (await codec.getNextFrame()).image;
      if (image.width > 0 && image.height > 0) valid.add(path);
    } catch (_) {
      /* Corrupt or unsupported files cannot participate. */
    } finally {
      image?.dispose();
      codec?.dispose();
    }
  }
  return valid;
}

Future<Map<String, String>> loadLetterAudio() async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final available = manifest.listAssets().toSet();
  return {
    for (final entry in letterAudioFiles.entries)
      if (available.contains('assets/audio/letters/${entry.value}'))
        entry.key: 'assets/audio/letters/${entry.value}',
  };
}
