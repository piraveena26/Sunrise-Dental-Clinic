<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRole = currentUser.getRole();
    String fullName = currentUser.getFullName();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Appointment Records - Sunrise Dental Clinic</title>
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
            <div class="relative z-10 flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
                <div>
                    <span class="px-3 py-1 bg-white/20 text-white rounded-full text-xs font-extrabold uppercase tracking-wider mb-3 inline-block">
                        <i class="fa-solid fa-list-check mr-1"></i> Patient Records & Memento Backup
                    </span>
                    <h1 class="text-3xl font-black tracking-tight">Registered Appointments</h1>
                    <p class="text-xs text-teal-100 mt-1 font-medium">Search, inspect, filter, or cancel appointments.</p>
                </div>
                <% if ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole)) { %>
                <a href="register-appointment.jsp" class="px-5 py-3 bg-white text-teal-800 font-extrabold rounded-2xl text-xs uppercase tracking-wider hover:bg-teal-50 transition-all shadow-md">
                    <i class="fa-solid fa-plus-circle mr-1"></i> New Booking
                </a>
                <% } %>
            </div>
        </div>

        <!-- Filter & Search Bar -->
        <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm mb-8 flex flex-col md:flex-row gap-4 justify-between items-center">
            <div class="relative w-full md:w-96">
                <i class="fa-solid fa-magnifying-glass absolute left-4 top-3.5 text-slate-400 text-xs"></i>
                <input type="text" placeholder="Search by Appointment No, Patient, or NIC..." class="w-full pl-10 pr-4 py-2.5 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
            </div>
            <div class="flex items-center space-x-3 w-full md:w-auto">
                <select class="px-4 py-2.5 rounded-2xl border border-slate-200 text-xs font-bold text-slate-700 bg-slate-50 focus:outline-none">
                    <option value="ALL">All Statuses</option>
                    <option value="CONFIRMED">Confirmed</option>
                    <option value="CANCELLED">Cancelled</option>
                </select>
            </div>
        </div>

        <!-- Appointments Table -->
        <div class="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="bg-slate-50/80 border-b border-slate-100 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                            <th class="py-4 px-6">Appt No</th>
                            <th class="py-4 px-6">Patient Name</th>
                            <th class="py-4 px-6">Dentist</th>
                            <th class="py-4 px-6">Treatment</th>
                            <th class="py-4 px-6">Date & Time</th>
                            <th class="py-4 px-6">Total Fee</th>
                            <th class="py-4 px-6">Status</th>
                            <th class="py-4 px-6 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-xs font-semibold text-slate-700">
                        <!-- Sample Row 1 -->
                        <tr class="hover:bg-slate-50 transition-colors">
                            <td class="py-4 px-6 font-extrabold text-teal-600">APT-1001</td>
                            <td class="py-4 px-6 font-bold text-slate-800">Piraveena Krishnakumar</td>
                            <td class="py-4 px-6">Dr. Chaminda Silva</td>
                            <td class="py-4 px-6">Routine Checkup</td>
                            <td class="py-4 px-6 text-slate-600">2026-08-20 @ 09:00</td>
                            <td class="py-4 px-6 font-bold text-slate-900">LKR 5,200.00</td>
                            <td class="py-4 px-6"><span class="px-3 py-1 bg-emerald-50 text-emerald-700 rounded-full text-[10px] font-extrabold">CONFIRMED</span></td>
                            <td class="py-4 px-6 text-right space-x-2">
                                <% if ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole)) { %>
                                <button onclick="cancelAppointment('APT-1001')" class="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold rounded-xl text-[11px] transition-all">
                                    <i class="fa-solid fa-ban mr-1"></i> Cancel
                                </button>
                                <% } %>
                            </td>
                        </tr>

                        <!-- Sample Row 2 -->
                        <tr class="hover:bg-slate-50 transition-colors">
                            <td class="py-4 px-6 font-extrabold text-teal-600">APT-1002</td>
                            <td class="py-4 px-6 font-bold text-slate-800">Saman Kumara</td>
                            <td class="py-4 px-6">Dr. Nimali Fernando</td>
                            <td class="py-4 px-6">Teeth Whitening</td>
                            <td class="py-4 px-6 text-slate-600">2026-08-21 @ 10:30</td>
                            <td class="py-4 px-6 font-bold text-slate-900">LKR 11,500.00</td>
                            <td class="py-4 px-6"><span class="px-3 py-1 bg-emerald-50 text-emerald-700 rounded-full text-[10px] font-extrabold">CONFIRMED</span></td>
                            <td class="py-4 px-6 text-right space-x-2">
                                <% if ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole)) { %>
                                <button onclick="cancelAppointment('APT-1002')" class="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold rounded-xl text-[11px] transition-all">
                                    <i class="fa-solid fa-ban mr-1"></i> Cancel
                                </button>
                                <% } %>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Patient Appointment Records
    </footer>

    <script>
        function cancelAppointment(aptNo) {
            if (confirm("Are you sure you want to cancel appointment " + aptNo + "?")) {
                alert("Appointment " + aptNo + " has been cancelled. Observer notifications dispatched.");
                window.location.reload();
            }
        }
    </script>
</body>
</html>
