import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffApprovalsPage extends StatefulWidget {
  const StaffApprovalsPage({super.key});

  @override
  State<StaffApprovalsPage> createState() => _StaffApprovalsPageState();
}

class _StaffApprovalsPageState extends State<StaffApprovalsPage> {
  // --- MOCK DATA: Pending Requests ---
  final List<Map<String, dynamic>> _pendingRequests = [
    {
      "id": "2114421",
      "name": "Muthu Kumar",
      "type": "Medical Certificate",
      "details": "Absent for CSCI 4332 on 23 Oct",
      "file": "mc_muthu.pdf",
      "date": "Applied: 2 hrs ago",
    },
    {
      "id": "2118876",
      "name": "John Doe",
      "type": "Medical Certificate",
      "details": "Absent for CSCI 4336 on 19 Nov",
      "file": "mc_john.pdf",
      "date": "Applied: 5 hrs ago",
    },
    {
      "id": "2119982",
      "name": "Ahmad Ali",
      "type": "Medical Certificate",
      "details": "Absent for CSCI 2303 on 22 Oct",
      "file": "mc_ahmad.pdf",
      "date": "Applied: 1 day ago",
    },
  ];

  // --- LOGIC: Process Request (Approve/Reject) ---
  void _processRequest(int index, bool isApproved) {
    String name = _pendingRequests[index]['name'];
    String studentId = _pendingRequests[index]['id'];
    String fileName = _pendingRequests[index]['file'];

    // 1. & 2. Send Notification to Student Portal (Simulated)
    _simulateSendNotification(studentId, fileName, isApproved);

    setState(() {
      _pendingRequests.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApproved ? "Request Approved" : "Request Rejected",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("Notification sent to student ($name)."),
          ],
        ),
        backgroundColor: isApproved ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Helper to simulate API call to backend
  void _simulateSendNotification(String id, String file, bool isApproved) {
    String status = isApproved ? "APPROVED" : "REJECTED";
    // TODO: Connect this to your Firebase/Database
    // Example: FirebaseFirestore.instance.collection('notifications').add(...)
    print("--- SERVER LOG ---");
    print("To Student ID: $id");
    print("Message: Your submission ($file) has been $status.");
    print("------------------");
  }

  // --- LOGIC: View Attachment ---
  // 3. Open the MC letter to view
  void _viewAttachment(String fileName, String studentName) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              // Dialog Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        fileName,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Dialog Content (Mock Viewer)
              Expanded(
                child: Container(
                  color: Colors.grey.shade100,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        size: 60,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Preview of MC for\n$studentName",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // NOTE: In a real app, you would use a PDF View package here
                      Text(
                        "(Document Viewer Placeholder)",
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Pending Approvals",
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
            child: _pendingRequests.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    itemCount: _pendingRequests.length,
                    itemBuilder: (context, index) {
                      return _buildRequestCard(_pendingRequests[index], index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: EMPTY STATE ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 20),
          Text(
            "All Caught Up!",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade400,
            ),
          ),
          Text(
            "No pending requests to review.",
            style: GoogleFonts.lato(color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: REQUEST CARD ---
  Widget _buildRequestCard(Map<String, dynamic> data, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      ),
      child: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.indigo.shade50,
                  child: Text(
                    data['name'][0],
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['name'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        data['id'],
                        style: GoogleFonts.sourceCodePro(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          data['type'].toUpperCase(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  data['date'],
                  style: GoogleFonts.lato(
                    fontSize: 11,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Details & Actions Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reason:",
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data['details'],
                  style: GoogleFonts.lato(color: Colors.black87),
                ),
                const SizedBox(height: 15),

                // Attachment (Made Clickable)
                InkWell(
                  onTap: () {
                    _viewAttachment(data['file'], data['name']);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 18,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          data['file'],
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _processRequest(index, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Reject"),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _processRequest(index, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text("Approve"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
