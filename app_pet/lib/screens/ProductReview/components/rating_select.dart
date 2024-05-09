import 'package:flutter/material.dart';

class StarRatingWidget extends StatefulWidget {
  final int maxRating;
  final Function(int) onRatingSelected;

  const StarRatingWidget({
    Key? key,
    this.maxRating = 5,
    required this.onRatingSelected,
  }) : super(key: key);

  @override
  _StarRatingWidgetState createState() => _StarRatingWidgetState();
}

class _StarRatingWidgetState extends State<StarRatingWidget> {
  int _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return IconButton(
          icon: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: Colors.yellow,
          ),
          onPressed: () {
            setState(() {
              _currentRating = index + 1;
              widget.onRatingSelected(_currentRating);
            });
          },
        );
      }),
    );
  }
}
