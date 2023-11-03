import 'package:askit/CustomWidgets.dart';
import 'package:flutter/material.dart';

import 'PostTask.dart';

class CategoryPick extends StatefulWidget {
  const CategoryPick({Key? key}) : super(key: key);

  @override
  State<CategoryPick> createState() => _CategoryPickState();
}

class _CategoryPickState extends State<CategoryPick> {
  final List<List<String>> gridData = [
    ['Home Work & Assignments', 'assets/CategoryIcons/Vector.png'],
    ['Office Work', 'assets/CategoryIcons/Group.png'],
    ['Lift-Move-Pack', 'assets/CategoryIcons/Vector (2).png'],
    ['Tutoring', 'assets/CategoryIcons/Vector (3).png'],
    ['Computer IT', 'assets/CategoryIcons/Vector (5).png'],
    ['Cleaning', 'assets/CategoryIcons/Group 2401.png'],
    ['Video & Editing', 'assets/CategoryIcons/Vector (1).png'],
    ['Photography', 'assets/CategoryIcons/Vector (6).png'],
    ['Design', 'assets/CategoryIcons/Vector (8).png'],
    ['Delivery & Errands', 'assets/CategoryIcons/Vector (11).png'],
    ['Pet Care', 'assets/CategoryIcons/Vector (4).png'],
    ['Gardening & PlantCare', 'assets/CategoryIcons/Vector (9).png'],
    ['Events', 'assets/CategoryIcons/Vector (7).png'],
    ['Custom', 'assets/CategoryIcons/Group 2562.png'],
    [],
  ];

  int _highlightedIndex = -1;

  String? _selectedCategory;
  String? _selectedIcon;

  void _onContainerTap(int index, List<String> data){
    setState(() {
      _highlightedIndex = index;
      _selectedCategory = data[0];
      _selectedIcon = gridData[index][1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomText(text: 'Need help with anything?', color: Colors.white, fontSize: 22,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.ac_unit_outlined),
                        CustomText(text: 'How does it work?', color: Colors.blue, fontSize: 16,)
                      ],
                    )
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: CustomText(text: 'Select a category and post a task', color: Colors.grey, fontSize: 16,),
            ),
            Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 95,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                    child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                        itemCount: gridData.length,
                        itemBuilder: (context, index){
                          bool lastItem = index == gridData.length -1;
                          if(lastItem){
                            return GestureDetector(
                              onTap: (){
                                setState(() {
                                  _highlightedIndex = index;
                                  _selectedCategory = "social";
                                  _selectedIcon = 'assets/CategoryIcons/Group 2480.png';
                                });
                              },
                              child: Container(
                                height: 100,
                                width: 80,
                                decoration: BoxDecoration(
                                    color: Colors.white10,
                                    borderRadius: BorderRadius.circular(10),
                                    border: _highlightedIndex == index ? Border.all(
                                      color: Colors.white,
                                    ) : null
                                ),
                                child: Image.asset('assets/CategoryIcons/Group 2480.png'),
                              ),
                            );
                          }else{
                            return GestureDetector(
                                onTap: ()=> _onContainerTap(index, gridData[index]),
                                child: CategoryTile(data: gridData[index], highlightedIndex: _highlightedIndex, index: index,));
                          }
                        }),
                  ),
                ),
            ),
            GestureDetector(
              onTap: (){
                _selectedCategory != null ? Navigator.push(context, MaterialPageRoute(builder: (context)=> Post(category: _selectedCategory, selectedIcon: _selectedIcon,))) : null;
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  color: _selectedCategory != null ? Colors.white : Colors.white10,
                ),
                child: Center(
                  child: Text('Continue',
                    style: TextStyle(
                      color: _selectedCategory != null ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
      // leading: IconButton(
      //   onPressed: (){
      //     Navigator.pop(context);
      //   },
      //   icon: const Icon(Icons.arrow_back_ios,
      //     color: Colors.white,
      //   ),
      // ),
      actions: [
        TextButton(onPressed: (){}, child: const Text('how can we assist?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ))
      ],
    );
  }
}