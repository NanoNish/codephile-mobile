part of 'feed_bloc.dart';

@Freezed(makeCollectionsUnmodifiable: false)
class FeedState with _$FeedState {
  const factory FeedState({
    @Default(Status.loading()) Status status,
    @Default(false) bool isFetchingNext,
    @Default(false) bool allLoaded,
    @Default([]) List<GroupedFeed> feeds,
  }) = _FeedState;

  const FeedState._();
}
