import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'dart:typed_data';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

const MaterialColor myPurple = MaterialColor(
  0xFF6C63FF, // Primary value (your exact color)
  <int, Color>{
    400: Color(0xFF6C63FF), // Your exact color
  },
);

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _dbHelper = DatabaseHelper();
  final _imagePicker = ImagePicker();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedCity = 'Lahore';
  String _selectedGender = 'Male';
  File? _imageFile;
  bool _isLoading = false;

  final List<String> _cities = ['Lahore', 'Sheikhupura', 'Faisalabad', 'Nankana sahib', 'Okara'];

  Future<void> _getImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        bool userExists = await _dbHelper.isUserExists(_usernameController.text);
        if (userExists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Username already exists!')),
          );
          setState(() => _isLoading = false);
          return;
        }

        Uint8List? imageBytes;
        if (_imageFile != null) {
          imageBytes = await _imageFile!.readAsBytes();
        }

        User newUser = User(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          city: _selectedCity ?? 'Lahore',
          gender: _selectedGender,
          address: _addressController.text,
          image: imageBytes,
        );

        int userId = await _dbHelper.saveUser(newUser.toMap());

        if (userId > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration successful!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Registration failed!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Join Us Today',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A44B7)),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _getImage,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : null,
                              child: _imageFile == null
                                  ? Icon(Icons.person, size: 50, color: Colors.grey[400])
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF6C63FF),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildTextFormField(
                        controller: _usernameController,
                        label: 'Username',
                        icon: Icons.person,
                        validator: (value) => value!.isEmpty ? 'Please enter username' : null,
                      ),
                      SizedBox(height: 15),
                      _buildTextFormField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => !value!.contains('@') ? 'Enter valid email' : null,
                      ),
                      SizedBox(height: 15),
                      _buildTextFormField(
                        controller: _passwordController,
                        label: 'Password',
                        icon: Icons.lock,
                        obscureText: true,
                        validator: (value) => value!.length < 6 ? 'Minimum 6 characters' : null,
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: InputDecoration(
                          labelText: 'City',
                          prefixIcon: Icon(Icons.location_city),
                          border: OutlineInputBorder(),
                        ),
                        items: _cities.map((city) => DropdownMenuItem(
                          value: city,
                          child: Text(city),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedCity = value),
                      ),
                      SizedBox(height: 15),
                      Text('Gender', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Male'),
                              value: 'Male',
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value!),
                              activeColor: Color(0xFF6C63FF),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text('Female'),
                              value: 'Female',
                              groupValue: _selectedGender,
                              onChanged: (value) => setState(() => _selectedGender = value!),
                              activeColor: Color(0xFF6C63FF),
                            ),
                          ),
                        ],
                      ),
                      _buildTextFormField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.home,
                        maxLines: 2,
                        validator: (value) => value!.isEmpty ? 'Please enter address' : null,
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _signup,
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text('SIGN UP', style: TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: myPurple[400],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
              child: RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: TextStyle(color: Colors.grey[600]),
                  children: [
                    TextSpan(
                      text: 'Login',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    int? maxLines,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: obscureText ? 1 : maxLines, // Ensure obscured fields are single-line
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(),
      ),
    );
  }
}