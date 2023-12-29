import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const DeadPiece({super.key, required this.imagePath, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      imagePath,
      colorFilter: isWhite
          ? ColorFilter.mode(Colors.grey[400]!, BlendMode.srcIn)
          : ColorFilter.mode(Colors.grey[800]!, BlendMode.srcIn),
    );
  }
}
