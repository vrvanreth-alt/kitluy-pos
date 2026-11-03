# KITLUY POS (គិតលុយ POS) 🚗⚡

> **Web POS System គ្រប់គ្រងហាងលក់សំបកកង់ឡាន អាគុយ ប្រេងម៉ាស៊ីន និងគ្រឿងបន្លាស់យានយន្ត តាមស្តង់ដា POS កម្ពុជា**
>
> Modern Automotive & Garage Point of Sale (POS) Web System built with Flutter & Supabase for Cambodia.

---

## 🌟 លក្ខណៈពិសេសសំខាន់ៗ (Key Features)

### ១. ស្តង់ដា POS ប្រទេសកម្ពុជា (Cambodian POS Standards)
- **ប្រព័ន្ធរូបិយប័ណ្ណទ្វេ (Dual-Currency Engine)**៖ គណនាតម្លៃជា **USD ($)** និង **KHR (៛)** ព្រមគ្នា កំណត់អត្រាប្តូរប្រាក់ (Exchange Rate ឧ. `1$ = 4,100 ៛`) តាមស្តង់ដារធនាគារជាតិនៃកម្ពុជា។
- **ការទូទាត់តាមស្តង់ដាជាតិ Bakong KHQR**៖ បង្កើត Dynamic EMVCo KHQR Code ជាមួយការគណនា Checksum CRC16-CCITT អាចស្កេនបង់តាមគ្រប់ធនាគារ (ABA, ACLEDA, Wing, Canadia...)។
- **ជម្រើសទូទាត់ចម្រុះ (Multi-payment & Split Cash)**៖ ទទួលប្រាក់ជា USD, KHR, ឬទូទាត់ចម្រុះ (Split USD+KHR ក្នុងវិក្កយបត្រតែមួយ) ព្រមទាំងគណនាប្រាក់អាប់ជាដុល្លារ ឬរៀលដោយស្វ័យប្រវត្តិ។
- **វិក្កយបត្រកម្ដៅ 80mm (Thermal Receipt)**៖ គាំទ្រពុម្ពអក្សរខ្មែរស្អាតច្បាស់ (Kantumruy Pro), បង្ហាញព័ត៌មានយានយន្ត ស្លាកលេខឡាន គីឡូម៉ែត្រ និងបោះពុម្ពភ្លាមៗ។

### ២. មុខងារឯកទេសសម្រាប់ហាងយានយន្ត (Auto Shop Specifics)
- **សំបកកង់ឡាន (Tires)**៖ គ្រប់គ្រងតាមទំហំ (Size ឧ. 215/55R17, 265/65R17), ម៉ាក (Michelin, Bridgestone...), DOT កូដសប្តាហ៍/ឆ្នាំផលិត, និងការធានា។
- **អាគុយ (Batteries)**៖ គ្រប់គ្រងតាមអំពែ (Capacity Ah), ប្រភេទក្បាល (JIS / DIN ក្បាលកប់) ព្រមទាំង **ប្រព័ន្ធកាត់កងថ្លៃអាគុយចាស់ (Old Battery Trade-in Rebate: -$10)** ដោយគ្រាន់តែចុច toggle មួយឃ្លីក។
- **ប្រេងម៉ាស៊ីន (Engine Oil)**៖ គ្រប់គ្រងតាម viscosity (0W-20, 5W-30, 10W-40), ចំណុះ (4L, 5L, 1L), ប្រភេទ Fully Synthetic, និងកត់ត្រា **គីឡូម៉ែត្រត្រូវប្តូរប្រេងលើកក្រោយ** (Next Service Reminder)។
- **គ្រឿងបន្លាស់ & សេវាកម្ម (Parts & Services)**៖ លេខកូដ OEM Part Number, ភាពត្រូវគ្នានឹងម៉ូដែលឡាន (Compatibility), ឈ្នួលប្តូរប្រេង, ថ្លៃថ្លឹងកង់ (Balancing), និងតម្រង់កង់ (Alignment 3D)។
- **ព័ត៌មានយានយន្ត & ជាង (Vehicle & Mechanic Tracking)**៖ កត់ត្រាស្លាកលេខឡាន (Plate Number ឧ. `ភ្នំពេញ 2BC-8899`), ម៉ូដែលឡាន, គីឡូម៉ែត្របច្ចុប្បន្ន, និងជាងទទួលបន្ទុកការងារ។

---

## 🛠️ បច្ចេកវិទ្យាប្រើប្រាស់ (Tech Stack)

- **Frontend**: Flutter 3.x (Web, macOS Desktop, Tablet/iPad)
- **Typography**: [Google Fonts Kantumruy Pro](https://fonts.google.com/specimen/Kantumruy+Pro)
- **State Management**: Flutter Riverpod 3 (Notifier Architecture)
- **QR Standard**: EMVCo Bakong KHQR (NBC Standard) + CRC16 Generator
- **Printing**: PDF / 80mm ESC/POS Thermal Printing (`printing`, `pdf`)
- **Backend / Database**: Google Cloud Firestore (NoSQL Real-time Sync & Offline Cache)
- **Hosting / CI/CD**: Firebase Hosting & GitHub Actions (Auto-deploy on push)
- **Live Production URL**: [https://kitluy-pos.web.app](https://kitluy-pos.web.app)

---

## 🚀 របៀបតម្លើង និងដំណើរការ (Getting Started)

### ១. Clone គម្រោង
```bash
git clone https://github.com/vrvanreth-alt/kitluy-pos.git
cd "KITLUY POS"
```

### ២. ទាញយក Dependencies
```bash
flutter pub get
```

### ៣. ដំណើរការលើ Chrome Web
```bash
flutter run -d chrome
```

### ៤. ឬដំណើរការលើ macOS Desktop
```bash
flutter run -d macos
```

### ៥. Build សម្រាប់ Production Web Server
```bash
flutter build web --release
```

---

## 🗄️ Database Setup (Google Cloud Firestore)
ប្រព័ន្ធប្រើប្រាស់ **Google Cloud Firestore (NoSQL Real-time)** ដែលមានទីតាំង Datacenter នៅ **Singapore (`asia-southeast1`)** ជិតប្រទេសកម្ពុជាបំផុត៖
- **Auto-Seeding**: នៅពេលដំណើរការកម្មវិធីលើកដំបូង ប្រព័ន្ធនឹងបញ្ចូលទំនិញស្វ័យប្រវត្តិចូលទៅក្នុង Firestore Collections (`products`)
- **Offline Mode**: គាំទ្រការលក់សូម្បីតែដាច់អ៊ីនធឺណិត (Offline Persistence) ហើយ Auto-Sync នៅពេលមានអ៊ីនធឺណិតឡើងវិញ
- **Atomic Stock Deduction**: កាត់ស្តុកទំនិញភ្លាមៗពេលចេញវិក្កយបត្រ (Firestore Batch Transactions)
- **Security Rules**: កំណត់នៅក្នុង [`firestore.rules`](firestore.rules)

---

## 📄 License
MIT License. Developed with ❤️ for Cambodian auto shops and garages.
