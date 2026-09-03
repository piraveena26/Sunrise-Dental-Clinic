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

    Patient patientProfile = null;
    int myAppointmentCount = 0;
    boolean isPatient = "PATIENT".equalsIgnoreCase(userRole);

    if (isPatient) {
        patientProfile = userDAO.getPatientByUserId(currentUser.getId());
        if (patientProfile == null && currentUser.getUsername() != null) {
            patientProfile = userDAO.getPatientByUsername(currentUser.getUsername());
        }
        if (patientProfile == null) {
            patientProfile = userDAO.getPatientByEmailOrPhone(currentUser.getEmail(), currentUser.getPhone());
        }

        String pEmail = patientProfile != null ? patientProfile.getEmail() : currentUser.getEmail();
        String pNic = patientProfile != null ? patientProfile.getNicPassport() : "";
        String pPhone = patientProfile != null ? patientProfile.getContactNumber() : currentUser.getPhone();

        List<Appointment> myApts = appointmentDAO.getAppointmentsForPatient(pEmail, pNic, pPhone, fullName);
        myAppointmentCount = myApts.size();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Sunrise Dental Clinic</title>
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

        <!-- Welcome Banner -->
        <div class="bg-gradient-to-r from-teal-700 via-teal-600 to-emerald-500 rounded-3xl p-8 text-white shadow-xl mb-8 relative overflow-hidden">
            <div class="relative z-10 flex flex-col md:flex-row md:items-center justify-between gap-6">
                <div>
                    <span class="px-3 py-1 bg-white/20 text-white rounded-full text-xs font-extrabold uppercase tracking-wider mb-3 inline-block">
                        <i class="fa-solid fa-hospital-user mr-1"></i> Multi-Role Portal &bull; Logged in as <%= userRole %>
                    </span>
                    <h1 class="text-3xl font-black tracking-tight">Welcome back, <%= fullName %>!</h1>
                    <p class="text-xs text-teal-100 mt-2 max-w-xl leading-relaxed font-medium">
                        <% if (isPatient) { %>
                            Access your personal dental appointments, schedule new treatments, view itemized bills, and receive instant observer notification alerts.
                        <% } else { %>
                            Sunrise Dental Clinic Management System. Access authorized tools, appointments, leave scheduling, and billing below.
                        <% } %>
                    </p>
                </div>
                <div>
                    <% if ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole)) { %>
                    <a href="register-appointment.jsp" class="px-6 py-3.5 bg-white text-teal-800 font-black rounded-2xl text-xs uppercase tracking-wider hover:bg-teal-50 transition-all duration-200 shadow-lg inline-flex items-center space-x-2">
                        <i class="fa-solid fa-calendar-plus text-base"></i>
                        <span>Book Appointment</span>
                    </a>
                    <% } %>
                </div>
            </div>
        </div>

        <!-- Role KPI Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex items-center space-x-4">
                <div class="w-12 h-12 bg-teal-100 text-teal-600 rounded-2xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-calendar-check"></i>
                </div>
                <div>
                    <span class="text-xs font-medium text-slate-400 uppercase tracking-wider block">
                        <%= isPatient ? "My Bookings" : "Today's Queue" %>
                    </span>
                    <span class="text-2xl font-extrabold text-slate-800">
                        <%= isPatient ? myAppointmentCount + " Active" : "12 Active" %>
                    </span>
                    <span class="text-xs text-emerald-600 font-semibold block mt-0.5">
                        <i class="fa-solid fa-check mr-1"></i> <%= isPatient ? "Personalized View" : "100% Slot Managed" %>
                    </span>
                </div>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex items-center space-x-4">
                <div class="w-12 h-12 bg-emerald-100 text-emerald-600 rounded-2xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-user-md"></i>
                </div>
                <div>
                    <span class="text-xs font-medium text-slate-400 uppercase tracking-wider block">Available Dentists</span>
                    <span class="text-2xl font-extrabold text-slate-800">2 On Duty</span>
                    <span class="text-xs text-emerald-600 font-semibold block mt-0.5">Dr. Silva & Dr. Fernando</span>
                </div>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex items-center space-x-4">
                <div class="w-12 h-12 bg-purple-100 text-purple-600 rounded-2xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-receipt"></i>
                </div>
                <div>
                    <span class="text-xs font-medium text-slate-400 uppercase tracking-wider block">
                        <%= isPatient ? "Decorator Pricing" : "Billing Status" %>
                    </span>
                    <span class="text-2xl font-extrabold text-slate-800">
                        <%= isPatient ? "Live Add-ons" : "Cashier Portal" %>
                    </span>
                    <span class="text-xs text-purple-600 font-semibold block mt-0.5">Itemized Add-ons & Tax</span>
                </div>
            </div>

            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm flex items-center space-x-4">
                <div class="w-12 h-12 bg-amber-100 text-amber-600 rounded-2xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-bell"></i>
                </div>
                <div>
                    <span class="text-xs font-medium text-slate-400 uppercase tracking-wider block">Notifications</span>
                    <span class="text-2xl font-extrabold text-slate-800">Email & SMS</span>
                    <span class="text-xs text-amber-600 font-semibold block mt-0.5">Observer Pattern Alerts</span>
                </div>
            </div>
        </div>

        <!-- Role Shortcuts Grid -->
        <h2 class="text-lg font-bold text-slate-800 mb-4 flex items-center">
            <i class="fa-solid fa-grip text-teal-600 mr-2"></i> Authorized System Actions (<%= userRole %>)
        </h2>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-10">

            <!-- Patient / Admin: Register Appointment -->
            <% if ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole)) { %>
            <a href="register-appointment.jsp" class="group bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:border-teal-200 transition-all flex flex-col justify-between">
                <div>
                    <div class="w-12 h-12 bg-teal-500 rounded-2xl text-white flex items-center justify-center text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-calendar-plus"></i>
                    </div>
                    <h3 class="text-base font-bold text-slate-800 group-hover:text-teal-600 transition-colors">Book New Appointment</h3>
                    <p class="text-xs text-slate-500 mt-2 leading-relaxed">
                        Book appointment, select doctor and date (leave dates automatically greyed out), add treatments with Decorator price preview.
                    </p>
                </div>
                <div class="mt-6 flex items-center text-xs font-bold text-teal-600 group-hover:translate-x-1 transition-transform">
                    <span>Open Booking Page</span>
                    <i class="fa-solid fa-arrow-right ml-2"></i>
                </div>
            </a>
            <% } %>

            <!-- Appointments List -->
            <a href="appointment-details.jsp" class="group bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:border-teal-200 transition-all flex flex-col justify-between">
                <div>
                    <div class="w-12 h-12 bg-emerald-500 rounded-2xl text-white flex items-center justify-center text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-file-invoice"></i>
                    </div>
                    <h3 class="text-base font-bold text-slate-800 group-hover:text-teal-600 transition-colors">
                        <%= isPatient ? "My Appointments" : "View All Appointments" %>
                    </h3>
                    <p class="text-xs text-slate-500 mt-2 leading-relaxed">
                        <%= isPatient ? "Inspect your registered appointments, check status, and cancel bookings if necessary." : "Search and inspect active appointments, check appointment status, and cancel appointments with Memento state backup." %>
                    </p>
                </div>
                <div class="mt-6 flex items-center text-xs font-bold text-emerald-600 group-hover:translate-x-1 transition-transform">
                    <span><%= isPatient ? "View My Appointments" : "View Appointments" %></span>
                    <i class="fa-solid fa-arrow-right ml-2"></i>
                </div>
            </a>

            <!-- Doctor / Admin: Leave Scheduling -->
            <% if ("ADMIN".equalsIgnoreCase(userRole) || "DOCTOR".equalsIgnoreCase(userRole)) { %>
            <a href="doctor-schedule.jsp" class="group bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:border-teal-200 transition-all flex flex-col justify-between">
                <div>
                    <div class="w-12 h-12 bg-sky-500 rounded-2xl text-white flex items-center justify-center text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-user-clock"></i>
                    </div>
                    <h3 class="text-base font-bold text-slate-800 group-hover:text-teal-600 transition-colors">Doctor Schedule & Leave</h3>
                    <p class="text-xs text-slate-500 mt-2 leading-relaxed">
                        Doctors can schedule leave dates or unavailable time slots to prevent patient double-booking.
                    </p>
                </div>
                <div class="mt-6 flex items-center text-xs font-bold text-sky-600 group-hover:translate-x-1 transition-transform">
                    <span>Manage Schedule</span>
                    <i class="fa-solid fa-arrow-right ml-2"></i>
                </div>
            </a>
            <% } %>

            <!-- Cashier / Admin: Billing -->
            <% if ("ADMIN".equalsIgnoreCase(userRole) || "CASHIER".equalsIgnoreCase(userRole)) { %>
            <a href="billing.jsp" class="group bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:border-teal-200 transition-all flex flex-col justify-between">
                <div>
                    <div class="w-12 h-12 bg-purple-500 rounded-2xl text-white flex items-center justify-center text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-receipt"></i>
                    </div>
                    <h3 class="text-base font-bold text-slate-800 group-hover:text-teal-600 transition-colors">Cashier Billing Portal</h3>
                    <p class="text-xs text-slate-500 mt-2 leading-relaxed">
                        Calculate treatment fees + add-on services, update payment statuses (Cash/Card), and print receipt invoices.
                    </p>
                </div>
                <div class="mt-6 flex items-center text-xs font-bold text-purple-600 group-hover:translate-x-1 transition-transform">
                    <span>Open Billing Engine</span>
                    <i class="fa-solid fa-arrow-right ml-2"></i>
                </div>
            </a>
            <% } %>

            <!-- Admin Only: Reports -->
            <% if ("ADMIN".equalsIgnoreCase(userRole)) { %>
            <a href="reports.jsp" class="group bg-white p-6 rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:border-teal-200 transition-all flex flex-col justify-between">
                <div>
                    <div class="w-12 h-12 bg-indigo-500 rounded-2xl text-white flex items-center justify-center text-xl mb-4 group-hover:scale-110 transition-transform">
                        <i class="fa-solid fa-chart-line"></i>
                    </div>
                    <h3 class="text-base font-bold text-slate-800 group-hover:text-teal-600 transition-colors">Analytics Reports</h3>
                    <p class="text-xs text-slate-500 mt-2 leading-relaxed">
                        Visual decision-making charts, treatment popularity metrics, monthly revenue trends, and doctor workload reports.
                    </p>
                </div>
                <div class="mt-6 flex items-center text-xs font-bold text-indigo-600 group-hover:translate-x-1 transition-transform">
                    <span>View Analytics</span>
                    <i class="fa-solid fa-arrow-right ml-2"></i>
                </div>
            </a>
            <% } %>

        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Logged in as <%= fullName %> (<%= userRole %>)
    </footer>

    <!-- Shared Toast Notifications -->
    <jsp:include page="shared-toast.jsp" />

</body>
</html>
