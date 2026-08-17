<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patient Registration - Sunrise Dental Clinic</title>
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

    <!-- Main Registration Section -->
    <main class="flex-grow py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-xl mx-auto bg-white rounded-3xl shadow-xl border border-slate-100 p-8 sm:p-10 relative overflow-hidden">
            
            <div class="absolute -right-12 -top-12 w-32 h-32 bg-teal-50 rounded-full blur-2xl pointer-events-none"></div>

            <div class="text-center mb-8">
                <div class="w-16 h-16 bg-teal-100 text-teal-600 rounded-3xl mx-auto flex items-center justify-center text-2xl mb-4 shadow-sm">
                    <i class="fa-solid fa-user-plus"></i>
                </div>
                <h1 class="text-2xl font-black text-slate-800 tracking-tight">New Patient Registration</h1>
                <p class="text-xs font-semibold text-slate-500 mt-1">Create your patient profile for instant dental appointment booking</p>
            </div>

            <!-- Display Error / Success Alert -->
            <% if (request.getAttribute("errorMessage") != null) { %>
            <div class="mb-6 p-4 rounded-2xl bg-rose-50 border border-rose-200 text-rose-700 text-xs font-bold flex items-center space-x-2">
                <i class="fa-solid fa-circle-exclamation text-base"></i>
                <span><%= request.getAttribute("errorMessage") %></span>
            </div>
            <% } %>

            <form action="register" method="POST" class="space-y-4">
                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Username *</label>
                        <input type="text" name="username" required placeholder="Choose a username" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Password *</label>
                        <input type="password" name="password" required placeholder="Create password" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Full Name *</label>
                    <input type="text" name="fullName" required placeholder="e.g. Piraveena Krishnakumar" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Email Address *</label>
                        <input type="email" name="email" required placeholder="name@example.com" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Phone Number *</label>
                        <input type="text" name="phone" required placeholder="+94 77 123 4567" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>
                </div>

                <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">NIC / Passport *</label>
                        <input type="text" name="nic" required placeholder="199854321098" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Age *</label>
                        <input type="number" name="age" required value="26" min="1" max="120" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Gender *</label>
                        <select name="gender" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                            <option value="Female">Female</option>
                            <option value="Male">Male</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                </div>

                <div>
                    <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Residential Address</label>
                    <textarea name="address" rows="2" placeholder="e.g. No. 45, Galle Road, Colombo 03" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50"></textarea>
                </div>

                <button type="submit" class="w-full py-4 bg-gradient-to-r from-teal-600 to-emerald-500 text-white font-extrabold rounded-2xl text-xs uppercase tracking-wider hover:opacity-95 transition-all duration-200 shadow-lg shadow-teal-500/25 mt-4">
                    <i class="fa-solid fa-check-circle mr-2"></i> Register Account & Proceed
                </button>
            </form>

            <div class="mt-6 text-center">
                <span class="text-xs text-slate-500">Already registered? </span>
                <a href="login.jsp" class="text-xs font-extrabold text-teal-600 hover:underline">Log in to your account</a>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Apache NetBeans & WAMP MySQL Architecture
    </footer>

</body>
</html>
