<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String userRole = (currentUser != null) ? currentUser.getRole() : "GUEST";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help Center & Patient FAQ - Sunrise Dental Clinic</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8fafc; }
        .faq-content { transition: max-height 0.3s ease-in-out, opacity 0.3s ease-in-out; }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between">

    <!-- Header Navigation -->
    <jsp:include page="shared-nav.jsp" />

    <!-- Main Content -->
    <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
        
        <!-- Banner -->
        <div class="bg-gradient-to-r from-teal-700 via-teal-600 to-emerald-600 rounded-3xl p-8 text-white shadow-xl mb-8 relative overflow-hidden">
            <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                <div>
                    <span class="px-3 py-1 bg-white/20 text-white rounded-full text-xs font-extrabold uppercase tracking-wider mb-3 inline-block">
                        <i class="fa-solid fa-circle-question mr-1"></i> Patient Support & Knowledge Base
                    </span>
                    <h1 class="text-3xl font-black tracking-tight">Help Center & Frequently Asked Questions</h1>
                    <p class="text-xs text-teal-100 mt-2 max-w-2xl leading-relaxed font-medium">
                        Find instant answers regarding online appointment booking, doctor schedules, LankaQR payments, fee breakdowns, and cancellation policies.
                    </p>
                </div>
                <div class="flex items-center space-x-3 bg-white/10 backdrop-blur-md px-5 py-3 rounded-2xl border border-white/20">
                    <div class="w-10 h-10 rounded-xl bg-white text-teal-700 flex items-center justify-center font-bold text-lg shadow-sm">
                        <i class="fa-solid fa-headset"></i>
                    </div>
                    <div>
                        <span class="text-[10px] uppercase font-extrabold text-teal-200 tracking-wider block">Clinic Helpline</span>
                        <span class="text-sm font-bold text-white">+94 11 234 5678</span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Quick Operational Guides (4 Role Cards) -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
                <div class="w-10 h-10 bg-teal-100 text-teal-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-user-plus"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">1. Patient Registration</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    Create a secure profile with your NIC, phone, and email. Prefills all booking details automatically.
                </p>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
                <div class="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-calendar-plus"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">2. Appointment Booking</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    Pick your dentist, treatment, and time slot. Add-on services calculate live. Blocked leave dates are prevented.
                </p>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
                <div class="w-10 h-10 bg-sky-100 text-sky-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-user-clock"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">3. Doctor Availability</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    Dentists manage leave dates directly. Real-time availability alerts prevent double-booking.
                </p>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-md transition-shadow">
                <div class="w-10 h-10 bg-purple-100 text-purple-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">4. QR & Billing Portal</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    Pay via Cash, Card, or LankaQR. Cashiers approve payments and print verified digital QR receipts.
                </p>
            </div>
        </div>

        <!-- FAQ Section -->
        <div class="bg-white rounded-3xl border border-slate-100 shadow-sm p-6 sm:p-8 mb-8">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-8 pb-6 border-b border-slate-100">
                <div>
                    <h2 class="text-xl font-black text-slate-900 flex items-center">
                        <i class="fa-solid fa-comments-question text-teal-600 mr-2.5"></i> Frequently Asked Questions by Patients
                    </h2>
                    <p class="text-xs text-slate-500 mt-1 font-medium">Click on any question below to expand the detailed answer.</p>
                </div>
                <div class="relative w-full sm:w-72">
                    <i class="fa-solid fa-magnifying-glass absolute left-3.5 top-3 text-slate-400 text-xs"></i>
                    <input type="text" id="faqSearch" onkeyup="filterFAQ()" placeholder="Search FAQ topics..." class="w-full pl-9 pr-4 py-2 rounded-xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                </div>
            </div>

            <!-- Accordion List -->
            <div class="space-y-4" id="faqContainer">
                
                <!-- FAQ 1: How to book -->
                <div class="faq-item border border-slate-100 rounded-2xl p-5 hover:border-teal-200 transition-all bg-slate-50/50">
                    <button onclick="toggleFAQ(this)" class="w-full flex justify-between items-center text-left focus:outline-none">
                        <span class="text-sm font-bold text-slate-800 flex items-center">
                            <span class="w-7 h-7 bg-teal-100 text-teal-700 rounded-xl flex items-center justify-center text-xs mr-3 font-black">Q1</span>
                            How do I book an appointment online?
                        </span>
                        <i class="fa-solid fa-chevron-down text-slate-400 text-xs transition-transform duration-200"></i>
                    </button>
                    <div class="faq-content hidden mt-4 pt-4 border-t border-slate-200/60 text-xs font-semibold text-slate-600 leading-relaxed space-y-2">
                        <p>Booking an appointment takes less than a minute:</p>
                        <ol class="list-decimal list-inside space-y-1 text-slate-700">
                            <li>Log in to your patient account (or register if you are new).</li>
                            <li>Navigate to <strong>"Book Appointment"</strong> in the top navigation bar.</li>
                            <li>Select your preferred <strong>Dentist</strong> (e.g. Dr. Rajendra or Dr. Kobishangar).</li>
                            <li>Choose your <strong>Treatment Type</strong> (e.g. Routine Checkup, Teeth Whitening, Root Canal).</li>
                            <li>Select an available <strong>Appointment Date</strong> and <strong>Time Slot</strong> (09:00 AM, 10:30 AM, 02:00 PM, 03:30 PM).</li>
                            <li>Optionally select any clinical add-on services (Digital X-Ray, Local Anaesthesia, Fluoride).</li>
                            <li>Click <strong>"Confirm & Register Appointment"</strong>. You will receive an auto-generated Appointment Number (e.g. <code>APT-1001</code>) and instant SMS & Email confirmations!</li>
                        </ol>
                    </div>
                </div>

                <!-- FAQ 2: Doctor leave & availability -->
                <div class="faq-item border border-slate-100 rounded-2xl p-5 hover:border-teal-200 transition-all bg-slate-50/50">
                    <button onclick="toggleFAQ(this)" class="w-full flex justify-between items-center text-left focus:outline-none">
                        <span class="text-sm font-bold text-slate-800 flex items-center">
                            <span class="w-7 h-7 bg-teal-100 text-teal-700 rounded-xl flex items-center justify-center text-xs mr-3 font-black">Q2</span>
                            What happens if a doctor is on leave or unavailable?
                        </span>
                        <i class="fa-solid fa-chevron-down text-slate-400 text-xs transition-transform duration-200"></i>
                    </button>
                    <div class="faq-content hidden mt-4 pt-4 border-t border-slate-200/60 text-xs font-semibold text-slate-600 leading-relaxed">
                        <p>
                            Our system features <strong>real-time availability protection</strong>. If a doctor has scheduled leave or is attending a conference on a particular date/slot:
                        </p>
                        <ul class="list-disc list-inside mt-2 space-y-1 text-slate-700">
                            <li>An immediate warning notification pops up on your screen: <em>"Doctor is NOT AVAILABLE on this date"</em>.</li>
                            <li>The booking submit button is automatically locked to prevent invalid appointments.</li>
                            <li>You can simply pick another available date or choose our other specialist dentist.</li>
                        </ul>
                    </div>
                </div>

                <!-- FAQ 3: Payment Methods & LankaQR -->
                <div class="faq-item border border-slate-100 rounded-2xl p-5 hover:border-teal-200 transition-all bg-slate-50/50">
                    <button onclick="toggleFAQ(this)" class="w-full flex justify-between items-center text-left focus:outline-none">
                        <span class="text-sm font-bold text-slate-800 flex items-center">
                            <span class="w-7 h-7 bg-teal-100 text-teal-700 rounded-xl flex items-center justify-center text-xs mr-3 font-black">Q3</span>
                            What payment methods are accepted, and how does the QR payment work?
                        </span>
                        <i class="fa-solid fa-chevron-down text-slate-400 text-xs transition-transform duration-200"></i>
                    </button>
                    <div class="faq-content hidden mt-4 pt-4 border-t border-slate-200/60 text-xs font-semibold text-slate-600 leading-relaxed space-y-2">
                        <p>We accept 3 convenient payment methods at our billing desk:</p>
                        <ul class="list-disc list-inside space-y-1 text-slate-700">
                            <li>💵 <strong>Cash Payment:</strong> Pay directly at the cashier desk.</li>
                            <li>💳 <strong>Credit / Debit Cards:</strong> All Visa & Mastercard accepted.</li>
                            <li>📱 <strong>LankaQR Scan-to-Pay:</strong> The cashier displays a dynamic LankaQR code on screen. You can scan it instantly with any Sri Lankan banking app (Commercial Bank, BOC, Sampath Bank, FriMi, eZ Cash, etc.) to complete payment without carrying cash or cards.</li>
                        </ul>
                        <p>Once payment is verified, the cashier approves the invoice and hands you an official receipt with a digital verification QR code.</p>
                    </div>
                </div>

                <!-- FAQ 4: How to cancel an appointment -->
                <div class="faq-item border border-slate-100 rounded-2xl p-5 hover:border-teal-200 transition-all bg-slate-50/50">
                    <button onclick="toggleFAQ(this)" class="w-full flex justify-between items-center text-left focus:outline-none">
                        <span class="text-sm font-bold text-slate-800 flex items-center">
                            <span class="w-7 h-7 bg-teal-100 text-teal-700 rounded-xl flex items-center justify-center text-xs mr-3 font-black">Q4</span>
                            Can I cancel my appointment if my plans change?
                        </span>
                        <i class="fa-solid fa-chevron-down text-slate-400 text-xs transition-transform duration-200"></i>
                    </button>
                    <div class="faq-content hidden mt-4 pt-4 border-t border-slate-200/60 text-xs font-semibold text-slate-600 leading-relaxed">
                        <p>
                            Yes. Log in and open the <strong>"Appointments"</strong> page to view your active bookings. Click the red <strong>"Cancel"</strong> button next to the appointment. The system will update your appointment status to <em>CANCELLED</em>, automatically remove the pending bill from the cashier queue, and notify clinic observers.
                        </p>
                    </div>
                </div>

                <!-- FAQ 5: Pricing Breakdown -->
                <div class="faq-item border border-slate-100 rounded-2xl p-5 hover:border-teal-200 transition-all bg-slate-50/50">
                    <button onclick="toggleFAQ(this)" class="w-full flex justify-between items-center text-left focus:outline-none">
                        <span class="text-sm font-bold text-slate-800 flex items-center">
                            <span class="w-7 h-7 bg-teal-100 text-teal-700 rounded-xl flex items-center justify-center text-xs mr-3 font-black">Q5</span>
                            How are treatment costs and add-ons calculated?
                        </span>
                        <i class="fa-solid fa-chevron-down text-slate-400 text-xs transition-transform duration-200"></i>
                    </button>
                    <div class="faq-content hidden mt-4 pt-4 border-t border-slate-200/60 text-xs font-semibold text-slate-600 leading-relaxed">
                        <p>
                            We follow 100% transparent pricing using our Dynamic Fee Calculator:
                        </p>
                        <ul class="list-disc list-inside mt-2 space-y-1 text-slate-700">
                            <li><strong>Base Treatment Fee:</strong> Routine Checkup (LKR 3,000), Dental Filling (LKR 4,500), Teeth Whitening (LKR 8,000), Root Canal (LKR 15,000), Braces (LKR 45,000).</li>
                            <li><strong>Optional Add-on Care:</strong> Digital X-Ray (+LKR 1,500), Local Anaesthesia (+LKR 700), Fluoride Treatment (+LKR 2,000), Hygiene Kit (+LKR 1,500).</li>
                            <li><strong>Standard Clinic Registration:</strong> LKR 500 per visit.</li>
                        </ul>
                    </div>
                </div>

            </div>
        </div>

        <!-- Contact & Emergency Support Banner -->
        <div class="bg-white rounded-3xl border border-slate-100 shadow-sm p-6 flex flex-col sm:flex-row justify-between items-center gap-4">
            <div class="flex items-center space-x-4">
                <div class="w-12 h-12 bg-teal-100 text-teal-700 rounded-2xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-envelope-open-text"></i>
                </div>
                <div>
                    <h4 class="text-sm font-extrabold text-slate-900">Still have questions or need clinical assistance?</h4>
                    <p class="text-xs text-slate-500 font-medium mt-0.5">Reach out to our customer care team at <span class="text-teal-600 font-bold">support@sunrisedental.com</span></p>
                </div>
            </div>
            <a href="register-appointment.jsp" class="px-5 py-3 bg-teal-600 hover:bg-teal-700 text-white font-bold rounded-2xl text-xs uppercase tracking-wider transition-all shadow-md">
                Book an Appointment Now
            </a>
        </div>

    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Patient Knowledge Base & Support Portal
    </footer>

    <script>
        function toggleFAQ(button) {
            const content = button.nextElementSibling;
            const icon = button.querySelector('i');
            
            if (content.classList.contains('hidden')) {
                content.classList.remove('hidden');
                icon.classList.add('rotate-180');
            } else {
                content.classList.add('hidden');
                icon.classList.remove('rotate-180');
            }
        }

        function filterFAQ() {
            const query = document.getElementById('faqSearch').value.toLowerCase();
            const items = document.querySelectorAll('.faq-item');

            items.forEach(item => {
                const text = item.innerText.toLowerCase();
                if (text.includes(query)) {
                    item.style.display = '';
                } else {
                    item.style.display = 'none';
                }
            });
        }
    </script>
</body>
</html>
