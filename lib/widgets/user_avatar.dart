import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config.dart';
import 'dart:io';

// Widget responsável por exibir o avatar do usuário
class UserAvatar extends StatelessWidget {
  final double radius; // Tamanho do avatar
  final VoidCallback? onTap; // Callback ao clicar no avatar

  const UserAvatar({Key? key, this.radius = 20, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    String? fotoPerfilUrl = user?.fotoPerfil;

    Widget avatar;
    // Se o usuário tem foto de perfil
    if (fotoPerfilUrl != null && fotoPerfilUrl.isNotEmpty) {
      String? cacheBuster;
      final userUpdatedAt = user?.updatedAt;
      if (userUpdatedAt != null) {
        cacheBuster = userUpdatedAt.millisecondsSinceEpoch.toString();
      } else {
        cacheBuster = DateTime.now().millisecondsSinceEpoch.toString();
      }
      if (fotoPerfilUrl.startsWith('http')) {
        // Foto de perfil é uma URL completa
        final url = fotoPerfilUrl.contains('?')
            ? '${fotoPerfilUrl}&t=$cacheBuster'
            : '${fotoPerfilUrl}?t=$cacheBuster';
        avatar = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: NetworkImage(url),
        );
      } else if (File(fotoPerfilUrl).existsSync()) {
        // Foto de perfil é um arquivo local
        avatar = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: FileImage(File(fotoPerfilUrl)),
        );
      } else {
        // Tenta montar URL do backend para foto
        String url = fotoPerfilUrl;
        if (!fotoPerfilUrl.startsWith('/')) {
          url = '/$fotoPerfilUrl';
        }
        String base = baseUrl;
        if (base.endsWith('/api')) {
          base = base.substring(0, base.length - 4);
        }
        String fullUrl = '$base$url';
        fullUrl = fullUrl.contains('?')
            ? '$fullUrl&t=$cacheBuster'
            : '$fullUrl?t=$cacheBuster';
        avatar = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: NetworkImage(fullUrl),
        );
      }
    } else {
      // Se não tem foto, mostra ícone padrão
      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
        child: Icon(Icons.person, color: Colors.grey.shade600, size: radius),
      );
    }

    // Permite ação ao clicar no avatar
    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }
    return avatar;
  }
} 