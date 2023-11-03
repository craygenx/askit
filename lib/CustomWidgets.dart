import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

typedef StringValidator = String? Function(String? value);
class CustomTextField extends StatelessWidget {
  final double width;
  final StringValidator? validator;
  final int? maxLines;
  final TextEditingController controller;
  final String hintText;
  const CustomTextField({Key? key, required this.width, required this.controller, required this.hintText, this.maxLines, this.validator}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(10)
      ),
      width: width,
      child: TextFormField(
        maxLines: maxLines ?? 1,
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          hintStyle: const TextStyle(
            color: Colors.grey
          ),
          hintText: hintText,
          contentPadding: const EdgeInsets.only(left: 8.0),
          border: InputBorder.none,
        )
      ),
    );
  }
}

class CustomText extends StatelessWidget {
  final String text;
  final Color color;
  final double fontSize;
  const CustomText({Key? key, required this.text, this.color=Colors.white, this.fontSize = 12.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.fade,
        style: TextStyle(
          color: color,
          fontSize: fontSize
        ),
      ),
    );
  }
}

class CustomDropDown extends StatefulWidget {
  final String? hint;
  final String? iconImage;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  const CustomDropDown({Key? key, this.hint, required this.items, this.value, required this.onChanged, this.iconImage}) : super(key: key);

  @override
  State<CustomDropDown> createState() => _CustomDropDownState();
}

class _CustomDropDownState extends State<CustomDropDown> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white30,
          borderRadius: BorderRadius.circular(10)
      ),
      child: DropdownButtonFormField<String>(
        hint: widget.hint != null ? Text(widget.hint!) : null,
        decoration: InputDecoration(
          prefix: widget.iconImage != null ? Image.asset(widget.iconImage!) : const Text(''),
          hintStyle: const TextStyle(
            color: Colors.grey,
          ),
          contentPadding: const EdgeInsets.only(left: 8.0),
          border: InputBorder.none,
        ),
        items: widget.items.map((item) => DropdownMenuItem<String>(
          value: item,
            child: Text(item),
        )).toList(),
        onChanged: widget.onChanged,
        value: widget.value,
      ),
    );
  }
}

class CustomDatePicker extends StatefulWidget {
  final String hint;
  final String? labelText;
  final TextEditingController controller;
  DateTime firstSelection;
  bool isFirstSelect = false;
  CustomDatePicker({Key? key, required this.hint, this.labelText, required this.controller, required this.firstSelection, required this.isFirstSelect}) : super(key: key);

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime _selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: widget.firstSelection,
        firstDate: widget.isFirstSelect ? widget.firstSelection : DateTime.now(),
        lastDate: DateTime(2050)
    );
    if(picked != null && picked != _selectedDate){
      setState(() {
        _selectedDate = picked;
        widget.firstSelection = picked;
        widget.isFirstSelect = true;
        widget.controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        _selectDate(context);
      },
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * .40,
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
                "${_selectedDate.toLocal()}".split(' ')[0]
            ),
            const Icon(Icons.arrow_drop_down_sharp)
          ],
        ),
      ),
    );
  }
}
class CategoryTile extends StatefulWidget {
  final List<String> data;
  final int highlightedIndex;
  final int index;
  const CategoryTile({Key? key, required this.data, required this.highlightedIndex, required this.index}) : super(key: key);

  @override
  State<CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<CategoryTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 80,
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
        border: widget.highlightedIndex == widget.index ? Border.all(
          color: Colors.white,
        ) : null
      ),
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            child: Image.asset(widget.data[1]),
          ),
          Center(child: CustomText(text: widget.data[0], color: Colors.grey,)),
        ],
      ),
    );
  }
}
class TaskCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Color backgroundColor;
  const TaskCard({Key? key, required this.data, this.backgroundColor = Colors.white12}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    final date = data['on_date_formatted'].toDate();
    final DateFormat formatter = DateFormat('EEEE, d MMMM');
    final formattedDate = formatter.format(date);
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    void showToastMessage(String message, Color textColor) =>
        Fluttertoast.showToast(
          msg: message,
          gravity: ToastGravity.TOP,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.amberAccent,
          textColor: textColor,
          fontSize: 16,
        );
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        width: MediaQuery.of(context).size.width * 95,
        child: Row(
          children: [
            SizedBox(
              height: 200,
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset(data['png_icon']),
                  )
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CustomText(text: data['category']),
                    Text(data['category'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Text(data['description'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          // overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // Expanded(child: CustomText(text: data['description'], fontSize: 18.0,)),
                    SizedBox(
                      height: 70,
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 8.0),
                                      child: SizedBox(
                                        child: Row(
                                          children: [
                                            Icon(Icons.pin_drop,
                                              color: Colors.grey,
                                            ),
                                            CustomText(text: 'Hauz khas, New Delhi')
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      child: Row(
                                        children: [
                                          const Icon(Icons.calendar_month,
                                            color: Colors.grey,
                                          ),
                                          CustomText(text: formattedDate)
                                          // CustomText(text: 'Sunday, 18 july')
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Icon(Icons.account_circle_outlined,
                                  color: Colors.grey,
                                ),
                                CustomText(text: '${data['offers'].length} Offers'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 200,
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: SvgPicture.asset('assets/askitIcons/tskBrief/rupee.svg',
                            width: 30,
                            height: 18,
                          ),
                        ),
                        const CustomText(text: "300", fontSize: 16),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: data['status'] == 'open' ? SvgPicture.asset(
                      'assets/askitIcons/tskBrief/green.svg',
                      width: 40,
                      height: 20,
                    ) : GestureDetector(
                      onTap: (){
                        showDialog(
                            context: context,
                            builder: (BuildContext context){
                              return AlertDialog(
                                title: const Text('Reopen Task'),
                                content: const Text('This action will reopen the post for public bidding.'),
                                contentTextStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                titleTextStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.blue,
                                ),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () async{
                                        String docId = data['Task_id'];
                                        try {
                                          await firestore.collection('Tasks').doc(docId)
                                              .update({'status' : 'open', 'offers' : []});
                                        }catch(e){
                                          showToastMessage('Error occurred', Colors.white);
                                        }
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Reopen'),
                                  ),
                                  ElevatedButton(
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('Cancel'),
                                  )
                                ],
                              );
                            },
                        );

                      },
                        child: const CustomText(text: 'Reopen', color: Colors.blue),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}





