//
//  getData.swift
//  wellSync
//
//  Created by Vidit Agarwal on 14/03/26.
//

import Foundation

var moodLogs: [MoodLog] = [
    
    // Today
    MoodLog(logId: UUID(), patientId: UUID(), mood: 4,
            date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    MoodLog(logId: UUID(), patientId: UUID(), mood: 3,
            date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    
    // Yesterday
    MoodLog(logId: UUID(), patientId: UUID(), mood: 2,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    MoodLog(logId: UUID(), patientId: UUID(), mood: 3,
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    
    // 2 days ago
    MoodLog(logId: UUID(), patientId: UUID(), mood: 5,
            date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    
    // 3 days ago
    MoodLog(logId: UUID(), patientId: UUID(), mood: 1,
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    MoodLog(logId: UUID(), patientId: UUID(), mood: 2,
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    
    // 4 days ago
    MoodLog(logId: UUID(), patientId: UUID(), mood: 3,
            date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    
    // 5 days ago
    MoodLog(logId: UUID(), patientId: UUID(), mood: 4,
            date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
            moodNote: nil, selectedFeeling: []),
    
    
    // 6 days ago
    MoodLog(logId: UUID(), patientId: UUID(), mood: 2,
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
            moodNote: nil, selectedFeeling: [])
]
let docID = UUID(uuidString: "6bf94a4d-cc66-4d87-a90d-be2500434e3d")!
var currentDoctor: Doctor?
var globalDoctor: [Doctor] = [
    Doctor(
        docID: docID,
        username: "admin",
        email: "meera.kumari@clinic.com",
        password: "Doc@1234",
        name: "Dr. Meera Kumari",
        dob: makeDate(1990, 3, 15),
        address: "Bengaluru, Karnataka",
        experience: 15,
        doctorImage: "profile",
        qualification: "MBBS, MD (Psychiatry)",
        registrationNumber: "KMC-2005-04821",
        identityNumber: "AADHAAR-9876-5432-1012",
        educationImageData: "image",
        registrationImageData: "image",
        identityImageData: "image"
    ),
    Doctor(
        docID: UUID(),
        username: "dr.priya_mehta",
        email: "priya.mehta@clinic.com",
        password: "Doc@1234",
        name: "Dr. Priya Mehta",
        dob: makeDate(1990, 3, 15),
        address: "45, Linking Road, Mumbai, Maharashtra",
        experience: 10,
        doctorImage: "Image",
        qualification: "MBBS, DPM (Psychological Medicine)",
        registrationNumber: "MMC-2010-07634",
        identityNumber: "AADHAAR-8765-4321-0923",
        educationImageData: "image",
        registrationImageData: "image",
        identityImageData: "image"
    ),
    Doctor(
        docID: UUID(),
        username: "dr.rohan_verma",
        email: "rohan.verma@clinic.com",
        password: "Doc@1234",
        name: "Dr. Rohan Verma",
        dob: makeDate(1990, 3, 15),
        address: "7, Sector 18, Noida, Uttar Pradesh",
        experience: 20,
        doctorImage: "Image 1",
        qualification: "MBBS, MD (Neurology), Fellowship in Psychiatry",
        registrationNumber: "DMC-2003-03312",
        identityNumber: "AADHAAR-7654-3210-8834",
        educationImageData: nil,
        registrationImageData: nil,
        identityImageData: nil
    ),
    Doctor(
        docID: UUID(),
        username: "dr.sneha_iyer",
        email: "sneha.iyer@clinic.com",
        password: "Doc@1234",
        name: "Dr. Sneha Iyer",
        dob: makeDate(1990, 3, 15),
        address: "23, Anna Nagar, Chennai, Tamil Nadu",
        experience: 8,
        doctorImage: "Image",
        qualification: "MBBS, MD (Psychiatry), CBT Certified",
        registrationNumber: "TNMC-2015-09821",
        identityNumber: "AADHAAR-6543-2109-7745",
        educationImageData: nil,
        registrationImageData: nil,
        identityImageData: nil
    ),
    Doctor(
        docID: UUID(),
        username: "dr.kabir_nair",
        email: "kabir.nair@clinic.com",
        password: "Doc@1234",
        name: "Dr. Kabir Nair",
        dob: makeDate(1990, 3, 15),
        address: "8, Indiranagar, Bengaluru, Karnataka",
        experience: 25,
        doctorImage: "Image 1",
        qualification: "MBBS, MD (Psychiatry), PhD (Clinical Psychology)",
        registrationNumber: "KMC-2000-01123",
        identityNumber: "AADHAAR-5432-1098-6656",
        educationImageData: nil,
        registrationImageData: nil,
        identityImageData: nil
    )
]
var globalPatient: [Patient] = [
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, docID: docID,
        name: "Aarav Sharma", email: "aarav.sharma@email.com", password: "Pass@1234",
        contact: "+91-9876543210",
        dob: makeDate(1990, 3, 15),
        nextSessionDate: makeDate(2026, 3, 17, hour: 10, minute: 0),
        imageURL: "https://picsum.photos/200.jpg", address: "12, MG Road, Bengaluru, Karnataka",
        condition: "Generalized Anxiety Disorder", sessionStatus: true, mood: 6,
        previousSessionDate: makeDate(2025, 3, 15, hour: 10, minute: 0)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!, docID: docID,
        name: "Priya Mehta", email: "priya.mehta@email.com", password: "Pass@1234",
        contact: "+91-9823456789",
        dob: makeDate(1995, 7, 22),
        nextSessionDate: makeDate(2026, 3, 17, hour: 11, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "45, Linking Road, Mumbai, Maharashtra",
        condition: "Major Depressive Disorder", sessionStatus: false, mood: 3,
        previousSessionDate: makeDate(2025, 3, 20, hour: 11, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!, docID: docID,
        name: "Rohan Verma", email: "rohan.verma@email.com", password: "Pass@1234",
        contact: "+91-9845671234",
        dob: makeDate(1988, 11, 5),
        nextSessionDate: makeDate(2026, 3, 17, hour: 9, minute: 0),
        imageURL: "https://picsum.photos/200.jpg", address: "7, Sector 18, Noida, Uttar Pradesh",
        condition: "PTSD", sessionStatus: true, mood: 5,
        previousSessionDate: makeDate(2025, 3, 22, hour: 9, minute: 0)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!, docID: docID,
        name: "Sneha Iyer", email: "sneha.iyer@email.com", password: "Pass@1234",
        contact: "+91-9901234567",
        dob: makeDate(1993, 1, 30),
        nextSessionDate: makeDate(2026, 3, 17, hour: 14, minute: 15),
        imageURL: "https://picsum.photos/200.jpg", address: "23, Anna Nagar, Chennai, Tamil Nadu",
        condition: "Bipolar Disorder", sessionStatus: nil, mood: 7,
        previousSessionDate: makeDate(2025, 3, 24, hour: 14, minute: 15)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!, docID: docID,
        name: "Kabir Nair", email: "kabir.nair@email.com", password: "Pass@1234",
        contact: "+91-9812345678",
        dob: makeDate(1985, 6, 18),
        nextSessionDate: makeDate(2026, 3, 17, hour: 16, minute: 0),
        imageURL: "https://picsum.photos/200.jpg", address: "8, Indiranagar, Bengaluru, Karnataka",
        condition: "OCD", sessionStatus: true, mood: 4,
        previousSessionDate: makeDate(2025, 3, 25, hour: 16, minute: 0)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!, docID: docID,
        name: "Ananya Gupta", email: "ananya.gupta@email.com", password: "Pass@1234",
        contact: "+91-9867345612",
        dob: makeDate(1997, 9, 12),
        nextSessionDate: makeDate(2026, 3, 16, hour: 10, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "56, Civil Lines, Delhi",
        condition: "Social Anxiety Disorder", sessionStatus: false, mood: 5,
        previousSessionDate: makeDate(2025, 3, 27, hour: 10, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!, docID: docID,
        name: "Vikram Singh", email: "vikram.singh@email.com", password: "Pass@1234",
        contact: "+91-9754321098",
        dob: makeDate(1982, 4, 25),
        nextSessionDate: makeDate(2026, 3, 16, hour: 13, minute: 0),
        imageURL: "https://picsum.photos/200.jpg", address: "34, Banjara Hills, Hyderabad, Telangana",
        condition: "Schizophrenia", sessionStatus: true, mood: 2,
        previousSessionDate: makeDate(2025, 3, 28, hour: 13, minute: 0)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!, docID: docID,
        name: "Meera Pillai", email: "meera.pillai@email.com", password: "Pass@1234",
        contact: "+91-9934567821",
        dob: makeDate(1991, 12, 8),
        nextSessionDate: makeDate(2026, 3, 16, hour: 15, minute: 45),
        imageURL: "https://picsum.photos/200.jpg", address: "19, Thrissur Road, Kochi, Kerala",
        condition: "Panic Disorder", sessionStatus: nil, mood: 6,
        previousSessionDate: makeDate(2025, 3, 29, hour: 15, minute: 45)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!, docID: docID,
        name: "Arjun Desai", email: "arjun.desai@email.com", password: "Pass@1234",
        contact: "+91-9878901234",
        dob: makeDate(1994, 2, 14),
        nextSessionDate: makeDate(2026, 3, 16   , hour: 11, minute: 0),
        imageURL: "https://picsum.photos/200.jpg", address: "88, CG Road, Ahmedabad, Gujarat",
        condition: "ADHD", sessionStatus: true, mood: 8,
        previousSessionDate: makeDate(2025, 3, 31, hour: 11, minute: 0)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!, docID: docID,
        name: "Divya Reddy", email: "divya.reddy@email.com", password: "Pass@1234",
        contact: "+91-9745678903",
        dob: makeDate(1996, 8, 27),
        nextSessionDate: makeDate(2026, 4, 16, hour: 9, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "67, Jubilee Hills, Hyderabad, Telangana",
        condition: "Eating Disorder", sessionStatus: false, mood: 4,
        previousSessionDate: makeDate(2025, 4, 1, hour: 9, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!, docID: docID,
        name: "Nikhil Joshi", email: "nikhil.joshi@email.com", password: "Pass@1234",
        contact: "+91-9823109876",
        dob: makeDate(1989, 5, 3),
        nextSessionDate: makeDate(2026, 4, 16, hour: 12, minute: 0),
        imageURL: "https://picsum.photos/200.jpg", address: "14, Shivajinagar, Pune, Maharashtra",
        condition: "Insomnia Disorder", sessionStatus: true, mood: 5,
        previousSessionDate: makeDate(2025, 4, 2, hour: 12, minute: 0)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!, docID: docID,
        name: "Pooja Kapoor", email: "pooja.kapoor@email.com", password: "Pass@1234",
        contact: "+91-9867098765",
        dob: makeDate(1992, 10, 16),
        nextSessionDate: makeDate(2026, 4, 16, hour: 14, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "3, Rajouri Garden, New Delhi",
        condition: "Borderline Personality Disorder", sessionStatus: nil, mood: 3,
        previousSessionDate: makeDate(2026, 4, 3, hour: 14, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!, docID: docID,
        name: "Rahul Banerjee", email: "rahul.banerjee@email.com", password: "Pass@1234",
        contact: "+91-9812098765",
        dob: makeDate(1987, 3, 4),
        nextSessionDate: makeDate(2026, 4, 16, hour: 10, minute: 15),
        imageURL: "https://picsum.photos/200.jpg", address: "22, Salt Lake, Kolkata, West Bengal",
        condition: "Substance Use Disorder", sessionStatus: true, mood: 4,
        previousSessionDate: makeDate(2025, 4, 4, hour: 10, minute: 15)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!, docID: docID,
        name: "Ishita Malhotra", email: "ishita.malhotra@email.com", password: "Pass@1234",
        contact: "+91-9798765432",
        dob: makeDate(1998, 6, 2),
        nextSessionDate: makeDate(2026, 4, 16, hour: 11, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "9, Vasant Vihar, New Delhi",
        condition: "Dysthymia", sessionStatus: false, mood: 5,
        previousSessionDate: makeDate(2025, 4, 5, hour: 11, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!, docID: docID,
        name: "Siddharth Rao", email: "siddharth.rao@email.com", password: "Pass@1234",
        contact: "+91-9765432109",
        dob: makeDate(1990, 9, 17),
        nextSessionDate: makeDate(2026, 4, 16, hour: 13, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "5, Koramangala, Bengaluru, Karnataka",
        condition: "Adjustment Disorder", sessionStatus: true, mood: 6,
        previousSessionDate: makeDate(2025, 4, 7, hour: 13, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!, docID: docID,
        name: "Kavya Menon", email: "kavya.menon@email.com", password: "Pass@1234",
        contact: "+91-9745123456",
        dob: makeDate(1993, 4, 11),
        nextSessionDate: makeDate(2025, 4, 22, hour: 15, minute: 0),
        imageURL: "https://picsum.photos/200.jpg", address: "11, Marathahalli, Bengaluru, Karnataka",
        condition: "Agoraphobia", sessionStatus: nil, mood: 4,
        previousSessionDate: makeDate(2025, 4, 8, hour: 15, minute: 0)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000017")!, docID: docID,
        name: "Aditya Kulkarni", email: "aditya.kulkarni@email.com", password: "Pass@1234",
        contact: "+91-9856234567",
        dob: makeDate(1986, 7, 29),
        nextSessionDate: makeDate(2025, 4, 23, hour: 9, minute: 45),
        imageURL: "https://picsum.photos/200.jpg", address: "78, Deccan Gymkhana, Pune, Maharashtra",
        condition: "Narcissistic Personality Disorder", sessionStatus: true, mood: 3,
        previousSessionDate: makeDate(2025, 4, 9, hour: 9, minute: 45)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000018")!, docID: docID,
        name: "Riya Saxena", email: "riya.saxena@email.com", password: "Pass@1234",
        contact: "+91-9934123456",
        dob: makeDate(1999, 2, 5),
        nextSessionDate: makeDate(2025, 4, 24, hour: 16, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "33, Hazratganj, Lucknow, Uttar Pradesh",
        condition: "Separation Anxiety Disorder", sessionStatus: false, mood: 7,
        previousSessionDate: makeDate(2025, 4, 10, hour: 16, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000019")!, docID: docID,
        name: "Manish Tiwari", email: "manish.tiwari@email.com", password: "Pass@1234",
        contact: "+91-9823456701",
        dob: makeDate(1984, 12, 22),
        nextSessionDate: makeDate(2025, 4, 25, hour: 8, minute: 30),
        imageURL: "https://picsum.photos/200.jpg", address: "6, Alkapuri, Vadodara, Gujarat",
        condition: "Intermittent Explosive Disorder", sessionStatus: true, mood: 2,
        previousSessionDate: makeDate(2025, 4, 11, hour: 8, minute: 30)
    ),
    Patient(
        patientID: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!, docID: docID,
        name: "Simran Kaur", email: "simran.kaur@email.com", password: "Pass@1234",
        contact: "+91-9878123456",
        dob: makeDate(1995, 5, 14),
        nextSessionDate: makeDate(2025, 4, 26, hour: 12, minute: 15),
        imageURL: "https://picsum.photos/200.jpg", address: "21, Sector 17, Chandigarh",
        condition: "Specific Phobia",  sessionStatus: nil, mood: 8,
        previousSessionDate: makeDate(2025, 4, 12, hour: 12, minute: 15)
    )
]
var globalSession: [SessionNote] = [

    // ══════════════════════════════════════════
    // Feb 1, 2026 — 3 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        date: makeDate(2026, 2, 1, hour: 9, minute: 0),
        notes: """
        Patient presents for annual wellness check. Blood pressure 122/78 mmHg, heart rate 72 bpm, BMI 24.6. \
        Reports occasional fatigue after work but otherwise no significant complaints. \
        Full blood count, lipid panel, fasting glucose, and thyroid function ordered as baseline. \
        Last dental and ophthalmology reviews were over 2 years ago – referrals sent. \
        Discussed importance of regular physical activity: currently sedentary at desk job 9 hours/day. \
        Recommended at least 150 minutes of moderate aerobic exercise per week. \
        Alcohol intake within safe limits. Non-smoker. Flu vaccine administered today. \
        Patient in good spirits. Review scheduled after blood results return in 2 weeks.
        """,
        images: nil,
        voice: nil,
        title: "Annual Wellness Check – Baseline Investigations"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        date: makeDate(2026, 2, 1, hour: 11, minute: 0),
        notes: """
        Patient is a 41-year-old female with a 3-week history of sharp, stabbing chest pain on the left side, \
        worse on deep inspiration and when lying flat. No radiation to arm or jaw. No exertional component. \
        Vitals stable. ECG shows saddle-shaped ST elevation across multiple leads, consistent with pericarditis. \
        Troponin mildly elevated at 0.04 ng/mL. Echo arranged urgently to exclude effusion. \
        Started ibuprofen 600 mg TDS with colchicine 0.5 mg BD as per ESC pericarditis protocol. \
        Advised complete rest and avoidance of strenuous physical activity for at least 3 months. \
        Cardiology review booked for next week. Cause likely viral; autoimmune and TB screen ordered. \
        Patient anxious – fully counselled on expected 4–6 week recovery timeline.
        """,
        images: "ecg_p2_pericarditis.pdf",
        voice: "voice_p2_s1.m4a",
        title: "Acute Pericarditis – Ibuprofen & Colchicine Initiated"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
        date: makeDate(2026, 2, 1, hour: 14, minute: 0),
        notes: """
        Patient is a 55-year-old male presenting with a 6-week history of progressive difficulty walking, \
        lower limb stiffness, and frequent tripping. Wife reports he has developed a shuffling gait and reduced arm swing. \
        Examination reveals bradykinesia, cogwheel rigidity bilaterally, and resting tremor of the right hand. \
        Postural reflexes mildly impaired. Cognitive screening (MMSE 28/30) within normal limits. \
        Clinical picture consistent with early Parkinson's Disease. \
        Urgent neurology referral made. MRI brain ordered to exclude structural causes. \
        DaTSCAN arranged through neurology. Levodopa/carbidopa not yet initiated pending specialist assessment. \
        Patient and wife counselled sensitively about the suspected diagnosis and the importance of the specialist review. \
        Physiotherapy and occupational therapy referrals sent in anticipation.
        """,
        images: nil,
        voice: nil,
        title: "Suspected Early Parkinson's Disease – Neurology Referral"
    ),

    // ══════════════════════════════════════════
    // Feb 3, 2026 — 2 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        date: makeDate(2026, 2, 3, hour: 9, minute: 30),
        notes: """
        Follow-up for recurrent lower urinary tract infections. Patient is a 33-year-old female with 4 UTIs in the past 12 months. \
        Current episode: dysuria, frequency, and suprapubic discomfort for 3 days. MSU sent. \
        Started trimethoprim 200 mg BD empirically for 7 days. \
        Renal tract ultrasound reviewed – no structural abnormality, no hydronephrosis. \
        Vaginal pH and swab taken to exclude bacterial vaginosis and candida as co-contributors. \
        Discussed post-coital antibiotic prophylaxis and evening low-dose prophylaxis options. \
        Advised on hydration, voiding after intercourse, and avoiding spermicidal products. \
        Urology referral submitted for further evaluation and cystoscopy if recurrence continues. \
        Review in 6 weeks with culture sensitivities.
        """,
        images: nil,
        voice: "voice_p4_s1.m4a",
        title: "Recurrent UTI Management – Prophylaxis Discussion"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        date: makeDate(2026, 2, 3, hour: 14, minute: 0),
        notes: """
        Patient is a 67-year-old male presenting with a 4-month history of progressive memory decline noted by his wife. \
        He repeats questions, forgets recent events, and has started misplacing items frequently. \
        No significant change in personality. No focal neurological deficits. MMSE score: 22/30. \
        MoCA: 18/30 – significant impairment in delayed recall and attention. \
        Bloods ordered: TFTs, B12, folate, LFTs, renal function, glucose, FBC – to exclude reversible causes. \
        MRI brain with contrast ordered. CT head preliminary ordered due to wait time for MRI. \
        Referred to memory clinic for formal neuropsychological assessment. \
        Family counselled on safety at home: removing trip hazards, supervising medication. \
        Driving safety raised – patient currently still driving; DVLA notification process discussed. \
        Follow-up after imaging and memory clinic appointment.
        """,
        images: nil,
        voice: nil,
        title: "Progressive Memory Decline – Dementia Workup"
    ),

    // ══════════════════════════════════════════
    // Feb 5, 2026 — 4 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
        date: makeDate(2026, 2, 5, hour: 9, minute: 0),
        notes: """
        Patient is a 28-year-old female presenting with a 2-month history of joint pains affecting hands, wrists, and knees, \
        associated with prolonged morning stiffness of more than 45 minutes. Mild photosensitive facial rash noted on cheeks. \
        Fatigue and hair thinning reported. No oral ulcers currently. \
        ANA titre 1:320 (positive, homogeneous pattern). Anti-dsDNA pending. Complement C3/C4 ordered. \
        Urine dipstick: 1+ protein. 24-hour urine protein and renal function requested. \
        Clinical picture highly suggestive of Systemic Lupus Erythematosus. \
        Urgent rheumatology referral submitted. Hydroxychloroquine 200 mg BD initiated pending specialist review. \
        Sun protection and avoidance counselled strongly. NSAIDs for joint pain in the short term. \
        Patient informed sensitively; literature and specialist nursing contact provided.
        """,
        images: "rash_p6_malar.jpg",
        voice: "voice_p6_s1.m4a",
        title: "Suspected SLE – Rheumatology Referral"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        date: makeDate(2026, 2, 5, hour: 10, minute: 30),
        notes: """
        Paediatric patient aged 9, brought in by father. Presenting with 5-day history of widespread itchy rash \
        appearing as fluid-filled blisters on trunk, scalp, and face. Temperature 38.1°C. \
        Clinical diagnosis: chickenpox (varicella). Not previously vaccinated. \
        Lesions at various stages: papules, vesicles, and some crusted. No involvement of eyes or mouth mucosa. \
        Acyclovir not indicated in uncomplicated childhood varicella per current guidelines. \
        Advised chlorphenamine for itch relief, paracetamol for fever, and calamine lotion. \
        Strict isolation until all lesions crusted (approximately 5 more days). School exclusion letter provided. \
        Siblings reviewed – one not vaccinated; varicella-zoster immunoglobulin not indicated as healthy child. \
        Parents advised on warning signs: breathing difficulty, confusion, secondary skin infection. \
        Chickenpox vaccination discussed for immunisation catch-up post-recovery.
        """,
        images: "rash_p7_varicella.jpg",
        voice: nil,
        title: "Chickenpox – Paediatric Management & Isolation"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
        date: makeDate(2026, 2, 5, hour: 13, minute: 0),
        notes: """
        Patient is a 48-year-old male presenting with a sudden onset severe headache, described as the worst headache of his life, \
        reaching peak intensity within seconds. Associated with neck stiffness and photophobia. \
        No fever at this point. No focal neurological deficit. Blood pressure 168/102 mmHg (likely reactive). \
        Thunderclap headache pattern – urgent CT head arranged immediately. \
        CT head report: hyperdensity in the basal cisterns consistent with subarachnoid haemorrhage. \
        Patient transferred to emergency department immediately. \
        Neurosurgery alerted. CTA brain ordered to identify aneurysmal source. \
        Nimodipine 60 mg 4-hourly initiated for vasospasm prevention per protocol. \
        Family contacted and updated. Complete documentation recorded for handover.
        """,
        images: "ct_p8_sah.jpg",
        voice: "voice_p8_s1.m4a",
        title: "Thunderclap Headache – SAH Identified & Emergency Transfer"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000019")!,
        date: makeDate(2026, 2, 5, hour: 15, minute: 0),
        notes: """
        Patient is a 36-year-old male with a 2-year history of intermittent abdominal cramping, bloating, and alternating \
        constipation and diarrhoea. Symptoms worsen with stress and improve partially after defecation. \
        No rectal bleeding, no unintentional weight loss, no nocturnal symptoms. \
        Rome IV criteria for Irritable Bowel Syndrome (IBS-M) met. \
        Coeliac serology (anti-TTG IgA) negative. FBC, CRP, and stool calprotectin normal – inflammatory bowel disease effectively excluded. \
        Commenced low-FODMAP dietary trial with dietitian referral. Mebeverine 135 mg TDS prescribed for cramps. \
        Explained the gut-brain axis role in IBS. Stress management and CBT referral offered. \
        Patient relieved serious pathology excluded. Symptom diary recommended for 4 weeks. \
        Review in 6 weeks to assess dietary response.
        """,
        images: nil,
        voice: nil,
        title: "IBS-M Diagnosis – Low FODMAP & Mebeverine"
    ),

    // ══════════════════════════════════════════
    // Feb 7, 2026 — 2 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
        date: makeDate(2026, 2, 7, hour: 9, minute: 30),
        notes: """
        Patient is a 72-year-old female presenting with a 3-week history of right hip pain and difficulty weight-bearing \
        following a minor fall on icy ground 3 weeks ago. \
        She initially dismissed the pain but it has progressively worsened with limited range of movement on examination. \
        X-ray right hip: subcapital neck of femur fracture, undisplaced. \
        Patient transferred urgently to orthopaedics for surgical fixation. \
        FRAX score calculated: 10-year hip fracture risk 18% – alendronate indicated post-operatively. \
        Calcium 1000 mg and vitamin D 800 IU commenced immediately. \
        Pre-operative bloods, ECG, and anaesthetic review arranged. \
        Physiotherapy to commence early post-surgery. \
        Falls risk assessment completed: polypharmacy reviewed, antihypertensives adjusted. \
        Daughter informed and present; advanced care preferences documented.
        """,
        images: "xray_p10_hip.jpg",
        voice: nil,
        title: "Undisplaced Neck of Femur Fracture – Orthopaedic Transfer"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
        date: makeDate(2026, 2, 7, hour: 14, minute: 0),
        notes: """
        Patient is a 25-year-old female presenting with a 6-month history of acne vulgaris affecting the face, chest, and back. \
        Multiple inflammatory papules, pustules, and 3 deeper nodules on the jaw. Scarring beginning to form. \
        Previous trials of benzoyl peroxide and topical clindamycin: inadequate response after 3 months. \
        Prescribed combined topical adapalene 0.1% and benzoyl peroxide 2.5% gel nightly. \
        Added oral doxycycline 100 mg OD for 3 months to reduce inflammatory burden. \
        Discussed contraception: patient on combined pill, adequate. \
        Isotretinoin discussed as next step if nodular acne does not respond in 3 months. \
        Patient counselled on isotretinoin teratogenicity and mandatory Pregnancy Prevention Programme requirements. \
        Dermatology referral submitted. Advised strict sun protection with topical retinoids. \
        Review in 12 weeks with photo documentation.
        """,
        images: "acne_p11.jpg",
        voice: "voice_p11_s1.m4a",
        title: "Moderate-Severe Acne – Isotretinoin Pathway Discussion"
    ),

    // ══════════════════════════════════════════
    // Feb 10, 2026 — 3 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
        date: makeDate(2026, 2, 10, hour: 9, minute: 0),
        notes: """
        Patient is a 60-year-old female with longstanding Type 2 Diabetes and hypertension, presenting for routine quarterly review. \
        HbA1c: 7.1% (well controlled). Blood pressure 128/80 mmHg. eGFR 72. Urine ACR 3.1 mg/mmol (normal). \
        Weight stable. No hypoglycaemic episodes reported. \
        Foot examination: no active ulcers; reduced monofilament sensation at both first metatarsal heads bilaterally. \
        Peripheral neuropathy progression documented. Referred to podiatry for high-risk foot surveillance. \
        Ophthalmology screen completed last month: background retinopathy, non-proliferative, monitoring only. \
        Statin dose reviewed – atorvastatin 40 mg continued. LDL 1.9 mmol/L (at target). \
        Flu and COVID-19 vaccinations up to date. Patient remains motivated. \
        Review in 3 months; repeat HbA1c and renal function.
        """,
        images: "foot_p12.jpg",
        voice: nil,
        title: "Diabetic Quarterly Review – Peripheral Neuropathy Noted"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
        date: makeDate(2026, 2, 10, hour: 11, minute: 30),
        notes: """
        Patient is a 19-year-old male presenting with a 4-day history of high fever (39.6°C), severe sore throat, \
        fatigue, and bilateral posterior cervical lymphadenopathy. Bilateral tonsillar enlargement with exudate. \
        Spleen tip palpable on examination. \
        Monospot test positive. FBC: atypical lymphocytes 22%. \
        Diagnosis: Infectious Mononucleosis (Epstein-Barr Virus). \
        Amoxicillin avoided due to risk of widespread rash in EBV. \
        Paracetamol and ibuprofen for symptomatic relief. Advised rest and adequate hydration. \
        Strict avoidance of contact sports and heavy lifting for minimum 4 weeks due to risk of splenic rupture. \
        Patient is a rugby player – counselled clearly that return to sport requires spleen to be non-palpable and ultrasound clearance. \
        LFTs ordered: mild transaminitis expected. Return if worsening dysphagia or respiratory difficulty.
        """,
        images: nil,
        voice: "voice_p13_s1.m4a",
        title: "Infectious Mononucleosis – Splenic Precautions"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!,
        date: makeDate(2026, 2, 10, hour: 14, minute: 30),
        notes: """
        Patient is a 44-year-old male presenting with a 3-month history of progressive shortness of breath on exertion, \
        dry cough, and mild ankle swelling. No chest pain. No orthopnoea or PND. \
        Previously well. Non-smoker. BMI 31. \
        Examination: bilateral basal crepitations, mild pitting oedema to mid-shin, JVP mildly elevated. \
        ECG: left bundle branch block – new finding. \
        BNP markedly elevated at 680 pg/mL. CXR: cardiomegaly, upper lobe venous diversion. \
        Working diagnosis: new-onset heart failure with reduced ejection fraction. \
        Echo arranged urgently. Commenced furosemide 40 mg OD, ramipril 2.5 mg OD. \
        Cardiology urgent referral submitted with all results attached. \
        Patient advised sodium and fluid restriction. Daily weight monitoring explained. \
        Admitted discussion: patient preferred outpatient monitoring; agreed with clear plan to attend ED if worsens.
        """,
        images: "cxr_p14_hf.jpg",
        voice: nil,
        title: "New-Onset Heart Failure – Urgent Cardiology Referral"
    ),

    // ══════════════════════════════════════════
    // Feb 12, 2026 — 2 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!,
        date: makeDate(2026, 2, 12, hour: 10, minute: 0),
        notes: """
        Patient is a 50-year-old female presenting with post-menopausal bleeding, 14 months after her last menstrual period. \
        Single episode 3 weeks ago, lasting 2 days, light in flow. No intermenstrual bleeding previously. \
        No pelvic pain, no urinary symptoms. Smear up to date (normal 18 months ago). \
        Pelvic examination: uterus normal size, cervix healthy, no adnexal masses. \
        Transvaginal ultrasound arranged urgently: endometrial thickness to be measured. \
        Referred to gynaecology urgently on a 2-week wait pathway for endometrial biopsy. \
        Patient counselled clearly that post-menopausal bleeding requires exclusion of endometrial carcinoma \
        and that the majority of cases are due to benign atrophy. \
        CA-125 ordered. Patient instructed not to use any topical oestrogen pending investigation results. \
        Support and reassurance provided.
        """,
        images: nil,
        voice: nil,
        title: "Post-Menopausal Bleeding – Urgent Gynaecology Referral"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!,
        date: makeDate(2026, 2, 12, hour: 14, minute: 0),
        notes: """
        Patient is a 31-year-old male presenting with a 10-day history of painful, swollen right knee. \
        No trauma. Temperature 37.8°C. Knee is hot, erythematous, fluctuant effusion present. \
        Urgent aspiration performed under aseptic technique: 30 mL of turbid yellow fluid aspirated. \
        Synovial fluid sent for urgent Gram stain, MC&S, crystal analysis, and cell count. \
        Patient commenced on IV flucloxacillin 2g QDS empirically pending Gram stain – admitted to medical ward. \
        Blood cultures taken. CRP 148 mg/L. WBC 16.2 × 10⁹/L. \
        Orthopaedics alerted for surgical washout if culture confirms septic arthritis or if no clinical improvement in 24 hours. \
        Risk factors explored: recent skin infection, no sexual history suggesting gonococcal source, no IVDU. \
        X-ray knee: joint space preserved, soft tissue swelling. \
        Patient and family updated on seriousness of septic arthritis and need for inpatient treatment.
        """,
        images: "xray_p16_knee.jpg",
        voice: "voice_p16_s1.m4a",
        title: "Septic Arthritis Right Knee – Aspiration & IV Antibiotics"
    ),

    // ══════════════════════════════════════════
    // Feb 14, 2026 — 4 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000017")!,
        date: makeDate(2026, 2, 14, hour: 9, minute: 0),
        notes: """
        Patient is a 39-year-old female referred by optician following incidental finding of elevated intraocular pressure \
        bilaterally (R: 26 mmHg, L: 24 mmHg) on routine eye test. No symptoms. \
        Visual fields: subtle nasal step defect noted on automated perimetry in the right eye. \
        No family history of glaucoma. No corticosteroid use. \
        Clinical findings consistent with Primary Open Angle Glaucoma, early stage. \
        Referred to ophthalmology urgently for formal gonioscopy, optic disc photography, and OCT nerve fibre layer analysis. \
        Latanoprost 0.005% eye drops prescribed as first-line IOP-lowering agent: one drop each eye at night. \
        Patient counselled on glaucoma being a silent, chronic condition. Explained lifelong treatment likely required. \
        Advised on correct eye drop instillation technique to avoid systemic absorption. \
        Reassured that early detection affords excellent prognosis.
        """,
        images: nil,
        voice: nil,
        title: "Early Glaucoma Detected – Ophthalmology Referral"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000018")!,
        date: makeDate(2026, 2, 14, hour: 10, minute: 30),
        notes: """
        Patient is a 53-year-old male with a 3-month history of right-sided neck swelling, mild dysphagia, \
        and a 4 kg unintentional weight loss. He is a 30 pack-year smoker with a history of regular alcohol use. \
        On examination: 3 cm firm, non-tender lymph node at level II right neck. Oropharynx clear on inspection. \
        Urgent 2-week wait head and neck cancer pathway activated. \
        CT neck and chest with contrast ordered. \
        Panendoscopy (nasopharyngoscopy, laryngoscopy) arranged by ENT. \
        PET-CT likely to follow staging. \
        HPV-associated oropharyngeal cancer considered in differential alongside squamous cell carcinoma of unknown primary. \
        Bloods: FBC, LFTs, LDH, TFTs sent. \
        Patient informed sensitively of the need to urgently exclude malignancy. Smoking cessation discussed. \
        Partner present; both given cancer nurse specialist contact number. \
        Alcohol reduction strongly advised.
        """,
        images: nil,
        voice: "voice_p18_s1.m4a",
        title: "Neck Mass & Dysphagia – 2WW Head & Neck Cancer Pathway"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000019")!,
        date: makeDate(2026, 2, 14, hour: 13, minute: 0),
        notes: """
        Patient is a 22-year-old university student presenting with a 2-week low mood, loss of interest in activities, \
        reduced concentration, disrupted sleep (sleeping 11-12 hours but still exhausted), and low motivation. \
        No appetite change. No suicidal ideation or self-harm. No previous psychiatric history. \
        Precipitants: academic pressure, social isolation, and recent relationship breakdown. \
        PHQ-9: 15 (moderately severe depression). GAD-7: 8 (mild anxiety). \
        Commenced sertraline 50 mg once daily. Counselled on delayed onset (2–4 weeks) and initial side effects. \
        Registered with university wellbeing service and student counselling. \
        Advised on sleep hygiene, regular meals, and light exercise. Safety netting: clear instructions given on \
        worsening suicidal thoughts to contact crisis line or attend ED. \
        Written safety plan provided. Review in 2 weeks.
        """,
        images: nil,
        voice: nil,
        title: "New-Onset Moderate Depression – Sertraline & Wellbeing Referral"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
        date: makeDate(2026, 2, 14, hour: 15, minute: 0),
        notes: """
        Patient is a 47-year-old female presenting with a 3-week history of right upper quadrant discomfort, \
        particularly after fatty meals, associated with nausea and one episode of vomiting. No fever. No jaundice. \
        Murphy's sign positive on examination. Ultrasound abdomen performed: multiple gallstones identified, \
        gallbladder wall thickened at 4.2 mm, no bile duct dilatation, no free fluid. \
        LFTs: mildly elevated ALP and GGT; bilirubin and ALT normal. \
        Diagnosis: symptomatic gallstone disease / biliary colic. \
        Referred to general surgery for elective laparoscopic cholecystectomy. \
        Ursodeoxycholic acid not indicated given surgical candidacy. \
        Low-fat diet advised to reduce symptom frequency while awaiting surgery. \
        Advised to attend ED if sharp, severe RUQ pain with fever, rigors, or jaundice develops (cholecystitis risk). \
        Patient comfortable with plan.
        """,
        images: "us_p20_gallstones.jpg",
        voice: "voice_p20_s1.m4a",
        title: "Symptomatic Gallstones – Surgical Referral"
    ),

    // ══════════════════════════════════════════
    // Feb 17, 2026 — 2 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        date: makeDate(2026, 2, 17, hour: 9, minute: 30),
        notes: """
        Review of blood results from wellness check on Feb 1. TSH: 0.9 mIU/L (normal). \
        Fasting glucose: 5.8 mmol/L (impaired fasting glucose, pre-diabetic range). \
        LDL cholesterol: 3.6 mmol/L. HDL: 1.3 mmol/L. Total cholesterol: 5.7 mmol/L. \
        10-year cardiovascular risk score: 8% (intermediate risk). \
        HbA1c ordered to confirm pre-diabetes status. Lifestyle intervention commenced: Mediterranean diet counselling, \
        weight reduction of 5-7% target, 150 min moderate exercise per week as primary intervention for pre-diabetes. \
        Statin therapy discussed but deferred pending 3-month lifestyle trial. \
        Patient motivated and receptive. Given structured pre-diabetes education programme referral. \
        Home glucose monitoring not yet initiated – will reconsider if HbA1c confirms pre-diabetes. \
        Ophthalmology and dental review confirmed booked. Review in 3 months.
        """,
        images: nil,
        voice: nil,
        title: "Impaired Fasting Glucose – Pre-Diabetes Lifestyle Programme"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        date: makeDate(2026, 2, 17, hour: 14, minute: 0),
        notes: """
        Pericarditis follow-up at 2 weeks. Patient reports significant improvement in chest pain, now 2/10 at rest. \
        No breathlessness at rest. Mild discomfort with deep breath persists. \
        Echo result reviewed: trivial pericardial effusion, no tamponade, normal LV systolic function. \
        CRP reduced from 68 to 22 mg/L – good response to anti-inflammatory therapy. \
        Autoimmune screen negative. TB IGRA negative. Viral aetiology most likely. \
        Ibuprofen being tolerated well. Colchicine continued for full 3-month course as per protocol to prevent recurrence. \
        Activity restriction reinforced – no gym, running, or heavy exercise until CRP normalises and symptoms resolve. \
        Cardiology review attended: confirmed management plan, repeat echo in 6 weeks. \
        Patient informed that recurrence rate is 15-30% after first episode; colchicine adherence is critical. \
        Next review in 4 weeks with repeat CRP.
        """,
        images: nil,
        voice: "voice_p2_s2.m4a",
        title: "Pericarditis 2-Week Review – Improving on Treatment"
    ),

    // ══════════════════════════════════════════
    // Feb 19, 2026 — 3 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
        date: makeDate(2026, 2, 19, hour: 9, minute: 0),
        notes: """
        Neurology review attended for suspected Parkinson's Disease. DaTSCAN report: reduced dopamine transporter \
        uptake in bilateral putamen, right greater than left – consistent with degenerative parkinsonism. \
        Neurologist has confirmed diagnosis of Parkinson's Disease, Hoehn and Yahr Stage 2. \
        Levodopa/carbidopa 100/25 mg TDS initiated by neurology. \
        Patient returned to our clinic for co-management coordination. \
        Parkinson's Disease nurse specialist allocated and first appointment confirmed. \
        SALT referral for swallowing assessment given mild dysphagia complaints. \
        Physiotherapy commenced: gait training, balance exercises, fall prevention. \
        Occupational therapy home visit arranged for safety modifications and adaptive aids. \
        DVLA notified as per guidance; patient voluntarily surrendered driving licence. Wife is primary carer. \
        Patient adjusting emotionally; referred to Parkinson's UK support group.
        """,
        images: nil,
        voice: "voice_p3_s2.m4a",
        title: "Parkinson's Disease Confirmed – Levodopa Initiated"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
        date: makeDate(2026, 2, 19, hour: 11, minute: 0),
        notes: """
        UTI follow-up. MSU culture result: E. coli, sensitive to trimethoprim – appropriate antibiotic confirmed. \
        Patient reports complete resolution of dysuria and frequency by day 5. \
        Vaginal swab: no BV or candida identified. \
        Discussed long-term prophylaxis options to prevent further recurrence: low-dose nitrofurantoin 50 mg nightly \
        or post-coital nitrofurantoin 100 mg. \
        Patient opted for post-coital prophylaxis given infection pattern correlating with intercourse. \
        Nitrofurantoin 100 mg post-coital prescribed with supply for 6 months. \
        Renal function confirmed normal before prescribing nitrofurantoin. G6PD deficiency excluded. \
        Topical oestrogen discussed as adjunct – deferred; patient pre-menopausal. \
        Cranberry extract discussed: evidence modest but patient may try if desired. \
        Urology appointment confirmed in 6 weeks.
        """,
        images: nil,
        voice: nil,
        title: "Recurrent UTI – Post-Coital Prophylaxis Commenced"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
        date: makeDate(2026, 2, 19, hour: 14, minute: 30),
        notes: """
        Memory clinic review attended. Formal neuropsychological testing confirmed moderate cognitive impairment \
        in multiple domains: episodic memory, visuospatial function, and executive processing. \
        MRI brain: cortical atrophy predominantly in temporal and parietal lobes bilaterally; no vascular lesions. \
        Reversible causes excluded: TFTs, B12, folate, glucose all normal. \
        Clinical diagnosis: Alzheimer's Disease, mild-moderate stage. \
        Donepezil 5 mg once nightly commenced. Counselled on titration to 10 mg after 4 weeks if tolerated. \
        Patient and wife counselled at length about the diagnosis, prognosis, and available support. \
        Lasting Power of Attorney discussed urgently given current capacity. \
        Memory support worker allocated. Carers' assessment for wife arranged. \
        Driving licence surrendered. Safety assessment at home completed. \
        Review in 6 weeks for medication tolerability and dose titration.
        """,
        images: "mri_p5_alzheimers.jpg",
        voice: "voice_p5_s2.m4a",
        title: "Alzheimer's Disease Diagnosed – Donepezil Initiated"
    ),

    // ══════════════════════════════════════════
    // Feb 21, 2026 — 2 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
        date: makeDate(2026, 2, 21, hour: 9, minute: 30),
        notes: """
        Rheumatology review attended. Anti-dsDNA positive at high titre. C3 22 mg/dL, C4 6 mg/dL – both low. \
        24-hour urine protein: 820 mg/day (significant proteinuria). Serum creatinine mildly elevated at 102 µmol/L. \
        Renal biopsy arranged for LN classification. \
        Pending biopsy: prednisolone 0.5 mg/kg/day commenced for active SLE. \
        Mycophenolate mofetil 500 mg BD initiated as steroid-sparing agent. Hydroxychloroquine dose increased to 400 mg OD. \
        Gastric protection: omeprazole 20 mg OD with steroids. \
        BP monitoring: target below 130/80 mmHg given proteinuria; ramipril 5 mg OD commenced. \
        Contraception review: current combined OCP stopped due to SLE thrombosis risk; \
        switched to progesterone-only pill and referred to gynaecology for coil discussion. \
        Occupational health letter written. Follow-up in 2 weeks post-biopsy.
        """,
        images: nil,
        voice: "voice_p6_s2.m4a",
        title: "SLE with Lupus Nephritis – MMF & Steroid Initiated"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
        date: makeDate(2026, 2, 21, hour: 14, minute: 0),
        notes: """
        Chickenpox follow-up at day 16. All lesions now crusted and healing well. No secondary bacterial infection. \
        No eye involvement confirmed by mother. Fever resolved day 6. Child back at school since day 12. \
        Mother reports child had one night of intense itching with secondary scratching – counselled on keeping nails short \
        and continuing antihistamine at night for another week if needed. \
        Chickenpox vaccination for the unvaccinated sibling discussed: recommended 2 doses, 4–8 weeks apart, \
        to complete catch-up immunisation as per UK schedule. \
        Varicella serology available if immunity status unclear in older family members. \
        No complications documented. Shingles risk in adulthood discussed briefly with parent. \
        No further follow-up required for this episode.
        """,
        images: nil,
        voice: nil,
        title: "Chickenpox Recovery – Sibling Vaccination Arranged"
    ),

    // ══════════════════════════════════════════
    // Feb 24, 2026 — 4 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
        date: makeDate(2026, 2, 24, hour: 9, minute: 0),
        notes: """
        Post-neurosurgical review following SAH and successful coil embolisation of right posterior communicating artery aneurysm. \
        Patient discharged from neurosurgical unit 12 days ago. Now presents for GP review and rehabilitation coordination. \
        Clinically improved; no new neurological deficits. Mild fatigue and concentration difficulties reported. \
        Nimodipine course completed. Blood pressure 138/88 mmHg – ramipril 5 mg OD commenced for cerebrovascular protection. \
        Aspirin not indicated post-SAH. \
        Referred to community neurological rehabilitation team for cognitive and functional recovery support. \
        Driving ban explained: DVLA requires minimum 6 months seizure-free with neurosurgical clearance. \
        Patient on 3-month sick leave; phased return-to-work plan discussed with occupational health. \
        Patient and spouse both given post-SAH psychological support referral. \
        Follow-up in 4 weeks; repeat MRA brain in 6 months via neurosurgery.
        """,
        images: nil,
        voice: "voice_p8_s2.m4a",
        title: "Post-SAH Follow-Up – Rehabilitation Coordination"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000009")!,
        date: makeDate(2026, 2, 24, hour: 10, minute: 30),
        notes: """
        IBS review at 6 weeks. Patient has been trialling low-FODMAP diet for 4 weeks with dietitian support. \
        Significant improvement in bloating and cramping (symptom score reduced 60%). \
        Diarrhoea frequency reduced from 4 times/day to once daily. Still some discomfort with wheat and onion. \
        Mebeverine continuing with good effect. \
        Low-FODMAP reintroduction phase started: systematically reintroducing food groups one at a time. \
        Stress acknowledged as a trigger: patient commenced mindfulness app (Headspace) and reports benefit. \
        CBT waitlist confirmed – 6-week wait. \
        Patient educated on long-term IBS management: dietary modifications, avoiding triggers, and \
        understanding that IBS does not increase risk of bowel cancer. \
        Discussed probiotics: some evidence for certain strains; patient may try Lactobacillus-based supplement. \
        Review in 3 months unless symptoms worsen.
        """,
        images: nil,
        voice: nil,
        title: "IBS 6-Week Review – Low-FODMAP Reintroduction Phase"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
        date: makeDate(2026, 2, 24, hour: 13, minute: 0),
        notes: """
        Post-operative review 3 weeks following right dynamic hip screw fixation for subcapital NOF fracture. \
        Wound healed well. Mobilising with frame on physiotherapy input. No surgical site infection. \
        Haemoglobin post-op: 9.8 g/dL (expected post-surgical anaemia). Iron supplementation continued. \
        Alendronate 70 mg weekly commenced for osteoporosis treatment. DEXA scan arranged. \
        Calcium and vitamin D ongoing. \
        Physiotherapy: partial weight-bearing progressing to full weight-bearing this week. \
        Occupational therapist completed home visit: stair rail fitted, bath seat arranged, bed height adjusted. \
        Falls multidisciplinary team review scheduled. Antihypertensive regimen adjusted to avoid orthostatic hypotension. \
        District nurse visiting daily. Daughter coordinates care at home. \
        Target: independent walking with stick by 6 weeks. Review in 3 weeks.
        """,
        images: nil,
        voice: "voice_p10_s2.m4a",
        title: "Post-NOF Fracture Surgery Review – Rehabilitation Progress"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000011")!,
        date: makeDate(2026, 2, 24, hour: 15, minute: 0),
        notes: """
        Acne review at 12 weeks. Significant improvement in inflammatory lesions on face and chest. \
        Nodular lesions on jaw reduced from 3 to 1, with post-inflammatory hyperpigmentation remaining. \
        Doxycycline completed 3-month course – stopping today. \
        Adapalene/BPO gel continued nightly; well tolerated with mild initial peeling now settled. \
        Dermatology appointment attended: isotretinoin recommended given nodular residual disease and early scarring. \
        Pregnancy prevention programme documentation completed: negative pregnancy test today, \
        two forms of contraception confirmed (combined pill + condoms), iPLEDGE-equivalent consent signed. \
        Isotretinoin 30 mg OD commenced (0.5 mg/kg/day starting dose). \
        Monthly LFTs and fasting lipids required. \
        Patient counselled on dry skin, lips, and eyes – emollients and lip balm prescribed. \
        Strongly advised no vitamin A supplements, waxing, or laser procedures during treatment. \
        Monthly review mandatory for isotretinoin monitoring.
        """,
        images: "acne_p11_wk12.jpg",
        voice: "voice_p11_s2.m4a",
        title: "Acne – Isotretinoin Commenced, iPLEDGE Completed"
    ),

    // ══════════════════════════════════════════
    // Feb 26, 2026 — 2 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000012")!,
        date: makeDate(2026, 2, 26, hour: 9, minute: 30),
        notes: """
        Podiatry review attended: feet classified as high-risk diabetic foot. \
        Thick callus over both first metatarsal heads where monofilament sensation reduced. \
        No active ulceration. Circulation: dorsalis pedis and posterior tibial pulses present bilaterally. \
        ABPI 1.0 bilaterally. Podiatry to review 3-monthly. \
        Patient reviewed for new symptom: intermittent burning pain in both feet at night, disturbing sleep. \
        Consistent with diabetic peripheral neuropathy. \
        Commenced amitriptyline 10 mg nocte for neuropathic pain; will titrate slowly. \
        Alternatives (gabapentin, duloxetine) discussed if amitriptyline not tolerated. \
        HbA1c optimisation remains key: patient reminded that tighter glycaemic control slows neuropathy progression. \
        Diabetic footwear prescription issued. \
        Capsaicin cream offered but patient declined. Review in 4 weeks for pain response.
        """,
        images: nil,
        voice: nil,
        title: "Diabetic Neuropathic Pain – Amitriptyline Initiated"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000013")!,
        date: makeDate(2026, 2, 26, hour: 14, minute: 0),
        notes: """
        Infectious mononucleosis review at 16 days. Fever fully resolved. Fatigue significantly improved. \
        Tonsils reducing in size, no further exudate. Lymphadenopathy persisting but reducing. \
        Repeat FBC: atypical lymphocytes 8% (down from 22%). LFTs: ALT 68 U/L (was 112 U/L), improving. \
        Spleen ultrasound performed: 14.2 cm – still enlarged. Sport restriction continued. \
        Student informed that return to rugby is not permitted until spleen measures less than 12 cm on repeat ultrasound \
        and he is asymptomatic; earliest repeat scan in 3 weeks. \
        Fatigue expected to persist 4–8 weeks; patient warned about post-viral fatigue syndrome risk. \
        Back to university lectures permitted as tolerated. \
        Advised no alcohol until LFTs fully normalised. \
        Patient frustrated by restrictions – counselled empathetically with written information leaflet. \
        Review in 3 weeks with repeat spleen ultrasound and LFTs.
        """,
        images: nil,
        voice: "voice_p13_s2.m4a",
        title: "Mono Recovery – Splenomegaly Persisting, Sports Ban Continued"
    ),

    // ══════════════════════════════════════════
    // Mar 3, 2026 — 3 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000014")!,
        date: makeDate(2026, 3, 3, hour: 9, minute: 0),
        notes: """
        Heart failure review 3 weeks post-diagnosis. Echo result available: dilated cardiomyopathy, EF 32%, \
        global hypokinesia, no significant valvular disease, no pericardial effusion. \
        Cardiology review attended: confirmed HFrEF (heart failure with reduced ejection fraction). \
        Cardiology has up-titrated ramipril to 5 mg BD and commenced carvedilol 3.125 mg BD. \
        Furosemide 40 mg OD continues. Eplerenone 25 mg OD added per cardiology recommendation. \
        Electrolytes monitored: potassium 4.6 mmol/L, creatinine 118 µmol/L. \
        Daily weight monitoring reinforced – patient has gained 1.5 kg this week (fluid). Furosemide dose adjusted to 40 mg BD temporarily. \
        Cardiac rehabilitation programme referral submitted. \
        ICD/CRT discussion deferred: will reassess after 3 months of optimal medical therapy. \
        Driving: DVLA notified as per HF guidance. Alcohol strongly advised against. \
        Patient coping better emotionally. Next review in 3 weeks with repeat echo in 3 months.
        """,
        images: nil,
        voice: nil,
        title: "HFrEF Follow-Up – Carvedilol & Eplerenone Added"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000015")!,
        date: makeDate(2026, 3, 3, hour: 11, minute: 0),
        notes: """
        Gynaecology 2-week wait review attended and results discussed in this consultation. \
        Transvaginal ultrasound: endometrial thickness 6.8 mm (borderline). \
        Endometrial pipelle biopsy performed by gynaecology: result – endometrial hyperplasia without atypia (no malignancy). \
        Gynaecologist recommends 3-month course of Mirena coil (levonorgestrel-releasing IUS) as first-line treatment. \
        Patient consented and coil inserted in gynaecology clinic. \
        Follow-up biopsy in 6 months to confirm regression. \
        Risk factors discussed: BMI 32, no HRT use, no PCOS. \
        Weight loss strongly advised as it reduces endogenous oestrogen excess. \
        Bariatric pathway discussed; BMI clinic referral submitted. \
        Patient reassured that no cancer found; however, hyperplasia without atypia has a small malignant potential \
        and compliance with 6-month follow-up biopsy is essential. \
        Review in 3 months for symptom check.
        """,
        images: nil,
        voice: "voice_p15_s2.m4a",
        title: "Endometrial Hyperplasia (No Atypia) – Mirena Coil Inserted"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000016")!,
        date: makeDate(2026, 3, 3, hour: 14, minute: 0),
        notes: """
        Septic arthritis follow-up. Synovial fluid culture: Staphylococcus aureus, MSSA, sensitive to flucloxacillin. \
        Patient completed 2 weeks IV flucloxacillin in hospital; now on oral flucloxacillin 1g QDS for 4 more weeks. \
        Knee significantly improved: no effusion, range of motion 0–110°, minimal residual warmth. \
        CRP reduced from 148 to 18 mg/L. WBC normalised. \
        Source identified: patient recalls a small skin cut on the shin 2 weeks before presentation. \
        Echocardiogram performed to exclude endocarditis: no vegetations, structurally normal valves. \
        Bone scan showed no osteomyelitis involvement. \
        Physiotherapy commenced: quadriceps strengthening and range of motion exercises. \
        Patient counselled on antibiotic course completion – no early stopping. \
        Risk of long-term joint damage from septic arthritis discussed. \
        Follow-up in 4 weeks; rheumatology to review if joint inflammation persists after infection clears.
        """,
        images: nil,
        voice: "voice_p16_s2.m4a",
        title: "Septic Arthritis – MSSA, Oral Antibiotics & Physiotherapy"
    ),

    // ══════════════════════════════════════════
    // Mar 10, 2026 — 2 Sessions
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000017")!,
        date: makeDate(2026, 3, 10, hour: 9, minute: 30),
        notes: """
        Ophthalmology review results discussed. OCT nerve fibre layer: thinning at superior and inferior poles of right optic disc. \
        Gonioscopy: open angles bilaterally. Visual field test: confirmed nasal step in right eye, left eye normal. \
        Diagnosis confirmed: Primary Open Angle Glaucoma, early right, suspect left. \
        Latanoprost reviewed: IOP now R: 18 mmHg, L: 19 mmHg – good response to drops. \
        Ophthalmology monitoring: every 4 months for visual field and disc photography initially. \
        Patient reports occasional stinging with drops – reassured, normal initially, resolves with time. \
        Checked technique: correct. Advised to use preservative-free formulation if irritation persists. \
        Patient's first-degree relatives advised to get IOP screening as glaucoma has hereditary component. \
        Systemic health check: blood pressure 118/72 mmHg (low normal BP can worsen POAG). \
        No medication changes needed at this stage. Next GP review in 6 months.
        """,
        images: nil,
        voice: nil,
        title: "Glaucoma – Latanoprost Effective, IOP Controlled"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000018")!,
        date: makeDate(2026, 3, 10, hour: 14, minute: 0),
        notes: """
        Neck mass results review. CT neck/chest: 3.2 cm right level II lymph node with necrotic centre, \
        no other nodal disease, no pulmonary metastases. \
        PET-CT performed: isolated right neck node uptake only, no primary tumour identified in the oropharynx, larynx, or nasopharynx. \
        Panendoscopy by ENT: bilateral tonsillectomy performed to identify occult primary; \
        histology returned p16-positive squamous cell carcinoma in right tonsil. \
        Diagnosis: HPV-positive oropharyngeal squamous cell carcinoma, cT1N1M0 (Stage I by AJCC 8th edition HPV-positive criteria). \
        Prognosis excellent: 3-year OS >85% with concurrent chemoradiation. \
        MDT decision: concurrent cisplatin and intensity-modulated radiotherapy (IMRT). \
        Oncology appointment confirmed. Dental review prior to radiotherapy essential. \
        Swallowing and nutritional assessment by SALT and dietitian. PEG tube placement discussed. \
        Patient counselled on treatment side effects. Smoking and alcohol cessation essential.
        """,
        images: "ct_p18_neck.jpg",
        voice: "voice_p18_s2.m4a",
        title: "HPV+ Oropharyngeal SCC Confirmed – Chemoradiation Planned"
    ),

    // ══════════════════════════════════════════
    // Mar 15, 2026 — 2 Sessions (Today)
    // ══════════════════════════════════════════

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000019")!,
        date: makeDate(2026, 3, 15, hour: 10, minute: 0),
        notes: """
        Depression 2-week review. Patient reports moderate improvement in sleep quality (now 7–8 hours). \
        Mood slightly better on most days but still experiencing episodes of profound low mood 2–3 times per week. \
        Sertraline 50 mg tolerated well: mild initial nausea in week 1 resolved. \
        No suicidal ideation or self-harm. PHQ-9 today: 11 (moderate – down from 15 at initiation). \
        Trajectory positive but dose increase considered. Sertraline increased to 100 mg OD. \
        University wellbeing service contact made; counselling waitlist confirmed at 3 weeks. \
        Social engagement improved slightly – attended one student society meeting this week. \
        Behavioural activation techniques discussed in depth: pleasure and achievement activities, \
        setting small manageable daily goals. Sleep hygiene reviewed – consistent wake time maintained. \
        Safety net remains in place. Next review in 4 weeks.
        """,
        images: nil,
        voice: nil,
        title: "Depression Review – Sertraline Increased to 100mg"
    ),

    SessionNote(
        sessionId: UUID(),
        patientId: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
        date: makeDate(2026, 3, 15, hour: 14, minute: 0),
        notes: """
        Gallstone follow-up. Patient awaiting elective laparoscopic cholecystectomy (listed, expected within 8 weeks). \
        Since last appointment, patient had one episode of more severe RUQ pain lasting 4 hours with rigors and temperature 38.3°C. \
        She managed at home and fever resolved by next morning. \
        Examination today: mild RUQ tenderness, no guarding, no jaundice. CRP 14 mg/L (mildly elevated). LFTs: ALP 112 U/L (mildly raised). \
        Repeat ultrasound arranged urgently: concerns about developing acute cholecystitis or Mirizzi syndrome. \
        General surgery contacted to expedite surgery given recent febrile episode consistent with acute cholecystitis. \
        Discussed risk of common bile duct stone migration (choledocholithiasis) – MRCP ordered if ALP rises further. \
        Antibiotic treatment: amoxicillin-clavulanate 625 mg TDS for 5 days given for current episode. \
        Patient advised to attend ED immediately for fever, jaundice, or severe unremitting pain. \
        Surgery team to contact patient within 48 hours to bring forward operative date.
        """,
        images: nil,
        voice: "voice_p20_s2.m4a",
        title: "Gallstone Complication – Cholecystitis Episode, Surgery Expedited"
    ),
]

let patientP1 = UUID(uuidString: "00000000-0000-0000-0000-000000000008")!
let patientP2 = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
let patientP3 = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!

let activityCatalog: [Activity] = [

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!,
        doctorID: docID,
        name: "Morning Walk",
        type: .timer,
        iconName: "figure.walk",
        description: "A brisk 20-minute morning walk to improve cardiovascular fitness and blood pressure control."
    ),

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000002")!,
        doctorID: docID,
        name: "Breathing Exercise",
        type: .timer,
        iconName: "lungs.fill",
        description: "Diaphragmatic breathing exercise to reduce anxiety and improve lung capacity. Inhale 4s, hold 4s, exhale 6s."
    ),

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000003")!,
        doctorID: docID,
        name: "Journaling",
        type: .upload,
        iconName: "camera.fill",
        description: "Upload handwritten journals."
    ),

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000004")!,
        doctorID: docID,
        name: "Art",
        type: .upload,
        iconName: "heart.text.square.fill",
        description: "Create mandala art with your imagination."
    ),

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000005")!,
        doctorID: docID,
        name: "Physiotherapy Stretches",
        type: .timer,
        iconName: "figure.cooldown",
        description: "Perform the prescribed lower back stretching routine. Hold each stretch for 30 seconds, 3 repetitions."
    ),

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000006")!,
        doctorID: docID,
        name: "Medication Photo Confirmation",
        type: .upload,
        iconName: "pills.fill",
        description: "Upload a photo of your medication blister pack after taking your evening dose for adherence tracking."
    ),

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000007")!,
        doctorID: docID,
        name: "Balance Training",
        type: .timer,
        iconName: "figure.stand",
        description: "Stand on one foot with eyes open for 30 seconds each side. Repeat 3 times to improve proprioception."
    ),

    Activity(
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000008")!,
        doctorID: docID,
        name: "Rash / Skin Photo Upload",
        type: .upload,
        iconName: "eye.fill",
        description: "Upload a daily photo of the affected skin area under natural light for dermatology remote review."
    ),
]

// MARK: - Assigned Activities (doctor → patient assignments)

let assignedActivities: [AssignedActivity] = [

    // ── Patient P1: Lower back rehab ───────────────────────────

    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000001")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!, // Morning Walk
        patientID: patientP1,
        doctorID: docID,
        frequency: 1,
        startDate: makeDate(2026, 2, 17, hour: 0, minute: 0),
        endDate:   makeDate(2026, 3, 17, hour: 0, minute: 0),
        doctorNote: "Start with 10 minutes if pain is above 5/10. Increase to 20 minutes by week 2.",
        status: .active
    ),

    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000002")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000005")!, // Physio Stretches
        patientID: patientP1,
        doctorID: docID,
        frequency: 2,
        startDate: makeDate(2026, 2, 17, hour: 0, minute: 0),
        endDate:   makeDate(2026, 3, 17, hour: 0, minute: 0),
        doctorNote: "Do once in the morning and once before bed. Stop immediately if sharp shooting pain occurs.",
        status: .active
    ),

    // Completed (past) assignment for P1
    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000003")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000004")!, // BP Reading
        patientID: patientP1,
        doctorID: docID,
        frequency: 1,
        startDate: makeDate(2026, 2, 1, hour: 0, minute: 0),
        endDate:   makeDate(2026, 2, 14, hour: 0, minute: 0),
        doctorNote: "Record morning BP before any medication. Upload photo of monitor screen.",
        status: .completed
    ),

    // ── Patient P2: Anxiety & cardiac recovery ─────────────────

    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000004")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000002")!, // Breathing Exercise
        patientID: patientP2,
        doctorID: docID,
        frequency: 3,
        startDate: makeDate(2026, 2, 1, hour: 0, minute: 0),
        endDate:   makeDate(2026, 3, 1, hour: 0, minute: 0),
        doctorNote: "Do morning, afternoon, and before bed. Use the 4-4-6 pattern. Log each session.",
        status: .active
    ),

    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000005")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000006")!, // Medication Photo
        patientID: patientP2,
        doctorID: docID,
        frequency: 1,
        startDate: makeDate(2026, 2, 1, hour: 0, minute: 0),
        endDate:   makeDate(2026, 4, 1, hour: 0, minute: 0),
        doctorNote: "Colchicine adherence is critical for pericarditis. Upload photo every evening after taking dose.",
        status: .active
    ),

    // ── Patient P3: Parkinson's balance ────────────────────────

    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000006")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000007")!, // Balance Training
        patientID: patientP3,
        doctorID: docID,
        frequency: 2,
        startDate: makeDate(2026, 2, 19, hour: 0, minute: 0),
        endDate:   makeDate(2026, 4, 19, hour: 0, minute: 0),
        doctorNote: "Only do near a wall or with a carer present. Do not attempt unsupervised if dizziness is present.",
        status: .active
    ),

    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000007")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!, // Morning Walk
        patientID: patientP3,
        doctorID: docID,
        frequency: 1,
        startDate: makeDate(2026, 2, 19, hour: 0, minute: 0),
        endDate:   makeDate(2026, 4, 19, hour: 0, minute: 0),
        doctorNote: "Walk with wife present at all times. Use walking aid provided. Focus on heel-strike gait pattern.",
        status: .active
    ),

    // Cancelled assignment for P3
    AssignedActivity(
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000008")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000005")!, // Physio Stretches
        patientID: patientP3,
        doctorID: docID,
        frequency: 2,
        startDate: makeDate(2026, 2, 19, hour: 0, minute: 0),
        endDate:   makeDate(2026, 3, 5, hour: 0, minute: 0),
        doctorNote: "Cancelled – patient reported increased rigidity; physio has revised the programme.",
        status: .cancelled
    ),
]

// MARK: - Activity Logs (patient completion records)

let activityLogs: [ActivityLog] = [

    // ── P1 logs – Morning Walk ─────────────────────────────────

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000001")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 17, hour: 8, minute: 0),
        time: "08:00 AM",
        duration: 720,   // 12 minutes
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000001")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 18, hour: 7, minute: 45),
        time: "07:45 AM",
        duration: 1080,  // 18 minutes
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000001")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 19, hour: 8, minute: 15),
        time: "08:15 AM",
        duration: 1200,  // 20 minutes
        uploadPath: nil
    ),

    // ── P1 logs – Physio Stretches (frequency 2/day) ───────────

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000002")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000005")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 17, hour: 7, minute: 0),
        time: "07:00 AM",
        duration: 600,
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000002")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000005")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 17, hour: 21, minute: 0),
        time: "09:00 PM",
        duration: 600,
        uploadPath: nil
    ),

    // Only 1 out of 2 done on Feb 18 (partially completed day)
    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000002")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000005")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 18, hour: 7, minute: 30),
        time: "07:30 AM",
        duration: 600,
        uploadPath: nil
    ),

    // ── P1 logs – BP Reading (completed assignment) ────────────

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000003")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000004")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 3, hour: 8, minute: 0),
        time: "08:00 AM",
        duration: nil,
        uploadPath: "uploads/p1/bp_20260203.jpg"
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000003")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000004")!,
        patientID: patientP1,
        date: makeDate(2026, 2, 5, hour: 8, minute: 10),
        time: "08:10 AM",
        duration: nil,
        uploadPath: "uploads/p1/bp_20260205.jpg"
    ),

    // ── P2 logs – Breathing Exercise (frequency 3/day) ─────────

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000004")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000002")!,
        patientID: patientP2,
        date: makeDate(2026, 2, 14, hour: 8, minute: 0),
        time: "08:00 AM",
        duration: 300,
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000004")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000002")!,
        patientID: patientP2,
        date: makeDate(2026, 2, 14, hour: 13, minute: 0),
        time: "01:00 PM",
        duration: 300,
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000004")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000002")!,
        patientID: patientP2,
        date: makeDate(2026, 2, 14, hour: 21, minute: 30),
        time: "09:30 PM",
        duration: 300,
        uploadPath: nil
    ),

    // ── P2 logs – Medication Upload ────────────────────────────

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000005")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000006")!,
        patientID: patientP2,
        date: makeDate(2026, 2, 14, hour: 21, minute: 0),
        time: "09:00 PM",
        duration: nil,
        uploadPath: "uploads/p2/med_20260214.jpg"
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000005")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000006")!,
        patientID: patientP2,
        date: makeDate(2026, 2, 17, hour: 21, minute: 15),
        time: "09:15 PM",
        duration: nil,
        uploadPath: "uploads/p2/med_20260217.jpg"
    ),

    // ── P3 logs – Balance Training ─────────────────────────────

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000006")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000007")!,
        patientID: patientP3,
        date: makeDate(2026, 2, 21, hour: 10, minute: 0),
        time: "10:00 AM",
        duration: 180,
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000006")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000007")!,
        patientID: patientP3,
        date: makeDate(2026, 2, 21, hour: 16, minute: 0),
        time: "04:00 PM",
        duration: 180,
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000006")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000007")!,
        patientID: patientP3,
        date: makeDate(2026, 2, 24, hour: 10, minute: 30),
        time: "10:30 AM",
        duration: 180,
        uploadPath: nil
    ),

    // ── P3 logs – Morning Walk ─────────────────────────────────

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000007")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!,
        patientID: patientP3,
        date: makeDate(2026, 2, 19, hour: 9, minute: 0),
        time: "09:00 AM",
        duration: 900,
        uploadPath: nil
    ),

    ActivityLog(
        logID: UUID(),
        assignedID: UUID(uuidString: "bbbb0000-0000-0000-0000-000000000007")!,
        activityID: UUID(uuidString: "aaaa0000-0000-0000-0000-000000000001")!,
        patientID: patientP3,
        date: makeDate(2026, 2, 21, hour: 9, minute: 15),
        time: "09:15 AM",
        duration: 1020,
        uploadPath: nil
    ),
]

func getCurrentDoctor(_ username:String){
    currentDoctor = globalDoctor.first { $0.username == username }
}

func makeDate(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0, minute: Int = 0) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = hour
    components.minute = minute
    print(Calendar.current.date(from: components)!)
    return Calendar.current.date(from: components)!
}

struct TodayActivityItem {
    let activity: Activity
    let assignment: AssignedActivity
    let completedToday: Int
    let logs: [ActivityLog]

    var remaining: Int {
        return max(0, assignment.frequency - completedToday)
    }

    var progressRatio: Float {
        guard assignment.frequency > 0 else { return 0 }
        return min(Float(completedToday) / Float(assignment.frequency), 1.0)
    }

    var isCompletedToday: Bool {
        return completedToday >= assignment.frequency
    }

    var frequencyText: String {
        return "\(completedToday) of \(assignment.frequency) done today"
    }

    var actionLabel: String {
        switch activity.type {
        case .timer:  return "Start Timer"
        case .upload: return "Upload Photo"
        }
    }
}

// MARK: - Build Today Items
func buildTodayItems(for patientID: UUID) -> [TodayActivityItem] {
    let today = Date()

    let todayAssignments = assignedActivities.filter {
        $0.patientID == patientID && $0.isActiveToday
    }

    return todayAssignments.compactMap { assignment in
        guard let activity = activityCatalog.first(where: {
            $0.activityID == assignment.activityID
        }) else { return nil }

        let todayLogs = activityLogs.filter {
            $0.assignedID == assignment.assignedID &&
            Calendar.current.isDate($0.date, inSameDayAs: today)
        }

        return TodayActivityItem(
            activity: activity,
            assignment: assignment,
            completedToday: todayLogs.count,
            logs: todayLogs
        )
    }
}
struct LogSummaryItem {
    let activity: Activity
    let totalLogs: Int
}

// MARK: - Build Log Summaries
func buildLogSummaries(for patientID: UUID) -> [LogSummaryItem] {

    let patientLogs = activityLogs.filter { $0.patientID == patientID }

    let grouped = Dictionary(grouping: patientLogs, by: { $0.activityID })

    return grouped.compactMap { (activityID, logs) in
        guard let activity = activityCatalog.first(where: {
            $0.activityID == activityID
        }) else { return nil }

        return LogSummaryItem(activity: activity, totalLogs: logs.count)
    }
    .sorted { $0.totalLogs > $1.totalLogs }
}
