⚡ Siyas Game Boost v2.0.0
A powerful, kernel-level game optimization module featuring a stunning, fully interactive WebUI. Tuned specifically to squeeze maximum performance out of the Redmi Note 8 Pro (Helio G90T / Mali-G76) for heavy titles like BGMI, PUBG Mobile, and Genshin Impact.
🚀 Features
Cyberpunk WebUI: Control your kernel directly from your browser (http://localhost:8080) with real-time stat tracking and animated toggles.
CPU & GPU Max Lock: Forces performance governors to keep all 8 cores and the Mali-G76 GPU running at peak frequencies.
Memory & Cache Management: Instantly kills background services and flushes pagecache/ART caches to free up RAM.
Display & Touch Tuning: Adjust display sync for specific FPS targets and boost touch sampling rates for ultra-responsive input polling.
Thermal Control: Adjusts thermal throttling thresholds for sustained gaming performance.
📋 Requirements
Root Access: Magisk, KernelSU, or ResuKISU installed.
OS: Android 11+ (API 30 or higher).
Architecture: ARM64-v8a.
Dependencies: busybox must be installed and accessible for the WebUI's CGI backend server to function.
🛠️ Installation
Download the latest SiyasGameBoost_v2.0.0.zip from the Releases tab.
Open your root manager (Magisk or KernelSU).
Navigate to the Modules tab and select Install from storage.
Select the downloaded ZIP file and wait for the flash to complete.
Reboot your device.
(Note: The module sets up base tweaks automatically on boot via service.sh).
🎮 Usage
Launch your root manager and tap the Action button on the Siyas Game Boost module.
The WebUI will automatically launch in your default browser.
Alternatively, open any browser and navigate to http://localhost:8080.
Select your game target from the grid.
Toggle your desired optimization modules.
Tap ⚡ APPLY BOOST to execute the kernel-level CGI scripts.
Watch the real-time shell log confirm your optimizations.
⚠️ Disclaimer
This module alters kernel parameters, CPU governors, and thermal limits. While built and tested for stability, modifying these values can increase device temperatures and battery consumption. Use at your own risk. I am not responsible for bricked devices, hardware degradation, or thermonuclear war.
👨‍💻 Developer
Created by Siyas.