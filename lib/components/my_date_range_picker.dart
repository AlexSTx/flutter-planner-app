import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:planner_app/misc/misc_helper.dart';
import 'package:planner_app/model/date_range.dart';

class MyDateRangePicker extends StatefulWidget {
  const MyDateRangePicker({
    super.key,
    required this.dateRange,
  });

  final DateRange dateRange;

  @override
  State<MyDateRangePicker> createState() => _MyDateRangePickerState();
}

class _MyDateRangePickerState extends State<MyDateRangePicker> {
  final _textStartDateController = TextEditingController();
  final _textEndDateController = TextEditingController();
  final _textStartTimeController = TextEditingController();
  final _textEndTimeController = TextEditingController();

  @override
  void initState() {

    _textStartDateController.text = widget.dateRange.pStartDate;
    _textEndDateController.text = widget.dateRange.pEndDate;
    _textStartTimeController.text = widget.dateRange.startTime ?? '00:00';
    _textEndTimeController.text = widget.dateRange.endTime ?? '00:00';
    super.initState();
  }

  @override
  void dispose() {
    _textStartDateController.dispose();
    _textEndDateController.dispose();
    _textStartTimeController.dispose();
    _textEndTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: 165,
              child: TextFormField(
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                    labelText: 'Data Inicial',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month)),
                controller: _textStartDateController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(2999, 12, 31));

                  _textStartDateController.text =
                      DateFormat('yyyy/MM/dd').format(date ?? DateTime.now());

                  if (_textEndDateController.text.isEmpty) {
                    _textEndDateController.text = _textStartDateController.text;
                  }
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'O campo data inicial não pode estar vazio';
                  }
                  return null;
                },
                onSaved: (value) {
                  widget.dateRange.startDate = DateTime.parse(value!.replaceAll('/', '-'));
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextFormField(
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                    labelText: 'Início',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.watch_later_outlined)),
                controller: _textStartTimeController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  TimeOfDay? startTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: widget.dateRange.startDate?.hour ?? 0,
                            minute: widget.dateRange.startDate?.minute ?? 0),
                      ) ??
                      const TimeOfDay(hour: 0, minute: 0);

                  _textStartTimeController.text = MiscHelper.formatTime(tod: startTime)!;

                  widget.dateRange.startDate ??= DateTime.now();
                  widget.dateRange.startDate = widget.dateRange.startDate!
                      .copyWith(hour: startTime.hour, minute: startTime.minute);
                },
                onSaved: (value) {
                  var time = value!.split(':');
                  widget.dateRange.changeStartTime(int.parse(time[0]), int.parse(time[1]));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            SizedBox(
              width: 165,
              child: TextFormField(
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                    labelText: 'Data Final',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month)),
                controller: _textEndDateController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  DateTime? date = await showDatePicker(
                      context: context,
                      firstDate: DateTime(1900, 1, 1),
                      lastDate: DateTime(2999, 12, 31));

                  _textEndDateController.text =
                      DateFormat('yyyy/MM/dd').format(date ?? DateTime.now());
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'O campo data final não pode estar vazio';
                  }
                  if (DateTime.parse(value.replaceAll('/', '-')).millisecondsSinceEpoch <
                      DateTime.parse(_textStartDateController.text.replaceAll('/', '-'))
                          .millisecondsSinceEpoch) {
                    return 'Data final não pode ser menor que inicial';
                  }
                  return null;
                },
                onSaved: (value) {
                  widget.dateRange.endDate = DateTime.parse(value!.replaceAll('/', '-'));
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 120,
              child: TextFormField(
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                    labelText: 'Fim',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.watch_later)),
                controller: _textEndTimeController,
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  TimeOfDay? endTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                            hour: widget.dateRange.endDate?.hour ?? 0,
                            minute: widget.dateRange.endDate?.minute ?? 0),
                      ) ??
                      const TimeOfDay(hour: 0, minute: 0);

                  _textEndTimeController.text = MiscHelper.formatTime(tod: endTime)!;

                  widget.dateRange.endDate ??= DateTime.now();
                  widget.dateRange.endDate = widget.dateRange.endDate!
                      .copyWith(hour: endTime.hour, minute: endTime.minute);
                },
                validator: (value) {
                  var tf = _textEndTimeController.text.split(':');
                  var ti = _textStartTimeController.text.split(':');

                  var iMinutes = int.parse(ti[0]) * 60 + int.parse(ti[1]);
                  var fMinutes = int.parse(tf[0]) * 60 + int.parse(tf[1]);

                  if (_textStartDateController.text == _textEndDateController.text &&
                      fMinutes < iMinutes) {
                    return 'Hora final não pode ser menor que hora inicial';
                  }
                  return null;
                },
                onSaved: (value) {
                  var time = value!.split(':');
                  widget.dateRange.changeEndTime(int.parse(time[0]), int.parse(time[1]));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
