part of 'feed_bloc.dart';

@freezed
class FeedState with _$FeedState {
  const factory FeedState({
    @Default(true) bool isLoading,
    @Default(false) bool isFetchingNext,
    @Default(false) bool allLoaded,
    @Default([]) List<GroupedFeed> feeds,
  }) = _FeedState;

  const FeedState._();
}
