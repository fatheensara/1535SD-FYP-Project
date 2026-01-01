import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StaffConsultationPage extends StatefulWidget {
  const StaffConsultationPage({super.key});

  @override
  State<StaffConsultationPage> createState() => _StaffConsultationPageState();
}

class _StaffConsultationPageState extends State<StaffConsultationPage> {
  // --- MOCK DATA: Requests ---
  final List<Map<String, dynamic>> _requests = [
    {
      "id": 1,
      "student": "Ahmad Ali",
      "matric": "2115542",
      "subject": "CSCI 2303",
      "reason": "Discuss Project Proposal",
      "time": "Requested: 10:00 AM, tomorrow",
      "rawTime": "10:00 AM - 10:30 AM",
    },
    {
      "id": 2,
      "student": "Sarah Lee",
      "matric": "2113341",
      "subject": "CSCI 4336",
      "reason": "Clarification on Assignment 1",
      "time": "Requested: 02:00 PM, tomorrow",
      "rawTime": "02:00 PM - 02:30 PM",
    },
  ];

  // --- MOCK DATA: Appointments ---
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
  ];

  // --- MOCK DATA: My Availability Slots ---
  final List<Map<String, String>> _myAvailability = [
    {
      "day": "Mon",
      "date": "30 Oct",
      "time": "10:00 AM - 12:00 PM",
      "location": "Office",
    },
    {
      "day": "Wed",
      "date": "01 Nov",
      "time": "02:00 PM - 04:00 PM",
      "location": "Online",
    },
    {
      "day": "Fri",
      "date": "03 Nov",
      "time": "09:00 AM - 11:00 AM",
      "location": "Office",
    },
  ];

  // --- TEMPORARY STATE FOR UNDO LOGIC ---
  Map<String, String>? _tempDeletedItem;
  int? _tempDeletedIndex;

  // --- LOGIC: Handle Request ---
  void _handleRequest(int index, bool accepted) {
    Map<String, dynamic> requestData = _requests[index];
    String studentName = requestData['student'];
    String studentMatric = requestData['matric'];

    setState(() {
      _requests.removeAt(index);
    });

    if (accepted) {
      _addToSchedule(requestData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Request from $studentName Approved"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      _sendDeclineNotification(studentName, studentMatric);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Request Declined."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _addToSchedule(Map<String, dynamic> req) {
    setState(() {
      _appointments.insert(0, {
        "student": req['student'],
        "subject": req['subject'],
        "date": "Fri, 27 Oct",
        "time": req['rawTime'],
        "venue": "Lecturer Office",
        "status": "Confirmed",
      });
    });
  }

  void _sendDeclineNotification(String name, String matric) {
    print("--- NOTIFICATION SENT TO $name ---");
  }

  // --- HELPER: Time Formatting ---
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return "${hour == 0 ? 12 : hour}:$minute $period";
  }

  // --- HELPER: Date Formatting ---
  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec",
    ];
    return months[month - 1];
  }

  String _getDayName(int weekday) {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[weekday - 1];
  }

  // --- LOGIC: Add/Edit Slot Dialog ---
  void _showAddEditSlotDialog(
    BuildContext context,
    StateSetter setSheetState, {
    int? index,
  }) {
    final bool isEditing = index != null;

    DateTime selectedDate = DateTime.now();
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);
    String selectedLocation = "Office";

    if (isEditing) {
      selectedLocation = _myAvailability[index!]['location']!;
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Widget buildLocationChip(String label, IconData icon) {
              final bool isSelected = selectedLocation == label;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setStateDialog(() => selectedLocation = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF4A00E0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF4A00E0)
                            : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: const Color(0xFF4A00E0).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          color: isSelected ? Colors.white : Colors.grey,
                          size: 20,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          label,
                          style: GoogleFonts.lato(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            Widget buildTimeSelector(
              String label,
              TimeOfDay time,
              bool isStart,
            ) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: time,
                          builder: (context, child) {
                            return MediaQuery(
                              data: MediaQuery.of(
                                context,
                              ).copyWith(alwaysUse24HourFormat: false),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            if (isStart)
                              startTime = picked;
                            else
                              endTime = picked;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: Color(0xFF4A00E0),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimeOfDay(time),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        isEditing ? "Edit Availability" : "New Availability",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      "Select Date",
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) {
                            return Theme(
                              data: ThemeData.light().copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF4A00E0),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null) {
                          setStateDialog(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A00E0).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF4A00E0).withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF4A00E0),
                            ),
                            const SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getDayName(selectedDate.weekday),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: const Color(0xFF4A00E0),
                                  ),
                                ),
                                Text(
                                  "${selectedDate.day} ${_getMonthName(selectedDate.month)} ${selectedDate.year}",
                                  style: GoogleFonts.lato(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        buildTimeSelector("From", startTime, true),
                        const SizedBox(width: 15),
                        buildTimeSelector("To", endTime, false),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Location",
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        buildLocationChip("Office", Icons.business),
                        const SizedBox(width: 10),
                        buildLocationChip("Online", Icons.videocam),
                        const SizedBox(width: 10),
                        buildLocationChip("Lab", Icons.computer),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey,
                            ),
                            child: const Text("Cancel"),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final newData = {
                                "day": _getDayName(selectedDate.weekday),
                                "date":
                                    "${selectedDate.day} ${_getMonthName(selectedDate.month)}",
                                "time":
                                    "${_formatTimeOfDay(startTime)} - ${_formatTimeOfDay(endTime)}",
                                "location": selectedLocation,
                              };

                              if (isEditing) {
                                _myAvailability[index!] = newData;
                              } else {
                                _myAvailability.add(newData);
                              }

                              setSheetState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A00E0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              isEditing ? "Save Changes" : "Add Slot",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- LOGIC: Show Availability Modal ---
  void _showAvailabilityModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    // Handle
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 20),
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    // Title
                    Text(
                      "My Availability Slots",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4A00E0),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Manage your open slots",
                      style: GoogleFonts.lato(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // --- UNDO BANNER (Internal - Replaces SnackBar) ---
                    if (_tempDeletedItem != null)
                      Container(
                        margin: const EdgeInsets.only(
                          bottom: 15,
                          left: 24,
                          right: 24,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade900,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              "Slot deleted",
                              style: TextStyle(color: Colors.white),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // UNDO ACTION
                                _myAvailability.insert(
                                  _tempDeletedIndex!,
                                  _tempDeletedItem!,
                                );
                                _tempDeletedItem = null;
                                _tempDeletedIndex = null;
                                setSheetState(() {});
                                setState(() {});
                              },
                              child: const Text(
                                "Undo",
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.grey,
                                size: 18,
                              ),
                              onPressed: () {
                                _tempDeletedItem = null;
                                _tempDeletedIndex = null;
                                setSheetState(() {});
                              },
                            ),
                          ],
                        ),
                      ),

                    // List
                    Expanded(
                      child: _myAvailability.isEmpty
                          ? Center(
                              child: Text(
                                "No slots added.",
                                style: GoogleFonts.lato(),
                              ),
                            )
                          : ListView.separated(
                              controller: controller,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              itemCount: _myAvailability.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final slot = _myAvailability[index];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF6F8FA),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // Date Box
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade200,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              slot['day']!,
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF4A00E0),
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              slot['date']!.split(' ')[0],
                                              style: GoogleFonts.lato(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 15),

                                      // Info Column
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.access_time_rounded,
                                                  size: 16,
                                                  color: Color(0xFF4A00E0),
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    slot['time']!,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 13,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  slot['location'] == "Online"
                                                      ? Icons.videocam_outlined
                                                      : Icons
                                                            .location_on_outlined,
                                                  size: 14,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 5),
                                                Expanded(
                                                  child: Text(
                                                    slot['location']!,
                                                    style: GoogleFonts.lato(
                                                      color:
                                                          Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Edit Button
                                      IconButton(
                                        onPressed: () => _showAddEditSlotDialog(
                                          context,
                                          setSheetState,
                                          index: index,
                                        ),
                                        icon: const Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blue,
                                          size: 20,
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                      const SizedBox(width: 5),

                                      // Delete Button (Updates State for Undo)
                                      IconButton(
                                        onPressed: () {
                                          _tempDeletedItem =
                                              _myAvailability[index];
                                          _tempDeletedIndex = index;

                                          _myAvailability.removeAt(index);
                                          setSheetState(() {});
                                          setState(() {});
                                          // NOTE: SnackBar removed.
                                          // Only internal banner will show now.
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.shade400,
                                          size: 20,
                                        ),
                                        constraints: const BoxConstraints(),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    // Add Button
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showAddEditSlotDialog(context, setSheetState),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A00E0),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text("Add New Slot"),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
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
          // Header Background
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

          // Content
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Overview",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_requests.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${_requests.length} New",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Pending Requests
                  if (_requests.isNotEmpty) ...[
                    Text(
                      "Pending Requests",
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

                  // Upcoming Appointments
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

      // FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAvailabilityModal,
        backgroundColor: const Color(0xFF4A00E0),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.edit_calendar_rounded),
        label: const Text(
          "Set Availability",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
