import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminApprovalsPage extends StatefulWidget {
  const AdminApprovalsPage({super.key});

  @override
  State<AdminApprovalsPage> createState() => _AdminApprovalsPageState();
}

class _AdminApprovalsPageState extends State<AdminApprovalsPage> {
  // Mock Data for Pending Requests
  final List<Map<String, dynamic>> _requests = [
    {
      "id": "REQ-001",
      "type": "Registration",
      "user": "Ahmad Albab",
      "role": "Student",
      "details": "Matric: 2114556",
      "time": "10 mins ago",
      "color": Colors.blueAccent,
    },
    {
      "id": "REQ-002",
      "type": "Medical Leave",
      "user": "Siti Sarah",
      "role": "Student",
      "details": "Reason: High Fever (MC Attached)",
      "time": "1 hour ago",
      "color": Colors.redAccent,
    },
    {
      "id": "REQ-003",
      "type": "Profile Update",
      "user": "Dr. Takumi",
      "role": "Staff",
      "details": "Change Dept to Software Engineering",
      "time": "3 hours ago",
      "color": Colors.purpleAccent,
    },
    {
      "id": "REQ-004",
      "type": "Registration",
      "user": "John Wick",
      "role": "Staff",
      "details": "Staff ID: S9999",
      "time": "5 hours ago",
      "color": Colors.blueAccent,
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Background is provided by AdminHomePage Stack if used as a tab.
    // If pushed as a new route, you might need to wrap this in the gradient container.
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pending Requests",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.orangeAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${_requests.length} Items Awaiting Action",
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Filter Button
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Icon(Icons.sort, color: Colors.tealAccent),
                  ),
                ],
              ),
            ),

            // --- REQUEST LIST ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  return _buildRequestCard(_requests[index], index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildRequestCard(Map<String, dynamic> req, int index) {
    return Dismissible(
      key: Key(req['id']),
      background: _buildSwipeAction(
        Alignment.centerLeft,
        Colors.green,
        Icons.check_circle_outline,
      ),
      secondaryBackground: _buildSwipeAction(
        Alignment.centerRight,
        Colors.red,
        Icons.cancel_outlined,
      ),
      onDismissed: (direction) {
        setState(() {
          _requests.removeAt(index);
        });
        String action = direction == DismissDirection.startToEnd
            ? "Approved"
            : "Rejected";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$action ${req['id']}"),
            backgroundColor: direction == DismissDirection.startToEnd
                ? Colors.green
                : Colors.red,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: req['color'].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: req['color']),
                        ),
                        child: Text(
                          req['type'].toUpperCase(),
                          style: GoogleFonts.sourceCodePro(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: req['color'],
                          ),
                        ),
                      ),
                      Text(
                        req['time'],
                        style: GoogleFonts.lato(
                          color: Colors.white30,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Text(
                          req['user'][0],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req['user'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            req['role'],
                            style: GoogleFonts.lato(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  // ignore: deprecated_member_use
                  Divider(color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 10),

                  Text(
                    req['details'],
                    style: GoogleFonts.lato(color: Colors.white70),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Manual Reject Trigger
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text("Deny"),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Manual Approve Trigger
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeAction(Alignment alignment, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
