import 'camera_gallery_service.dart';
import 'package:image_picker/image_picker.dart';

class CameraGalleryServiceImpl extends CameraGalleryService {
  final ImagePicker _picker = ImagePicker();

  @override
  Future<String?> selectPhoto() async{
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80, //Resolución
      );

      if( photo == null ) return null;

      print('tenemos una imagen ${photo.path}');
      return photo.path;
  }

  @override
  Future<String?> takePhoto() async{
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80, //Resolución
      preferredCameraDevice: CameraDevice.rear, //Camara trasera (elegir cámara)
      );

      if( photo == null ) return null;

      print('tenemos una imagen ${photo.path}');
      return photo.path;
  }
  
}