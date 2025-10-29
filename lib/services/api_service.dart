import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api';
    } else {
      return 'http://localhost:3000/api';
    }
  }

  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Lấy danh sách users
 static Future<Map<String, dynamic>> getUsers({
  int page = 1,
  int limit = 5,
  String sortBy = 'username',
  String sortOrder = 'asc',
  String? search,
}) async {
  try {
    final params = {
      'page': page.toString(),
      'limit': limit.toString(),
      'sortBy': sortBy,
      'sortOrder': sortOrder,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final uri = Uri.parse('$baseUrl/users').replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'success': data['success'] ?? false,
        'users': data['users'] ?? [],
        'total': data['total'] ?? 0,
      };
    }
    return {'success': false, 'users': [], 'total': 0};
  } catch (e) {
    print('Error getting users: $e');
    return {'success': false, 'users': [], 'total': 0};
  }
}

  // Lấy thông tin user theo ID
  static Future<User?> getUserById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users/$id'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          return User.fromJson(data['user']);
        }
      }
      // Handle 404 or other errors
      return null;
    } catch (e) {
      print('Error getting user by ID: $e');
      return null;
    }
  }

  // Thêm user mới
  static Future<Map<String, dynamic>> addUser({
    required String username,
    required String email,
    required String password,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      if (imageBytes != null && imageName != null) {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/users'),
        );
        request.fields['username'] = username;
        request.fields['email'] = email;
        request.fields['password'] = password;
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
          ),
        );
        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        final response = await http.post(
          Uri.parse('$baseUrl/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
          }),
        );
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Cập nhật user
  static Future<Map<String, dynamic>> updateUser({
    required String id,
    required String username,
    required String email,
    required String password,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      // If there is an image, send as multipart/form-data
      if (imageBytes != null && imageName != null) {
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('$baseUrl/users/$id'),
        );
        request.fields['username'] = username;
        request.fields['email'] = email;
        request.fields['password'] = password;
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: imageName,
          ),
        );

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        return jsonDecode(responseBody);
      } else {
        // If no image, send as application/json
        final response = await http.put(
          Uri.parse('$baseUrl/users/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': username,
            'email': email,
            'password': password,
          }),
        );
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Xóa user
  static Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/users/$id'));
      final data = jsonDecode(response.body);
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Tìm kiếm users
  static Future<List<User>> searchUsers(String keyword) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/search/$keyword'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          List<User> users = (data['users'] as List)
              .map((json) => User.fromJson(json))
              .toList();
          return users;
        }
      }
      return [];
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Lấy URL đầy đủ của ảnh
  static String getImageUrl(String imagePath) {
    if (imagePath.isEmpty) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return baseUrl.replaceAll('/api', '') + imagePath;
  }
}
