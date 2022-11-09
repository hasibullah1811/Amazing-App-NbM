import 'package:flutter/widgets.dart';

enum GoogleDriveSpace {
  appDataFolder,
  drive,
}

class GoogleDriveFileUploadMetaData {
  final String? description;
  final String? name;

  /// visible to all apps
  final Map<String, dynamic>? properties;

  /// visible to request app only
  final Map<String, dynamic>? appProperties;

  GoogleDriveFileUploadMetaData({
    this.properties,
    this.appProperties,
    this.description,
    @required this.name,
  }) : assert(name != null);
}

class GoogleDriveFileMetaData {
  final String? kind;
  final String? id;
  final String? mimeType;
  final String? description;
  final String? name;
  final List<String>? spaces;
  final DateTime? createdTime;
  final DateTime? modifiedTime;
  final int? size;

  /// visible to all apps
  final Map<String, dynamic>? properties;

  /// private to request app
  final Map<String, dynamic>? appProperties;

  GoogleDriveFileMetaData({
    this.kind,
    this.id,
    this.mimeType,
    this.description,
    this.name,
    this.properties,
    this.appProperties,
    this.spaces,
    this.createdTime,
    this.modifiedTime,
    this.size,
  });

  @override
  String toString() {
    return 'GoogleDriveFileMetaData(kind: $kind, id: $id, mimeType: $mimeType, description: $description, name: $name, properties: $properties, appProperties: $appProperties, spaces: $spaces, createdTime: $createdTime, modifiedTime: $modifiedTime, size: $size)';
  }
}
