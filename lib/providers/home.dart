import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:hakata_file_manager/common/functions.dart';
import 'package:hakata_file_manager/common/style.dart';
import 'package:hakata_file_manager/services/client.dart';
import 'package:hakata_file_manager/services/file.dart';
import 'package:path/path.dart' as p;

class HomeProvider with ChangeNotifier {
  ClientService clientService = ClientService();
  FileService fileService = FileService();
  String selectDirectoryPath = '';
  List<File> uploadFiles = [];
  int uploadFilesIndex = 0;
  DateTime createDate = DateTime.now();
  TextEditingController clientNumberController = TextEditingController();
  FocusNode clientNumberFocusNode = FocusNode();
  String clientName = '';
  FocusNode keyboardFocusNode = FocusNode();

  String searchCreateDateStart = '';
  String searchCreateDateEnd = '';
  String searchClientNumber = '';

  Future<List<Map<String, String>>> getFiles() async {
    List<Map<String, String>> ret = [];
    String createDateStart = dateText('yyyy-MM-dd', sDefaultDateStart);
    String createDateEnd = dateText('yyyy-MM-dd', sDefaultDateEnd);
    String tmpCreateDateStart = await getPrefsString('createDateStart') ?? '';
    if (tmpCreateDateStart != '') {
      createDateStart = tmpCreateDateStart;
    }
    String tmpCreateDateEnd = await getPrefsString('createDateEnd') ?? '';
    if (tmpCreateDateEnd != '') {
      createDateEnd = tmpCreateDateEnd;
    }
    String tmpClientNumber = await getPrefsString('clientNumber') ?? '';
    searchCreateDateStart = createDateStart;
    searchCreateDateEnd = createDateEnd;
    searchClientNumber = tmpClientNumber;
    notifyListeners();
    List<Map> tmpFiles = await fileService.select(searchMap: {
      'clientNumber': tmpClientNumber,
      'createDateStart': createDateStart,
      'createDateEnd': createDateEnd,
    });
    for (Map map in tmpFiles) {
      ret.add({
        'id': '${map['id']}',
        'clientNumber': map['clientNumber'],
        'clientName': map['clientName'],
        'filePath': map['filePath'],
        'createDate': map['createDate'],
      });
    }
    return ret;
  }

  Future selectDirectory() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    uploadFiles.clear();
    uploadFilesIndex = 0;
    createDate = DateTime.now();
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

  void dateOnChange(DateTime value) {
    createDate = value;
    notifyListeners();
  }

  Future checkClientNumber() async {
    if (clientNumberController.text == '') return;
    List<Map> tmpClients = await clientService.select(searchMap: {
      'number': clientNumberController.text,
      'name': '',
      'orderBy': '',
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
    createDate = DateTime.now();
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
      createDate: createDate,
    );
    return error;
  }

  Future autoFocus() async {
    clientNumberFocusNode.unfocus();
    await Future.delayed(const Duration(seconds: 1));
    clientNumberFocusNode.requestFocus();
  }
}
