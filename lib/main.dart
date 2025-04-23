import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_app/presentation/bloc/adoption/adoption_bloc.dart';
import 'package:mobile_app/presentation/bloc/animal/animal_bloc.dart';
import 'package:mobile_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:mobile_app/presentation/bloc/auth/auth_event.dart';
import 'package:mobile_app/presentation/bloc/donation/donation_bloc.dart';
import 'package:mobile_app/presentation/bloc/event/event_bloc.dart';
import 'package:mobile_app/presentation/bloc/ngo/ngo_bloc.dart';
import 'package:mobile_app/presentation/bloc/notification/notification_bloc.dart';
import 'package:mobile_app/routes/app_router.dart';

import 'config/theme.dart';
import 'di/injection_container.dart' as di;

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    print('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    print('onClose -- ${bloc.runtimeType}');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print('onTransition -- ${bloc.runtimeType}: ${transition.currentState} -> ${transition.nextState}');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    print('onError -- ${bloc.runtimeType}: $error');
    super.onError(bloc, error, stackTrace);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = MyBlocObserver();

  await di.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent())),
        BlocProvider(create: (_) => di.sl<AnimalBloc>()),
        BlocProvider(create: (_) => di.sl<NGOBloc>()),
        BlocProvider(create: (_) => di.sl<EventBloc>()),
        BlocProvider(create: (_) => di.sl<NotificationBloc>()),
        BlocProvider(create: (_) => di.sl<DonationBloc>()),
        BlocProvider(create: (_) => di.sl<AdoptionBloc>()),
      ],
      child: MaterialApp(
        title: 'Pet Adoption App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        onGenerateRoute: _appRouter.onGenerateRoute,
      ),
    );
  }
}