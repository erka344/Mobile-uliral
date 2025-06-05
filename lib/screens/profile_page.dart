import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/global_keys.dart';
import 'package:shop_app/provider/globalProvider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  void changeLan() {
    final context = GlobalKeys.navigatorKey.currentContext!;
    if (context.locale == const Locale('en', 'US')) {
      context.setLocale(const Locale('mn', 'MN'));
    } else {
      context.setLocale(const Locale('en', 'US'));
    }
  }

  void signOut() {
    Provider.of<Global_provider>(context, listen: false).signOut();
    context.go('/sign-in');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<Global_provider>(
          builder: (context, provider, child) {
            final user = provider.currentUser;
            if (user == null) {
              return Center(
                child: Text('Please login to view profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                )
              );
              
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.grey.shade200,
                          child: Text(
                            user.displayName?[0].toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName ?? 'User',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'ID: ${user.uid}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.black54),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(onPressed: changeLan, child: Text("Change language")),
                      ElevatedButton(onPressed: signOut, child: Text("Sign out")),
                    ],
                  ),
                  
                  _profileSection('My orders'),
                  _divider(),
                  _profileSection('Shipping addresses'),
                  _divider(),
                  _profileSection('Payment methods'),
                  _divider(),
                  _profileSection('Promotion codes'),
                  _divider(),
                  _profileSection('My reviews'),
                  _divider(),
                  _profileSection('Settings'),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileSection(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.expand_more, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.grey.shade300,
      thickness: 1,
      height: 0,
    );
  }
}