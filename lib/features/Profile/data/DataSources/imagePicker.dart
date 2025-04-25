import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Imagepickerr {
  Future<File> uploadimg(String inputSource) async {
    final picker = ImagePicker();
    final XFile? pickerimg = await picker.pickImage(
        source:
            inputSource == 'camera' ? ImageSource.camera : ImageSource.gallery);
            File imageFile = File(pickerimg!.path );
            return imageFile;
  }
  
}