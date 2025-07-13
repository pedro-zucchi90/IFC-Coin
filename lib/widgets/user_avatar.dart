import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config.dart';
import 'dart:io';

class UserAvatar extends StatelessWidget {
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({Key? key, this.radius = 20, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    String? fotoPerfilUrl = user?.fotoPerfil;

    print('fotoPerfil: $fotoPerfilUrl'); // DEBUG

    Widget avatar;
    if (fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty) {
      if (fotoPerfilUrl.startsWith('http')) {
        avatar = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: NetworkImage(fotoPerfilUrl),
        );
      } else if (File(fotoPerfilUrl).existsSync()) {
        avatar = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: FileImage(File(fotoPerfilUrl)),
        );
      } else {
        // Tenta montar URL do backend
        String url = fotoPerfilUrl;
        if (!fotoPerfilUrl.startsWith('/')) {
          url = '/$fotoPerfilUrl';
        }
        String base = baseUrl;
        if (base.endsWith('/api')) {
          base = base.substring(0, base.length - 4);
        }
        String fullUrl = '$base$url';
        avatar = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: NetworkImage(fullUrl),
        );
      }
    } else {
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: Icon(Icons.person, color: Colors.grey.shade600, size: radius),
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
} 