<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
<%@ page import="com.sunrisedental.dao.UserDAO" %>
<%@ page import="com.sunrisedental.model.Patient" %>
<%@ page import="com.sunrisedental.dao.AppointmentDAO" %>
<%@ page import="com.sunrisedental.model.Appointment" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRole = currentUser.getRole();
    String fullName = currentUser.getFullName();

    UserDAO userDAO = new UserDAO();
    AppointmentDAO appointmentDAO = new AppointmentDAO();

    Patient patientProfile = userDAO.getPatientByUserId(currentUser.getId());
    if (patientProfile == null && currentUser.getUsername() != null) {
        patientProfile = userDAO.getPatientByUsername(currentUser.getUsername());
    }
    if (patientProfile == null) {
        patientProfile = userDAO.getPatientByEmailOrPhone(currentUser.getEmail(), currentUser.getPhone());
    }

    String patientNic = patientProfile != null ? patientProfile.getNicPassport() : "";
    String patientEmail = (patientProfile != null && patientProfile.getEmail() != null) ? patientProfile.getEmail() : currentUser.getEmail();
    String patientPhone = (patientProfile != null && patientProfile.getContactNumber() != null) ? patientProfile.getContactNumber() : currentUser.getPhone();

    List<Appointment> appointmentList;
    boolean isPatientView = "PATIENT".equalsIgnoreCase(userRole);

    if (isPatientView) {
        // Strict Patient Isolation: only show appointments booked by this specific logged-in patient
        appointmentList = appointmentDAO.getAppointmentsForPatient(patientEmail, patientNic, patientPhone, fullName);
    } else {
        // Staff/Admin/Doctor/Cashier: view all appointments
        appointmentList = appointmentDAO.getAllAppointments();
    }
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
                        <i class="fa-solid fa-list-check mr-1"></i> <%= isPatientView ? "My Patient Bookings" : "All Clinic Appointments" %>
                    </span>
                    <h1 class="text-3xl font-black tracking-tight">
                        <%= isPatientView ? "My Registered Appointments" : "Registered Appointments" %>
                    </h1>
                    <p class="text-xs text-teal-100 mt-1 font-medium">
                        <%= isPatientView ? "Showing all bookings for patient " + fullName + (patientNic != null && !patientNic.isEmpty() ? " (NIC: " + patientNic + ")" : "") : "Manage, inspect, and filter clinic appointments across all doctors." %>
                    </p>
                </div>
                <% if ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole)) { %>
                <a href="register-appointment.jsp" class="px-5 py-3 bg-white text-teal-800 font-extrabold rounded-2xl text-xs uppercase tracking-wider hover:bg-teal-50 transition-all shadow-md inline-flex items-center space-x-2">
                    <i class="fa-solid fa-plus-circle text-sm"></i>
                    <span>New Booking</span>
                </a>
                <% } %>
            </div>
        </div>

        <!-- Filter & Search Bar -->
        <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm mb-8 flex flex-col md:flex-row gap-4 justify-between items-center">
            <div class="relative w-full md:w-96">
                <i class="fa-solid fa-magnifying-glass absolute left-4 top-3.5 text-slate-400 text-xs"></i>
                <input type="text" id="searchInput" onkeyup="filterTable()" placeholder="Search by Appt No, Doctor, or Treatment..." class="w-full pl-10 pr-4 py-2.5 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
            </div>
            <div class="flex items-center space-x-3 w-full md:w-auto">
                <select id="statusFilter" onchange="filterTable()" class="px-4 py-2.5 rounded-2xl border border-slate-200 text-xs font-bold text-slate-700 bg-slate-50 focus:outline-none">
                    <option value="ALL">All Statuses</option>
                    <option value="CONFIRMED">Confirmed</option>
                    <option value="CANCELLED">Cancelled</option>
                    <option value="COMPLETED">Completed</option>
                </select>
            </div>
        </div>

        <!-- Appointments Table -->
        <div class="bg-white rounded-3xl border border-slate-100 shadow-sm overflow-hidden">
            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse" id="appointmentsTable">
                    <thead>
                        <tr class="bg-slate-50/80 border-b border-slate-100 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                            <th class="py-4 px-6">Appt No</th>
                            <th class="py-4 px-6">Patient Details</th>
                            <th class="py-4 px-6">Dentist</th>
                            <th class="py-4 px-6">Treatment</th>
                            <th class="py-4 px-6">Date & Time</th>
                            <th class="py-4 px-6">Total Fee</th>
                            <th class="py-4 px-6">Status</th>
                            <th class="py-4 px-6 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-xs font-semibold text-slate-700">
                        <% if (appointmentList.isEmpty()) { %>
                        <tr>
                            <td colspan="8" class="py-12 text-center text-slate-400">
                                <div class="w-12 h-12 bg-slate-100 text-slate-400 rounded-full flex items-center justify-center mx-auto text-xl mb-3">
                                    <i class="fa-solid fa-calendar-xmark"></i>
                                </div>
                                <span class="font-bold text-sm text-slate-600">No appointments found.</span>
                                <p class="text-xs text-slate-400 mt-1">
                                    <%= isPatientView ? "You have not booked any appointments yet." : "No clinic appointments have been registered yet." %>
                                </p>
                                <% if (isPatientView) { %>
                                <a href="register-appointment.jsp" class="mt-4 inline-block px-4 py-2 bg-teal-600 text-white rounded-xl text-xs font-bold hover:bg-teal-700 transition-all">
                                    Book Your First Appointment
                                </a>
                                <% } %>
                            </td>
                        </tr>
                        <% } else { %>
                            <% for (Appointment a : appointmentList) { 
                                String pName = a.getPatient() != null ? a.getPatient().getFullName() : "Patient";
                                String pPhone = a.getPatient() != null ? a.getPatient().getContactNumber() : "";
                                String pNic = a.getPatient() != null ? a.getPatient().getNicPassport() : "";
                                String status = a.getStatus() != null ? a.getStatus().toUpperCase() : "CONFIRMED";
                                String statusClass = "CONFIRMED".equals(status) ? "bg-emerald-50 text-emerald-700" :
                                                     "CANCELLED".equals(status) ? "bg-rose-50 text-rose-700" : "bg-sky-50 text-sky-700";
                            %>
                            <tr class="hover:bg-slate-50 transition-colors appointment-row" data-status="<%= status %>">
                                <td class="py-4 px-6 font-extrabold text-teal-600"><%= a.getAppointmentNumber() %></td>
                                <td class="py-4 px-6">
                                    <span class="font-bold text-slate-800 block"><%= pName %></span>
                                    <span class="text-[11px] text-slate-400 block"><%= pPhone %><% if (pNic != null && !pNic.isEmpty()) { %> &bull; NIC: <%= pNic %><% } %></span>
                                </td>
                                <td class="py-4 px-6 font-medium text-slate-700"><%= a.getDentistName() %></td>
                                <td class="py-4 px-6 font-semibold text-slate-800">
                                    <%= a.getTreatmentType() %>
                                    <% if (a.getAddOns() != null && !a.getAddOns().isEmpty()) { %>
                                    <span class="text-[10px] text-teal-600 block mt-0.5">+ <%= String.join(", ", a.getAddOns()) %></span>
                                    <% } %>
                                </td>
                                <td class="py-4 px-6 text-slate-600 font-medium"><%= a.getAppointmentDate() %> @ <%= a.getAppointmentTime() %></td>
                                <td class="py-4 px-6 font-bold text-slate-900">LKR <%= String.format("%,.2f", a.getTotalCost()) %></td>
                                <td class="py-4 px-6">
                                    <span class="px-3 py-1 rounded-full text-[10px] font-extrabold <%= statusClass %>"><%= status %></span>
                                </td>
                                <td class="py-4 px-6 text-right space-x-2">
                                    <% if ("CONFIRMED".equalsIgnoreCase(status) && ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole))) { %>
                                    <button onclick="cancelAppointment('<%= a.getAppointmentNumber() %>')" class="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold rounded-xl text-[11px] transition-all">
                                        <i class="fa-solid fa-ban mr-1"></i> Cancel
                                    </button>
                                    <% } else if ("CANCELLED".equalsIgnoreCase(status)) { %>
                                    <span class="text-[11px] text-slate-400 italic">Cancelled</span>
                                    <% } %>
                                </td>
                            </tr>
                            <% } %>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Logged in as <%= fullName %> (<%= userRole %>)
    </footer>

    <script>
        function filterTable() {
            const search = document.getElementById('searchInput').value.toLowerCase();
            const status = document.getElementById('statusFilter').value.toUpperCase();
            const rows = document.querySelectorAll('.appointment-row');

            rows.forEach(row => {
                const text = row.innerText.toLowerCase();
                const rowStatus = row.getAttribute('data-status').toUpperCase();

                const matchesSearch = text.includes(search);
                const matchesStatus = status === 'ALL' || rowStatus === status;

                if (matchesSearch && matchesStatus) {
                    row.style.display = '';
                } else {
                    row.style.display = 'none';
                }
            });
        }

        async function cancelAppointment(aptNo) {
            if (!confirm("Are you sure you want to cancel appointment " + aptNo + "?")) {
                return;
            }

            try {
                const formData = new URLSearchParams();
                formData.append('appointmentNumber', aptNo);

                const res = await fetch('cancel-appointment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    },
                    body: formData.toString()
                });

                const data = await res.json();
                if (data.success) {
                    showToast("Appointment " + aptNo + " cancelled successfully. System observers notified.", "danger", "Booking Cancelled");
                    setTimeout(() => {
                        window.location.reload();
                    }, 1200);
                } else {
                    showToast("Could not cancel appointment: " + (data.message || "Unknown error"), "error", "Cancellation Failed");
                }
            } catch (err) {
                console.error(err);
                showToast("Error connecting to server.", "error", "Network Error");
            }
        }

        // Universal Toast Notification Function
        function showToast(message, type = 'success', title = '') {
            const container = document.getElementById('toastContainer');
            if (!container) return;

            const toast = document.createElement('div');
            toast.className = 'pointer-events-auto flex items-start space-x-3 p-4 rounded-2xl shadow-xl border backdrop-blur-md transform transition-all duration-300 translate-y-[-10px] opacity-0';

            let icon = '';
            let defaultTitle = '';
            let bgClasses = '';

            if (type === 'success') {
                bgClasses = 'bg-emerald-50/95 border-emerald-300 text-emerald-900 shadow-emerald-500/10';
                icon = '<i class="fa-solid fa-circle-check text-emerald-600 text-lg mt-0.5"></i>';
                defaultTitle = title || 'Success';
            } else if (type === 'error' || type === 'danger') {
                bgClasses = 'bg-rose-50/95 border-rose-300 text-rose-900 shadow-rose-500/10';
                icon = '<i class="fa-solid fa-circle-xmark text-rose-600 text-lg mt-0.5"></i>';
                defaultTitle = title || 'Booking Cancelled';
            } else if (type === 'warning') {
                bgClasses = 'bg-amber-50/95 border-amber-300 text-amber-900 shadow-amber-500/10';
                icon = '<i class="fa-solid fa-triangle-exclamation text-amber-600 text-lg mt-0.5"></i>';
                defaultTitle = title || 'Notice';
            } else {
                bgClasses = 'bg-sky-50/95 border-sky-300 text-sky-900 shadow-sky-500/10';
                icon = '<i class="fa-solid fa-circle-info text-sky-600 text-lg mt-0.5"></i>';
                defaultTitle = title || 'Notification';
            }

            toast.className += ' ' + bgClasses;

            toast.innerHTML = icon +
                '<div class="flex-1 pr-2">' +
                    '<h4 class="text-xs font-black uppercase tracking-wider">' + defaultTitle + '</h4>' +
                    '<p class="text-xs font-semibold mt-0.5 leading-relaxed">' + message + '</p>' +
                '</div>' +
                '<button onclick="this.parentElement.remove()" class="text-slate-400 hover:text-slate-700 text-sm">' +
                    '<i class="fa-solid fa-xmark"></i>' +
                '</button>';

            container.appendChild(toast);

            setTimeout(() => {
                toast.classList.remove('translate-y-[-10px]', 'opacity-0');
                toast.classList.add('translate-y-0', 'opacity-100');
            }, 10);

            setTimeout(() => {
                toast.classList.remove('translate-y-0', 'opacity-100');
                toast.classList.add('translate-y-[-10px]', 'opacity-0');
                setTimeout(() => toast.remove(), 300);
            }, 4500);
        }
    </script>

    <!-- Toast Notification Container -->
    <div id="toastContainer" class="fixed top-6 right-6 z-50 flex flex-col space-y-3 pointer-events-none max-w-sm w-full"></div>
</body>
</html>
