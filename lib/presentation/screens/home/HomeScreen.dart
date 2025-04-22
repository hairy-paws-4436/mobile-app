import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/presentation/screens/home/tabs/NGOsTab.dart';
import 'package:mobile_app/presentation/screens/home/tabs/animals_tab.dart';
import 'package:mobile_app/presentation/screens/home/tabs/events_tab.dart';
import 'package:mobile_app/presentation/screens/home/tabs/profile_tab.dart';

import '../../../config/theme.dart';
import '../../../data/models/user.dart';
import '../../../di/injection_container.dart';
import '../../bloc/animal/animal_bloc.dart';
import '../../bloc/animal/animal_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/event/event_event.dart';
import '../../bloc/ngo/ngo_bloc.dart';
import '../../bloc/ngo/ngo_event.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late User _currentUser;
  
  final List<String> _titles = [
    'Pet Adoption',
    'NGOs',
    'Events',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // Load initial data for all tabs
    context.read<AnimalBloc>().add(FetchAnimalsEvent());
    context.read<NGOBloc>().add(FetchNGOsEvent());
    context.read<EventBloc>().add(FetchEventsEvent());
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          _currentUser = state.user;

          return Scaffold(
            appBar: AppBar(
              title: Text(_titles[_currentIndex]),
              actions: [
                // Notification Bell
                BlocProvider(
                  create: (context) => sl<NotificationBloc>()..add(FetchNotificationsEvent()),
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.notifications),
                        onPressed: () {
                          Navigator.pushNamed(context, '/notifications');
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: [
                // Pets Tab
                AnimalsTab(),

                // NGOs Tab
                NGOsTab(),

                // Events Tab
                EventsTab(),

                // Profile Tab
                ProfileTab(user: _currentUser),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.pets),
                  label: 'Pets',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.business),
                  label: 'NGOs',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event),
                  label: 'Events',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
            floatingActionButton: _buildFloatingActionButton(),
          );
        }

        // If not authenticated, show loading
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    // Only show FAB for specific tabs and roles
    if (_currentIndex == 0 && _currentUser.role == 'owner') {
      // Add pet FAB for owners in pets tab
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/animal-form');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 2 && _currentUser.role == 'ngo') {
      // Add event FAB for NGOs in events tab
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/event-form');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      );
    }
    
    return null;
  }
}
