import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:scout_spirit/src/models/reward_token.dart';
import 'package:scout_spirit/src/models/rewards/reward.dart';
import 'package:scout_spirit/src/services/rewards.dart';
import 'package:scout_spirit/src/themes/theme.dart';

class RewardClaimPage extends StatefulWidget {
  final RewardToken reward;

  RewardClaimPage({Key? key, required this.reward}) : super(key: key);

  @override
  _RewardClaimPageState createState() => _RewardClaimPageState();
}

class _RewardClaimPageState extends State<RewardClaimPage> {
  bool loading = false;
  final ConfettiController _confettiController =
      ConfettiController(duration: Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(children: [
          Center(
              child: Card(
                  child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 24.0, horizontal: 36.0),
                      child: Flex(
                        direction: Axis.vertical,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '¡Felicitaciones!',
                            style: appTheme.textTheme.headline1,
                          ),
                          SizedBox(
                            height: 16.0,
                          ),
                          Text('Elige una recompensa!'),
                          SizedBox(
                            height: 16.0,
                          ),
                          _buildBoxesList(),
                        ],
                      )))),
          Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2,
                emissionFrequency: 0.01,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 120,
                maxBlastForce: 20,
                minBlastForce: 15,
                gravity: 0.1,
              ))
        ]),
      ),
    );
  }

  Widget _buildBoxesList() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.reward.body.boxes
          .asMap()
          .keys
          .map((index) => ElevatedButton(
              child: Text('Recompensa #$index'),
              onPressed: loading ? null : () => claimReward(boxIndex: index)))
          .toList(),
    );
  }

  Future<void> claimReward({int? boxIndex}) async {
    setState(() {
      loading = true;
    });
    List<Reward> rewards;
    try {
      rewards =
          await RewardsService().claimReward(widget.reward, boxIndex: boxIndex);
    } catch (e) {
      setState(() {
        loading = false;
      });
      throw e;
    }
    NavigatorState nav = Navigator.of(context);
    await nav.pushNamed('/rewards/claim', arguments: rewards);
    nav.pop();
  }
}