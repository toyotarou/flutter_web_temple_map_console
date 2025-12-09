import 'package:flutter/material.dart';

import '../../models/temple_model.dart';

class TempleCell extends StatelessWidget {
  const TempleCell({
    super.key,
    required this.temple,
    required this.width,
    required this.collapsedHeight,
    required this.expandedHeight,
    required this.buttonHeight,
    required this.isExpanded,
    required this.onTapCell,
    required this.onTapButton,
  });

  final TempleModel temple;
  final double width;
  final double collapsedHeight;
  final double expandedHeight;
  final double buttonHeight;
  final bool isExpanded;
  final VoidCallback onTapCell;
  final VoidCallback onTapButton;

  String get _dateStr => "${temple.date.year}/${temple.date.month.toString().padLeft(2, '0')}/01";

  @override
  Widget build(BuildContext context) {
    final double h = isExpanded ? expandedHeight : collapsedHeight;

    return GestureDetector(
      onTap: onTapCell,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: width,
        height: h,
        decoration: BoxDecoration(
          border: Border.all(width: 2),
          color: Colors.green.shade100,
        ),
        child: isExpanded
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(_dateStr, style: const TextStyle(fontSize: 12)),
                          const SizedBox(height: 4),

                          Text(
                            temple.temple,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    height: buttonHeight,
                    child: InkWell(
                      onTap: onTapButton,
                      child: Container(
                        color: Colors.green.shade700,
                        alignment: Alignment.center,
                        child: const Text('詳細を見る', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(_dateStr, style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    temple.temple,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
      ),
    );
  }
}
