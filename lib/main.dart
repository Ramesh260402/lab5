import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => FactoryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()), // AuthProvider added
      ],
      child: MaterialApp(
        title: 'Factory Dashboard',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(), // Initial route set to LoginPage
          '/factory': (context) => FactoryDashboardPage(),
          '/engineers': (context) => EngineerListPage(),
          '/notifications': (context) => NotificationSettingsPage(),
          '/activate': (context) => AccountActivationPage(),
          '/otp': (context) => OTPInputPage(),
          '/improvements': (context) => ImprovementsPage(),
          '/mobile_activate': (context) => MobileActivationPage(),
        },
      ),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login(String phoneNumber, String otp) {
    // Implement your login logic here
    // For now, we will just simulate a successful login
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow[100], // Light yellow color
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: EdgeInsets.all(16.0),
              child: Image.network(
                'https://seeklogo.com/images/U/upm-new-logo-6911DC0B99-seeklogo.com.png',
                height: 100, // Adjust height as needed
                width: 100, // Adjust width as needed
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Request for OTP logic here
                // For now, let's simulate the request by enabling the OTP field
                otpController.clear(); // Clear previous OTP input
                // Enable OTP field for input
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Enter OTP'),
                      content: TextField(
                        controller: otpController,
                        decoration: InputDecoration(labelText: 'OTP'),
                        keyboardType: TextInputType.number,
                      ),
                      actions: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                            // You can add OTP validation logic here
                          },
                          child: Text('Submit'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Request OTP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Login logic here after OTP validation
                Provider.of<AuthProvider>(context, listen: false)
                    .login(phoneController.text, otpController.text);
                if (Provider.of<AuthProvider>(context, listen: false)
                    .isLoggedIn) {
                  Navigator.pushReplacementNamed(context, '/factory');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class FactoryProvider extends ChangeNotifier {
  int _selectedFactory = 2;
  Map<int, List<String>> _factorySensors = {
    1: ['Temperature', 'Pressure', 'Humidity', 'Vibration'],
    2: ['Speed', 'Torque', 'Power', 'Voltage'],
    3: ['Flow', 'Level', 'Density', 'Viscosity'],
    4: ['Current', 'Frequency', 'Resistance', 'Inductance'],
    5: ['pH', 'Conductivity', 'Salinity', 'Turbidity']
  };

  int get selectedFactory => _selectedFactory;
  List<String> get sensors => _factorySensors[_selectedFactory] ?? [];

  void selectFactory(int factory) {
    _selectedFactory = factory;
    notifyListeners();
  }
}

class FactoryDashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<FactoryProvider>(
          builder: (context, factoryProvider, child) {
            return Text('Factory ${factoryProvider.selectedFactory}');
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SensorReadings(),
            ),
          ),
          FactoryButtons(),
          SizedBox(height: 20),
          Text('1549.7 kW'),
          SizedBox(height: 20),
          Text('Timestamp: ${DateTime.now()}'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Engineers',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
            backgroundColor: Colors.blue,
          ),
        ],
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/engineers');
              break;
            case 1:
              Navigator.pushNamed(context, '/factory');
              break;
            case 2:
              Navigator.pushNamed(context, '/notifications');
              break;
          }
        },
      ),
    );
  }
}

class SensorReadings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<String> sensors = context.watch<FactoryProvider>().sensors;
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 3 / 2,
      children: List.generate(sensors.length, (index) {
        return Card(
          child: Center(
            child: Text(sensors[index]),
          ),
        );
      }),
    );
  }
}

class FactoryButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: List.generate(5, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                context.read<FactoryProvider>().selectFactory(index + 1);
              },
              child: Text('Factory ${index + 1}'),
            ),
          );
        }),
      ),
    );
  }
}

class EngineerListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Engineer List'),
      ),
      body: ListView(
        children: List.generate(10, (index) {
          return ListTile(
            title: Text('Engineer ${index + 1}'),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InvitationPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class InvitationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invite Engineer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Engineer Email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationSettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notification Settings'),
      ),
      body: Center(
        child: Text('Notification Settings Page'),
      ),
    );
  }
}

class AccountActivationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Activation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter your activation code'),
            TextField(
              decoration: InputDecoration(labelText: 'Activation Code'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/otp');
              },
              child: Text('Activate'),
            ),
          ],
        ),
      ),
    );
  }
}

class OTPInputPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OTP Input'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Enter the OTP sent to your email'),
            TextField(
              decoration: InputDecoration(labelText: 'OTP'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, ModalRoute.withName('/factory'));
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class ImprovementsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Improvements'),
      ),
      body: Center(
        child: Text('Improvements Page'),
      ),
    );
  }
}

class MobileActivationPage extends StatelessWidget {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mobile Activation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'OTP'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<AuthProvider>(context, listen: false)
                    .login(phoneController.text, otpController.text);
                if (Provider.of<AuthProvider>(context, listen: false)
                    .isLoggedIn) {
                  Navigator.pushReplacementNamed(context, '/factory');
                }
              },
              child: Text('Activate'),
            ),
          ],
        ),
      ),
    );
  }
}
