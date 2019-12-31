import 'dart:convert';
import 'dart:io';

import 'package:blue_alliance_client/blue_alliance_client.dart';
import 'package:blue_alliance_client/io.dart';

const apiBase = 'https://www.thebluealliance.com/api/v3';

const teams = ['frc624', 'frc1477', 'frc5892'];

void main() async {
  var client = TbaClient(await File('key.txt').readAsString(),
      cache: TbaCacheCompressor(FileSystemCache('cache')));

  for (var team in teams) {
    var stats = ClimbStats();
    var matches =
        (jsonDecode((await client.get('$apiBase/team/$team/matches/2019')).body)
                as List)
            .whereType<Map<String, dynamic>>();

    for (var match in matches.where((m) => m['score_breakdown'] != null)) {
      switch (() {
        var alliances = match['alliances'];
        var blue = alliances['blue']['team_keys'];
        var red = alliances['red']['team_keys'];

        var breakdown = match['score_breakdown'];
        var blueBreakdown = breakdown['blue'];
        var redBreakdown = breakdown['red'];

        if (blue[0] == team) {
          return blueBreakdown['endgameRobot1'];
        } else if (blue[1] == team) {
          return blueBreakdown['endgameRobot2'];
        } else if (blue[2] == team) {
          return blueBreakdown['endgameRobot3'];
        } else if (red[0] == team) {
          return redBreakdown['endgameRobot1'];
        } else if (red[1] == team) {
          return redBreakdown['endgameRobot2'];
        } else if (red[2] == team) {
          return redBreakdown['endgameRobot3'];
        } else {
          throw 'a team\'s match did not involve it: ${match['key']} for $team';
        }
      }()) {
        case 'HabLevel1':
          stats.hab1++;
          break;
        case 'HabLevel2':
          stats.hab2++;
          break;
        case 'HabLevel3':
          stats.hab3++;
          break;
        default:
          stats.noClimb++;
      }
    }

    print('$team: $stats');
  }

  client.close();
}

class ClimbStats {
  int noClimb = 0;
  int hab1 = 0;
  int hab2 = 0;
  int hab3 = 0;

  @override
  String toString() =>
      'noClimb = $noClimb, hab1 = $hab1, hab2 = $hab2, hab3 = $hab3';
}
