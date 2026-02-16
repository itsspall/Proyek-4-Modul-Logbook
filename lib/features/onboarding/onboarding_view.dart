// OnboardingView memiliki sebuah variabel int step = 1.
// Logika: Jika tombol "Next" ditekan, step++. Jika step > 3, maka pindah ke LoginView menggunakan Navigator.pushReplacement.
import 'package:flutter/material.dart';
import 'package:logbook_app_001/features/auth/login_view.dart';
class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _step = 1;
  final List<String> _imagesOnboarding = [
    'assets/images/gambar_1.jpg',
    'assets/images/gambar_2.jpg',
    'assets/images/gambar_3.jpg',
  ];

  void _nextStep() {
    if (_step < _imagesOnboarding.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Area untuk PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _imagesOnboarding.length,
                onPageChanged: (index) {
                  setState(() {
                    _step = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(40.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Tampilkan Gambar dari Assets
                        Image.asset(
                          _imagesOnboarding[index],
                          height: 300, // Atur tinggi gambar agar rapi
                        ),
                        const SizedBox(height: 20),
                        // Judul Opsional sesuai gambar
                        Text(
                          "Langkah ${index + 1}",
                          style: const TextStyle(
                            fontSize: 24, 
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Deskripsi singkat tentang fitur aplikasi di sini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bagian dot indicator dan tombol next
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0, left: 20, right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indikator Titik 3 (Dot Indicator)
                  Row(
                    children: List.generate(
                      _imagesOnboarding.length,
                      (index) => buildDot(index),
                    ),
                  ),

                  // Tombol Next / Start
                  ElevatedButton(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 10,
      width: _step == index ? 25 : 10,
      decoration: BoxDecoration(
        color: _step == index ? Colors.deepPurple : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}