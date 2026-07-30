import 'dart:io';

void main() {
  final source = File(r'C:\Users\Lenovo\.gemini\antigravity-ide\brain\49266b3a-adc8-4904-80a0-e3c780aa2b2e\tropical_beach_1785350772647.png');
  final target = File(r'C:\Dhaval\flutter\Tournamnet App\Projects\TournaX\public\template_assets\slot_list_background\tropical_beach.png');
  
  if (source.existsSync()) {
    target.parent.createSync(recursive: true);
    source.copySync(target.path);
    print('SUCCESS: Copied tropical_beach.png to Laravel public assets!');
  } else {
    print('ERROR: Source file not found');
  }
}
