import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_model.dart';
import 'dart:typed_data';

class ViewRecordsPage extends StatefulWidget {
  @override
  _ViewRecordsPageState createState() => _ViewRecordsPageState();
}

const MaterialColor myPurple = MaterialColor(
  0xFF6C63FF, // Primary value (your exact color)
  <int, Color>{
    400: Color(0xFF6C63FF), // Your exact color
  },
);

class _ViewRecordsPageState extends State<ViewRecordsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<User> _users = [];
  bool _isLoading = true;
  bool _sortAscending = true;
  int _sortColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _dbHelper.getAllUsers();
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  void _sort<T>(Comparable<T> Function(User user) getField, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _users.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Records'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '${_users.length} Users Found',
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600]),
            ),
            SizedBox(height: 10),
            Expanded(
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(
                          label: Text('ID'),
                          onSort: (columnIndex, ascending) =>
                              _sort<num>((user) => user.id ?? 0, columnIndex, ascending),
                        ),
                        DataColumn(
                          label: Text('Username'),
                          onSort: (columnIndex, ascending) =>
                              _sort<String>((user) => user.username, columnIndex, ascending),
                        ),
                        DataColumn(
                          label: Text('Email'),
                          onSort: (columnIndex, ascending) =>
                              _sort<String>((user) => user.email, columnIndex, ascending),
                        ),
                        DataColumn(
                          label: Text('City'),
                          onSort: (columnIndex, ascending) =>
                              _sort<String>((user) => user.city, columnIndex, ascending),
                        ),
                        DataColumn(
                          label: Text('Actions'),
                        ),
                      ],
                      rows: _users.map((user) => DataRow(
                        cells: [
                          DataCell(Text(user.id.toString())),
                          DataCell(Text(user.username)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.city)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_red_eye, color: Color(0xFF6C63FF)),
                                onPressed: () => _showUserDetails(context, user),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(context, user),
                              ),
                            ],
                          )),
                        ],
                      )).toList(),
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      headingRowColor: MaterialStateColor.resolveWith(
                              (states) => Color(0xFF6C63FF).withOpacity(0.1)),
                      dataRowHeight: 60,
                      showBottomBorder: true,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteUser(BuildContext context, User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User?'),
        content: Text('Delete ${user.username} permanently?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    if (confirmed == true) {
      try {
        int deletedCount = await _dbHelper.deleteUser(user.id!);
        if (deletedCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _loadUsers(); // Refresh the list
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User not found'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showUserDetails(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        Center(
        child: CircleAvatar(
        radius: 50,
          backgroundImage: user.image != null
              ? MemoryImage(user.image! as Uint8List)
              : null,
          child: user.image == null
              ? Icon(Icons.person, size: 50)
              : null,
        ),
      ),
      SizedBox(height: 20),
      Center(
        child: Text(
          user.username,
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A44B7)),
        ),
      ),
    SizedBox(height: 5),
    Center(
    child: Text(
    user.email,
    style: TextStyle(color: Colors.grey[600]),
    ),
    ),
    SizedBox(height: 20),
    _buildDetailItem('User ID', user.id.toString()),
    _buildDetailItem('City', user.city),
    _buildDetailItem('Gender', user.gender),
    _buildDetailItem('Address', user.address),
    SizedBox(height: 20),
    SizedBox(
    width: double.infinity,
    child: ElevatedButton(
    onPressed: () => Navigator.pop(context),
    child: Text('Close'),
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
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600]),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          Divider(),
        ],
      ),
    );
  }
}