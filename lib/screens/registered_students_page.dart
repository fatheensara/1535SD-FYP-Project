import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/card_registry_service.dart';
import '../models/student_model.dart';

class RegisteredStudentsPage extends StatefulWidget {
  const RegisteredStudentsPage({super.key});

  @override
  State<RegisteredStudentsPage> createState() => _RegisteredStudentsPageState();
}

class _RegisteredStudentsPageState extends State<RegisteredStudentsPage> {
  Map<String, Student> _registeredStudents = {};
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRegisteredStudents();
  }

  Future<void> _loadRegisteredStudents() async {
    final students = await CardRegistryService.getRegisteredStudents();
    if (mounted) {
      setState(() {
        _registeredStudents = students;
        _isLoading = false;
      });
    }
  }

  Future<void> _unregisterStudent(String cardUid) async {
    final student = _registeredStudents[cardUid];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unregister Student'),
        content: Text(
          'Are you sure you want to unregister ${student?.name}? This will remove their card from the system.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unregister'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await CardRegistryService.unregisterStudentCard(cardUid);
      if (success && mounted) {
        await _loadRegisteredStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${student?.name} unregistered successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  List<MapEntry<String, Student>> _getFilteredStudents() {
    if (_searchQuery.isEmpty) {
      return _registeredStudents.entries.toList();
    }

    final lowerQuery = _searchQuery.toLowerCase();
    return _registeredStudents.entries.where((entry) {
      final student = entry.value;
      return student.name.toLowerCase().contains(lowerQuery) ||
          student.studentId.toLowerCase().contains(lowerQuery) ||
          student.course.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = _getFilteredStudents();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5), // Person A's background
      appBar: AppBar(
        title: Text(
          'Registered Students',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.purple.shade900, // Admin purple theme
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterOptions,
            tooltip: 'Filter Options',
          ),
        ],
      ),
      body: _buildStudentList(filteredStudents),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No Students Registered'
                : 'No Students Found',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Register student cards in the admin panel'
                : 'Try adjusting your search criteria',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(List<MapEntry<String, Student>> filteredStudents) {
    return Column(
      children: [
        // Search Bar (Person A's styling)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                // ignore: deprecated_member_use
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by name, ID, or course...',
              hintStyle: GoogleFonts.lato(color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: Colors.purple.shade600),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Colors.purple.shade600,
                  width: 2.0,
                ),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
            ),
          ),
        ),

        // Statistics Card (Person A's style)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade50, Colors.blue.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                _registeredStudents.length.toString(),
                'Total Students',
                Icons.people,
                Colors.purple.shade800,
              ),
              _buildStatItem(
                filteredStudents.length.toString(),
                'Showing',
                Icons.filter_list,
                Colors.blue.shade600,
              ),
              _buildStatItem(
                _getActiveTodayCount().toString(),
                'Active Today',
                Icons.event_available,
                Colors.green.shade600,
              ),
            ],
          ),
        ),

        // Students List
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : filteredStudents.isEmpty
              ? _buildEmptyState()
              : _buildStudentsList(filteredStudents),
        ),
      ],
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.lato(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.purple.shade600),
            const SizedBox(height: 16),
            Text(
              'Loading student data...',
              style: GoogleFonts.lato(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList(List<MapEntry<String, Student>> students) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.blue.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final entry = students[index];
          final cardUid = entry.key;
          final student = entry.value;
          return _buildStudentCard(cardUid, student);
        },
      ),
    );
  }

  Widget _buildStudentCard(String cardUid, Student student) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.blue.shade100],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.purple.shade600, size: 24),
          ),
          title: Text(
            student.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.badge, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'ID: ${student.studentId}',
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.school, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    student.course,
                    style: GoogleFonts.lato(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 12,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Card: ${student.physicalCardUid.substring(0, 10)}...',
                    style: GoogleFonts.sourceCodePro(
                      fontSize: 11,
                      color: Colors.green.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Registered: ${_formatDate(student.registeredAt)}',
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.shade600,
                size: 20,
              ),
              onPressed: () => _unregisterStudent(cardUid),
              tooltip: 'Unregister Student',
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to count "active today" (mock implementation)
  int _getActiveTodayCount() {
    // This is a mock implementation - you can replace with real logic
    final now = DateTime.now();
    return _registeredStudents.values.where((student) {
      final registeredDate = student.registeredAt;
      return now.difference(registeredDate).inDays <=
          7; // Active if registered in last 7 days
    }).length;
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Options',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 20),
            // Add filter options here if needed
            Text(
              'Use the search bar above to filter students',
              style: GoogleFonts.lato(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
