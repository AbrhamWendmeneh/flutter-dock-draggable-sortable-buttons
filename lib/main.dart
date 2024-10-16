import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// [MyApp] builds the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock<IconData>(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return DraggableIcon(icon: icon);
            },
          ),
        ),
      ),
    );
  }
}

/// Draggable icon widget to represent each item in the dock.
class DraggableIcon extends StatelessWidget {
  /// Creates a draggable icon.
  const DraggableIcon({
    required this.icon,
    super.key,
  });

  /// The icon to display.
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<IconData>(
      data: icon,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[700],
          ),
          child: Center(child: Icon(icon, color: Colors.white, size: 32)),
        ),
      ),
      childWhenDragging: Container(),
      child: Container(
        constraints: const BoxConstraints(minWidth: 48),
        height: 48,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.primaries[icon.hashCode % Colors.primaries.length],
        ),
        child: Center(child: Icon(icon, color: Colors.white)),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends IconData> extends StatefulWidget {
  /// Creates a [Dock] with the specified items and builder.
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends IconData> extends State<Dock<T>>
    with TickerProviderStateMixin {
  /// [T] items being manipulated.
  late List<T> _items;

  /// Animation controller for the dock.
  late AnimationController _controller;

  /// Stores the current drag index.
  int? _draggedIndex;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Moves an item from one position to another with animation.
  void _moveItem(int fromIndex, int toIndex) {
    setState(() {
      final item = _items.removeAt(fromIndex);
      _items.insert(toIndex, item);
    });
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          _items.length,
          (index) {
            return MouseRegion(
              onEnter: (_) {
                setState(() {
                  _draggedIndex = index;
                });
              },
              onExit: (_) {
                setState(() {
                  _draggedIndex = null;
                });
              },
              child: DragTarget<IconData>(
                onWillAccept: (data) {
                  setState(() {
                    _draggedIndex = index;
                  });
                  return true;
                },
                onAccept: (data) {
                  if (_draggedIndex != null && _items.contains(data)) {
                    final draggedIndex = _items.indexOf(data as T);
                    _moveItem(draggedIndex, _draggedIndex!);
                    _controller.forward(from: 0.0);
                  }
                  setState(() {
                    _draggedIndex = null;
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final scale = (_draggedIndex != null &&
                              (_draggedIndex == index ||
                                  (_draggedIndex! - 1 == index) ||
                                  (_draggedIndex! + 1 == index)))
                          ? 1.3
                          : 1.0;

                      return Transform.scale(
                        scale: scale,
                        child: DraggableIcon(
                          icon: _items[index],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
