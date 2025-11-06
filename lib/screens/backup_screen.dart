import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String _backupStatus = '';
  final String _apiBaseUrl = 'http://localhost:3000/api';

  Future<void> _createBackup() async {
    setState(() {
      _isBackingUp = true;
      _backupStatus = 'جاري إنشاء النسخة الاحتياطية...';
    });

    try {
      // اختيار مجلد الحفظ
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

      if (selectedDirectory == null) {
        setState(() {
          _isBackingUp = false;
          _backupStatus = 'تم إلغاء العملية';
        });
        return;
      }

      // إنشاء اسم ملف بالتاريخ والوقت
      final timestamp =
          DateFormat('yyyy-MM-dd_HH-mm-ss').format(DateTime.now());
      final backupFileName = 'SalesDB_Backup_$timestamp.bak';
      final backupPath = '$selectedDirectory\\$backupFileName';

      // طلب النسخ الاحتياطي من API
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/backup/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'backupPath': backupPath}),
      );

      if (response.statusCode == 200) {
        json.decode(response.body); // تحقق من صحة الاستجابة
        setState(() {
          _backupStatus = '✅ تم إنشاء النسخة الاحتياطية بنجاح!\n📁 $backupPath';
          _isBackingUp = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء النسخة الاحتياطية بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // معالجة رسائل الخطأ من السيرفر
        String errorMsg = 'فشل إنشاء النسخة الاحتياطية';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['error'] ?? errorMsg;
          if (errorData['suggestion'] != null) {
            errorMsg += '\n\n💡 ${errorData['suggestion']}';
          }
        } catch (e) {
          // استخدام الرسالة الافتراضية
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _backupStatus = '❌ خطأ:\n$errorMessage';
        _isBackingUp = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> _restoreBackup() async {
    setState(() {
      _isRestoring = true;
      _backupStatus = 'جاري استعادة النسخة الاحتياطية...';
    });

    try {
      // اختيار ملف النسخة الاحتياطية
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bak'],
      );

      if (result == null) {
        setState(() {
          _isRestoring = false;
          _backupStatus = 'تم إلغاء العملية';
        });
        return;
      }

      final backupPath = result.files.single.path!;

      // تأكيد الاستعادة
      if (mounted) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('تأكيد الاستعادة'),
            content: const Text(
              'تحذير: سيتم استبدال جميع البيانات الحالية!\nهل أنت متأكد من المتابعة؟',
              style: TextStyle(color: Colors.red),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('نعم، استعادة'),
              ),
            ],
          ),
        );

        if (confirm != true) {
          setState(() {
            _isRestoring = false;
            _backupStatus = 'تم إلغاء الاستعادة';
          });
          return;
        }
      }

      // طلب الاستعادة من API
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/backup/restore'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'backupPath': backupPath}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _backupStatus = '✅ تم استعادة النسخة الاحتياطية بنجاح!';
          _isRestoring = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم استعادة النسخة الاحتياطية بنجاح'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // معالجة رسائل الخطأ من السيرفر
        String errorMsg = 'فشل استعادة النسخة الاحتياطية';
        try {
          final errorData = json.decode(response.body);
          errorMsg = errorData['error'] ?? errorMsg;
        } catch (e) {
          // استخدام الرسالة الافتراضية
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _backupStatus = '❌ خطأ:\n$errorMessage';
        _isRestoring = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النسخ الاحتياطي والاستعادة'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة النسخ الاحتياطي
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.backup, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    const Text(
                      'إنشاء نسخة احتياطية',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'احفظ نسخة من قاعدة البيانات الحالية',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isBackingUp ? null : _createBackup,
                      icon: _isBackingUp
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isBackingUp
                          ? 'جاري الإنشاء...'
                          : 'إنشاء نسخة احتياطية'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // بطاقة الاستعادة
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Icon(Icons.restore, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'استعادة نسخة احتياطية',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'استرجع البيانات من نسخة احتياطية سابقة',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isRestoring ? null : _restoreBackup,
                      icon: _isRestoring
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(_isRestoring
                          ? 'جاري الاستعادة...'
                          : 'استعادة من ملف'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // حالة العملية
            if (_backupStatus.isNotEmpty)
              Card(
                color: _backupStatus.contains('✅')
                    ? Colors.green.shade50
                    : _backupStatus.contains('❌')
                        ? Colors.red.shade50
                        : Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    _backupStatus,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
