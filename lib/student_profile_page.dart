import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'welcome.dart';
import 'fade_page_route.dart';
import 'student_nfc_page.dart';
import 'student_security_page.dart';
import 'student_scan_activity_page.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  // --- STATE VARIABLES ---

  // 1. Profile Data
  String _nickname = "Nurul Iman";
  String _gender = "Female"; // Options: Male, Female

  // 2. Photo State
  // In a real app, you would use 'File? _imageFile' with the image_picker package.
  // Here we simulate it with a boolean to toggle between a custom mock image and default.
  bool _hasCustomPhoto = true;

  // 3. Card Customization State
  Color _cardColor = const Color(0xFF4A00E0); // Default Purple
  bool _useGradient = true;

  // Rainbow Palette (Standard Flutter Colors)
  final List<Color> _rainbowColors = [
    const Color(0xFF4A00E0), // Original Purple
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.blueGrey,
    Colors.black,
  ];

  // --- LOGIC: EDIT PROFILE DIALOG ---
  void _showEditProfileDialog() {
    TextEditingController nameController = TextEditingController(
      text: _nickname,
    );
    String tempGender = _gender;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                "Edit Profile",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nickname Input
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Nickname",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Gender Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: tempGender,
                    decoration: InputDecoration(
                      labelText: "Gender",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.people_outline),
                    ),
                    items: ["Male", "Female"]
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      setStateDialog(() => tempGender = val!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _nickname = nameController.text;
                      _gender = tempGender;
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- LOGIC: PHOTO OPTIONS ---
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Change Profile Photo",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text("Take Photo"),
                onTap: () {
                  // In real app: Call ImagePicker().pickImage(source: ImageSource.camera)
                  setState(() => _hasCustomPhoto = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Photo Updated!")),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.purple),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  // In real app: Call ImagePicker().pickImage(source: ImageSource.gallery)
                  setState(() => _hasCustomPhoto = true);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Photo Uploaded!")),
                  );
                },
              ),
              if (_hasCustomPhoto)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text("Remove Photo (Default)"),
                  onTap: () {
                    setState(() => _hasCustomPhoto = false);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          children: [
            // --- 1. HEADER ---
            _buildProfileHeader(),

            // --- 2. VIRTUAL ID CARD ---
            Transform.translate(
              offset: const Offset(0, -40),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildVirtualCard(),

                    const SizedBox(height: 30),

                    // --- 3. CUSTOMIZATION SECTION (NEW) ---
                    _buildSectionTitle("Customize Card Skin"),
                    _buildCardCustomizer(),

                    const SizedBox(height: 30),

                    // --- 4. SETTINGS MENU ---
                    _buildSectionTitle("Device & Account"),
                    _buildMenuTile(
                      icon: Icons.nfc_rounded,
                      title: "NFC Sensitivity",
                      subtitle: "Calibrate for faster scanning",
                      onTap: () => Navigator.push(
                        context,
                        FadePageRoute(page: const StudentNfcPage()),
                      ),
                    ),
                    _buildMenuTile(
                      icon: Icons.lock_outline,
                      title: "Security",
                      subtitle: "Biometrics & App Lock",
                      onTap: () => Navigator.push(
                        context,
                        FadePageRoute(page: const StudentSecurityPage()),
                      ),
                    ),
                    _buildMenuTile(
                      icon: Icons.history_rounded,
                      title: "Scan Activity",
                      subtitle: "View recent device handshakes",
                      onTap: () => Navigator.push(
                        context,
                        FadePageRoute(page: const StudentScanActivityPage()),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- 5. LOGOUT ---
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            FadePageRoute(page: const WelcomeScreen()),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.red.shade100),
                          ),
                        ),
                        child: Text(
                          "Log Out",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 80, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF2D3436),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          // Avatar with Edit Badge
          GestureDetector(
            onTap: _showPhotoOptions,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.grey.shade300,
                    // If custom photo is true, show mock image, else show icon
                    backgroundImage: _hasCustomPhoto
                        ? const NetworkImage('https://i.pravatar.cc/300?img=12')
                        : null,
                    child: !_hasCustomPhoto
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey.shade600,
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),

          // Editable Info
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    _nickname,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Student • $_gender",
                    style: GoogleFonts.lato(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _showEditProfileDialog,
                icon: const Icon(Icons.edit, color: Colors.white54, size: 20),
                tooltip: "Edit Profile",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualCard() {
    // Determine Card Decoration based on user selection
    BoxDecoration cardDecoration;

    if (_useGradient) {
      // Create a gradient derived from the selected color
      // Logic: Main color to a lighter version of itself
      cardDecoration = BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _cardColor,
            HSVColor.fromColor(_cardColor)
                .withValue(0.8)
                .withHue((HSVColor.fromColor(_cardColor).hue + 20) % 360)
                .toColor(),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _cardColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );
    } else {
      // Solid Color
      cardDecoration = BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: _cardColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      );
    }

    return Container(
      height: 220,
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 45,
                height: 35,
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                  // ignore: deprecated_member_use
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Center(
                  // ignore: deprecated_member_use
                  child: Icon(
                    Icons.memory,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(0.8),
                    size: 24,
                  ),
                ),
              ),
              // ignore: deprecated_member_use
              Icon(Icons.wifi, color: Colors.white.withOpacity(0.6), size: 28),
            ],
          ),

          // Student Details
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "211XXXX",
                style: GoogleFonts.sourceCodePro(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "STUDENT NAME",
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _nickname.toUpperCase(), // Displaying editable nickname
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "VALID THRU",
                        style: GoogleFonts.lato(
                          color: Colors.white54,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "12/26",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- NEW: ADVANCED CARD CUSTOMIZER ---
  Widget _buildCardCustomizer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Solid vs Gradient Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Effect Style",
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              Row(
                children: [
                  Text(
                    "Solid",
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: !_useGradient ? Colors.black : Colors.grey,
                    ),
                  ),
                  Switch(
                    value: _useGradient,
                    activeThumbColor: _cardColor,
                    onChanged: (val) {
                      setState(() {
                        _useGradient = val;
                      });
                    },
                  ),
                  Text(
                    "Gradient",
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: _useGradient ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 20),

          // 2. Rainbow Color Picker
          Text(
            "Base Color",
            style: GoogleFonts.lato(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _rainbowColors.length,
              // ignore: unnecessary_underscores
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                Color c = _rainbowColors[index];
                bool isSelected = _cardColor == c;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _cardColor = c;
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                      boxShadow: [
                        if (isSelected)
                          // ignore: deprecated_member_use
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: c.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.purple.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.purple.shade400, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
