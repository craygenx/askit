import 'package:askit/SignUp.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/material.dart';

class ServiceOptions extends StatefulWidget {
  const ServiceOptions({Key? key}) : super(key: key);

  @override
  State<ServiceOptions> createState() => _ServiceOptionsState();
}

class _ServiceOptionsState extends State<ServiceOptions> {
  String serviceType = '';
  bool _check1 = false;
  bool _check2 = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const CustomAppBar(),
      body: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: SizedBox(
            height: 50,
            width: 50,
            child: Image.asset(
              'assets/logo/Group 2461.png',
              width: MediaQuery.of(context).size.width * .6,
              height: 40,
            ),
          ),
        ),
        const SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Tell us how you want to use Askit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              Text('You can always change within the app',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFFA7A7A7),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                child: ListTile(
                  tileColor: _check1 ? Colors.blueGrey : Colors.white30,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    setState(() {
                      _check1 = !_check1;
                      _check2 = !_check1;
                      serviceType = 'Provider';
                    });
                  },
                  leading:
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Checkbox(value: _check1, onChanged: (bool? value){
                            setState((){
                              _check1 = value!;
                              //_check1 = value ?? false;
                              _check2 = !_check1;
                              serviceType = 'Requester';
                            });
                          },
                            activeColor: Colors.blue,
                          ),
                          Container(
                          width: 19,
                          height: 19,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              )
                          ),
                        ),
                        ],
                      ),
                        title:
                          const Text('As a Service Requester',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        subtitle:
                          const Text('Getting things done, post tasks',
                            style: TextStyle(
                              color: Color(0xFFA7A7A7),
                            ),
                          ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                child: ListTile(
                  tileColor: _check2 ? Colors.blueGrey : Colors.white30,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () {
                    setState(() {
                      _check2 = !_check2;
                      _check1 = !_check2;
                      serviceType = 'Provider';
                    });
                  },
                  leading:
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Checkbox(value: _check2, onChanged: (bool? value){
                            setState((){
                              _check2 = value!;
                              //_check1 = value ?? false;
                              _check1 = !_check2;
                              serviceType = 'Provider';
                            });
                          }, activeColor: Colors.blue,),
                          Container(
                            width: 19,
                            height: 19,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 1.0,
                              )
                            ),
                        ),
                        ]
                      ),
                      title:
                          const Text('As a Service Provider',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                    subtitle:
                          const Text('Start earning by completing tasks.',
                            style: TextStyle(
                              color: Color(0xFFA7A7A7),
                            ),
                          )
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(CommunityMaterialIcons.lightbulb_on_outline,
                        color: Colors.white,
                      ),
                    ),
                    Text('How this works?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> SignUp(serviceType: serviceType)));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * .8,
                  height: 50,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Colors.white
                  ),
                  child: const Center(
                    child: Text('Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        )
      ],
        ),
    );
  }
}
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({Key? key}) : super(key: key);

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: (){
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Colors.white,
        ),
      ),
      title: const Text(
        'Getting Started',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white
        ),
      ),
    );
  }
}
