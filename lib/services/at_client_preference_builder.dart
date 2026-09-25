import 'dart:io';
import 'package:at_client_mobile/at_client_mobile.dart';
import 'package:path_provider/path_provider.dart';

class AtClientPreferenceBuilder {
  static const String namespace = "prescriptionapp";
  static const String rootDomain = "root.atsign.org";

  static Future<AtClientPreference> build() async {
    final appDocDir = await getApplicationSupportDirectory();
    final appDocPath = appDocDir.path;

    return AtClientPreference()
      ..rootDomain = rootDomain
      ..namespace = namespace
      ..hiveStoragePath = appDocPath
      ..commitLogPath = appDocPath
      ..isLocalStoreRequired = true;
  }
}