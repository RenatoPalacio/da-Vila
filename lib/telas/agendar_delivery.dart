import 'dart:ui';
import 'package:compradordodia/widgets/botaocustomizado.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:date_format/date_format.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Example holidays
final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};


class AgendarDelivery extends StatefulWidget {
  String _idPedido;
  AgendarDelivery(this._idPedido, {Key key}) : super(key: key);
  @override
  _AgendarDeliveryState createState() => _AgendarDeliveryState();

}

class _AgendarDeliveryState extends State<AgendarDelivery> with TickerProviderStateMixin {
  Map<DateTime, List> _events;
  List _selectedEvents;
  AnimationController _animationController;
  CalendarController _calendarController;
  String _idPedido;
  //String _diaSelecionado = formatDate(DateTime.now(), [dd, "/", mm, "/", yyyy]).toString();
  DateTime _diaSelecionado = DateTime.now();
  DateTime _dateTime = DateTime.now();
  var _dataDeliveryRecuperada = DateTime.now();
  var _horaDeliveryRecuperada = DateTime.now();
  Firestore db = Firestore.instance;
  bool _lendoDelivery = true;

  _agendarData(){
    showDialog(
        context: context,
        builder: (context){
          return StatefulBuilder(builder: (context, setState){
            return AlertDialog(
              title: Text("Selecione o horário"),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TimePickerSpinner(
                    time: _horaDeliveryRecuperada,
                    is24HourMode: false,
                    minutesInterval: 30,
                    normalTextStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.grey
                    ),
                    highlightedTextStyle: TextStyle(
                        fontSize: 24,
                        color: Colors.deepOrange
                    ),
                    spacing: 50,
                    itemHeight: 80,
                    isForce2Digits: true,
                    onTimeChange: (time) {
                      setState(() {
                        _dateTime = time;
                        _horaDeliveryRecuperada = _dateTime;
                      });
                    },),
                  Text(
                    "Entregador agendado para:",
                    style: TextStyle(
                        fontSize: 18
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(formatDate(_diaSelecionado, [dd, "/", mm, "/", yyyy]).toString()),
                        Text(_dateTime.hour.toString() + ":" + _dateTime.minute.toString().padLeft(2, '0'))
                      ],
                    ),
                  ),
                  Padding(
                    padding:  EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FlatButton(
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        FlatButton(
                          child: Text(
                            "Confirmar",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.deepOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _confirmarData();
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          });
      }
    );
  }

  _confirmarData(){
    db.collection("pedidos").document(_idPedido).updateData({
      "dataDeliveryAgendada" : _diaSelecionado,
      "horaDeliveryAgendada" : _dateTime
    });
    Navigator.pop(context);
  }

  _lerDataAgendada() async {
    DocumentSnapshot _dados = await db.collection("pedidos").document(_idPedido).get();
    if(_dados["dataDeliveryAgendada"] != null && _dados["horaDeliveryAgendada"] != null){
      _dataDeliveryRecuperada = _dados["dataDeliveryAgendada"].toDate();
      _horaDeliveryRecuperada = _dados["horaDeliveryAgendada"].toDate();
      _diaSelecionado = _dataDeliveryRecuperada;
      _dateTime = _horaDeliveryRecuperada;
      setState(() {
        _lendoDelivery = false;
        return _dataDeliveryRecuperada;
      });
    } else {
      setState(() {
        _lendoDelivery = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    final _selectedDay = DateTime.now();
    _idPedido = widget._idPedido;
    _lerDataAgendada();

    _events = {
      _selectedDay.subtract(Duration(days: 30)): ['Event A0', 'Event B0', 'Event C0'],
      _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
      _selectedDay.subtract(Duration(days: 20)): ['Event A2', 'Event B2', 'Event C2', 'Event D2'],
      _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
      _selectedDay.subtract(Duration(days: 10)): ['Event A4', 'Event B4', 'Event C4'],
      _selectedDay.subtract(Duration(days: 4)): ['Event A5', 'Event B5', 'Event C5'],
      _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
      _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
      _selectedDay.add(Duration(days: 1)): ['Event A8', 'Event B8', 'Event C8', 'Event D8'],
      _selectedDay.add(Duration(days: 3)): Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
      _selectedDay.add(Duration(days: 7)): ['Event A10', 'Event B10', 'Event C10'],
      _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
      _selectedDay.add(Duration(days: 17)): ['Event A12', 'Event B12', 'Event C12', 'Event D12'],
      _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
      _selectedDay.add(Duration(days: 26)): ['Event A14', 'Event B14', 'Event C14'],
    };

    _selectedEvents = _events[_selectedDay] ?? [];
    _calendarController = CalendarController();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _calendarController.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime day, List events, List holidays) {
    _diaSelecionado = day;
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(DateTime first, DateTime last, CalendarFormat format) {

  }

  void _onCalendarCreated(DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onCalendarCreated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Agendar delivery"),
      ),
      body: SafeArea(
          child: _lendoDelivery
              ? Row(mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(),)])
              : Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(16, 32, 0, 16),
                child: Text(
                  "Qual data você quer programar o entregador?",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              //_buildTableCalendar(),
              _buildTableCalendarWithBuilders(),
              const SizedBox(height: 8.0),
              _buildButtons(),
              const SizedBox(height: 8.0),
            ],
          ),
      )
    );
  }
  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.monday,
      calendarStyle: CalendarStyle(
        selectedColor: Colors.deepOrange[400],
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.brown[700],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        formatButtonTextStyle: TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Colors.deepOrange[400],
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: _onDaySelected,
      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
      locale: "pt_BR",
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    print(_dataDeliveryRecuperada);
    return TableCalendar(
      initialSelectedDay: _dataDeliveryRecuperada,
      locale: 'pt_BR',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: '',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        centerHeaderTitle: true,
        formatButtonVisible: false,
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return FadeTransition(
            opacity: Tween(begin: 0.0, end: 1.0).animate(_animationController),
            child: Container(
              margin: const EdgeInsets.all(4.0),
              padding: const EdgeInsets.only(top: 5.0, left: 6.0),
              color: Colors.deepOrange[300],
              width: 100,
              height: 100,
              child: Text(
                '${date.day}',
                style: TextStyle().copyWith(fontSize: 16.0),
              ),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.amber[400],
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          if (holidays.isNotEmpty) {
            children.add(
              Positioned(
                right: -2,
                top: -2,
                child: _buildHolidaysMarker(),
              ),
            );
          }

          return children;
        },
      ),

      onDaySelected: (date, events, holidays) {
        _onDaySelected(date, events, holidays);
        _animationController.forward(from: 0.0);
      },

      onVisibleDaysChanged: _onVisibleDaysChanged,
      onCalendarCreated: _onCalendarCreated,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date) ? Colors.brown[300] : Colors.blue[400],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    final dateTime = _events.keys.elementAt(_events.length - 2);
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(left: 8),
              child: FlatButton(
                child: Text(
                  "Mês",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _calendarController.setCalendarFormat(CalendarFormat.month);
                  });
                },
              ),
            ),
            Padding(
                padding: EdgeInsets.only(right: 16),
                child: FlatButton(
                  child: Text(
                    "Semana",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.deepOrange,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _calendarController.setCalendarFormat(CalendarFormat.week);
                    });
                  },
                ),
            )
          ],
        ),
        const SizedBox(height: 8.0),
        Padding(
            padding: EdgeInsets.only(top: 24),
            child: BotaoCustomizado(
              textoBotao: 'Agendar data',
              onPressed: _agendarData,
            ),
        )
      ],
    );
  }

  Widget _buildEventList() {
    return ListView(
      children: _selectedEvents
          .map((event) => Container(
        decoration: BoxDecoration(
          border: Border.all(width: 0.8),
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListTile(
          title: Text(event.toString()),
          onTap: () => print('$event tapped!'),
        ),
      ))
          .toList(),
    );
  }
}
