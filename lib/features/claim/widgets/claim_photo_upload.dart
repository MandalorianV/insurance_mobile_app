import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insurance_mobile_app/theme/theme_extension.dart';
import 'package:easy_localization/easy_localization.dart';

class ClaimPhotoUpload extends StatelessWidget {
  final ValueNotifier<List<XFile>> photosNotifier;
  final VoidCallback onAddPhoto;
  final void Function(int index) onRemovePhoto;

  const ClaimPhotoUpload({
    super.key,
    required this.photosNotifier,
    required this.onAddPhoto,
    required this.onRemovePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<XFile>>(
      valueListenable: photosNotifier,
      builder: (context, photoList, _) {
        if (photoList.isEmpty) {
          return GestureDetector(
            onTap: onAddPhoto,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: context.appColors.card.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.appColors.border,
                  style: BorderStyle.solid,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  const Text('📷', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 8),
                  Text(
                    'claim.photo_add'.tr(),
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'claim.photo_helper'.tr(),
                    style: context.textTheme.labelSmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: photoList.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              if (index == photoList.length) {
                return GestureDetector(
                  onTap: onAddPhoto,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: context.appColors.card.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: context.appColors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      Icons.add_rounded,
                      color: context.appColors.textSub,
                      size: 32,
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(photoList[index].path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => onRemovePhoto(index),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
