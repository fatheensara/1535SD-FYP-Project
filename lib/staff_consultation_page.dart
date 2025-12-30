import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffConsultationPage extends StatefulWidget {
  const StaffConsultationPage({super.key});

  @override
  State<StaffConsultationPage> createState() => _StaffConsultationPageState();
}

class _StaffConsultationPageState extends State<StaffConsultationPage> {
  // --- MOCK DATA ---
  final List<Map<String, dynamic>> _requests = [
    {
      "id": 1,
      "student": "Ahmad Ali",
      "matric": "2115542",
      "subject": "CSCI 2303",
      "reason": "Discuss Project Proposal",
      "time": "Requested: 10:00 AM, tomorrow",
    },
    {
      "id": 2,
      "student": "Sarah Lee",
      "matric": "2113341",
      "subject": "CSCI 4336",
      "reason": "Clarification on Assignment 1",
      "time": "Requested: 02:00 PM, tomorrow",
    },
  ];

  final List<Map<String, dynamic>> _appointments = [
    {
      "student": "Muthu Kumar",
      "subject": "CSCI 4332",
      "date": "Wed, 25 Oct",
      "time": "11:30 AM - 12:00 PM",
      "venue": "Lecturer Office",
      "status": "Confirmed",
    },
    {
      "student": "Jessica M.",
      "subject": "FYP Consultation",
      "date": "Thu, 26 Oct",
      "time": "09:00 AM - 09:30 AM",
      "venue": "Online (Meet)",
      "status": "Confirmed",
    },
    {
      "student": "Lee Wei Ming",
      "subject": "CSCI 2303",
      "date": "Thu, 26 Oct",
      "time": "02:00 PM - 02:30 PM",
      "venue": "Lecturer Office",
      "status": "Confirmed",
    },
  ];

  void _handleRequest(int index, bool accepted) {
    setState(() {
      String name = _requests[index]['student'];
      _requests.removeAt(index);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accepted
                ? "Request from $name Approved"
                : "Request from $name Declined",
          ),
          backgroundColor: accepted ? Colors.green : Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Consultation",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
              color: Colors.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 1. HEADER BACKGROUND
          Container(
            height: 250,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A0038), Color(0xFF4A00E0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),

          // 2. CONTENT
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Manage Requests",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Overview",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- PENDING REQUESTS SECTION ---
                  if (_requests.isNotEmpty) ...[
                    Text(
                      "Pending Requests (${_requests.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(221, 255, 255, 255),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ..._requests.asMap().entries.map((entry) {
                      return _buildRequestCard(entry.value, entry.key);
                    }),
                    const SizedBox(height: 25),
                  ],

                  // --- UPCOMING APPOINTMENTS SECTION ---
                  Text(
                    "Upcoming Schedule",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ..._appointments.map((data) => _buildAppointmentCard(data)),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button to set availability
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Manage Availability Clicked")),
          );
        },
        backgroundColor: const Color(0xFF4A00E0),
        icon: const Icon(Icons.edit_calendar_rounded),
        label: const Text("Set Availability"),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildRequestCard(Map<String, dynamic> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        // ignore: deprecated_member_use
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.orange.shade50,
                child: Text(
                  data['student'][0],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['student'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${data['matric']} • ${data['subject']}",
                      style: GoogleFonts.lato(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Pending",
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Reason: ${data['reason']}",
            style: GoogleFonts.lato(color: Colors.black87, fontSize: 13),
          ),
          const SizedBox(height: 5),
          Text(
            data['time'],
            style: GoogleFonts.lato(
              color: Colors.grey,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleRequest(index, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleRequest(index, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Approve"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Date Column
          Column(
            children: [
              Text(
                data['date'].split(',')[0],
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                data['date'].split(' ')[1],
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4A00E0),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          Container(height: 40, width: 1, color: Colors.grey.shade200),
          const SizedBox(width: 15),
          // Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['subject'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  "with ${data['student']}",
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 12,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data['time'],
                      style: GoogleFonts.lato(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Venue Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              data['venue'].contains("Online")
                  ? Icons.videocam_outlined
                  : Icons.location_on_outlined,
              size: 16,
              color: const Color(0xFF4A00E0),
            ),
          ),
        ],
      ),
    );
  }
}
