import 'dart:io';
import 'package:bot_timer/services/notification_service.dart';
import 'package:bot_timer/utils/local_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final TextEditingController _timeController = TextEditingController();
  List<String> _selectedFiles = [];
  bool _fileUploaded = false;
  double? _volume;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int timer = LocalStorage().getTimer();
      _timeController.text = timer.toString();
      _loadExistingAudioFiles();
      await NotificationService().initialize();
      var volumeTemporario = await NotificationService().getVolume();
      setState(() {
        _volume = volumeTemporario;
      });
    });
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingAudioFiles() async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final soundsDir = Directory(path.join(appDocDir.path, 'audios_bot'));

      if (await soundsDir.exists()) {
        List<FileSystemEntity> files = soundsDir.listSync();
        List<String> audioFiles = [];

        for (var file in files) {
          if (file is File) {
            String fileName = path.basename(file.path);
            if (fileName.endsWith('.mp3') || fileName.endsWith('.wav')) {
              audioFiles.add(fileName);
            }
          }
        }

        if (audioFiles.isNotEmpty) {
          setState(() {
            _selectedFiles = audioFiles;
            _fileUploaded = true;
          });
        }
      }
    } catch (e) {
      print("Erro ao carregar arquivos existentes: $e");
    }
  }

  Future<void> _selectAudioFile(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final appDocDir = await getApplicationDocumentsDirectory();
        final soundsDir = Directory(path.join(appDocDir.path, 'audios_bot'));

        if (!await soundsDir.exists()) {
          await soundsDir.create(recursive: true);
        }

        List<String> savedFileNames = [];

        for (PlatformFile platformFile in result.files) {
          if (platformFile.path != null) {
            final file = File(platformFile.path!);
            final fileName = platformFile.name;

            await file.copy(path.join(soundsDir.path, fileName));
            savedFileNames.add(fileName);
          }
        }

        setState(() {
          _selectedFiles.addAll(savedFileNames);
          _fileUploaded = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${savedFileNames.length} arquivos de áudio salvos com sucesso!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar arquivos: $e')),
      );
    }
  }

  Future<void> _removeAudioFile(String fileName) async {
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final filePath = path.join(appDocDir.path, 'audios_bot', fileName);
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _selectedFiles.remove(fileName);
        if (_selectedFiles.isEmpty) {
          _fileUploaded = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arquivo removido: $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover arquivo: $e')),
      );
    }
  }

  setVolume(double volume) async {
    await NotificationService().setVolume(volume);
    setState(() {
      _volume = volume;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              decoration: InputDecoration(
                labelText: "Tempo do bot em minutos",
              ),
              keyboardType: TextInputType.number,
              controller: _timeController,
            ),
            // Slider(
            //   value: _volume ?? 0,
            //   min: 0.0,
            //   max: 1.0,
            //   divisions: 10,
            //   label: "${(_volume ?? 0 * 100).toStringAsFixed(0)}%",
            //   onChanged: (value) async {
            //     await setVolume(value);
            //   },
            // ),
            Text('Volume das notificações'),
            SizedBox(height: 15),
            Text(
              "Som de notificação",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () async => await _selectAudioFile(context),
              icon: Icon(Icons.upload_file),
              label: Text("Selecionar arquivos de áudio"),
            ),
            if (_selectedFiles.isNotEmpty)
              Container(
                height: 150,
                margin: EdgeInsets.only(top: 8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.audio_file,
                        size: 20,
                        color: Colors.green,
                      ),
                      title: Text(
                        _selectedFiles[index],
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, size: 16),
                        onPressed: () => _removeAudioFile(_selectedFiles[index]),
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar"),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final minutes = int.tryParse(_timeController.text);
                      await LocalStorage().setTimer(minutes!);
                      Navigator.pop(context, {});
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Os minutos dever ser numeros")),
                      );
                    }
                  },
                  child: Text("Salvar"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
