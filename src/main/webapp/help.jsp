<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Operational Manual - Sunrise Dental Clinic</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8fafc; }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between">

    <!-- Header Navigation -->
    <jsp:include page="shared-nav.jsp" />

    <!-- Main Content -->
    <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
        
        <!-- Banner -->
        <div class="bg-gradient-to-r from-teal-700 to-emerald-600 rounded-3xl p-8 text-white shadow-xl mb-8 relative overflow-hidden">
            <div class="relative z-10">
                <span class="px-3 py-1 bg-white/20 text-white rounded-full text-xs font-extrabold uppercase tracking-wider mb-3 inline-block">
                    <i class="fa-solid fa-circle-question mr-1"></i> System Manual & User Guidance
                </span>
                <h1 class="text-3xl font-black tracking-tight">Staff & Patient Operational Manual</h1>
                <p class="text-xs text-teal-100 mt-2 max-w-2xl leading-relaxed font-medium">
                    Learn how to navigate multi-role access, patient self-registration, doctor leave scheduling, and cashier billing.
                </p>
            </div>
        </div>

        <!-- Help Modules Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                <div class="w-10 h-10 bg-teal-100 text-teal-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-user-plus"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">1. Patient Self-Registration</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    New patients can click 'Register' to create a patient profile. Once registered, patients log in to book appointments directly.
                </p>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                <div class="w-10 h-10 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-calendar-plus"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">2. Appointment Booking</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    Select dentist, treatment type, date, and time. Add-on costs calculate live. Blocked doctor leave dates automatically disable submission.
                </p>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                <div class="w-10 h-10 bg-sky-100 text-sky-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-user-clock"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">3. Doctor Leave Schedule</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    Doctors log in to mark leave dates or unavailable time slots, ensuring patients cannot schedule appointments during leave periods.
                </p>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                <div class="w-10 h-10 bg-purple-100 text-purple-600 rounded-2xl flex items-center justify-center text-lg mb-3">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <h3 class="text-sm font-bold text-slate-800">4. Cashier Billing Portal</h3>
                <p class="text-xs text-slate-500 mt-1 leading-relaxed">
                    Cashiers view treatment fees, add-on costs, mark payments as PAID (Cash/Card), and print itemized customer receipts.
                </p>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | User Guidance Manual
    </footer>

</body>
</html>
