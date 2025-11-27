import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassDetailsPage extends StatelessWidget {
  final String classTitle;

  const ClassDetailsPage({super.key, required this.classTitle});

  @override
  Widget build(BuildContext context) {
    // Dummy History Data
    final List<Map<String, dynamic>> history = [
      {"date": "Nov 26", "status": "Pending", "color": Colors.orange},
      {"date": "Nov 24", "status": "Present", "color": Colors.green},
      {"date": "Nov 22", "status": "Late", "color": Colors.yellow.shade800},
      {
        "date": "Nov 20",
        "status": "Absent",
        "color": Colors.red,
      }, // MC Attached
      {"date": "Nov 18", "status": "Present", "color": Colors.green},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Class History", style: GoogleFonts.poppins()),
        backgroundColor: Colors.purple.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(24),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.purple.shade900,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  classTitle,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Attendance Rate: 80%",
                  style: GoogleFonts.lato(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // History List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: item['color'].withOpacity(0.2),
                      child: Icon(
                        item['status'] == "Present"
                            ? Icons.check
                            : item['status'] == "Absent"
                            ? Icons.close
                            : Icons.access_time,
                        color: item['color'],
                        size: 20,
                      ),
                    ),
                    title: Text(
                      item['date'],
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      item['status'],
                      style: GoogleFonts.lato(
                        color: item['color'],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: item['status'] == "Absent"
                        ? Text(
                            "MC Submitted",
                            style: GoogleFonts.lato(fontSize: 12),
                          )
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
}
