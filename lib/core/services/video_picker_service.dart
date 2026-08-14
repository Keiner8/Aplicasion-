import 'package:file_picker/file_picker.dart';
import '../models/subtitle_models.dart';

class VideoPickerService {
  Future<PickedVideo?> pickVideo() async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: false,
    );

    final files = result?.files;
    if (files == null || files.isEmpty) return null;

    final file = files.first;

    return PickedVideo(name: file.name, path: file.path, sizeBytes: file.size);
  }
}
