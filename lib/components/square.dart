import 'package:chess/components/piece.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Square extends StatelessWidget {
  final bool isValidMove;
  final bool isSelected;
  final bool isWhite;
  final ChessPiece? piece;
  final void Function()? onTap;
  const Square(
      {super.key,
      required this.isWhite,
      this.piece,
      required this.isSelected,
      this.onTap,
      required this.isValidMove});

  @override
  Widget build(BuildContext context) {
    Color? squareColor;
    if (isSelected) {
      squareColor = Colors.green;
    } else if (isValidMove) {
      squareColor = Colors.green[300];
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
          margin: EdgeInsets.all(isValidMove ? 2 : 0),
          color: squareColor,
          child: piece != null
              ? SvgPicture.asset(
                  piece!.imagePath,
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                      piece!.isWhite ? Colors.white : Colors.black,
                      BlendMode.srcIn),
                )
              : null),
    );
  }
}
