// lib/widgets/card_preview.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CardPreview extends StatelessWidget {
  final Map<String, dynamic>? cardData;
  final VoidCallback? onTap;
  final VoidCallback? onCreateCard;
  final bool isLoading;
  final bool hasCard; 

  // Add these gradients to match profile page
  static final List<List<Color>> _cardGradients = [
    [const Color(0xFF4A00E0), const Color(0xFF8E2DE2)], // Royal Purple
    [const Color(0xFF000428), const Color(0xFF004e92)], // Midnight Blue
    [const Color(0xFF11998e), const Color(0xFF38ef7d)], // Fresh Mint
    [const Color(0xFFcb2d3e), const Color(0xFFef473a)], // Fire Red
    [const Color(0xFF232526), const Color(0xFF414345)], // Sleek Black
  ];

  const CardPreview({
    super.key,
    this.cardData,
    this.onTap,
    this.onCreateCard,
    this.isLoading = false,
    this.hasCard = false, 
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingPreview();
    }

    if (!hasCard || cardData == null) {  
      return _buildNoCardPreview();
    }

    if (cardData == null) {
      return _buildNoCardPreview();
    }

    return _buildCardPreview();
  }

  Widget _buildLoadingPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(
              'Loading card...',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCardPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.credit_card_off,
                  color: Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'No Virtual Card',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Create a virtual card for NFC attendance',
              style: GoogleFonts.lato(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onCreateCard,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Virtual Card'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardPreview() {
    final name = cardData!['name'] ?? 'Unknown';
    final studentId = cardData!['studentId'] ?? 'Unknown';
    final course = cardData!['course'] ?? 'Unknown';
    
    // Get skin index from card data or use default
    final skinIndex = cardData!['skinIndex'] ?? 0;
    final safeIndex = skinIndex.clamp(0, _cardGradients.length - 1);
    final gradientColors = _cardGradients[safeIndex];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.memory,
                              color: Colors.white.withOpacity(0.8),
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Virtual Card',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade200,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Card content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ID: $studentId',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      course,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (cardData!['physicalCardUid'] != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'NFC: ${cardData!['physicalCardUid']!.substring(0, 8)}...',
                        style: GoogleFonts.sourceCodePro(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 8),

                // Quick actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onTap,
                      icon: Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'View Full',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onCreateCard,
                      icon: Icon(
                        Icons.refresh,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Recreate',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}