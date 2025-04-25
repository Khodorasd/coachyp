import 'package:coachyp/Pages/HomePage.dart';
import 'package:coachyp/Pages/firebase_notifications.dart';
import 'package:coachyp/features/auth/presentation/pages/User_sign_up.dart';
import 'package:coachyp/features/auth/presentation/pages/welcome.dart';
import 'package:coachyp/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:coachyp/features/posts/data/datasources/post_remote_data_source_impl.dart';
import 'package:coachyp/features/posts/data/repositories/post_repository_impl.dart';
import 'package:coachyp/features/posts/domain/repositories/post_repository.dart';
import 'package:coachyp/features/posts/domain/use_cases/create_post.dart';
import 'package:coachyp/features/posts/domain/use_cases/fetch_posts.dart';
import 'package:coachyp/features/auth/presentation/pages/login.dart';
import 'package:coachyp/features/posts/domain/use_cases/create_post.dart';
import 'package:coachyp/firebase/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp( 
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //await FirebaseNotifications().initNotifications();

  runApp(
    MultiProvider(
      providers: [
        Provider<PostRemoteDataSource>(
          create: (_) => PostRemoteDataSourceImpl(),
        ),
        ProxyProvider<PostRemoteDataSource, PostRepository>(
          update: (_, remote, __) => PostRepositoryImpl(remote),
        ),
        ProxyProvider<PostRepository, FetchPosts>(
          update: (_, repo, __) => FetchPosts(repo),
        ),
        ProxyProvider<PostRepository, CreatePost>(
          update: (_, repo, __) => CreatePost(repo),
        ),
      ],
      child: const COACHY(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class COACHY extends StatefulWidget {
  const COACHY({super.key});  

  @override
  State<COACHY> createState() => _COACHYState();
}

class _COACHYState extends State<COACHY> {
  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

    // navigatorKey: navigatorKey,
    
      debugShowCheckedModeBanner: false,
      home:  FutureBuilder(
        future: Future.delayed(const Duration(seconds: 2)), // Splash duration
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Welcome(); // Show splash screen
          }
          
          // Check auth state after splash
          final user = FirebaseAuth.instance.currentUser;
          if (user != null && user.emailVerified) {
            return HomePage();
          } else {
            return Login(); // Or Welcome() if you want different behavior
          }
        },
      ),
      routes: {
        "sign_up": (context) => const ClientSignUp(),
        "HomePage": (context) => const HomePage(),
        "Login": (context) => const Login(),
        

      },
      
    );
  }
}