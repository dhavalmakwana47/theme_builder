import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/editor_notifier.dart';
import '../../../../core/constants/app_colors.dart';

class VariablePreviewDialog extends ConsumerWidget {
  const VariablePreviewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorNotifierProvider);
    final notifier = ref.read(editorNotifierProvider.notifier);
    final vars = state.template.globalVariables;

    return Dialog(
      backgroundColor: AppColors.panelBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.data_object, color: AppColors.accentSecondary),
                const SizedBox(width: 8),
                const Text(
                  'Dynamic Variables Tester',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                Switch(
                  value: state.isPreviewMode,
                  activeColor: AppColors.accentSecondary,
                  onChanged: (_) => notifier.togglePreviewMode(),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Override template placeholders live on the canvas for dynamic tournament data testing.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const Divider(color: AppColors.borderDark, height: 24),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 350),
              child: ListView(
                shrinkWrap: true,
                children: vars.entries.map((entry) {
                  final activeVal = state.overrideVariables[entry.key] ?? entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(
                            entry.key,
                            style: const TextStyle(color: AppColors.accentPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: TextEditingController(text: activeVal),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              filled: true,
                              fillColor: AppColors.panelHeader,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
                            ),
                            onChanged: (val) {
                              notifier.updateOverrideVariable(entry.key, val);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPrimary),
                icon: const Icon(Icons.check, size: 16, color: Colors.white),
                label: const Text('Apply & Close', style: TextStyle(color: Colors.white)),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
