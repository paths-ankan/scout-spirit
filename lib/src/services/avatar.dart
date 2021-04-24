import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:scout_spirit/src/models/avatar.dart';
import 'package:scout_spirit/src/models/rewards/reward.dart';
import 'package:scout_spirit/src/services/authentication.dart';
import 'package:scout_spirit/src/services/rest_api.dart';
import 'package:scout_spirit/src/services/rewards.dart';

class AvatarService extends RestApiService {
  static AvatarService _instance = AvatarService._internal();

  BehaviorSubject<Avatar> _authenticatedAvatar = new BehaviorSubject<Avatar>();

  Avatar get snapAuthenticatedAvatar => _authenticatedAvatar.value!;

  Stream<Avatar?> get authenticatedAvatar => _authenticatedAvatar.stream;

  AvatarService._internal();

  factory AvatarService() {
    return _instance;
  }

  Stream<List<AvatarPart>> getAvailableAvatarRewards() {
    Stream<List<Reward>> avatarRewards =
        RewardsService().getByCategory("avatar");
    return avatarRewards.transform<List<AvatarPart>>(
        StreamTransformer.fromHandlers(
            handleData: (data, sink) =>
                sink.add(data.map((e) => e as AvatarPart).toList())));
  }

  Stream<List<T>> getAvailableAvatarRewardsByType<T extends AvatarPart>() {
    return getAvailableAvatarRewards().transform<List<T>>(
        StreamTransformer.fromHandlers(handleData: (data, sink) {
      sink.add(data.whereType<T>().toList());
    }));
  }

  Future<void> updateAvailableAvatarRewards() async {
    await RewardsService().updateCategory("avatar");
  }

  Future<Avatar> getUserAvatar(String userId) async {
    Map<String, dynamic> avatar =
        await get('api/beneficiaries/$userId/avatar/');
    print(avatar);
    return Avatar.fromMap(avatar);
  }

  Future<Avatar> getAuthenticatedAvatar() async {
    Avatar avatar =
        await getUserAvatar(AuthenticationService().authenticatedUserId);
    _authenticatedAvatar.sink.add(avatar);
    return avatar;
  }

  Future<Avatar> updateAuthenticatedAvatar() async {
    String userId = AuthenticationService().authenticatedUserId;
    Map<String, dynamic> response =
        await put('api/beneficiaries/$userId/avatar/', _authenticatedAvatar.value!.toIdMap());
    Avatar newAvatar = Avatar.fromMap(response);
    _authenticatedAvatar.sink.add(newAvatar);
    return newAvatar;
  }

  Avatar changeAvatarClothes(AvatarPartEnum type, AvatarPart? part) {
    Avatar avatar = _authenticatedAvatar.value!;
    avatar = avatar.copyChanging(type, part);
    _authenticatedAvatar.sink.add(avatar);
    return avatar;
  }

  void dispose() {
    _authenticatedAvatar.close();
  }
}