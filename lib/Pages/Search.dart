
import 'package:coachyp/colors.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

import 'package:coachyp/colors.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final TextEditingController _searchController = TextEditingController();

  List<String> allItems = [
    "Coach Mark",
    "Coach Lucy",
    "Spartan Gym",
    "Elite Training",
    "Coach Mike",
    "Strength Lab",
    "Coach Lara",
    "PowerFit Gym",
  ];

  List<String> filteredItems = [];

  @override
  void initState() {
    super.initState();
    filteredItems = allItems;

    _searchController.addListener(() {
      filterSearchResults(_searchController.text);
    });
  }

  void filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredItems = allItems;
      });
    } else {
      setState(() {
        filteredItems = allItems
            .where((item) => item.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Container(
                  height: 45,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      icon: Icon(LineIcons.search, color: Colors.grey[700], size: 20),
                      hintText: "Search",
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontFamily: "Jersey15", color: Colors.grey[700], fontSize: 18),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[700]),
                        onPressed: () => _searchController.clear(),
                      ),
                    ),
                    style: const TextStyle(fontFamily: "Jersey15", fontSize: 19),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: filteredItems.isEmpty
          ? const Center(
              child: Text("No results found", style: TextStyle(color: Colors.white, fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    title: Text(filteredItems[index]),
                    onTap: () {
                      // Handle item tap
                    },
                  ),
                );
              },
            ),
    );
  }
}
