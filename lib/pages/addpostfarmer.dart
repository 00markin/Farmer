import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddPostFarmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AddPostScreen();
  }
}

class AddPostScreen extends StatefulWidget {
  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {

  DateTime selectedDate = DateTime.now();
  double _height, _width;
  GlobalKey<FormState> _key = GlobalKey();
  String _itemName , _quantity ;
  bool _load = false;
  String _email = '';
  SharedPreferences prefs;

  @override
  void initState(){
    super.initState();
    try {
      SharedPreferences.getInstance().then((sharedPrefs) {
        setState(() {
          prefs = sharedPrefs;
          _email = prefs.getString('email');
        });
      });
    } catch (e) {
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }

  }

  @override
  Widget build(BuildContext context) {

    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Post'),
      ),
      body: Container(
        height: _height,
        width: _width,
        padding: EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              image(),
              form(),
              SizedBox(height: _height / 12),
              button(),
            ],
          ),
        ),
      ),
    );
  }

  Widget image() {
    return Container(
      margin: EdgeInsets.only(top: _height / 15.0),
      height: 100.0,
      width: 100.0,
      decoration: new BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: new Image.asset('images/login.png'),
    );
  }

  Widget form() {
    return Container(
      margin: EdgeInsets.only(
          left: _width / 12.0,
          right: _width / 12.0,
          top: _height / 15.0),
      child: Form(
        key: _key,
        child: Column(
          children: <Widget>[
            itemName(),
            SizedBox(height: _height / 40.0),
            itemQuantity(),
            SizedBox(height: _height / 40.0),
            harvestTime(),
          ],
        ),
      ),
    );
  }

  Widget itemName() {
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child: TextFormField(
        onSaved: (input) => _itemName = input,
        keyboardType: TextInputType.text,
        cursorColor: Colors.green,
        obscureText: false,
        decoration: InputDecoration(
          hintText: "Item Name",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget itemQuantity() {
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child: TextFormField(
        onSaved: (input) => _quantity = input,
        keyboardType: TextInputType.text,
        cursorColor: Colors.green,
        obscureText: false,
        decoration: InputDecoration(
          hintText: "Quantity in kg/litre",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }


  TextEditingController valHarvest = new TextEditingController();
  String _selectedtime = '';
  int yr = DateTime.now().year;
  Widget harvestTime(){
    return Material(
      borderRadius: BorderRadius.circular(30.0),
      elevation: 10,
      child:TextFormField(
          onSaved: (input) => _selectedtime = input,
          keyboardType: TextInputType.datetime,
          readOnly: true,
          controller: valHarvest,
          cursorColor: Colors.green,
          obscureText: false,
          decoration: InputDecoration(
            suffixIcon: new Icon(Icons.calendar_today, color: Colors.green, size: 20),
            hintText: "Harvest Time",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none),
          ),
          onTap: ()async{
            final datePick= await showDatePicker(
                context: context,
                initialDate: new DateTime.now(),
                firstDate: new DateTime.now(),
                lastDate: new DateTime(yr+2),
                builder: (BuildContext context, Widget child) {
              return Theme(
                data: ThemeData.light().copyWith(
//                    primarySwatch: buttonTextColor,//OK/Cancel button text color
                    primaryColor: const Color(0xFF4CAF50),//Head background
                    accentColor: const Color(0xFF4CAF50),//selection color
                  dialogBackgroundColor: Colors.white,//Background color
                colorScheme: ColorScheme.light(primary: const Color(0xFF4CAF50)),
                buttonTheme: ButtonThemeData(
                    textTheme: ButtonTextTheme.primary
                ),
                ),
                child: child,
              );
            },
            );
            if(datePick!=null){
              setState(() {
                _selectedtime = "${datePick.month}/${datePick.day}/${datePick.year}";
                valHarvest.text = _selectedtime;
                print(_selectedtime);
              });
            }
          }
      ),
    );
  }

  Widget button() {
    return !_load ? RaisedButton(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      onPressed: () {
        final formstate = _key.currentState;
        formstate.save();
        if (_itemName == null || _itemName.isEmpty) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Item Name Cannot be empty')));
        } else if (_quantity == null || _quantity.isEmpty) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Quantity Cannot be empty')));
        }
        else if (_selectedtime == null || _selectedtime.isEmpty) {
          Scaffold.of(context).showSnackBar(
              SnackBar(content: Text('Harvest Time Cannot be empty')));
        }
        else {
          setState(() {
            _load = true;
          });
          add();
        }
      },
      textColor: Colors.white,
      padding: EdgeInsets.all(0.0),
      child: Container(
        alignment: Alignment.center,
        width: _width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          gradient: LinearGradient(
            colors: <Color>[Colors.green, Colors.lightGreen],
          ),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text('Add Post', style: TextStyle(fontSize: 15)),
      ),
    ) : Center(
      child: CircularProgressIndicator(),
    );
  }

  Future<void> add() async{
    try{
      print(_email);
      await Firestore.instance.collection('users').document(_email).updateData({'orders':FieldValue.arrayUnion([{'item' :_itemName , 'Quantity' : _quantity , 'HarvestTime': _selectedtime ,'TimeStamp' : DateTime.now()}])});
      setState((){_load = false;});
      Navigator.of(context).pushReplacementNamed('home');
    }catch(e){
      setState((){_load = false;});
      print(e.message);
      Scaffold.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

}


