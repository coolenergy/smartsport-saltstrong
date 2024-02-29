import 'package:flutter/material.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

class CustomListTile extends StatelessWidget {
  final String title;
  final Widget? icon;
  final Function()? onTapLayer;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final Widget? checkmark;
  final double? paddingLeft;
  final bool pad;
  const CustomListTile({
    Key? key,
    required this.title,
    required this.isSelected,
    required this.onSelected,
    this.icon,
    this.onTapLayer,
    this.checkmark,
    this.paddingLeft,
    this.pad = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onSelected(!isSelected);
        onTapLayer?.call();
      },
      child: Padding(
        padding: pad ? EdgeInsets.only(right: 12.0, left: paddingLeft ?? 0.0) : EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  width: isSelected ? 2 : 1,
                  color: isSelected ? Colors.black : Colors.grey,
                ),
                color: Colors.white,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisSize: pad ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null)
                        ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            isSelected ? SaltStrongColors.primaryBlue : Colors.black,
                            BlendMode.srcIn,
                          ),
                          child: icon!,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          title,
                          style: TextStyle(
                            color: isSelected ? SaltStrongColors.primaryBlue : Colors.black,

                          ),
                        ),
                      ),
                    ],
                  ),
                  if (checkmark != null)
                    Positioned(
                      left: 0, // Added to position checkmark at start
                      child: checkmark!,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
