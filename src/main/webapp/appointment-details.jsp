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
                            <tr class="hover:bg-slate-50 transition-colors appointment-row" data-status="<%= status %>" id="row-<%= a.getAppointmentNumber() %>">
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
                                    <button onclick="openCancelModal('<%= a.getAppointmentNumber() %>')" class="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold rounded-xl text-[11px] transition-all cursor-pointer">
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

    <!-- Custom Cancel Appointment Confirmation Modal -->
    <div id="cancelConfirmModal" class="hidden fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-sm w-full p-6 text-center shadow-2xl border border-slate-100 transform transition-all duration-200">
            <div class="w-14 h-14 bg-rose-100 text-rose-600 rounded-2xl flex items-center justify-center mx-auto text-2xl mb-4">
                <i class="fa-solid fa-calendar-xmark"></i>
            </div>
            <h3 class="text-lg font-black text-slate-900 tracking-tight">Cancel Appointment</h3>
            <p class="text-xs text-slate-500 mt-2 leading-relaxed font-medium">
                Are you sure you want to cancel appointment <span id="cancelAptNoSpan" class="text-rose-600 font-extrabold"></span>? This booking will be removed from the active schedule.
            </p>
            <div class="mt-6 flex space-x-3">
                <button type="button" onclick="closeCancelModal()" class="flex-1 py-3 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-2xl text-xs transition-all cursor-pointer">
                    Keep Booking
                </button>
                <button type="button" onclick="confirmCancelAppointment()" class="flex-1 py-3 bg-rose-600 hover:bg-rose-700 text-white font-bold rounded-2xl text-xs uppercase tracking-wider transition-all shadow-lg shadow-rose-500/25 flex items-center justify-center space-x-1 cursor-pointer">
                    <span>Yes, Cancel</span>
                </button>
            </div>
        </div>
    </div>

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

        let pendingCancelAptNo = null;

        function openCancelModal(aptNo) {
            pendingCancelAptNo = aptNo;
            document.getElementById('cancelAptNoSpan').innerText = aptNo;
            const modal = document.getElementById('cancelConfirmModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
        }

        function closeCancelModal() {
            pendingCancelAptNo = null;
            const modal = document.getElementById('cancelConfirmModal');
            modal.classList.add('hidden');
            modal.classList.remove('flex');
        }

        async function confirmCancelAppointment() {
            if (!pendingCancelAptNo) return;
            const aptNo = pendingCancelAptNo;
            closeCancelModal();

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
                    showToast('Appointment ' + aptNo + ' cancelled successfully.', 'error', 'Booking Cancelled');
                    
                    // Immediately update row appearance in DOM
                    const row = document.getElementById('row-' + aptNo);
                    if (row) {
                        row.setAttribute('data-status', 'CANCELLED');
                        const statusBadgeTd = row.querySelector('td:nth-child(7)');
                        if (statusBadgeTd) {
                            statusBadgeTd.innerHTML = '<span class="px-3 py-1 rounded-full text-[10px] font-extrabold bg-rose-50 text-rose-700">CANCELLED</span>';
                        }
                        const actionTd = row.querySelector('td:nth-child(8)');
                        if (actionTd) {
                            actionTd.innerHTML = '<span class="text-[11px] text-slate-400 italic">Cancelled</span>';
                        }
                    }
                } else {
                    showToast('Could not cancel appointment: ' + (data.message || 'Unknown error'), 'error', 'Cancellation Failed');
                }
            } catch (err) {
                console.error(err);
                showToast('Error connecting to server.', 'error', 'Network Error');
            }
        }
    </script>

    <!-- Shared Toast Notifications -->
    <jsp:include page="shared-toast.jsp" />
</body>
</html>
