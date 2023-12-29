import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/helper/helper_methods.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'components/dead_piece.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];

  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];
  bool isWhiteTurn = true;

  // Initial Position of kings
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkState = false;

  @override
  void initState() {
    _initializeBoard();
    super.initState();
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (index) => List.generate(8, (index) => null),
    );

    // Place Pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = const ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: false,
          imagePath: 'asset/images/pawn.svg');
      newBoard[6][i] = const ChessPiece(
          type: ChessPieceType.pawn,
          isWhite: true,
          imagePath: 'asset/images/pawn.svg');
    }

    // Place Rooks
    newBoard[0][0] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'asset/images/rook.svg');
    newBoard[0][7] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: false,
        imagePath: 'asset/images/rook.svg');

    newBoard[7][0] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'asset/images/rook.svg');
    newBoard[7][7] = const ChessPiece(
        type: ChessPieceType.rook,
        isWhite: true,
        imagePath: 'asset/images/rook.svg');

    // Place Knights
    newBoard[0][1] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'asset/images/knight.svg');
    newBoard[0][6] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: false,
        imagePath: 'asset/images/knight.svg');

    newBoard[7][1] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'asset/images/knight.svg');
    newBoard[7][6] = const ChessPiece(
        type: ChessPieceType.knight,
        isWhite: true,
        imagePath: 'asset/images/knight.svg');

    // Place Bishops
    newBoard[0][2] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'asset/images/bishop.svg');
    newBoard[0][5] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: false,
        imagePath: 'asset/images/bishop.svg');

    newBoard[7][2] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'asset/images/bishop.svg');
    newBoard[7][5] = const ChessPiece(
        type: ChessPieceType.bishop,
        isWhite: true,
        imagePath: 'asset/images/bishop.svg');

    // Place Queens
    newBoard[0][3] = const ChessPiece(
        type: ChessPieceType.queen,
        isWhite: false,
        imagePath: 'asset/images/queen.svg');
    newBoard[7][3] = const ChessPiece(
        type: ChessPieceType.queen,
        isWhite: true,
        imagePath: 'asset/images/queen.svg');

    // Place Kings
    newBoard[0][4] = const ChessPiece(
        type: ChessPieceType.king,
        isWhite: false,
        imagePath: 'asset/images/king.svg');
    newBoard[7][4] = const ChessPiece(
        type: ChessPieceType.king,
        isWhite: true,
        imagePath: 'asset/images/king.svg');

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      // Check for pawn promotion
      if (selectedPiece != null &&
          selectedPiece!.type == ChessPieceType.pawn &&
          ((selectedPiece!.isWhite && row == 0) ||
              (!selectedPiece!.isWhite && row == 7))) {
        for (int i = 0; i < validMoves.length; i++) {
          if (validMoves[i][0] == row && validMoves[i][1] == col) {
            promotePawn(row, col);
            break;
          }
        }
      }
      //  if there is no piece selected and the current square has a piece, select the piece
      else if (selectedPiece == null && board[row][col] != null) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedCol = col;
          selectedRow = row;
          selectedPiece = board[row][col];
        }
      } else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedCol = col;
        selectedRow = row;
        selectedPiece = board[row][col];
      }

      //  if there is a piece selected and the current square is a valid move, move the piece
      else if (selectedPiece != null) {
        for (var position in validMoves) {
          if (position[0] == row && position[1] == col) {
            movePiece(row, col);
          }
        }
      }
    });

    validMoves =
        calculateRealValidMoves(selectedRow, selectedCol, selectedPiece, true);
  }

  void promotePawn(int row, int col) {
    showCupertinoDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote Pawn'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Choose a piece to promote your pawn:'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  promoteToPiece(row, col, ChessPieceType.queen);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                  padding: const EdgeInsets.all(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.emoji_objects, size: 24),
                    SizedBox(height: 8),
                    Text('Queen'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  promoteToPiece(row, col, ChessPieceType.rook);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.green,
                  padding: const EdgeInsets.all(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.castle, size: 24),
                    SizedBox(height: 8),
                    Text('Rook'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  promoteToPiece(row, col, ChessPieceType.bishop);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                  padding: const EdgeInsets.all(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.crop_square, size: 24),
                    SizedBox(height: 8),
                    Text('Bishop'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  promoteToPiece(row, col, ChessPieceType.knight);
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.purple,
                  padding: const EdgeInsets.all(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.abc, size: 24),
                    SizedBox(height: 8),
                    Text('Knight'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    isWhiteTurn = !isWhiteTurn;
  }

  void promoteToPiece(int row, int col, ChessPieceType pieceType) {
    Map<ChessPieceType, String> pieceCount = {
      ChessPieceType.pawn: 'pawn',
      ChessPieceType.rook: 'rook',
      ChessPieceType.knight: 'knight',
      ChessPieceType.bishop: 'bishop',
      ChessPieceType.queen: 'queen',
      ChessPieceType.king: 'king',
    };
    setState(() {
      ChessPiece promotedPiece = ChessPiece(
        type: pieceType,
        isWhite: selectedPiece!.isWhite,
        imagePath: 'asset/images/${pieceCount[pieceType]}.svg',
      );

      board[row][col] = promotedPiece;
      board[selectedRow][selectedCol] = null;

      if (isKingInCheck(!isWhiteTurn)) {
        checkState = true;
      } else {
        checkState = false;
      }

      setState(() {
        selectedPiece = null;
        selectedRow = -1;
        selectedCol = -1;
        validMoves = [];
      });

      if (isCheckMate(!isWhiteTurn)) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Check Mate!"),
            actions: [
              TextButton(
                onPressed: resetGame,
                child: const Text("Reset Game"),
              )
            ],
          ),
        );
      }
      // Change turn
    });
    Navigator.pop(context); // Close the promotion dialog
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }
    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:

        // Pawns can move one square forward if the square is empty
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }

        // Pawns can move two squares forward if the square is empty and the pawn is in its starting position
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }

        // Pawns can move diagonally forward if the square is occupied by an enemy piece
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }

        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }

        break;
      case ChessPieceType.rook:

        // Rooks can move any number of squares horizontally or vertically if the square is empty
        var directions = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1]
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.knight:

        // Knights can move in an L shape if the square is empty or occupied by an enemy piece
        var knightMoves = [
          [1, 2],
          [1, -2],
          [-1, 2],
          [-1, -2],
          [2, 1],
          [2, -1],
          [-2, 1],
          [-2, -1]
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:

        // Bishops can move any number of squares diagonally if the square is empty or occupied by an enemy piece

        var directions = [
          [1, 1],
          [-1, 1],
          [1, -1],
          [-1, -1]
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:

        // Kings can move one square in any direction if the square is empty or occupied by an enemy piece

        var directions = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [-1, 1],
          [1, -1],
          [-1, -1]
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.queen:

        // Queens can move any number of squares horizontally, vertically, or diagonally if the square is empty or occupied by an enemy piece

        var directions = [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1],
          [1, 1],
          [-1, 1],
          [1, -1],
          [-1, -1]
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      default:
    }

    return candidateMoves;
  }

  List<List<int>> calculateRealValidMoves(
      int row, int col, ChessPiece? piece, bool checkSimulation) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        if (simulatedMoveIsSafe(piece!, row, col, endCol, endRow)) {
          realValidMoves.add([endRow, endCol]);
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }
    return realValidMoves;
  }

  void movePiece(int newRow, int newCol) {
    if (board[newRow][newCol] != null) {
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // Check if piece is a king and it is moved
    if (selectedPiece!.type == ChessPieceType.king) {
      if (selectedPiece!.isWhite) {
        whiteKingPosition = [newRow, newCol];
      } else {
        blackKingPosition = [newRow, newCol];
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    if (isKingInCheck(!isWhiteTurn)) {
      checkState = true;
    } else {
      checkState = false;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];
    });

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Check Mate!"),
          actions: [
            TextButton(
              onPressed: resetGame,
              child: const Text("Reset Game"),
            )
          ],
        ),
      );
    }
    // Change turn
    isWhiteTurn = !isWhiteTurn;
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPosition =
        isWhiteKing ? whiteKingPosition : blackKingPosition;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }
        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], false);

        if (pieceValidMoves.any((move) =>
            move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
          return true;
        }
      }
    }

    return false;
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endCol, int endRow) {
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    List<int>? originalKingPosition;
    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        originalKingPosition = whiteKingPosition;
      } else {
        originalKingPosition = blackKingPosition;
      }
      if (piece.isWhite) {
        whiteKingPosition = [endRow, endCol];
      } else {
        blackKingPosition = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPosition = originalKingPosition!;
      } else {
        blackKingPosition = originalKingPosition!;
      }
    }
    return !kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calculateRealValidMoves(i, j, board[i][j], true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  void resetGame() {
    setState(() {
      _initializeBoard();
      whitePiecesTaken.clear();
      blackPiecesTaken.clear();
      isWhiteTurn = true;
      checkState = false;
      blackKingPosition = [0, 4];
      whiteKingPosition = [7, 4];
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // White Pieces Taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
              itemCount: whitePiecesTaken.length,
            ),
          ),

          Expanded(
            flex: 3,
            child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 8 * 8,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8),
                itemBuilder: (context, index) {
                  int row = index ~/ 8;
                  int col = index % 8;

                  bool isSelected = selectedRow == row && selectedCol == col;

                  // Check if the current square is a valid move
                  bool isValidMove = false;
                  for (var position in validMoves) {
                    if (position[0] == row && position[1] == col) {
                      isValidMove = true;
                    }
                  }
                  return Square(
                    isValidMove: isValidMove,
                    onTap: () => pieceSelected(row, col),
                    piece: board[row][col],
                    isWhite: isWhite(index),
                    isSelected: isSelected,
                  );
                }),
          ),

          // Black Pieces Taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
              itemCount: blackPiecesTaken.length,
            ),
          ),
        ],
      ),
    );
  }
}
