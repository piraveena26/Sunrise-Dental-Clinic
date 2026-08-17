<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff & Patient Login - Sunrise Dental Clinic</title>
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

    <!-- Login Container -->
    <main class="flex-grow flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-md w-full bg-white rounded-3xl shadow-xl border border-slate-100 p-8 sm:p-10 relative overflow-hidden">
            
            <div class="absolute -left-12 -top-12 w-32 h-32 bg-teal-50 rounded-full blur-2xl pointer-events-none"></div>

            <div class="text-center mb-8">
                <div class="w-16 h-16 bg-teal-600 text-white rounded-3xl mx-auto flex items-center justify-center text-3xl mb-4 shadow-lg shadow-teal-500/30">
                    <i class="fa-solid fa-tooth"></i>
                </div>
                <h1 class="text-2xl font-black text-slate-800 tracking-tight">Sunrise Dental Clinic</h1>
                <p class="text-xs font-semibold text-slate-500 mt-1">Multi-Role Authentication Portal</p>
            </div>

            <!-- Alerts -->
            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-bold flex items-center space-x-2">
                <i class="fa-solid fa-circle-exclamation text-base"></i>
                <span><%= request.getAttribute("errorMessage") %></span>
            </div>
            <% } %>

            <% if (request.getAttribute("successMessage") != null) { %>
            <div class="mb-6 p-4 rounded-2xl bg-emerald-50 border border-emerald-200 text-emerald-700 text-xs font-bold flex items-center space-x-2">
                <i class="fa-solid fa-circle-check text-base"></i>
                <span><%= request.getAttribute("successMessage") %></span>
            </div>
            <% } %>

            <form action="login" method="POST" class="space-y-4">
                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">User Role</label>
                    <select name="role" id="roleSelect" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                        <option value="ADMIN">System Administrator</option>
                        <option value="PATIENT" selected>Patient</option>
                        <option value="DOCTOR">Doctor / Dentist</option>
                        <option value="CASHIER">Cashier / Billing Staff</option>
                    </select>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Username</label>
                    <input type="text" id="usernameInput" name="username" required placeholder="Enter your username" value="patient1" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Password</label>
                    <input type="password" id="passwordInput" name="password" required placeholder="Enter password" value="patient123" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                </div>

                <button type="submit" class="w-full py-4 bg-gradient-to-r from-teal-600 to-emerald-500 text-white font-extrabold rounded-2xl text-xs uppercase tracking-wider hover:opacity-95 transition-all duration-200 shadow-lg shadow-teal-500/25 mt-2">
                    <i class="fa-solid fa-right-to-bracket mr-2"></i> Log In to Dashboard
                </button>
            </form>

            <!-- Demo Preset Quick Login Buttons -->
            <div class="mt-8 pt-6 border-t border-slate-100">
                <span class="text-[11px] font-bold text-slate-400 uppercase tracking-wider block mb-3 text-center">Quick Demo Login Shortcuts:</span>
                <div class="grid grid-cols-2 gap-2">
                    <button type="button" onclick="fillLogin('admin', 'admin123', 'ADMIN')" class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-[11px] font-bold flex items-center justify-center space-x-1 transition-all">
                        <i class="fa-solid fa-shield-halved text-teal-600"></i>
                        <span>Admin</span>
                    </button>
                    <button type="button" onclick="fillLogin('patient1', 'patient123', 'PATIENT')" class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-[11px] font-bold flex items-center justify-center space-x-1 transition-all">
                        <i class="fa-solid fa-user-injured text-teal-600"></i>
                        <span>Patient</span>
                    </button>
                    <button type="button" onclick="fillLogin('doctor1', 'doctor123', 'DOCTOR')" class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-[11px] font-bold flex items-center justify-center space-x-1 transition-all">
                        <i class="fa-solid fa-user-md text-teal-600"></i>
                        <span>Doctor</span>
                    </button>
                    <button type="button" onclick="fillLogin('cashier', 'cashier123', 'CASHIER')" class="px-3 py-2 bg-slate-100 hover:bg-slate-200 text-slate-700 rounded-xl text-[11px] font-bold flex items-center justify-center space-x-1 transition-all">
                        <i class="fa-solid fa-cash-register text-teal-600"></i>
                        <span>Cashier</span>
                    </button>
                </div>
            </div>

            <div class="mt-6 text-center">
                <span class="text-xs text-slate-500">Need a new patient account? </span>
                <a href="register.jsp" class="text-xs font-extrabold text-teal-600 hover:underline">Self Register Here</a>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Multi-Role Authentication Portal
    </footer>

    <script>
        function fillLogin(user, pass, role) {
            document.getElementById('usernameInput').value = user;
            document.getElementById('passwordInput').value = pass;
            document.getElementById('roleSelect').value = role;
        }
    </script>
</body>
</html>
