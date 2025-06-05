import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/firebase_options.dart';
import 'package:shop_app/provider/globalProvider.dart';
import '../../../screens/home_page.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ChangeNotifierProvider(
      create: (context) => Global_provider(),
      child: EasyLocalization(
        child: MyApp(), 
        supportedLocales: [Locale('en', 'US'), Locale('mn', 'MN')], 
        fallbackLocale: Locale('en', 'US'),
        path: 'assets/translations'
      )
      ));
}
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => HomePage(),
      routes: [
        GoRoute(
          path: '/sign-in',
          builder: (context, state) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(), // <<== энэ мөр хэрэгтэй
              ],
              actions: [
                ForgotPasswordAction(((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: <String, String?>{
                      'email': email,
                    },
                  );
                  context.push(uri.toString());
                })),
                AuthStateChangeAction(((context, state) {
                  final user = switch (state) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null
                  };
                  if (user == null) {
                    return;
                  }
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  if (!user.emailVerified) {
                    user.sendEmailVerification();
                    const snackBar = SnackBar(
                        content: Text(
                            'Please check your email to verify your email address'));
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  }
                  context.pushReplacement('/');
                })),
              ],
            );
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
            );
          },
        ),
      ],
    ),
  ],
);
class MyApp extends StatelessWidget {
  const MyApp({super.key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // theme: ThemeData(
      //   useMaterial3: true,
      //   primarySwatch: Colors.grey,
      //   // textTheme: GoogleFonts.robotoTextTheme(
      //   //   Theme.of(context).textTheme,
      //   // ),
      //   visualDensity: VisualDensity.adaptivePlatformDensity,
      // ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaleFactor: 1),
        child: child!,
      ),
    );
  }
}
