import 'package:flutter/material.dart';
import '../widgets/game_card.dart';
import '../models/game.dart';
import '../services/auth_service.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _days = 30;
  int _hours = 30;
  int _minutes = 30;
  int _seconds = 30;
  Timer? _timer;
  
  // Animation controllers for each time unit - make them nullable
  AnimationController? _daysController;
  AnimationController? _hoursController;
  AnimationController? _minutesController;
  AnimationController? _secondsController;
  
  // Previous values to detect changes
  int _prevDays = 30;
  int _prevHours = 30;
  int _prevMinutes = 30;
  int _prevSeconds = 30;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _initControllers();
    
    // Start the timer after controllers are initialized
    _startTimer();
  }
  
  void _initControllers() {
    _daysController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _hoursController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _minutesController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _secondsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    // Cancel timer first
    _timer?.cancel();
    
    // Then dispose controllers
    _daysController?.dispose();
    _hoursController?.dispose();
    _minutesController?.dispose();
    _secondsController?.dispose();
    
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return; // Check if widget is still mounted
      
      setState(() {
        // Store previous values
        _prevDays = _days;
        _prevHours = _hours;
        _prevMinutes = _minutes;
        _prevSeconds = _seconds;
        
        if (_seconds > 0) {
          _seconds--;
        } else {
          _seconds = 59;
          if (_minutes > 0) {
            _minutes--;
          } else {
            _minutes = 59;
            if (_hours > 0) {
              _hours--;
            } else {
              _hours = 23;
              if (_days > 0) {
                _days--;
              } else {
                timer.cancel();
              }
            }
          }
        }
        
        // Trigger animations for changed values
        if (_prevSeconds != _seconds && _secondsController != null) {
          _secondsController!.reset();
          _secondsController!.forward();
        }
        
        if (_prevMinutes != _minutes && _minutesController != null) {
          _minutesController!.reset();
          _minutesController!.forward();
        }
        
        if (_prevHours != _hours && _hoursController != null) {
          _hoursController!.reset();
          _hoursController!.forward();
        }
        
        if (_prevDays != _days && _daysController != null) {
          _daysController!.reset();
          _daysController!.forward();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final games = [
      Game(
        title: 'IMPOSSIBLE CLIMB',
        description: 'Game Description most be here',
        icon: Icons.gamepad,
        prize: 'Cash Prize',
        prizeValue: 500,
        rating: 4.5,
      ),
      Game(
        title: 'KIDZIMA ADVENTURES',
        description: 'Game Description most be here',
        icon: Icons.gamepad,
        prize: 'Cash Prize',
        prizeValue: 500,
        rating: 3.5,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF090C0B),
        image: DecorationImage(
          image: AssetImage('assets/images/bg-gradient.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User profile section
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFF2A2A3A),
                          child: const Text(
                            'BH',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Bashdar ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Hakim',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0x4025332F), // #25332F with 25% opacity
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFF96C3BC), // #96C3BC color for star icon
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Level 5',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.75),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Countdown section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101513),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Countdown',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              // Calculate the width available for each time box
                              final boxWidth = (constraints.maxWidth - 24) / 4; // 24 is for spacing between boxes
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildTimeBox(context, _days, 'Days', _daysController, boxWidth),
                                  _buildTimeBox(context, _hours, 'Hours', _hoursController, boxWidth),
                                  _buildTimeBox(context, _minutes, 'Minutes', _minutesController, boxWidth),
                                  _buildTimeBox(context, _seconds, 'Seconds', _secondsController, boxWidth),
                                ],
                              );
                            }
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'The Game will be started after 30 mos, 29 days, 29 hrs, 29 min.',
                            style: TextStyle(
                              color: Color(0xFF737373),
                              fontSize: 12, // Reduced font size
                            ),
                            maxLines: 2, // Allow wrapping
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.notifications_outlined, size: 16), // Reduced icon size
                              label: const Text('Notify Me', style: TextStyle(fontSize: 14)), // Reduced font size
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFF262B29),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: Color(0xFF2A2A3A)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Game cards
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.55,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        final game = games[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF101513),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: AspectRatio(
                                  aspectRatio: 1.5,
                                  child: Container(
                                    color: index == 0 ? const Color(0xFF00B894) : const Color(0xFF6AB04C),
                                    child: Center(
                                      child: Text(
                                        game.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2A2A3A),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.white,
                                                  size: 12,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  game.rating.toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$ ${game.prizeValue.toInt()}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Game Name',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        game.description,
                                        style: const TextStyle(
                                          color: Color(0xFF8E8E8E),
                                          fontSize: 11,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {},
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: Colors.black,
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            minimumSize: const Size.fromHeight(40),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                'Play Now',
                                                style: TextStyle(fontSize: 12),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.arrow_forward,
                                                size: 12,
                                                color: Colors.grey.shade800,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // News section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101513),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'News for you',
                            style: TextStyle(
                              color: Color(0xFF8E8E8E),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          RichText(
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Since yesterday your ',
                                  style: TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 16, // Reduced font size
                                  ),
                                ),
                                TextSpan(
                                  text: 'sales ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16, // Reduced font size
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: 'have increased!',
                                  style: TextStyle(
                                    color: Color(0xFF8E8E8E),
                                    fontSize: 16, // Reduced font size
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBox(BuildContext context, int value, String label, AnimationController? controller, double boxWidth) {
    final fontSize = boxWidth * 0.5; // Responsive font size based on box width
    
    if (controller == null) {
      // Fallback if controller is not initialized
      return Container(
        width: boxWidth,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF242F2C),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: const Color(0xFF96C3BC),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: const Color(0xFFEFEFEF),
                fontSize: boxWidth * 0.15, // Responsive font size for label
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }
    
    return Container(
      width: boxWidth,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF242F2C),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: AnimatedBuilder(
              animation: controller,
              builder: (context, child) {
                // Create a fade-in animation
                final opacity = controller.value < 0.5 
                    ? 1.0 - controller.value * 2 // Fade out in first half
                    : (controller.value - 0.5) * 2; // Fade in in second half
                
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Center(
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: const Color(0xFF96C3BC),
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFFEFEFEF),
              fontSize: boxWidth * 0.15, // Responsive font size for label
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
