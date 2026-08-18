<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRole = currentUser.getRole();
    if (!"ADMIN".equalsIgnoreCase(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Decision-Making Reports - Sunrise Dental Clinic</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
                    <i class="fa-solid fa-chart-line mr-1"></i> Admin Analytics & Decision-Making Reports
                </span>
                <h1 class="text-3xl font-black tracking-tight">Clinic Operational Reports</h1>
                <p class="text-xs text-teal-100 mt-2 max-w-2xl leading-relaxed font-medium">
                    Visual decision-making charts for treatment popularity, revenue distribution, and doctor workload analytics.
                </p>
            </div>
        </div>

        <!-- Charts Grid -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
            <!-- Treatment Distribution -->
            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                <h3 class="text-base font-bold text-slate-800 mb-4 flex items-center">
                    <i class="fa-solid fa-chart-pie text-teal-600 mr-2"></i> Treatment Popularity Share
                </h3>
                <div class="h-64 flex items-center justify-center">
                    <canvas id="treatmentChart"></canvas>
                </div>
            </div>

            <!-- Revenue Trend -->
            <div class="bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                <h3 class="text-base font-bold text-slate-800 mb-4 flex items-center">
                    <i class="fa-solid fa-chart-column text-emerald-600 mr-2"></i> Monthly Revenue (LKR)
                </h3>
                <div class="h-64 flex items-center justify-center">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>
        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Admin Decision-Making Reports
    </footer>

    <script>
        new Chart(document.getElementById('treatmentChart'), {
            type: 'doughnut',
            data: {
                labels: ['Routine Checkup', 'Teeth Whitening', 'Root Canal', 'Braces', 'Fillings'],
                datasets: [{
                    data: [35, 25, 15, 15, 10],
                    backgroundColor: ['#0d9488', '#10b981', '#6366f1', '#a855f7', '#f59e0b']
                }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });

        new Chart(document.getElementById('revenueChart'), {
            type: 'bar',
            data: {
                labels: ['May', 'Jun', 'Jul', 'Aug'],
                datasets: [{
                    label: 'Revenue (LKR)',
                    data: [420000, 580000, 640000, 780000],
                    backgroundColor: '#0d9488',
                    borderRadius: 8
                }]
            },
            options: { responsive: true, maintainAspectRatio: false }
        });
    </script>
</body>
</html>
