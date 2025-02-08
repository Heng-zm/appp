import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

/// MyApp now manages both theme and language state.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;
  String _selectedLanguage = "English";

  void _toggleTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
    });
  }

  void _setLanguage(String lang) {
    setState(() {
      _selectedLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter UI Course',
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: HomeScreen(
        isDarkTheme: _isDarkTheme,
        onThemeToggle: _toggleTheme,
        selectedLanguage: _selectedLanguage,
        onLanguageChange: _setLanguage,
      ),
    );
  }
}

/// HomeScreen manages the overall scaffold, including the AppBar, Drawer, Bottom Navigation,
/// and switching between pages. A GlobalKey is used to control the HomeContent (courses list).
class HomeScreen extends StatefulWidget {
  final bool isDarkTheme;
  final VoidCallback onThemeToggle;
  final String selectedLanguage;
  final Function(String) onLanguageChange;

  HomeScreen({
    required this.isDarkTheme,
    required this.onThemeToggle,
    required this.selectedLanguage,
    required this.onLanguageChange,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final List<Widget> _pages;
  // GlobalKey to access HomeContent state (for adding courses)
  final GlobalKey<_HomeContentState> homeContentKey =
      GlobalKey<_HomeContentState>();

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeContent(
          key: homeContentKey, selectedLanguage: widget.selectedLanguage),
      BroadcastPage(language: widget.selectedLanguage),
      CoursesPage(language: widget.selectedLanguage),
      SettingsPage(language: widget.selectedLanguage),
    ];
  }

  // Helper getters to change text based on language.
  String get _appBarTitle =>
      widget.selectedLanguage == "English" ? "Dashboard" : "លស្បូរ";

  List<BottomNavigationBarItem> get _bottomNavItems {
    return widget.selectedLanguage == "English"
        ? [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.public), label: 'Broadcast'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ]
        : [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ផ្ទះ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.public), label: 'ផ្សព្វផ្សាយ'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'ការបង្រៀន'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'ការកំណត់'),
          ];
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.selectedLanguage == "English"
              ? "Select Language"
              : "ជ្រើសរើសភាសា"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("English"),
                onTap: () {
                  widget.onLanguageChange("English");
                  Navigator.pop(context);
                  setState(() {}); // Update UI texts.
                },
              ),
              ListTile(
                title: Text("ខ្មែរ"),
                onTap: () {
                  widget.onLanguageChange("ខ្មែរ");
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _showLanguageDialog,
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(widget.selectedLanguage == "English"
                      ? 'No new notifications'
                      : 'គ្មានការ​ជូនដំណឹង​ថ្មី'),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue[900]),
              child: Text(
                widget.selectedLanguage == "English" ? 'Menu' : 'មឺនុយ',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(widget.selectedLanguage == "English"
                  ? 'Profile'
                  : 'ពត៌មាន​ផ្ទាល់'),
              onTap: () {},
            ),
            // Theme toggle switch:
            SwitchListTile(
              title: Text(widget.selectedLanguage == "English"
                  ? 'Dark Theme'
                  : 'ម៉ូដងងឹត'),
              value: widget.isDarkTheme,
              onChanged: (value) {
                widget.onThemeToggle();
              },
              secondary: Icon(Icons.brightness_6),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text(widget.selectedLanguage == "English"
                  ? 'Settings'
                  : 'ការកំណត់'),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(widget.selectedLanguage == "English"
                  ? 'Logout'
                  : 'ចេញពីប្រព័ន្ធ'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: _bottomNavItems,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // If Home page (courses list) is active, open the add course form.
          if (_currentIndex == 0) {
            homeContentKey.currentState?.showAddCourseDialog();
          } else {
            // You can add actions for other pages as needed.
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(widget.selectedLanguage == "English"
                  ? 'No action available'
                  : 'ពុំមានសកម្មភាព'),
            ));
          }
        },
      ),
    );
  }
}

/// HomeContent displays the main content for the Home tab, including:
/// - Search filtering
/// - Categories (static for now)
/// - A featured courses carousel
/// - The list of courses with pull-to-refresh and fade-in animations
class HomeContent extends StatefulWidget {
  final String selectedLanguage;
  const HomeContent({Key? key, required this.selectedLanguage})
      : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  String searchQuery = '';

  // Initial list of courses.
  List<Course> courses = [
    Course(
        title: 'UX UI Course',
        instructor: 'Cristiano Ronaldo',
        students: 8915,
        icon: Icons.design_services),
    Course(
        title: 'C++ Course',
        instructor: 'Lionel Messi',
        students: 7543,
        icon: Icons.code),
    Course(
        title: 'JavaScript Course',
        instructor: 'Neymar Jr',
        students: 6532,
        icon: Icons.computer),
    Course(
        title: 'Adobe Creative Suite',
        instructor: 'Kylian Mbappé',
        students: 4321,
        icon: Icons.adobe),
    Course(
        title: 'Database Course',
        instructor: 'Zlatan Ibrahimovic',
        students: 3210,
        icon: Icons.storage),
  ];

  // Simulate a refresh by adding a new course.
  Future<void> _refreshCourses() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      courses.add(
        Course(
            title: 'New Course ${courses.length + 1}',
            instructor: 'New Instructor',
            students: 1000,
            icon: Icons.new_releases),
      );
    });
  }

  /// Opens a bottom sheet to add a new course.
  void showAddCourseDialog() {
    final titleController = TextEditingController();
    final instructorController = TextEditingController();
    final studentsController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // For keyboard to adjust
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.selectedLanguage == "English"
                    ? 'Add New Course'
                    : 'បន្ថែមវគ្គសិក្សាថ្មី',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: widget.selectedLanguage == "English"
                      ? 'Course Title'
                      : 'ចំណងជើងវគ្គសិក្សា',
                ),
              ),
              TextField(
                controller: instructorController,
                decoration: InputDecoration(
                  labelText: widget.selectedLanguage == "English"
                      ? 'Instructor'
                      : 'អ្នកបង្រៀន',
                ),
              ),
              TextField(
                controller: studentsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: widget.selectedLanguage == "English"
                      ? 'Number of Students'
                      : 'ចំនួនសិស្ស',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  String title = titleController.text.trim();
                  String instructor = instructorController.text.trim();
                  int students =
                      int.tryParse(studentsController.text.trim()) ?? 0;
                  if (title.isNotEmpty && instructor.isNotEmpty) {
                    setState(() {
                      courses.add(Course(
                          title: title,
                          instructor: instructor,
                          students: students,
                          icon: Icons.new_releases));
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.selectedLanguage == "English"
                    ? 'Add Course'
                    : 'បន្ថែមវគ្គសិក្សា'),
              ),
              SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter courses based on the search query.
    List<Course> filteredCourses = courses
        .where((course) =>
            course.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Column(
      children: [
        // Search Field
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: widget.selectedLanguage == "English"
                  ? 'Search courses...'
                  : 'ស្វែងរកវគ្គសិក្សា...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),
        // Categories List (static for demonstration)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: (widget.selectedLanguage == "English"
                    ? ['Home', 'Courses', 'Reports']
                    : ['ផ្ទះខ្ញុំ', 'ការបង្រៀន', 'របាយការណ៍'])
                .map(
                  (category) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () {},
                      child: Text(category),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        // Featured Courses Carousel
        Container(
          height: 180,
          margin: EdgeInsets.symmetric(vertical: 10),
          child: PageView(
            controller: PageController(viewportFraction: 0.9),
            children: [
              FeaturedCourseCard(
                title: widget.selectedLanguage == "English"
                    ? 'Featured: UX UI Course'
                    : 'មុខងារ: វគ្គ UX UI',
                description: widget.selectedLanguage == "English"
                    ? 'Learn design fundamentals'
                    : 'សិក្សាមូលដ្ឋានរចនាប័ទ្ម',
              ),
              FeaturedCourseCard(
                title: widget.selectedLanguage == "English"
                    ? 'Featured: C++ Course'
                    : 'មុខងារ: វគ្គ C++',
                description: widget.selectedLanguage == "English"
                    ? 'Master C++ programming'
                    : 'ជាអ្នកមានជំនាញក្នុងការសរសេរ C++',
              ),
            ],
          ),
        ),
        // Course List with Pull-to-Refresh and Fade-In Animation
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshCourses,
            child: ListView.builder(
              itemCount: filteredCourses.length,
              itemBuilder: (context, index) {
                return TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500),
                  builder: (context, double opacity, child) {
                    return Opacity(
                      opacity: opacity,
                      child: child,
                    );
                  },
                  child: CourseTile(
                      course: filteredCourses[index],
                      language: widget.selectedLanguage),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// A simple model representing a Course.
class Course {
  final String title;
  final String instructor;
  final int students;
  final IconData icon;

  Course({
    required this.title,
    required this.instructor,
    required this.students,
    required this.icon,
  });
}

/// A course tile with hero animation, a favorite toggle, and fade-in effect.
class CourseTile extends StatefulWidget {
  final Course course;
  final String language;
  CourseTile({required this.course, required this.language});

  @override
  _CourseTileState createState() => _CourseTileState();
}

class _CourseTileState extends State<CourseTile> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: 'course-${widget.course.title}',
        child: Icon(widget.course.icon, size: 40, color: Colors.blue[900]),
      ),
      title: Text(widget.course.title,
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.language == "English"
              ? 'Instructor: ${widget.course.instructor}'
              : 'អ្នកបង្រៀន: ${widget.course.instructor}'),
          Text(widget.language == "English"
              ? 'Students: ${widget.course.students}'
              : 'ចំនួនសិស្ស: ${widget.course.students}'),
          Row(
            children: List.generate(
                5,
                (index) => Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.orange,
                    )),
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.red),
        onPressed: () {
          setState(() {
            isFavorite = !isFavorite;
          });
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CourseDetail(course: widget.course, language: widget.language),
          ),
        );
      },
    );
  }
}

/// The CourseDetail page now includes hero animations for the course icon
/// and a reviews section where users can read and add reviews.
class CourseDetail extends StatefulWidget {
  final Course course;
  final String language;
  CourseDetail({required this.course, required this.language});

  @override
  _CourseDetailState createState() => _CourseDetailState();
}

class _CourseDetailState extends State<CourseDetail> {
  // Initial dummy reviews.
  List<String> reviews = ["Great course!", "Very informative!", "Loved it!"];

  void _showReviewDialog() {
    final reviewController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.language == "English"
              ? "Write a Review"
              : "សរសេរការវាយតម្លៃ"),
          content: TextField(
            controller: reviewController,
            decoration: InputDecoration(
              hintText: widget.language == "English"
                  ? 'Enter your review'
                  : 'បញ្ចូលការវាយតម្លៃរបស់អ្នក',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(widget.language == "English" ? "Cancel" : "បោះបង់"),
            ),
            ElevatedButton(
              onPressed: () {
                String newReview = reviewController.text.trim();
                if (newReview.isNotEmpty) {
                  setState(() {
                    reviews.add(newReview);
                  });
                }
                Navigator.pop(context);
              },
              child: Text(widget.language == "English" ? "Submit" : "ដាក់ស្នើ"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
        backgroundColor: Colors.blue[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Hero(
                tag: 'course-${widget.course.title}',
                child:
                    Icon(widget.course.icon, size: 80, color: Colors.blue[900]),
              ),
            ),
            SizedBox(height: 20),
            Text(widget.course.title,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text(
              widget.language == "English"
                  ? 'Instructor: ${widget.course.instructor}'
                  : 'អ្នកបង្រៀន: ${widget.course.instructor}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              widget.language == "English"
                  ? 'Students: ${widget.course.students}'
                  : 'ចំនួនសិស្ស: ${widget.course.students}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Text(
              widget.language == "English"
                  ? 'Course Description:'
                  : 'ពិពណ៌នាវគ្គសិក្សា:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              widget.language == "English"
                  ? 'This is a detailed description of the course. It includes content, prerequisites, and more information to help you decide if this course is right for you.'
                  : 'នេះជាការពិពណ៌នាលម្អិតអំពីវគ្គសិក្សា។ វារួមមានមាតិកា លក្ខខណ្ឌមុន និងព័ត៌មានបន្ថែមដើម្បីជួយអ្នកសម្រេចចិត្តថាវគ្គនេះសមរម្យសម្រាប់អ្នកឬអត់។',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              widget.language == "English" ? 'Reviews:' : 'ការវាយតម្លៃ:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // Display reviews in a limited-height container.
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.comment, size: 20),
                    title: Text(reviews[index]),
                  );
                },
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: _showReviewDialog,
                child: Text(widget.language == "English"
                    ? 'Write a Review'
                    : 'សរសេរការវាយតម្លៃ'),
              ),
            ),
            Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                backgroundColor: Colors.blue[900],
              ),
              onPressed: () {
                // Enrollment action can be implemented here.
              },
              icon: Icon(Icons.play_arrow),
              label: Text(
                  widget.language == "English" ? 'Enroll Now' : 'ចុះឈ្មោះឥឡូវ'),
            )
          ],
        ),
      ),
    );
  }
}

/// A featured course card used in the carousel.
class FeaturedCourseCard extends StatelessWidget {
  final String title;
  final String description;

  FeaturedCourseCard({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(description, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

/// Placeholder page for "Broadcast".
class BroadcastPage extends StatelessWidget {
  final String language;
  BroadcastPage({required this.language});
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Text(language == "English" ? 'Broadcast Page' : 'ទំព័រផ្សព្វផ្សាយ'),
    );
  }
}

/// Placeholder page for "Courses".
class CoursesPage extends StatelessWidget {
  final String language;
  CoursesPage({required this.language});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(language == "English" ? 'Courses Page' : 'ទំព័រវគ្គសិក្សា'),
    );
  }
}

/// Placeholder page for "Settings".
class SettingsPage extends StatelessWidget {
  final String language;
  SettingsPage({required this.language});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(language == "English" ? 'Settings Page' : 'ទំព័រការកំណត់'),
    );
  }
}
