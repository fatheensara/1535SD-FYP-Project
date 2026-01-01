import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffLeaveStatusPage extends StatefulWidget {
  // Accept optional new application data
  final Map<String, dynamic>? newApplication;

  const StaffLeaveStatusPage({super.key, this.newApplication});

  @override
  State<StaffLeaveStatusPage> createState() => _StaffLeaveStatusPageState();
}

class _StaffLeaveStatusPageState extends State<StaffLeaveStatusPage> {
  // Mock Data for Leave History (Mutable List)
  final List<Map<String, dynamic>> _leaveHistory = [
    {
      "type": "Annual Leave",
      "date": "20 Dec - 25 Dec",
      "reason": "Family vacation",
      "attachment": null,
      "status": "Approved",
      "color": "green",
    },
  ];

  @override
  void initState() {
    super.initState();
    // If a new application was passed, add it to the top of the list
    if (widget.newApplication != null) {
      _leaveHistory.insert(0, widget.newApplication!);
    }
  }

  // --- LOGIC: Show Application Details (Preview) ---
  void _showApplicationPreview(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Application Details",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4A00E0),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 10),
              _buildDetailRow("Leave Type", item['type']),
              _buildDetailRow("Duration", item['date']),
              _buildDetailRow(
                "Status",
                item['status'],
                color: item['status'] == "Pending Approval"
                    ? Colors.orange
                    : Colors.green,
              ),
              const SizedBox(height: 15),
              Text(
                "Reason:",
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  item['reason'] ?? "No reason provided",
                  style: GoogleFonts.lato(color: Colors.black87),
                ),
              ),
              const SizedBox(height: 15),
              if (item['attachment'] != null) ...[
                Text(
                  "Attachment:",
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_file,
                      size: 18,
                      color: Color(0xFF4A00E0),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      item['attachment'],
                      style: GoogleFonts.lato(
                        color: const Color(0xFF4A00E0),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.lato(color: Colors.grey.shade600)),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: Text(
          "Application Status",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _leaveHistory.length,
        itemBuilder: (context, index) {
          final item = _leaveHistory[index];
          final isPending = item['status'] == "Pending Approval";

          return GestureDetector(
            onTap: () => _showApplicationPreview(item), // OPEN PREVIEW
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border(
                  left: BorderSide(
                    color: isPending ? Colors.orange : Colors.green,
                    width: 4,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['type']!,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isPending
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          item['status']!,
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPending ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        "${item['date']}",
                        style: GoogleFonts.lato(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (isPending)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "Waiting for Admin approval. Tap to view.",
                            style: GoogleFonts.lato(
                              color: Colors.orange.shade300,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
