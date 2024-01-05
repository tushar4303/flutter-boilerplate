import 'package:flutter/material.dart';

class GridScreen extends StatefulWidget {
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
            TextField(
              maxLength: rows * columns,
              onChanged: (value) {
                setState(() {
                  inputString = value;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Random Order:'),
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
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  _searchAndHighlight();
                });
              },
              decoration: InputDecoration(
                labelText: 'Search text:',
                labelStyle: TextStyle(color: Colors.black87),
                // Disable the search text field if not all elements are filled
                enabled: inputString.length == rows * columns,
              ),
            ),
            const SizedBox(height: 20),
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
                              value.length > 0 ? value[0] : '';
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
            SizedBox(
              height: 40,
            )
          ],
        ),
      ),
    );
  }

  void _initializeGrid() {
    grid = List.generate(rows, (index) => List.filled(columns, ''));
    highlightMatrix =
        List.generate(rows, (index) => List.filled(columns, false));
    _updateSearchTextEnabled();
  }

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

  void _updateSearchTextEnabled() {
    setState(() {
      controller.text = '';
    });
  }
}
