import 'dart:convert';
import 'package:deezerapim1sir/musique/music.dart';
import 'package:deezerapim1sir/service/music_provider_player.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<Music>> _musicFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _musicFuture = _fetchMusic("youssou ndour");
  }

  Future<List<Music>> _fetchMusic(String query) async {
    try {
      final response = await http.get(
        Uri.parse("https://api.deezer.com/search?q=$query"),
      );

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body);
        return (responseJson["data"] as List).map((music) {
          return Music(
            music["album"]["title"] ?? "Unknown Album",
            music["artist"]["picture"] ?? "",
            music["preview"] ?? "",
            music["title"] ?? "Unknown Title",
          );
        }).toList();
      } else {
        throw Exception("Failed to load music: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  void _searchMusic() {
    setState(() {
      _musicFuture = _fetchMusic(_searchController.text);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deezer Music'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: FutureBuilder<List<Music>>(
        future: _musicFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No music found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return _MusicTile(music: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search Music"),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Enter artist or song name",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: _searchMusic,
            child: const Text("Search"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _MusicTile extends StatelessWidget {
  final Music music;

  const _MusicTile({required this.music});

  @override
  Widget build(BuildContext context) {
    final player = Provider.of<MusicPlayerProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            music.artistPicture,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.music_note),
          ),
        ),
        title: Text(
          music.songTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          music.albumTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(
            player.currentMusic == music && player.isPlaying
                ? Icons.pause_circle_filled
                : Icons.play_circle_fill,
            size: 36,
            color: Colors.cyan,
          ),
          onPressed: () => player.togglePlayPause(music),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}