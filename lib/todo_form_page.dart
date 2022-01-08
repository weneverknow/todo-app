import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_database_example/constant.dart';
import 'package:local_database_example/model/todo.dart';
import 'package:local_database_example/provider/todo_provider.dart';
import 'package:local_database_example/service/save_user_cache.dart';
import 'package:local_database_example/todo_page.dart';
import 'package:local_database_example/widget/text/title_text.dart';
import 'extension/time_of_day_extension.dart';
import 'extension/date_time_extension.dart';
import 'extension/string_extension.dart';

class TodoFormPage extends StatefulWidget {
  const TodoFormPage({this.todo, Key? key}) : super(key: key);
  final Todo? todo;

  @override
  _TodoFormPageState createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  bool isDone = false;
  TodoProvider todoProvider = TodoProvider();
  bool isLoading = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    todoProvider.initDatabase();
    initForm();
    super.initState();
  }

  initForm() {
    if (widget.todo != null) {
      titleController.text = widget.todo!.title!;
      descController.text = widget.todo!.description!;
      timeController.text = widget.todo!.time!;
      dateController.text = widget.todo!.date!;
      isDone = widget.todo!.done == 1;
      setState(() {});
    }
  }

  TitleText? _titleText;

  selectDate() async {
    final datePicker = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.parse('2021-01-01'),
        lastDate: DateTime.parse('2024-12-31'));
    if (datePicker != null && datePicker != _selectedDate) {
      setState(() {
        _selectedDate = datePicker;
        dateController.text = datePicker.formatSaving();
      });
      print(datePicker);
    }
  }

  selectTime() async {
    final timePicker =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (timePicker != null && timePicker != _selectedTime) {
      setState(() {
        _selectedTime = timePicker;
        timeController.text =
            timePicker.format(context).formatSaving(); //.formatSaving();
      });
    }
  }

  save() async {
    setState(() {
      isLoading = true;
    });
    final user = await SaveUserCache.getUser();
    final todo = widget.todo != null
        ? widget.todo!.copyWith(
            title: titleController.text,
            date: dateController.text,
            time: timeController.text,
            description: descController.text)
        : Todo(
            userId: user!,
            date: dateController.text,
            time: timeController.text,
            title: titleController.text,
            description: descController.text);
    final result = widget.todo != null
        ? await todoProvider.update(todo)
        : await todoProvider.insert(todo);

    setState(() {
      isLoading = false;
    });
    if (result != null) {
      Get.snackbar(widget.todo != null ? 'Update Task' : 'Create Task',
          '${widget.todo != null ? "Update" : "Create"} Task Successfully',
          backgroundColor: Color(0xffE55E3C), colorText: Colors.white);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.chevron_left_rounded,
              color: Colors.black,
              size: 30,
            ),
          ),
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          centerTitle: true,
          title: (_titleText = TitleText()
                ..text =
                    widget.todo != null ? 'UPDATE TASK' : 'CREATE NEW TASK')
              .child),
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date'),
                Row(
                  children: [
                    Flexible(
                      flex: 4,
                      fit: FlexFit.tight,
                      child: buildInput(
                          controller: dateController, readOnly: true),
                    ),
                    Flexible(
                        fit: FlexFit.tight,
                        child: IconButton(
                            onPressed: () => selectDate(),
                            icon: Icon(Icons.calendar_today_rounded)))
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Time'),
                Row(
                  children: [
                    Flexible(
                      flex: 4,
                      fit: FlexFit.tight,
                      child: buildInput(
                          controller: timeController, readOnly: true),
                    ),
                    Flexible(
                        fit: FlexFit.tight,
                        child: IconButton(
                            onPressed: () => selectTime(),
                            icon: Icon(Icons.timer_rounded)))
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Title'),
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: buildInput(controller: titleController),
                    )
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Description'),
                Row(
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: buildInput(
                          controller: descController,
                          height: 100,
                          inputtype: TextInputType.multiline),
                    )
                  ],
                )
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: isLoading
                ? CircularProgressIndicator(
                    color: progressColor,
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        primary: primaryColor,
                        padding: EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.3)),
                    onPressed: () => save(),
                    child: Text(
                        widget.todo != null ? 'UPDATE TASK' : 'CREATE TASK')),
          )
        ],
      ),
    );
  }

  Container buildInput(
      {double? height = 50,
      TextInputType? inputtype,
      bool readOnly = false,
      TextEditingController? controller}) {
    return Container(
      height: height,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 1),
            spreadRadius: -1,
            blurRadius: 6)
      ], color: Color(0xffF0F0F0), borderRadius: BorderRadius.circular(10)),
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: inputtype,
        maxLines: 4,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        decoration: InputDecoration(
            enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
      ),
    );
  }
}
