import 'package:flutter/material.dart';

class DragConfirmButton extends StatefulWidget {
  final String label;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool confirmOnLeft;
  final Icon? confirmIcon;
  final Icon? cancelIcon;

  const DragConfirmButton({
    Key? key,
    required this.label,
    required this.onConfirm,
    this.onCancel, 
    this.confirmOnLeft = false,
    this.confirmIcon,
    this.cancelIcon,
  }) : super(key: key);

  @override
  _DragConfirmButtonState createState() => _DragConfirmButtonState();
}

class _DragConfirmButtonState extends State<DragConfirmButton> {
  double _dragPosition = 0.0;
  bool _isRight = false;
  bool _isLeft = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenWidth = MediaQuery.of(context).size.width;
      final buttonMaxWidth = screenWidth / 3;
      final buttonMinWidth = screenWidth / 4;
      final buttonWidth = buttonMaxWidth.clamp(buttonMinWidth, buttonMaxWidth);
      setState(() {
        _dragPosition = (screenWidth - buttonWidth) / 2; // Recalculate center position based on adjusted width
      });
    });
  }

  bool _isConfirmed() {
    if(widget.confirmOnLeft){
      return _isLeft || (_isRight && widget.onCancel == null);
    } else{
      return _isRight || (_isLeft && widget.onCancel == null);
    }
  }

  bool _isCancelled() {
    if(widget.confirmOnLeft){
      return _isRight || (_isLeft && widget.onCancel != null);
    } else{
      return _isLeft || (_isRight && widget.onCancel != null);
    }
  }

  Widget _buildConfirmIcon() {
    return widget.confirmIcon ?? Icon(
      Icons.check_circle,
      color: Colors.green,
      size: 40, // Match the height of the row
    );
  }

  Widget _buildCancelIcon() {
    return widget.cancelIcon ?? Icon(
      Icons.cancel,
      color: Colors.red,
      size: 40, // Match the height of the row
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonMaxWidth = screenWidth / 3;
    final buttonMinWidth = screenWidth / 4;
    final buttonWidth = buttonMaxWidth.clamp(buttonMinWidth, buttonMaxWidth);
    final centerPosition = (screenWidth - buttonWidth) / 2;
    final buffer = 20.0; // Add buffer distance

    return SizedBox(
      width: screenWidth,
      height: 50,
      child: Stack(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(25),
            ),
            alignment: Alignment.center,
            child: (() {
              if (_isConfirmed() || (!_isCancelled() && widget.onCancel == null)) {
                return _buildConfirmIcon();
              } else if (_isCancelled() && widget.onCancel != null) {
                return _buildCancelIcon();
              } else {
                return null;
              }
            })(),
          ),
          GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _dragPosition += details.delta.dx;
                final isDraggingRight = _dragPosition >= screenWidth - buttonWidth - buffer;
                final isDraggingLeft = _dragPosition <= buffer;

                if (isDraggingRight) {
                  _isRight = true;
                  _isLeft = false;
                  _dragPosition = screenWidth - buttonWidth;
                } else if (isDraggingLeft) {
                  _isLeft = true;
                  _isRight = false;
                  _dragPosition = 0;
                } else {
                  _isRight = false;
                  _isLeft = false;
                }
              });
            },
            onHorizontalDragEnd: (details) {
              if (_isConfirmed()) {
                widget.onConfirm();
              } else if (_isCancelled()) {
                widget.onCancel!(); // Call onCancel only if it's provided
              } else {
                // Reset position if not confirmed or cancelled
                widget.onConfirm();
              }
              setState(() {
                _dragPosition = centerPosition; // Reset to center after confirmation or cancellation
              });
            },
            child: Stack(
              children: [
                Positioned(
                  left: _dragPosition,
                  child: Container(
                    key: Key('drag_button_${widget.key}'),
                    height: 50,
                    width: buttonWidth,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      widget.label,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}