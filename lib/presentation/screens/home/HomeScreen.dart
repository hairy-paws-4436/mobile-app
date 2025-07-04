import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/presentation/screens/home/tabs/NGOsTab.dart';
import 'package:mobile_app/presentation/screens/home/tabs/animals_tab.dart';
import 'package:mobile_app/presentation/screens/home/tabs/events_tab.dart';
import 'package:mobile_app/presentation/screens/home/tabs/profile_tab.dart';
import 'package:mobile_app/presentation/screens/home/tabs/recommendations_tab.dart';

import '../../../config/theme.dart';
import '../../../data/models/user.dart';
import '../../../di/injection_container.dart';
import '../../bloc/animal/animal_bloc.dart';
import '../../bloc/animal/animal_event.dart';
import '../../bloc/animal/animal_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/event/event_event.dart';
import '../../bloc/matching/matching_bloc.dart';
import '../../bloc/matching/matching_event.dart';
import '../../bloc/matching/matching_state.dart';
import '../../bloc/ngo/ngo_bloc.dart';
import '../../bloc/ngo/ngo_event.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late User _currentUser;

  late List<String> _titles;
  late List<Widget> _tabs;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _setupTabsForUser(User user) {
    if (user.role == 'adopter') {
      // Para adoptantes: mostrar recomendaciones
      _titles = [
        'Recomendaciones',
        'Todas las Mascotas',
        'NGOs',
        'Eventos',
        'Perfil',
      ];
      _tabs = [
        RecommendationsTab(),
        AnimalsTab(),
        NGOsTab(),
        EventsTab(),
        ProfileTab(user: user),
      ];
    } else {
      // Para owners y NGOs: mantener tabs originales
      _titles = [
        'Pet Adoption',
        'NGOs',
        'Events',
        'Profile',
      ];
      _tabs = [
        AnimalsTab(),
        NGOsTab(),
        EventsTab(),
        ProfileTab(user: user),
      ];
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Load data based on tab and user role
    if (_currentUser.role == 'adopter') {
      switch (index) {
        case 0: // Recommendations
        // Verificar si ya hay recomendaciones cargadas
          final currentMatchingState = context.read<MatchingBloc>().state;
          if (currentMatchingState is! RecommendationsLoaded) {
            context.read<MatchingBloc>().add(GetRecommendationsEvent());
          }
          break;
        case 1: // All Animals
          context.read<AnimalBloc>().add(FetchAnimalsEvent());
          break;
        case 2: // NGOs
          context.read<NGOBloc>().add(FetchNGOsEvent());
          break;
        case 3: // Events
          context.read<EventBloc>().add(FetchEventsEvent());
          break;
        case 4: // Profile
          context.read<NotificationBloc>().add(FetchNotificationsEvent());
          break;
      }
    } else {
      switch (index) {
        case 0: // Animals
          context.read<AnimalBloc>().add(FetchAnimalsEvent());
          break;
        case 1: // NGOs
          context.read<NGOBloc>().add(FetchNGOsEvent());
          break;
        case 2: // Events
          context.read<EventBloc>().add(FetchEventsEvent());
          break;
        case 3: // Profile
          context.read<NotificationBloc>().add(FetchNotificationsEvent());
          break;
      }
    }
  }

  void _loadInitialData() {
    if (context.read<AnimalBloc>().state is! AnimalsLoaded) {
      context.read<AnimalBloc>().add(FetchAnimalsEvent());
    }

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
          _setupTabsForUser(_currentUser);

          return Scaffold(
            appBar: AppBar(
              title: Text(_titles[_currentIndex]),
              actions: [
                // Smart matching preferences (solo para adoptantes)
                if (_currentUser.role == 'adopter')
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      Navigator.pushNamed(context, '/preferences-form');
                    },
                    tooltip: 'Configurar Preferencias',
                  ),

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
              children: _tabs,
            ),
            bottomNavigationBar: _buildBottomNavigationBar(),
            floatingActionButton: _buildFloatingActionButton(),
          );
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    if (_currentUser.role == 'adopter') {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology),
            label: 'Para Ti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Explorar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'NGOs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      );
    } else {
      return BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Mascotas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'NGOs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Eventos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      );
    }
  }

  Widget? _buildFloatingActionButton() {
    // Para adoptantes en tab de recomendaciones
    if (_currentUser.role == 'adopter' && _currentIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/preferences-form');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.tune),
        tooltip: 'Ajustar Preferencias',
      );
    }
    // Para owners/NGOs en tab de mascotas
    else if ((_currentUser.role == 'adopter' && _currentIndex == 1) ||
        (_currentUser.role != 'adopter' && _currentIndex == 0)) {
      if (_currentUser.role == 'owner' || _currentUser.role == 'ong') {
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/animal-form');
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
          tooltip: 'Agregar Mascota',
        );
      }
    }
    // Para NGOs en tab de eventos
    else if (_currentIndex == (_currentUser.role == 'adopter' ? 3 : 2) && _currentUser.role == 'ong') {
      return FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/event-form');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
        tooltip: 'Crear Evento',
      );
    }

    return null;
  }
}