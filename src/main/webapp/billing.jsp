<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
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
    if (!"ADMIN".equalsIgnoreCase(userRole) && !"CASHIER".equalsIgnoreCase(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    AppointmentDAO appointmentDAO = new AppointmentDAO();
    List<Appointment> appointments = appointmentDAO.getAllAppointments();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Billing Portal - Sunrise Dental Clinic</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8fafc; }
        @media print {
            body * { visibility: hidden; }
            #printableReceipt, #printableReceipt * { visibility: visible; }
            #printableReceipt { position: absolute; left: 0; top: 0; width: 100%; }
        }
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
                    <i class="fa-solid fa-receipt mr-1"></i> Cashier Billing & Invoice Generator
                </span>
                <h1 class="text-3xl font-black tracking-tight">Patient Billing Engine</h1>
                <p class="text-xs text-teal-100 mt-2 max-w-2xl leading-relaxed font-medium">
                    Calculate treatment fees + add-on services + registration fees. Update payment status and generate printable invoice receipts.
                </p>
            </div>
        </div>

        <!-- Invoices List -->
        <div class="bg-white rounded-3xl border border-slate-100 shadow-sm p-6">
            <h2 class="text-base font-bold text-slate-800 mb-6 flex items-center">
                <i class="fa-solid fa-file-invoice-dollar text-teal-600 mr-2"></i> Pending & Completed Invoices
            </h2>

            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="border-b border-slate-100 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                            <th class="pb-3">Invoice No</th>
                            <th class="pb-3">Appt No</th>
                            <th class="pb-3">Patient Name</th>
                            <th class="pb-3">Treatment Fee</th>
                            <th class="pb-3">Add-ons</th>
                            <th class="pb-3">Reg. Fee</th>
                            <th class="pb-3">Grand Total</th>
                            <th class="pb-3">Payment Status</th>
                            <th class="pb-3 text-right">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-xs font-semibold text-slate-700">
                        <% if (appointments.isEmpty()) { %>
                        <tr>
                            <td colspan="9" class="py-8 text-center text-slate-400 font-bold">
                                No appointments available for billing.
                            </td>
                        </tr>
                        <% } else { 
                            int invIdx = 5001;
                            for (Appointment a : appointments) {
                                String pName = a.getPatient() != null ? a.getPatient().getFullName() : "Patient";
                                double base = a.getBaseCost();
                                double total = a.getTotalCost();
                                double regFee = 500.0;
                                double addonsFee = Math.max(0, total - base);
                                double grandTotal = total + regFee;
                                String invNo = "INV-" + (invIdx++);
                                String status = a.getStatus();
                                String payStatus = "COMPLETED".equalsIgnoreCase(status) ? "PAID (Card)" : "UNPAID";
                                String payClass = "PAID (Card)".equals(payStatus) ? "bg-emerald-50 text-emerald-700" : "bg-amber-50 text-amber-700";
                        %>
                        <tr class="hover:bg-slate-50 transition-colors" id="row-<%= invNo %>">
                            <td class="py-4 font-bold text-purple-600"><%= invNo %></td>
                            <td class="py-4 font-extrabold text-teal-600"><%= a.getAppointmentNumber() %></td>
                            <td class="py-4 font-bold text-slate-800"><%= pName %></td>
                            <td class="py-4">LKR <%= String.format("%,.2f", base) %></td>
                            <td class="py-4">LKR <%= String.format("%,.2f", addonsFee) %></td>
                            <td class="py-4">LKR <%= String.format("%,.2f", regFee) %></td>
                            <td class="py-4 font-extrabold text-slate-900">LKR <%= String.format("%,.2f", grandTotal) %></td>
                            <td class="py-4">
                                <span id="status-<%= invNo %>" class="px-3 py-1 rounded-full text-[10px] font-extrabold <%= payClass %>"><%= payStatus %></span>
                            </td>
                            <td class="py-4 text-right space-x-1">
                                <button onclick="markAsPaid('<%= invNo %>')" class="px-3 py-1.5 bg-emerald-50 hover:bg-emerald-100 text-emerald-700 font-bold rounded-xl text-[11px] transition-all">
                                    <i class="fa-solid fa-check mr-1"></i> Paid
                                </button>
                                <button onclick="printReceipt('<%= invNo %>', '<%= a.getAppointmentNumber() %>', '<%= pName %>', '<%= a.getTreatmentType() %>', '<%= String.format("%.2f", grandTotal) %>', document.getElementById('status-<%= invNo %>').innerText)" class="px-3 py-1.5 bg-teal-50 hover:bg-teal-100 text-teal-700 font-bold rounded-xl text-[11px] transition-all">
                                    <i class="fa-solid fa-print mr-1"></i> Receipt
                                </button>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Printable Receipt Modal -->
    <div id="receiptModal" class="hidden fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
        <div id="printableReceipt" class="bg-white rounded-3xl max-w-md w-full p-8 shadow-2xl border border-slate-100">
            <div class="text-center pb-6 border-b border-slate-100">
                <div class="w-12 h-12 bg-teal-600 text-white rounded-2xl flex items-center justify-center mx-auto text-xl mb-2">
                    <i class="fa-solid fa-tooth"></i>
                </div>
                <h3 class="text-lg font-black text-slate-900">SUNRISE DENTAL CLINIC</h3>
                <p class="text-[10px] text-slate-500 uppercase font-bold tracking-wider">No. 45, Galle Road, Colombo 03 &bull; Tel: +94 11 234 5678</p>
            </div>

            <div class="py-4 space-y-2 text-xs font-semibold text-slate-700">
                <div class="flex justify-between"><span>Invoice Number:</span><span id="rcptInv" class="font-extrabold text-purple-600"></span></div>
                <div class="flex justify-between"><span>Appointment No:</span><span id="rcptApt" class="font-extrabold text-teal-600"></span></div>
                <div class="flex justify-between"><span>Patient Name:</span><span id="rcptPatient" class="font-bold text-slate-900"></span></div>
                <div class="flex justify-between"><span>Treatment:</span><span id="rcptTreatment"></span></div>
                <div class="flex justify-between border-t border-slate-100 pt-2 text-sm font-black text-slate-900">
                    <span>Total Paid:</span><span id="rcptTotal" class="text-teal-600"></span>
                </div>
                <div class="flex justify-between"><span>Status:</span><span id="rcptStatus" class="text-emerald-600 font-bold"></span></div>
            </div>

            <div class="mt-6 flex space-x-3">
                <button onclick="window.print()" class="flex-1 py-3 bg-teal-600 text-white font-bold rounded-2xl text-xs uppercase tracking-wider hover:bg-teal-700 transition-all">
                    <i class="fa-solid fa-print mr-1"></i> Print
                </button>
                <button onclick="document.getElementById('receiptModal').classList.add('hidden')" class="flex-1 py-3 bg-slate-100 text-slate-700 font-bold rounded-2xl text-xs uppercase tracking-wider hover:bg-slate-200 transition-all">
                    Close
                </button>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Cashier Billing Module
    </footer>

    <script>
        function markAsPaid(invNo) {
            const el = document.getElementById('status-' + invNo);
            if (el) {
                el.innerText = 'PAID (Cash)';
                el.className = 'px-3 py-1 rounded-full text-[10px] font-extrabold bg-emerald-50 text-emerald-700';
            }
        }

        function printReceipt(inv, apt, patient, treatment, total, status) {
            document.getElementById('rcptInv').innerText = inv;
            document.getElementById('rcptApt').innerText = apt;
            document.getElementById('rcptPatient').innerText = patient;
            document.getElementById('rcptTreatment').innerText = treatment;
            document.getElementById('rcptTotal').innerText = 'LKR ' + parseFloat(total).toLocaleString() + '.00';
            document.getElementById('rcptStatus').innerText = status;
            document.getElementById('receiptModal').classList.remove('hidden');
        }
    </script>
</body>
</html>
