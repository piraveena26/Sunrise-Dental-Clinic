<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    String userRole = (currentUser != null) ? currentUser.getRole() : "GUEST";
    String fullName = (currentUser != null) ? currentUser.getFullName() : "Guest User";
    String currentPath = request.getRequestURI();
%>
<header class="bg-white border-b border-slate-200 sticky top-0 z-50 shadow-sm">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-20">
            <!-- Brand Logo -->
            <a href="dashboard.jsp" class="flex items-center space-x-3 group">
                <div class="w-12 h-12 rounded-2xl bg-gradient-to-tr from-teal-600 to-emerald-400 flex items-center justify-center shadow-lg shadow-teal-500/20 group-hover:scale-105 transition-transform duration-300">
                    <i class="fa-solid fa-tooth text-white text-2xl"></i>
                </div>
                <div>
                    <span class="text-xl font-black text-slate-900 tracking-tight block">SUNRISE</span>
                    <span class="text-xs font-bold tracking-widest text-teal-600 block uppercase">Dental Clinic</span>
                </div>
            </a>

            <!-- Navigation Links Based on User Role -->
            <nav class="hidden md:flex items-center space-x-1 font-semibold text-sm">
                <a href="dashboard.jsp" class="px-4 py-2.5 rounded-xl transition-all flex items-center space-x-2 <%= currentPath.endsWith("dashboard.jsp") ? "bg-teal-50 text-teal-600 font-bold" : "text-slate-600 hover:text-teal-600 hover:bg-slate-50" %>">
                    <i class="fa-solid fa-chart-pie"></i>
                    <span>Dashboard</span>
                </a>

                <!-- Patient & Admin: Book Appointment -->
                <% if ("ADMIN".equalsIgnoreCase(userRole) || "PATIENT".equalsIgnoreCase(userRole)) { %>
                <a href="register-appointment.jsp" class="px-4 py-2.5 rounded-xl transition-all flex items-center space-x-2 <%= currentPath.endsWith("register-appointment.jsp") ? "bg-teal-50 text-teal-600 font-bold" : "text-slate-600 hover:text-teal-600 hover:bg-slate-50" %>">
                    <i class="fa-solid fa-calendar-plus"></i>
                    <span>Book Appointment</span>
                </a>
                <% } %>

                <!-- Appointments List: Admin, Patient, Doctor -->
                <% if (!"GUEST".equalsIgnoreCase(userRole)) { %>
                <a href="appointment-details.jsp" class="px-4 py-2.5 rounded-xl transition-all flex items-center space-x-2 <%= currentPath.endsWith("appointment-details.jsp") ? "bg-teal-50 text-teal-600 font-bold" : "text-slate-600 hover:text-teal-600 hover:bg-slate-50" %>">
                    <i class="fa-solid fa-file-invoice"></i>
                    <span>Appointments</span>
                </a>
                <% } %>

                <!-- Doctor & Admin: Leave & Schedule Management -->
                <% if ("ADMIN".equalsIgnoreCase(userRole) || "DOCTOR".equalsIgnoreCase(userRole)) { %>
                <a href="doctor-schedule.jsp" class="px-4 py-2.5 rounded-xl transition-all flex items-center space-x-2 <%= currentPath.endsWith("doctor-schedule.jsp") ? "bg-teal-50 text-teal-600 font-bold" : "text-slate-600 hover:text-teal-600 hover:bg-slate-50" %>">
                    <i class="fa-solid fa-user-clock"></i>
                    <span>Doctor Leave</span>
                </a>
                <% } %>

                <!-- Cashier & Admin: Billing Module -->
                <% if ("ADMIN".equalsIgnoreCase(userRole) || "CASHIER".equalsIgnoreCase(userRole)) { %>
                <a href="billing.jsp" class="px-4 py-2.5 rounded-xl transition-all flex items-center space-x-2 <%= currentPath.endsWith("billing.jsp") ? "bg-teal-50 text-teal-600 font-bold" : "text-slate-600 hover:text-teal-600 hover:bg-slate-50" %>">
                    <i class="fa-solid fa-receipt"></i>
                    <span>Billing</span>
                </a>
                <% } %>

                <!-- Admin Only: Reports -->
                <% if ("ADMIN".equalsIgnoreCase(userRole)) { %>
                <a href="reports.jsp" class="px-4 py-2.5 rounded-xl transition-all flex items-center space-x-2 <%= currentPath.endsWith("reports.jsp") ? "bg-teal-50 text-teal-600 font-bold" : "text-slate-600 hover:text-teal-600 hover:bg-slate-50" %>">
                    <i class="fa-solid fa-chart-line"></i>
                    <span>Reports</span>
                </a>
                <% } %>

                <a href="help.jsp" class="px-4 py-2.5 rounded-xl transition-all flex items-center space-x-2 <%= currentPath.endsWith("help.jsp") ? "bg-teal-50 text-teal-600 font-bold" : "text-slate-600 hover:text-teal-600 hover:bg-slate-50" %>">
                    <i class="fa-solid fa-circle-question"></i>
                    <span>Help</span>
                </a>
            </nav>

            <!-- User Status & Logout / Register Button -->
            <div class="flex items-center space-x-3">
                <% if (currentUser != null) { %>
                <div class="hidden lg:flex items-center space-x-2 bg-slate-100 px-3 py-1.5 rounded-2xl">
                    <div class="w-8 h-8 rounded-full bg-teal-600 text-white flex items-center justify-center font-bold text-xs">
                        <%= userRole.substring(0, 1) %>
                    </div>
                    <div class="text-left">
                        <span class="text-xs font-bold text-slate-800 block leading-tight"><%= fullName %></span>
                        <span class="text-[10px] font-semibold text-teal-600 uppercase tracking-wider block"><%= userRole %></span>
                    </div>
                </div>
                <button type="button" onclick="openLogoutModal()" class="px-4 py-2.5 bg-rose-50 text-rose-600 hover:bg-rose-600 hover:text-white font-bold rounded-2xl text-xs transition-all duration-200 border border-rose-200 shadow-sm flex items-center space-x-1.5 cursor-pointer">
                    <i class="fa-solid fa-right-from-bracket"></i>
                    <span>Logout</span>
                </button>
                <% } else { %>
                <a href="register.jsp" class="px-4 py-2.5 bg-slate-100 text-slate-700 hover:bg-slate-200 font-bold rounded-2xl text-xs transition-all duration-200">
                    <i class="fa-solid fa-user-plus mr-1"></i> Register
                </a>
                <a href="login.jsp" class="px-4 py-2.5 bg-teal-600 text-white hover:bg-teal-700 font-bold rounded-2xl text-xs transition-all duration-200 shadow-md">
                    <i class="fa-solid fa-right-to-bracket mr-1"></i> Login
                </a>
                <% } %>
            </div>
        </div>
    </div>
</header>

<!-- Custom Logout Confirmation Modal -->
<div id="logoutConfirmModal" class="hidden fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-3xl max-w-sm w-full p-6 text-center shadow-2xl border border-slate-100 transform transition-all duration-200">
        <div class="w-14 h-14 bg-rose-100 text-rose-600 rounded-2xl flex items-center justify-center mx-auto text-2xl mb-4">
            <i class="fa-solid fa-right-from-bracket"></i>
        </div>
        <h3 class="text-lg font-black text-slate-900 tracking-tight">Confirm Sign Out</h3>
        <p class="text-xs text-slate-500 mt-2 leading-relaxed font-medium">
            Are you sure you want to log out of <strong class="text-slate-700">Sunrise Dental Clinic</strong>?
        </p>
        <div class="mt-6 flex space-x-3">
            <button type="button" onclick="closeLogoutModal()" class="flex-1 py-3 bg-slate-100 hover:bg-slate-200 text-slate-700 font-bold rounded-2xl text-xs transition-all">
                Cancel
            </button>
            <a href="logout" class="flex-1 py-3 bg-rose-600 hover:bg-rose-700 text-white font-bold rounded-2xl text-xs uppercase tracking-wider transition-all shadow-lg shadow-rose-500/25 flex items-center justify-center space-x-1">
                <span>Sign Out</span>
            </a>
        </div>
    </div>
</div>

<script>
    function openLogoutModal() {
        const m = document.getElementById('logoutConfirmModal');
        if (m) {
            m.classList.remove('hidden');
            m.classList.add('flex');
        }
    }
    function closeLogoutModal() {
        const m = document.getElementById('logoutConfirmModal');
        if (m) {
            m.classList.add('hidden');
            m.classList.remove('flex');
        }
    }
</script>

