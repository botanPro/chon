import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _selectedCity;

  final List<String> _cities = ['Erbil', 'Duhok', 'Suliymaniyah'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360 || screenSize.height < 600;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF010202),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              label: Text(
                'Back',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.06,
            vertical: 24.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ARE YOU READY TO',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 20 : 25,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [
                        Color(0xFF94C1BA),
                        Color(0xFF3A4C49),
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                ),
              ),
              Text(
                'PLAY THE GAMES?',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 20 : 25,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: const [
                        Color(0xFF94C1BA),
                        Color(0xFF3A4C49),
                      ],
                    ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Personal Information',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 24 : 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.left,
              ),
              Text(
                'Please fill in your details to complete your profile',
                style: GoogleFonts.inter(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.white.withOpacity(0.7),
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(height: isSmallScreen ? 24 : 40),
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                hint: 'Enter your first name',
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                hint: 'Enter your last name',
                isSmallScreen: isSmallScreen,
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF101513),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCity,
                        hint: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Select your city',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: isSmallScreen ? 12 : 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        dropdownColor: const Color(0xFF101513),
                        isExpanded: true,
                        icon: Padding(
                          padding: const EdgeInsets.only(right: 16),
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        ),
                        items: _cities.map((String city) {
                          return DropdownMenuItem<String>(
                            value: city,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                city,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 12 : 14,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCity = newValue;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                height: 56,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 240, 240, 240),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      if (_firstNameController.text.isNotEmpty &&
                          _lastNameController.text.isNotEmpty &&
                          _selectedCity != null) {
                        // Navigate to main screen and remove all previous routes
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/home',
                          (route) => false,
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF090C0B),
                              fontSize: isSmallScreen ? 11 : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            color: const Color(0xFF090C0B),
                            size: isSmallScreen ? 18 : 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontWeight: FontWeight.w500,
            fontSize: isSmallScreen ? 12 : 14,
            fontFamily: 'Inter',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF101513),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF101513),
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: isSmallScreen ? 12 : 14,
                fontFamily: 'Inter',
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
