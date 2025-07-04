import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_app/data/repositories/notification_preferences_repository.dart';
import 'package:mobile_app/data/services/notification_preferences_service.dart';
import 'package:mobile_app/presentation/bloc/notification-preferences/notification_preferences_bloc.dart';

import '../core/storage/secure_storage.dart';
import '../data/repositories/adoption_repository.dart';
import '../data/repositories/animal_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/donation_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/gamification_repository.dart';
import '../data/repositories/matching_repository.dart';
import '../data/repositories/ngo_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/post_adoption_repository.dart';
import '../data/services/adoption_service.dart';
import '../data/services/animal_service.dart';
import '../data/services/api_client.dart';
import '../data/services/auth_service.dart';
import '../data/services/donation_service.dart';
import '../data/services/event_service.dart';
import '../data/services/gamification_service.dart';
import '../data/services/matching_service.dart';
import '../data/services/ngo_service.dart';
import '../data/services/notification_service.dart';
import '../data/services/post_adoption_service.dart';
import '../presentation/bloc/adoption/adoption_bloc.dart';
import '../presentation/bloc/animal/animal_bloc.dart';
import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/donation/donation_bloc.dart';
import '../presentation/bloc/event/event_bloc.dart';
import '../presentation/bloc/gamification/gamification_bloc.dart';
import '../presentation/bloc/matching/matching_bloc.dart';
import '../presentation/bloc/ngo/ngo_bloc.dart';
import '../presentation/bloc/notification/notification_bloc.dart';
import '../presentation/bloc/post-adoption/post_adoption_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => SecureStorage(storage: sl()));
  sl.registerLazySingleton(() => ApiClient(
    httpClient: sl(),
    secureStorage: sl(),
    baseUrl: 'http://192.168.18.65:3000', // Replace with your API URL
  ));

  // Services
  sl.registerLazySingleton(() => AuthService(apiClient: sl()));
  sl.registerLazySingleton(() => AnimalService(apiClient: sl()));
  sl.registerLazySingleton(() => AdoptionService(apiClient: sl()));
  sl.registerLazySingleton(() => NGOService(apiClient: sl()));
  sl.registerLazySingleton(() => EventService(apiClient: sl()));
  sl.registerLazySingleton(() => DonationService(apiClient: sl()));
  sl.registerLazySingleton(() => NotificationService(apiClient: sl()));
  sl.registerLazySingleton(() => MatchingService(apiClient: sl()));
  sl.registerLazySingleton(() => GamificationService(apiClient: sl()));
  sl.registerLazySingleton(() => PostAdoptionService(apiClient: sl()));
  sl.registerLazySingleton(() => NotificationPreferencesService(apiClient: sl()));

  // Repositories
  sl.registerLazySingleton(() => AuthRepository(
    authService: sl(),
    secureStorage: sl(),
  ));
  sl.registerLazySingleton(() => AnimalRepository(animalService: sl()));
  sl.registerLazySingleton(() => AdoptionRepository(adoptionService: sl()));
  sl.registerLazySingleton(() => NGORepository(ngoService: sl()));
  sl.registerLazySingleton(() => EventRepository(eventService: sl()));
  sl.registerLazySingleton(() => DonationRepository(donationService: sl()));
  sl.registerLazySingleton(() => NotificationRepository(notificationService: sl()));
  sl.registerLazySingleton(() => MatchingRepository(matchingService: sl()));
  sl.registerLazySingleton(() => GamificationRepository(gamificationService: sl()));
  sl.registerLazySingleton(() => PostAdoptionRepository(postAdoptionService: sl()));
  sl.registerLazySingleton(() => NotificationPreferencesRepository(notificationPreferencesService: sl()));

  // BLoCs
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  sl.registerFactory(() => AnimalBloc(animalRepository: sl()));
  sl.registerFactory(() => AdoptionBloc(adoptionRepository: sl()));
  sl.registerFactory(() => NGOBloc(ngoRepository: sl()));
  sl.registerFactory(() => EventBloc(eventRepository: sl()));
  sl.registerFactory(() => DonationBloc(donationRepository: sl()));
  sl.registerFactory(() => NotificationBloc(notificationRepository: sl()));
  sl.registerFactory(() => MatchingBloc(matchingRepository: sl()));
  sl.registerFactory(() => GamificationBloc(gamificationRepository: sl()));
  sl.registerFactory(() => PostAdoptionBloc(postAdoptionRepository: sl()));
  sl.registerFactory(() => NotificationPreferencesBloc(notificationPreferencesRepository: sl()));
}