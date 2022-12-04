import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'file.dart';

class GoogleDriveClient {
  GoogleDriveSpace? _space;
  Dio _dio;
  String? token;

  GoogleDriveClient(this._dio,
      {GoogleDriveSpace? space, required String? token}) {
    _space = space ?? GoogleDriveSpace.appDataFolder;

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          if (token != null && token != '') {
            request.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(request);
        },
      ),
    );
    _dio.options.validateStatus = (code) => code == 200 || code == 204;
  }

  /// list all google files
  Future<List<GoogleDriveFileMetaData>> list() async {
    Response response = await _dio.get(
      'https://www.googleapis.com/drive/v3/files',
      queryParameters: {
        'fields':
            'files(id,name,kind,mimeType,description,properties,appProperties,spaces,createdTime,modifiedTime,size)',
        // _space == GoogleDriveSpace.appDataFolder ? 'appDataFolder' : null,
      },
    );

    return (response.data['files'] as List)
        .map(
          (file) => GoogleDriveFileMetaData(
            kind: file['kind'],
            id: file['id'],
            mimeType: file['mimeType'],
            description: file['description'],
            name: file['name'],
            properties: file['properties'],
            appProperties: file['appProperties'],
            spaces: List.castFrom(file['spaces']),
            createdTime: DateTime.tryParse(file['createdTime']),
            modifiedTime: DateTime.tryParse(file['modifiedTime']),
            size: file['size'] != null ? int.tryParse(file['size']) : null,
          ),
        )
        .toList();
  }

  /// list all google files base on space
  Future<List<GoogleDriveFileMetaData>> listSpace(String folderId) async {
    Response response = await _dio.get(
      'https://www.googleapis.com/drive/v3/files',
      // 'https://www.googleapis.com/drive/v3/files?q=\"$folderId\"+in+parents&fields=files(*)',
      queryParameters: {
        'fields':
            'files(id,name,kind,mimeType,description,properties,appProperties,spaces,createdTime,modifiedTime,size)',
        // 'files(*)',
        'q': '\"$folderId\" in parents',
        // '1zdj4XT5XdsAHHnXUNlBKkBZ0myJhYBtq',
        // _space == GoogleDriveSpace.appDataFolder ? 'appDataFolder' : null,
      },
    );

    return (response.data['files'] as List)
        .map(
          (file) => GoogleDriveFileMetaData(
            kind: file['kind'],
            id: file['id'],
            mimeType: file['mimeType'],
            description: file['description'],
            name: file['name'],
            properties: file['properties'],
            appProperties: file['appProperties'],
            spaces: List.castFrom(file['spaces']),
            createdTime: DateTime.tryParse(file['createdTime']),
            modifiedTime: DateTime.tryParse(file['modifiedTime']),
            size: file['size'] != null ? int.tryParse(file['size']) : null,
          ),
        )
        .toList();
  }

  /// list all google files base on space
  Future<List<GoogleDriveFileMetaData>> listSpaceFolder(String folderId) async {
    Response response = await _dio.get(
      'https://www.googleapis.com/drive/v3/files',
      // 'https://www.googleapis.com/drive/v3/files?q=\"$folderId\"+in+parents&fields=files(*)',
      queryParameters: {
        'fields':
            'files(id,name,kind,mimeType,description,properties,appProperties,spaces,createdTime,modifiedTime,size)',
        // 'files(*)',
        'q': '\"$folderId\" in parents',
        // '1zdj4XT5XdsAHHnXUNlBKkBZ0myJhYBtq',
        // _space == GoogleDriveSpace.appDataFolder ? 'appDataFolder' : null,
      },
    );

    final files = (response.data['files'] as List)
        .map((file) => GoogleDriveFileMetaData(
              kind: file['kind'],
              id: file['id'],
              mimeType: file['mimeType'],
              description: file['description'],
              name: file['name'],
              properties: file['properties'],
              appProperties: file['appProperties'],
              spaces: List.castFrom(file['spaces']),
              createdTime: DateTime.tryParse(file['createdTime']),
              modifiedTime: DateTime.tryParse(file['modifiedTime']),
              size: file['size'] != null ? int.tryParse(file['size']) : null,
            ))
        .toList();
    List<GoogleDriveFileMetaData> sorted_files = [];
    files.forEach((element) {
      if (element.mimeType == "application/vnd.google-apps.folder") {
        sorted_files.add(element);
      }
    });
    files.forEach((element) {
      if (element.mimeType != "application/vnd.google-apps.folder") {
        sorted_files.add(element);
      }
    });

    return sorted_files;
  }

  /// get a google file meta data
  Future<GoogleDriveFileMetaData> get(String id) async {
    Response response = await _dio.get(
      'https://www.googleapis.com/drive/v3/files/$id',
      queryParameters: {
        'fields':
            'id,name,kind,mimeType,description,properties,appProperties,spaces,createdTime,modifiedTime,size',
      },
    );

    var file = response.data;
    return GoogleDriveFileMetaData(
      kind: file['kind'],
      id: file['id'],
      mimeType: file['mimeType'],
      description: file['description'],
      name: file['name'],
      properties: file['properties'],
      appProperties: file['appProperties'],
      spaces: List.castFrom(file['spaces']),
      createdTime: DateTime.tryParse(file['createdTime']),
      modifiedTime: DateTime.tryParse(file['modifiedTime']),
      size: file['size'] != null ? int.tryParse(file['size']) : null,
    );
  }

  // Future createFolder(
  //     GoogleDriveFileUploadMetaData metaData, String name) async {
  //   final fileMetadata = {
  //     "name": 'Invoices',
  //     "mimeType": 'application/vnd.google-apps.folder',
  //   };
  //   final file = await
  // }

  /// create a google file
  Future<GoogleDriveFileMetaData> create(
      GoogleDriveFileUploadMetaData metaData, File file,
      {required Function(int, int) onUploadProgress,
      required String parent}) async {
    print('check 1 ${file.path}');

    try {} catch (e) {}
    Response metaResponse = await _dio.post(
      'https://www.googleapis.com/upload/drive/v3/files',
      queryParameters: {
        'uploadType': 'resumable',
      },
      data: {
        'parents': [parent],
        'properties': metaData.properties,
        'appProperties': metaData.appProperties,
        'description': metaData.description,
        'name': metaData.name,
        'mimeType': mime(file.path),
      },
    );

    print('check 2');
    String uploadUrl = metaResponse.headers.value('Location') as String;
    Response uploadResponse = await _dio.put(
      uploadUrl,
      options: Options(headers: {'Content-Length': file.lengthSync()}),
      data: file.openRead(),
      onSendProgress: (count, total) => onUploadProgress.call(count, total),
    );
    print('ITs being uploaded $token - $file - ${metaData.toString()}');
    return await get(uploadResponse.data['id']);
  }

  /// download a google file
  Future<File> download(String id, String filename,
      {required Function(int, int) onDownloadProgress}) async {
    String path = join((await getTemporaryDirectory()).path, filename);
    await _dio.download(
      'https://www.googleapis.com/drive/v3/files/$id',
      path,
      queryParameters: {
        'alt': 'media',
      },
      options: Options(headers: {HttpHeaders.acceptEncodingHeader: "*"}),
      onReceiveProgress: (count, total) =>
          onDownloadProgress.call(count, total),
    );
    return File(path);
  }

  /// delete a google file
  Future<void> delete(String id) async {
    await _dio.delete('https://www.googleapis.com/drive/v3/files/$id');
  }
}
