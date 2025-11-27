import 'package:flutter/material.dart';

// This class creates a reusable fade transition.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        // Set the transition duration
        transitionDuration: const Duration(milliseconds: 300),

        // The page that will be built
        pageBuilder: (context, animation, secondaryAnimation) => page,

        // The transitionsBuilder defines *how* the page transitions
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Use a FadeTransition
          return FadeTransition(
            // The animation is a value from 0.0 (transparent) to 1.0 (opaque)
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child:
                child, // The 'child' is the new page (e.g., StudentSignInPage)
          );
        },
      );
}
