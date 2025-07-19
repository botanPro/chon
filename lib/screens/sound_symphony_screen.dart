import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class SoundSymphonyScreen extends StatefulWidget {
  const SoundSymphonyScreen({super.key});

  @override
  State<SoundSymphonyScreen> createState() => _SoundSymphonyScreenState();
}

class _SoundSymphonyScreenState extends State<SoundSymphonyScreen>
    with TickerProviderStateMixin {
  final List<String> _notes = ['Do', 'Re', 'Mi', 'Fa', 'Sol', 'La', 'Si'];
  final List<Color> _noteColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  List<SoundNode> _nodes = [];
  List<Connection> _connections = [];
  SoundNode? _selectedNode;
  int _score = 0;
  int _harmony = 0;
  Timer? _melodyTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String? _currentMelody;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeNodes();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _initializeNodes() {
    _nodes = List.generate(12, (index) {
      return SoundNode(
        id: index,
        note: _notes[Random().nextInt(_notes.length)],
        position: Offset(
          50.0 + Random().nextDouble() * 300,
          50.0 + Random().nextDouble() * 500,
        ),
        color: _noteColors[Random().nextInt(_noteColors.length)],
      );
    });
  }

  void _onPanStart(DragStartDetails details) {
    final node = _findNearestNode(details.localPosition);
    if (node != null) {
      setState(() {
        _selectedNode = node;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_selectedNode == null) return;

    final nearNode = _findNearestNode(details.localPosition);
    if (nearNode != null && nearNode != _selectedNode) {
      _tryConnect(_selectedNode!, nearNode);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _selectedNode = null;
    });
    if (_connections.length >= 3) {
      _playMelody();
    }
  }

  SoundNode? _findNearestNode(Offset position) {
    for (final node in _nodes) {
      if ((node.position - position).distance < 30) {
        return node;
      }
    }
    return null;
  }

  void _tryConnect(SoundNode from, SoundNode to) {
    if (_connections.any((c) =>
        (c.from == from && c.to == to) || (c.from == to && c.to == from)))
      return;

    setState(() {
      _connections.add(Connection(from: from, to: to));
      _pulseController.forward().then((_) => _pulseController.reverse());
    });
  }

  void _playMelody() {
    final melody =
        _connections.map((c) => '${c.from.note}-${c.to.note}').join(' ');
    setState(() {
      _isPlaying = true;
      _currentMelody = melody;
    });

    // Simulate playing the melody
    _melodyTimer?.cancel();
    _melodyTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final index = timer.tick - 1;
      if (index >= _connections.length) {
        timer.cancel();
        _evaluateMelody();
        return;
      }

      setState(() {
        _connections[index].isPlaying = true;
        if (index > 0) {
          _connections[index - 1].isPlaying = false;
        }
      });
    });
  }

  void _evaluateMelody() {
    // Evaluate the melody based on music theory rules (simplified)
    int points = _connections.length * 100;
    int harmonyBonus = 0;

    // Check for patterns
    final notes = _connections.map((c) => c.from.note).toList();
    if (_hasAscendingPattern(notes)) {
      harmonyBonus += 500;
    }
    if (_hasDescendingPattern(notes)) {
      harmonyBonus += 500;
    }

    setState(() {
      _score += points + harmonyBonus;
      _harmony = harmonyBonus;
      _isPlaying = false;
      _connections.forEach((c) => c.isPlaying = false);
      _connections.clear();
    });

    if (_score >= 5000) {
      _showWinDialog();
    }
  }

  bool _hasAscendingPattern(List<String> notes) {
    for (int i = 0; i < notes.length - 2; i++) {
      final index1 = _notes.indexOf(notes[i]);
      final index2 = _notes.indexOf(notes[i + 1]);
      if (index2 > index1) return true;
    }
    return false;
  }

  bool _hasDescendingPattern(List<String> notes) {
    for (int i = 0; i < notes.length - 2; i++) {
      final index1 = _notes.indexOf(notes[i]);
      final index2 = _notes.indexOf(notes[i + 1]);
      if (index2 < index1) return true;
    }
    return false;
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Masterpiece! 🎵',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You\'ve composed a winning symphony!',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Final Score: $_score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Back to Home'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _score = 0;
                _harmony = 0;
                _connections.clear();
                _initializeNodes();
              });
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _melodyTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Sound Symphony'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Score',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _score.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  if (_harmony > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '+$_harmony',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (_currentMelody != null && _isPlaying)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _currentMelody!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  painter: SymphonyPainter(
                    nodes: _nodes,
                    connections: _connections,
                    selectedNode: _selectedNode,
                  ),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SoundNode {
  final int id;
  final String note;
  final Offset position;
  final Color color;

  SoundNode({
    required this.id,
    required this.note,
    required this.position,
    required this.color,
  });
}

class Connection {
  final SoundNode from;
  final SoundNode to;
  bool isPlaying;

  Connection({
    required this.from,
    required this.to,
    this.isPlaying = false,
  });
}

class SymphonyPainter extends CustomPainter {
  final List<SoundNode> nodes;
  final List<Connection> connections;
  final SoundNode? selectedNode;

  SymphonyPainter({
    required this.nodes,
    required this.connections,
    this.selectedNode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw connections
    for (final connection in connections) {
      paint.color = connection.isPlaying
          ? Colors.white
          : connection.from.color.withOpacity(0.5);
      canvas.drawLine(
        connection.from.position,
        connection.to.position,
        paint,
      );
    }

    // Draw nodes
    for (final node in nodes) {
      final isSelected = node == selectedNode;
      final nodePaint = Paint()
        ..color = isSelected ? Colors.white : node.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(node.position, isSelected ? 25 : 20, nodePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: node.note,
          style: TextStyle(
            color: isSelected ? node.color : Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        node.position.translate(
          -textPainter.width / 2,
          -textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(SymphonyPainter oldDelegate) => true;
}
