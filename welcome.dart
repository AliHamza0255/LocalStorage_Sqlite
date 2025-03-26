import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'database_helper.dart';
import 'user_model.dart';

class WelcomePage extends StatefulWidget {
  final String username;

  WelcomePage({required this.username});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _dbHelper = DatabaseHelper();
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      var userData = await _dbHelper.getUserByUsername(widget.username);
      if (userData != null) {
        setState(() {
          _user = User.fromMap(userData);
          _isLoading = false;
        });
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(child: Text('Profile not available'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF4A44B7)],
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _user!.image != null
                          ? MemoryImage(_user!.image! as Uint8List)
                          : null,
                      child: _user!.image == null
                          ? Icon(Icons.person, size: 60, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60),
            Text(
              _user!.username,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A44B7)),
            ),
            SizedBox(height: 5),
            Text(
              _user!.email,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600]),
            ),
            SizedBox(height: 30),
            _buildProfileCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileItem(Icons.location_city, 'City', _user!.city),
            Divider(),
            _buildProfileItem(Icons.transgender, 'Gender', _user!.gender),
            Divider(),
            _buildProfileItem(Icons.home, 'Address', _user!.address),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Color(0xFF6C63FF), size: 24),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600]),
                ),
                SizedBox(height: 5),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}