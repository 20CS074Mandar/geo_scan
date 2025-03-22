import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:geo_scan/Models/checkpoint.dart';
import 'package:geo_scan/View/HomePage.dart';
import 'package:geo_scan/db/db_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SelectLocation extends StatefulWidget {
  const SelectLocation({super.key});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  DatabaseHelper dbHelper = DatabaseHelper();
  bool _loading = true;
  List<Checkpoint> _checkpoints = [];
  Checkpoint? _selectedCheckpoint;

  @override
  void initState() {
    super.initState();
    _loadCheckpoints();
  }

  Future<void> _loadCheckpoints() async {
    try {
      _checkpoints = await getCheckpointsFromDb();
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      // Show error dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Error"),
            content: Text("Failed to load checkpoints: $e"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> _saveSelectedCheckpoint(Checkpoint checkpoint) async {
    try {
      SharedPreferences preferences = await SharedPreferences.getInstance();
      await preferences.setInt("currentCheckpointId", checkpoint.id!);
      await preferences.setString(
          "currentCheckpointName", checkpoint.checkpoint_name);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save checkpoint: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Location'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Choose a Checkpoint Location',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: _checkpoints.isEmpty
                      ? const Center(child: Text('No checkpoints available'))
                      : ListView.builder(
                          itemCount: _checkpoints.length,
                          itemBuilder: (context, index) {
                            final checkpoint = _checkpoints[index];
                            final isSelected =
                                _selectedCheckpoint == checkpoint;

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                title: Text(
                                  checkpoint.checkpoint_name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Text(
                                  'Lat: ${checkpoint.latitude.toStringAsFixed(6)}, '
                                  'Lng: ${checkpoint.longitude.toStringAsFixed(6)}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Theme.of(context).primaryColor,
                                        size: 28,
                                      )
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedCheckpoint = checkpoint;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _selectedCheckpoint == null
                        ? null
                        : () => _saveSelectedCheckpoint(_selectedCheckpoint!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: const Text(
                      'Confirm Location',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<List<Checkpoint>> getCheckpointsFromDb() async {
    return await dbHelper.getCheckpoints();
  }
}
