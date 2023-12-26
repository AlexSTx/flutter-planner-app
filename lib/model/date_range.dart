import 'package:intl/intl.dart';
import 'package:planner_app/misc/misc_helper.dart';

class DateRange {
  DateTime? today, startDate, endDate;

  DateRange({this.today, this.startDate, this.endDate});

  void changeStartTime(int hour, int minute) {
    if (startDate == null) return;
    startDate = startDate!.copyWith(hour: hour, minute: minute);
  }

  void changeEndTime(int hour, int minute) {
    if (endDate == null) return;
    endDate = endDate!.copyWith(hour: hour, minute: minute);
  }

  get endTime => MiscHelper.formatTime(dt: endDate);

  get startTime => MiscHelper.formatTime(dt: startDate);

  get pStartDate => startDate == null ? '' : DateFormat('yyyy/MM/dd').format(startDate!);

  get pEndDate => startDate == null ? '' : DateFormat('yyyy/MM/dd').format(endDate!);

  get hStartDate => startDate == null ? '' : DateFormat('yyyy-MM-dd').format(startDate!);

  get hEndDate => startDate == null ? '' : DateFormat('yyyy-MM-dd').format(endDate!);
}
