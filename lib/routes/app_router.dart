import 'package:flutter/material.dart';

import '../presentation/screens/adoption/adoption_details_screen.dart';
import '../presentation/screens/adoption/adoption_request_form_screen.dart';
import '../presentation/screens/adoption/adoption_requests_screen.dart';
import '../presentation/screens/animal/animal_details_screen.dart';
import '../presentation/screens/animal/animal_form_screen.dart';
import '../presentation/screens/animal/owner_animals_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/auth/register_screen.dart';
import '../presentation/screens/auth/two_factor_screen.dart';
import '../presentation/screens/donation/donation_form_screen.dart';
import '../presentation/screens/donation/donations_screen.dart';
import '../presentation/screens/event/event_details_screen.dart';
import '../presentation/screens/event/event_form_screen.dart';
import '../presentation/screens/event/events_screen.dart';
import '../presentation/screens/home/HomeScreen.dart';
import '../presentation/screens/ngo/ngo_details_screen.dart';
import '../presentation/screens/ngo/ngo_form_screen.dart';
import '../presentation/screens/ngo/ngos_screen.dart';
import '../presentation/screens/notification/notifications_screen.dart';
import '../presentation/screens/profile/change_password_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/splash_screen.dart';
class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
    // Auth
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case '/register':
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case '/two-factor':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TwoFactorScreen(userId: args['userId']),
        );

    // Home
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());

    // Profile
      case '/profile':
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case '/change-password':
        return MaterialPageRoute(builder: (_) => ChangePasswordScreen());

    // Animals
      case '/animal-details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AnimalDetailsScreen(animalId: args['animalId']),
        );
      case '/animal-form':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AnimalFormScreen(animalId: args?['animalId']),
        );
      case '/owner-animals':
          return MaterialPageRoute(builder: (_) => OwnerAnimalsScreen());

    // Adoptions
      case '/adoption-requests':
        return MaterialPageRoute(builder: (_) => AdoptionRequestsScreen());
      case '/adoption-details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AdoptionDetailsScreen(adoptionId: args['adoptionId']),
        );
      case '/adoption-request-form':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AdoptionRequestFormScreen(animalId: args['animalId']),
        );

    // NGOs
      case '/ngos':
        return MaterialPageRoute(builder: (_) => NGOsScreen());
      case '/ngo-details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => NGODetailsScreen(ngoId: args['ngoId']),
        );
      case '/ngo-form':
        return MaterialPageRoute(builder: (_) => NGOFormScreen());

    // Events
      case '/events':
        return MaterialPageRoute(builder: (_) => EventsScreen());
      case '/event-details':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EventDetailsScreen(eventId: args['eventId']),
        );
      case '/event-form':
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => EventFormScreen(eventId: args?['eventId']),
        );

    // Donations
      case '/donations':
        return MaterialPageRoute(builder: (_) => DonationsScreen());
      case '/donation-form':
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DonationFormScreen(ngoId: args['ngoId']),
        );

    // Notifications
      case '/notifications':
        return MaterialPageRoute(builder: (_) => NotificationsScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
