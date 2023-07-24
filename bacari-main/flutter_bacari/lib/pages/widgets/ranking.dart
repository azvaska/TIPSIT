import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bacari/pages/api_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../main.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({Key? key}) : super(key: key);

  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<RankingEntity> userRankings = [];
  List<RankingEntity> barRankings = [];
  late List<List<RankingEntity>> rankings;
  int rankingToShow = 0;
  int _selectedIndex = 0;
  String actualUserName = "";
  int userRankingPosition = 0;
  late ApiProvider apiProvider;

  @override
  void initState() {
    super.initState();
    apiProvider = Provider.of<ApiProvider>(context, listen: false);
  }

  final List<Icon> leadboardIcons = [
    const Icon(Icons.people),
    const Icon(Icons.local_bar), //sports bar or wine bar(vino)
  ];

  Future<List<List<RankingEntity>>> _getLeaderboard() async {

    //Profilo utente
    var response = await apiProvider.makeBackendCall('profile', null);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      actualUserName = data['username'];
    }

    //Classifica utenti

    var userResponse =
        await apiProvider.makeBackendCall('get_leaderboard_people', null);

    if (userResponse.statusCode == 200) {
      List<dynamic> userJsonRanking =
          jsonDecode(userResponse.body) as List<dynamic>;

      userRankings.clear(); // svuota la lista
      for (var rank in userJsonRanking) {
        //aggiungere posizione utente
        if (actualUserName == rank['username']) {
          userRankingPosition = (userRankings.length) + 1;
        }

        userRankings.add(RankingEntity(
            nome: rank['username'],
            punteggio: int.parse((rank['score'].toString()) != "null"
                ? rank['score'].toString()
                : '0')));
      }
    } else {
      throw Exception('Failed to load leadedynamicrboard');
    }

    //Classifica bacari
    var barResponse =
        await apiProvider.makeBackendCall('get_leaderboard_bacari', null);

    if (barResponse.statusCode == 200) {
      List<dynamic> barJsonRankings =
          jsonDecode(barResponse.body) as List<dynamic>;

      barRankings.clear(); // svuota la lista
      for (var rank in barJsonRankings) {
        barRankings.add(RankingEntity(
            nome: rank['name'],
            punteggio: int.parse((rank['score'].toString()) != "null"
                ? rank['score'].toString()
                : '0')));
      }
    } else {
      throw Exception('Failed to load leaderboard');
    }

    rankings = [
      userRankings as List<RankingEntity>,
      barRankings as List<RankingEntity>
    ];
    return rankings;
  }

  void formatScore() {
    print('ciao');
  }

  void _onLeadboardChanged(Icon? value) {
    setState(() {
      rankingToShow == 1 ? 0 : 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        centerTitle: true,
        actions: [
          DropdownButton<int>(
            value: _selectedIndex,
            onChanged: (index) {
              setState(() {
                _selectedIndex = index!;
                rankingToShow = _selectedIndex;
              });
            },
            dropdownColor: Colors.red,
            items: [
              DropdownMenuItem(
                value: 0,
                child: leadboardIcons[0],
              ),
              DropdownMenuItem(
                value: 1,
                child: leadboardIcons[1],
              )
            ],
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: FutureBuilder(
          future: _getLeaderboard(),
          builder:
              (context, AsyncSnapshot<List<List<RankingEntity>>> snapshot) {
            if (snapshot.hasData) {
              final classifica = snapshot.data!;
              return ListView.builder(
                itemCount: classifica[rankingToShow].length,
                itemBuilder: (context, index) {
                  final giocatore = classifica[rankingToShow][index];
                  return Card(
                    color:
                        index == userRankingPosition - 1 && rankingToShow == 0
                            ? Colors.yellow
                            : null,
                    child: ListTile(
                      leading: Text((index + 1).toString()),
                      title: Text(
                        giocatore.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Text(
                        giocatore.punteggio.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text("${snapshot.error}"));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class RankingEntity {
  final String nome;
  final int punteggio;

  RankingEntity({required this.nome, required this.punteggio});
}
