import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart'; // ✅ Fixed Import Path

class StaffStudentRequestsPage extends StatelessWidget {
  const StaffStudentRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text("Registration Requests", style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('lecturer_requests')
            .where('status', isEqualTo: 'Pending') // Only show pending
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var requests = snapshot.data!.docs;
          
          if (requests.isEmpty) {
            return Center(child: Text("No pending requests.", style: GoogleFonts.lato(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var req = requests[index];
              return _buildRequestCard(context, req);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, QueryDocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.orange.shade50, child: const Icon(Icons.person_add, color: Colors.orange)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Admin added: ${data['studentName']}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    Text("${data['subject']} - ${data['section']}", style: GoogleFonts.lato(color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleDecision(context, doc.id, data, false),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text("Reject"),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleDecision(context, doc.id, data, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Accept"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- FEATURE 3: APPROVE/REJECT LOGIC ---
  void _handleDecision(BuildContext context, String docId, Map<String, dynamic> data, bool isApproved) async {
    await NotificationService.processRegistrationRequest(
      requestId: docId,
      studentName: data['studentName'],
      subject: data['subject'],
      isApproved: isApproved,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(isApproved ? "✅ Student Accepted" : "❌ Student Rejected")),
    );
  }
}