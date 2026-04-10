import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/profile_model.dart';
import '../profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _nombreCtrl   = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _matricCtrl   = TextEditingController();
  final _fraseCtrl    = TextEditingController();

  File?  _fotoFile;
  bool   _editMode = false;
  bool   _saving   = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<ProfileProvider>().loadProfile();
      _populateFields();
    });
  }

  void _populateFields() {
    final p = context.read<ProfileProvider>().profile;
    if (p != null) {
      _nombreCtrl.text   = p.nombre;
      _apellidoCtrl.text = p.apellido;
      _matricCtrl.text   = p.matricula;
      _fraseCtrl.text    = p.frase;
    } else {
      // Sin perfil → entrar directo en modo edición
      setState(() => _editMode = true);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _matricCtrl.dispose();
    _fraseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source:       ImageSource.gallery,
      imageQuality: 80,
      maxWidth:     512,
    );
    if (picked != null) setState(() => _fotoFile = File(picked.path));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final provider    = context.read<ProfileProvider>();
    final existingFoto = provider.profile?.fotoPath;

    final profile = ProfileModel(
      nombre:    _nombreCtrl.text.trim(),
      apellido:  _apellidoCtrl.text.trim(),
      matricula: _matricCtrl.text.trim(),
      fotoPath:  _fotoFile?.path ?? existingFoto,
      frase:     _fraseCtrl.text.trim(),
    );

    final ok = await provider.saveProfile(profile);
    if (!mounted) return;
    setState(() {
      _saving  = false;
      _editMode = !ok;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? '✓ Perfil guardado' : 'Error al guardar'),
      backgroundColor: ok ? AppTheme.auroraGreen : AppTheme.meteorRed,
    ));
  }

  // ── Vista de perfil (modo lectura) ─────────────────────────
  Widget _profileView(ProfileModel p) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Avatar
            GestureDetector(
              onTap: _editMode ? _pickPhoto : null,
              child: CircleAvatar(
                radius: 64,
                backgroundColor: AppTheme.nebulaPurple,
                backgroundImage: _fotoFile != null
                    ? FileImage(_fotoFile!)
                    : p.fotoPath != null
                        ? FileImage(File(p.fotoPath!))
                        : null,
                child: (_fotoFile == null && p.fotoPath == null)
                    ? const Icon(Icons.person,
                        size: 64, color: AppTheme.moonWhite)
                    : null,
              ),
            ),
            const SizedBox(height: 24),

            // Nombre
            Text(
              '${p.nombre} ${p.apellido}',
              style: const TextStyle(
                color:      AppTheme.moonWhite,
                fontSize:   24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Matrícula
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color:        AppTheme.nebulaPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppTheme.nebulaPurple.withOpacity(0.5)),
              ),
              child: Text(
                p.matricula,
                style: const TextStyle(
                  color:       AppTheme.starGold,
                  fontSize:    14,
                  fontWeight:  FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Frase motivadora
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:        AppTheme.deepBlue,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.starGold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.format_quote,
                      color: AppTheme.starGold, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    p.frase,
                    style: const TextStyle(
                      color:      AppTheme.moonWhite,
                      fontSize:   15,
                      fontStyle:  FontStyle.italic,
                      height:     1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App info
            const Divider(color: AppTheme.nebulaPurple),
            const SizedBox(height: 16),
            const Text('CieloObs',
                style: TextStyle(
                    color:      AppTheme.starGold,
                    fontSize:   18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text(
              'App de observaciones del cielo\nRepública Dominicana 🇩🇴',
              style:     TextStyle(color: AppTheme.cosmicGrey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Formulario de edición ──────────────────────────────────
  Widget _editForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [

          // Avatar con tap para cambiar
          Center(
            child: GestureDetector(
              onTap: _pickPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 56,
                    backgroundColor: AppTheme.nebulaPurple,
                    backgroundImage: _fotoFile != null
                        ? FileImage(_fotoFile!)
                        : context.watch<ProfileProvider>().profile?.fotoPath != null
                            ? FileImage(File(
                                context.read<ProfileProvider>().profile!.fotoPath!))
                            : null,
                    child: (_fotoFile == null &&
                            context.read<ProfileProvider>().profile?.fotoPath == null)
                        ? const Icon(Icons.person,
                            size: 56, color: AppTheme.moonWhite)
                        : null,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTheme.starGold,
                      child: const Icon(Icons.camera_alt,
                          size: 16, color: AppTheme.darkSpace),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _nombreCtrl,
            style:      const TextStyle(color: AppTheme.moonWhite),
            decoration: const InputDecoration(
              labelText:  'Nombre *',
              prefixIcon: Icon(Icons.person_outline,
                  color: AppTheme.cosmicGrey),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _apellidoCtrl,
            style:      const TextStyle(color: AppTheme.moonWhite),
            decoration: const InputDecoration(
              labelText:  'Apellido *',
              prefixIcon: Icon(Icons.person_outline,
                  color: AppTheme.cosmicGrey),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _matricCtrl,
            style:      const TextStyle(color: AppTheme.moonWhite),
            decoration: const InputDecoration(
              labelText:  'Matrícula *',
              prefixIcon: Icon(Icons.badge_outlined,
                  color: AppTheme.cosmicGrey),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _fraseCtrl,
            maxLines:   3,
            style:      const TextStyle(color: AppTheme.moonWhite),
            decoration: const InputDecoration(
              labelText:          'Frase motivadora *',
              alignLabelWithHint: true,
              prefixIcon:         Icon(Icons.format_quote,
                  color: AppTheme.cosmicGrey),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
          ),
          const SizedBox(height: 28),

          ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon:      _saving
                ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Guardando...' : 'Guardar perfil'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        actions: [
          if (!_editMode && provider.hasProfile)
            IconButton(
              icon:    const Icon(Icons.edit_outlined),
              tooltip: 'Editar perfil',
              onPressed: () => setState(() => _editMode = true),
            ),
          if (_editMode && provider.hasProfile)
            IconButton(
              icon:    const Icon(Icons.close),
              tooltip: 'Cancelar',
              onPressed: () {
                _populateFields();
                setState(() {
                  _editMode = false;
                  _fotoFile = null;
                });
              },
            ),
        ],
      ),
      body: provider.loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.starGold))
          : _editMode
              ? _editForm()
              : provider.hasProfile
                  ? SingleChildScrollView(child: _profileView(provider.profile!))
                  : _editForm(),
    );
  }
}