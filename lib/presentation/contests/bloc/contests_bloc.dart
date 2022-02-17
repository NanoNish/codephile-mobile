import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/constants/strings.dart';
import '../../../data/services/local/storage_service.dart';
import '../../../domain/models/contest.dart';
import '../../../domain/models/contest_filter.dart';
import '../../../domain/repositories/cp_repository.dart';

part 'contests_event.dart';
part 'contests_state.dart';
part 'contests_bloc.freezed.dart';

class ContestsBloc extends Bloc<ContestsEvent, ContestsState> {
  ContestsBloc() : super(const ContestsState()) {
    on<FetchContests>(_fetchContests);
    on<UpdateFilter>(_updateFilter);
  }

  void _fetchContests(FetchContests event, Emitter<ContestsState> emit) async {
    final contest = await CPRepository.contestList();
    _ongoing = [...?contest?.ongoing];
    _upcoming = [...?contest?.upcoming];
    applyFilter();
    final contests = [..._filteredUpcoming, ..._filteredOngoing];
    emit(state.copyWith(contests: contests, isLoading: false));
  }

  void _updateFilter(UpdateFilter event, Emitter<ContestsState> emit) {}

  void applyFilter() {
    _filteredOngoing = [];
    _filteredUpcoming = [];
    if (_filter!.ongoing ?? false) {
      _filteredOngoing.addAll(
        _ongoing.where(
          (element) => _filter!.check(
            ongoing: element,
          ),
        ),
      );
    }

    if (_filter!.upcoming ?? false) {
      _filteredUpcoming.addAll(
        _upcoming.where(
          (element) => _filter!.check(
            upcoming: element,
          ),
        ),
      );
    }
  }

  ContestFilter? _filter;
  List<Ongoing> _ongoing = [], _filteredOngoing = [];
  List<Upcoming> _upcoming = [], _filteredUpcoming = [];

  void init() {
    final exists = StorageService.exists(AppStrings.filterKey);
    if (!exists) {
      StorageService.filter = ContestFilter(
        duration: 4,
        platform: [true, true, true, true, false],
        startDate: DateTime.now(),
        ongoing: true,
        upcoming: true,
      );
    }

    _filter = StorageService.filter;
    add(const FetchContests());
  }
}

extension on ContestFilter {
  bool checkPlatform(String platformName) {
    switch (platformName.toLowerCase()) {
      case 'codechef':
        return platform?[0] ?? false;
      case 'codeforces':
        return platform?[1] ?? false;
      case 'hackerearth':
        return platform?[2] ?? false;
      case 'hackerrank':
        return platform?[3] ?? false;
      default:
        return platform?[4] ?? false;
    }
  }

  bool check({
    Upcoming? upcoming,
    Ongoing? ongoing,
  }) {
    assert(upcoming != null || ongoing != null, '');
    final platfromCheck = checkPlatform(
      upcoming != null ? upcoming.platform : ongoing!.platform,
    );

    if (!platfromCheck) return platfromCheck;

    Duration _maxDuration;
    switch (duration) {
      case 0:
        _maxDuration = const Duration(hours: 2);
        break;
      case 1:
        _maxDuration = const Duration(hours: 3);
        break;
      case 2:
        _maxDuration = const Duration(hours: 5);
        break;
      case 3:
        _maxDuration = const Duration(days: 1);
        break;
      case 4:
        _maxDuration = const Duration(days: 10);
        break;
      case 5:
        _maxDuration = const Duration(days: 31);
        break;
      default:
        _maxDuration = Duration(days: 1e5.toInt());
    }

    final durationCheck = upcoming != null
        ? upcoming.compareDuration(_maxDuration)
        : ongoing!.compareDuration(_maxDuration);

    if (!durationCheck) return durationCheck;

    bool? startCheck;
    if (upcoming != null) startCheck = upcoming.compareStart(startDate!);

    startCheck ??= true;
    if (!startCheck) return startCheck;

    return true;
  }
}

extension on Upcoming {
  bool compareDuration(Duration _duration) {
    return _duration.compareTo(endTime.difference(startTime)) >= 0;
  }

  bool compareStart(DateTime _startDate) {
    return startTime.isAfter(_startDate);
  }
}

extension on Ongoing {
  bool compareDuration(Duration _duration) {
    return _duration.compareTo(endTime.difference(DateTime.now())) >= 0;
  }
}
