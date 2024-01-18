import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/services/file.dart';
import 'package:path/path.dart' as p;

class HomeProvider with ChangeNotifier {
  ClientService clientService = ClientService();
  FileService fileService = FileService();
  List<Map<String, String>> files = [];
  String selectDirectoryPath = '';
  List<File> uploadFiles = [];
  int uploadFilesIndex = 0;
  TextEditingController clientNumberController = TextEditingController();
  FocusNode clientNumberFocusNode = FocusNode();
  String clientName = '';

  Future getFiles() async {
    files.clear();
    String tmpClientNumber = await getPrefsString('clientNumber') ?? '';
    List<Map> tmpFiles = await fileService.select(searchMap: {
      'clientNumber': tmpClientNumber,
    });
    for (Map map in tmpFiles) {
      files.add({
        'id': '${map['id']}',
        'clientNumber': map['clientNumber'],
        'clientName': map['clientName'],
        'filePath': map['filePath'],
      });
    }
    notifyListeners();
  }

  Future selectDirectory() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    uploadFiles.clear();
    uploadFilesIndex = 0;
    clientNumberController.clear();
    clientName = '';
    if (path != null) {
      Directory directory = Directory(path);
      selectDirectoryPath = directory.path;
      List<FileSystemEntity> dirFiles = await directory.list().toList();
      for (var file in dirFiles) {
        if (file is File) {
          String extension = p.extension(file.path);
          if (extension == '.pdf') {
            uploadFiles.add(file);
          }
        }
      }
    }
    notifyListeners();
  }

  void uploadFileLeft() {
    uploadFilesIndex -= 1;
    clientNumberController.clear();
    clientName = '';
    notifyListeners();
  }

  void uploadFileRight() {
    uploadFilesIndex += 1;
    clientNumberController.clear();
    clientName = '';
    notifyListeners();
  }

  Future checkClientNumber() async {
    if (clientNumberController.text == '') return;
    List<Map> tmpClients = await clientService.select(searchMap: {
      'number': clientNumberController.text,
    });
    if (tmpClients.isNotEmpty) {
      clientName = tmpClients.first['name'];
    } else {
      clientName = '';
    }
    notifyListeners();
  }

  void uploadFileAllClear() {
    uploadFiles.clear();
    uploadFilesIndex = 0;
    clientNumberController.clear();
    clientName = '';
    notifyListeners();
  }

  void uploadFileClear() {
    uploadFiles.removeAt(uploadFilesIndex);
    if (uploadFiles.isNotEmpty) {
      uploadFilesIndex = 0;
      clientNumberController.clear();
      clientName = '';
    } else {
      uploadFiles.clear();
    }
    notifyListeners();
  }

  Future<String?> uploadFileSave() async {
    String? error = await fileService.insert(
      clientNumber: clientNumberController.text,
      clientName: clientName,
      uploadFile: uploadFiles[uploadFilesIndex],
    );
    return error;
  }

  Future autoFocus() async {
    clientNumberFocusNode.unfocus();
    await Future.delayed(const Duration(seconds: 1));
    clientNumberFocusNode.requestFocus();
  }
}
