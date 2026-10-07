import 'package:flutter_test/flutter_test.dart';
import 'package:watch_app/core/ui/team_section.dart';

void main() {
  test('the lead developer is SuikaRYP', () {
    expect(kCoreTeam.map((m) => m.name), ['SuikaRYP']);
    expect(kCoreTeam.single.link, 'https://github.com/SuikaRyp');
  });

  test('the contributor team is the three hand-listed members', () {
    expect(kFixedCommunity.map((m) => m.name), [
      'yogzoffc',
      'ObyMoods',
      'mangyaanzofficial',
    ]);
  });

  test('TeamMember.avatar falls back to the GitHub avatar, then empty', () {
    const gh = TeamMember(name: 'x', role: 'r', link: 'l', github: 'octocat');
    expect(gh.avatar, 'https://github.com/octocat.png?size=200');
    const manual = TeamMember(name: 'm', role: 'r', link: 'l');
    expect(manual.avatar, '');
  });
}
