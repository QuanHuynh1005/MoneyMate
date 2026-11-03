
import 'package:flutter/material.dart';

void main() {
  runApp(const MoneyMateApp());
}

class MoneyMateApp extends StatelessWidget {
  const MoneyMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MoneyMate',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFFF9FB),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE99AB5),
        ),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const pink = Color(0xFFE99AB5);
  static const dark = Color(0xFF393139);
  static const grey = Color(0xFF999099);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Good morning,',
                        style: TextStyle(color: grey, fontSize: 14),
                      ),
                      const Text(
                        'Quân 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF9E3EC),
                    child: Icon(Icons.person, color: pink),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Balance card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: pink,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '12,500,000 đ',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _balanceItem(
                            Icons.arrow_downward,
                            'Income',
                            '15,000,000 đ',
                          ),
                        ),
                        Expanded(
                          child: _balanceItem(
                            Icons.arrow_upward,
                            'Expense',
                            '2,500,000 đ',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Monthly expense
              const Text(
                'Monthly Overview',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: dark,
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total expenses this month',
                      style: TextStyle(color: grey),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '2,500,000 đ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: dark,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.5,
                        minHeight: 10,
                        backgroundColor: Color(0xFFFCEAF0),
                        color: pink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '50% of monthly budget used',
                      style: TextStyle(color: grey, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Recent transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(color: pink),
                    ),
                  ),
                ],
              ),

              _transactionItem(
                Icons.fastfood,
                'Food & Drinks',
                'Today, 09:30 AM',
                '-85,000 đ',
                const Color(0xFFFFE9DF),
              ),
              _transactionItem(
                Icons.directions_bus,
                'Transportation',
                'Today, 08:15 AM',
                '-25,000 đ',
                const Color(0xFFE7EDFF),
              ),
              _transactionItem(
                Icons.shopping_bag,
                'Shopping',
                'Yesterday, 04:20 PM',
                '-350,000 đ',
                const Color(0xFFF9E3EC),
              ),
            ],
          ),
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: pink,
        unselectedItemColor: grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Statistics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _balanceItem(IconData icon, String title, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _transactionItem(
    IconData icon,
    String title,
    String date,
    String amount,
    Color background,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: background,
            child: Icon(icon, color: pink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dark,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),
        ],
      ),
    );
  }
}
