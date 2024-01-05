// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:quickalert/quickalert.dart';

class GridScreen extends StatefulWidget {
  const GridScreen({Key? key}) : super(key: key);

  @override
  _GridScreenState createState() => _GridScreenState();
}

class _GridScreenState extends State<GridScreen> {
  int rows = 3;
  int columns = 3;
  String inputString = '';
  String searchText = '';
  List<List<String>> grid = List.generate(3, (index) => List.filled(3, ''));
  List<List<bool>> highlightMatrix =
      List.generate(3, (index) => List.filled(3, false));
  bool randomOrder = false;

  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showAlerts();
    });
  }

  // Show informative alerts on screen initialization
  Future<void> _showAlerts() async {
    await Future.delayed(
        const Duration(milliseconds: 300)); // Delay between alerts
    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text:
          'Fill the grid either by manually entering values in each block or use the input textfield to automatically fill the grid for you.',
    );

    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      text:
          "Enable 'Random Order' to highlight every letter from the search word, regardless of their sequence. Turn it off to search for words either vertically or horizontally in the grid.",
    );

    await Future.delayed(const Duration(seconds: 1)); // Delay between alerts
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Enter number of rows and columns:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 50,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        rows = int.parse(value);
                        _initializeGrid();
                      });
                    },
                  ),
                ),
                const Text('x'),
                SizedBox(
                  width: 50,
                  child: TextField(
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        columns = int.parse(value);
                        _initializeGrid();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Input textfield for manual grid entry
            TextField(
              maxLength: rows * columns,
              onChanged: (value) {
                setState(() {
                  inputString = value.toLowerCase();

                  _distributeStringToGrid();
                  _searchAndHighlight();
                  _updateSearchTextEnabled();
                });
              },
              decoration: const InputDecoration(
                labelText: 'Enter a string:',
                labelStyle: TextStyle(color: Colors.black87),
              ),
            ),
            const SizedBox(height: 10),
            // Checkbox for random order highlighting
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Random Order:'),
                Checkbox(
                  value: randomOrder,
                  onChanged: (value) {
                    setState(() {
                      randomOrder = value!;
                      _searchAndHighlight();
                    });
                  },
                ),
              ],
            ),
            // Search textfield
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                  _searchAndHighlight();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search text:',
                labelStyle: const TextStyle(color: Colors.black87),
                // Disable the search text field if not all elements are filled
                enabled: inputString.length == rows * columns,
              ),
            ),
            const SizedBox(height: 20),
            // Display the grid using GridView.builder
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: rows * columns,
              itemBuilder: (context, index) {
                int rowIndex = index ~/ columns;
                int columnIndex = index % columns;
                TextEditingController cellController =
                    TextEditingController(text: grid[rowIndex][columnIndex]);

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black),
                    color: highlightMatrix[rowIndex][columnIndex]
                        ? Colors.blueAccent[200]
                        : null,
                  ),
                  child: Center(
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: cellController,
                      style: TextStyle(
                        color: highlightMatrix[rowIndex][columnIndex]
                            ? Colors.white
                            : Colors.black,
                      ),
                      onChanged: (value) {
                        setState(() {
                          grid[rowIndex][columnIndex] =
                              value.isNotEmpty ? value[0] : '';
                          _updateSearchTextEnabled();
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }

  // Initialize grid based on the entered number of rows and columns
  void _initializeGrid() {
    grid = List.generate(rows, (index) => List.filled(columns, ''));
    highlightMatrix =
        List.generate(rows, (index) => List.filled(columns, false));
    _updateSearchTextEnabled();
  }

  // Distribute input string to the grid
  void _distributeStringToGrid() {
    int index = 0;
    grid = List.generate(rows, (index) => List.filled(columns, ''));
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        if (index < inputString.length) {
          grid[i][j] = inputString[index];
          index++;
        }
      }
    }
    _updateSearchTextEnabled();
  }

  // Search for the entered text and highlight corresponding grid elements
  void _searchAndHighlight() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        highlightMatrix[i][j] = false;
      }
    }

    if (randomOrder) {
      // Check randomly
      _checkRandomOrder();
    } else {
      // Check horizontally
      _checkHorizontal();
      // Check vertically
      _checkVertical();
    }
  }

  // Check for random order of the search text
  void _checkRandomOrder() {
    List<String> shuffledSearchText = searchText.split('')..shuffle();

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        for (int k = 0; k < shuffledSearchText.length; k++) {
          if (grid[i][j] == shuffledSearchText[k]) {
            highlightMatrix[i][j] = true;

            shuffledSearchText.removeAt(k);
            break;
          }
        }
      }
    }
  }

  // Check for the search text horizontally
  void _checkHorizontal() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        for (int k = 0; k < searchText.length; k++) {
          if (j + k < columns && grid[i][j + k] == searchText[k]) {
            highlightMatrix[i][j + k] = true;
          } else {
            break;
          }
        }
      }
    }
  }

  // Check for the search text vertically
  void _checkVertical() {
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        for (int k = 0; k < searchText.length; k++) {
          if (i + k < rows && grid[i + k][j] == searchText[k]) {
            highlightMatrix[i + k][j] = true;
          } else {
            break;
          }
        }
      }
    }
  }

  // Update the state to enable or disable the search textfield
  void _updateSearchTextEnabled() {
    setState(() {
      controller.text = '';
    });
  }
}
