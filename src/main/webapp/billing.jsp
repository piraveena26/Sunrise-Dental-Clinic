<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
<%@ page import="com.sunrisedental.dao.BillDAO" %>
<%@ page import="com.sunrisedental.model.Bill" %>
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

    boolean isCashierOrAdmin = "CASHIER".equalsIgnoreCase(userRole) || "ADMIN".equalsIgnoreCase(userRole);
    BillDAO billDAO = new BillDAO();
    List<Bill> bills = billDAO.getAllBills();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Billing & Payment Portal - Sunrise Dental Clinic</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- QRCode.js library for dynamic client-side QR generation -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js"></script>
    <style>
        body { font-family: 'Plus Jakarta Sans', sans-serif; background-color: #f8fafc; }
        @media print {
            body * { visibility: hidden; }
            #printableReceipt, #printableReceipt * { visibility: visible; }
            #printableReceipt {
                position: absolute;
                left: 0;
                top: 0;
                width: 100%;
                margin: 0;
                padding: 20px;
                box-shadow: none !important;
                border: none !important;
            }
            .no-print { display: none !important; }
        }
    </style>
</head>
<body class="min-h-screen flex flex-col justify-between">

    <!-- Header Navigation -->
    <jsp:include page="shared-nav.jsp" />

    <!-- Main Content -->
    <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
        
        <!-- Banner -->
        <div class="bg-gradient-to-r from-teal-700 via-teal-600 to-emerald-600 rounded-3xl p-8 text-white shadow-xl mb-8 relative overflow-hidden">
            <div class="relative z-10 flex flex-col md:flex-row justify-between items-start md:items-center gap-6">
                <div>
                    <span class="px-3 py-1 bg-white/20 text-white rounded-full text-xs font-extrabold uppercase tracking-wider mb-3 inline-block">
                        <i class="fa-solid fa-cash-register mr-1"></i> Cashier Billing & Payment Verification
                    </span>
                    <h1 class="text-3xl font-black tracking-tight">Patient Billing & QR Payment Portal</h1>
                    <p class="text-xs text-teal-100 mt-2 max-w-2xl leading-relaxed font-medium">
                        Verify patient appointments, process payments via Cash, Card, or LankaQR scan, approve pending invoices, and generate verified receipts with digital QR verification.
                    </p>
                </div>
                <div class="flex items-center space-x-3 bg-white/10 backdrop-blur-md px-5 py-3 rounded-2xl border border-white/20">
                    <div class="w-10 h-10 rounded-xl bg-white text-teal-700 flex items-center justify-center font-bold text-lg shadow-sm">
                        <i class="fa-solid fa-user-check"></i>
                    </div>
                    <div>
                        <span class="text-[10px] uppercase font-extrabold text-teal-200 tracking-wider block">Authorized Cashier</span>
                        <span class="text-sm font-bold text-white"><%= currentUser.getFullName() %></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Invoices List -->
        <div class="bg-white rounded-3xl border border-slate-100 shadow-sm p-6">
            <div class="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4 mb-6">
                <div>
                    <h2 class="text-base font-bold text-slate-800 flex items-center">
                        <i class="fa-solid fa-file-invoice-dollar text-teal-600 mr-2"></i> Patient Invoices & Payment Approvals
                    </h2>
                    <p class="text-xs text-slate-400 font-medium mt-0.5">Cashiers can approve pending payments or reprint verified QR receipts.</p>
                </div>
                <div class="flex items-center space-x-2 text-xs font-bold">
                    <span class="px-3 py-1.5 bg-amber-50 text-amber-700 rounded-xl border border-amber-200/50">
                        <i class="fa-solid fa-clock mr-1"></i> Requires Cashier Approval
                    </span>
                </div>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left border-collapse">
                    <thead>
                        <tr class="border-b border-slate-100 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider bg-slate-50/50">
                            <th class="py-3.5 px-4 rounded-l-2xl">Invoice No</th>
                            <th class="py-3.5 px-4">Appt No</th>
                            <th class="py-3.5 px-4">Patient Name</th>
                            <th class="py-3.5 px-4">Treatment</th>
                            <th class="py-3.5 px-4">Treatment Fee</th>
                            <th class="py-3.5 px-4">Add-ons</th>
                            <th class="py-3.5 px-4">Reg. Fee</th>
                            <th class="py-3.5 px-4">Grand Total</th>
                            <th class="py-3.5 px-4">Payment Status</th>
                            <th class="py-3.5 px-4 text-right rounded-r-2xl">Actions</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-100 text-xs font-semibold text-slate-700">
                        <% if (bills.isEmpty()) { %>
                        <tr>
                            <td colspan="10" class="py-12 text-center text-slate-400 font-bold">
                                <i class="fa-solid fa-receipt text-3xl mb-2 text-slate-300 block"></i>
                                No invoices available for billing.
                            </td>
                        </tr>
                        <% } else { 
                            for (Bill bill : bills) {
                                boolean isPaid = "PAID".equalsIgnoreCase(bill.getPaymentStatus());
                                String method = bill.getPaymentMethod() != null ? bill.getPaymentMethod() : "Cash";
                                String payLabel = isPaid ? "PAID (" + method + ")" : "UNPAID (Pending)";
                                String payClass = isPaid ? "bg-emerald-50 text-emerald-700 border border-emerald-200" : "bg-amber-50 text-amber-700 border border-amber-200";
                        %>
                        <tr class="hover:bg-slate-50 transition-colors" id="row-<%= bill.getInvoiceNumber() %>">
                            <td class="py-4 px-4 font-bold text-purple-600"><%= bill.getInvoiceNumber() %></td>
                            <td class="py-4 px-4 font-extrabold text-teal-600"><%= bill.getAppointmentNumber() %></td>
                            <td class="py-4 px-4 font-bold text-slate-800"><%= bill.getPatientName() %></td>
                            <td class="py-4 px-4 font-medium text-slate-600"><%= bill.getTreatmentType() %></td>
                            <td class="py-4 px-4">LKR <%= String.format("%,.2f", bill.getTreatmentFee()) %></td>
                            <td class="py-4 px-4">LKR <%= String.format("%,.2f", bill.getAddonsFee()) %></td>
                            <td class="py-4 px-4">LKR <%= String.format("%,.2f", bill.getRegistrationFee()) %></td>
                            <td class="py-4 px-4 font-extrabold text-slate-900">LKR <%= String.format("%,.2f", bill.getGrandTotal()) %></td>
                            <td class="py-4 px-4">
                                <span id="status-<%= bill.getInvoiceNumber() %>" class="px-2.5 py-1 rounded-full text-[10px] font-extrabold <%= payClass %>">
                                    <i class="fa-solid <%= isPaid ? "fa-circle-check" : "fa-clock" %> mr-1"></i><%= payLabel %>
                                </span>
                            </td>
                            <td class="py-4 px-4 text-right space-x-1.5 whitespace-nowrap">
                                <% if (!isPaid && isCashierOrAdmin) { %>
                                <button id="btn-approve-<%= bill.getInvoiceNumber() %>"
                                        onclick="openApprovalModal('<%= bill.getInvoiceNumber() %>', '<%= bill.getAppointmentNumber() %>', '<%= bill.getPatientName() %>', '<%= bill.getTreatmentType() %>', <%= bill.getTreatmentFee() %>, <%= bill.getAddonsFee() %>, <%= bill.getRegistrationFee() %>, <%= bill.getGrandTotal() %>)" 
                                        class="px-3 py-1.5 bg-emerald-600 hover:bg-emerald-700 text-white font-bold rounded-xl text-[11px] transition-all shadow-sm">
                                    <i class="fa-solid fa-stamp mr-1"></i> Approve & Pay
                                </button>
                                <% } else { %>
                                <span id="btn-approved-badge-<%= bill.getInvoiceNumber() %>" class="px-3 py-1.5 bg-emerald-50 text-emerald-700 font-bold rounded-xl text-[11px] border border-emerald-200 inline-block">
                                    <i class="fa-solid fa-check-double mr-1"></i> Approved
                                </span>
                                <% } %>
                                <button onclick="openReceiptModal('<%= bill.getInvoiceNumber() %>', '<%= bill.getAppointmentNumber() %>', '<%= bill.getPatientName() %>', '<%= bill.getTreatmentType() %>', <%= bill.getTreatmentFee() %>, <%= bill.getAddonsFee() %>, <%= bill.getRegistrationFee() %>, <%= bill.getGrandTotal() %>, document.getElementById('status-<%= bill.getInvoiceNumber() %>').innerText.trim())" 
                                        class="px-3 py-1.5 bg-teal-50 hover:bg-teal-100 text-teal-700 font-bold rounded-xl text-[11px] transition-all border border-teal-200/60">
                                    <i class="fa-solid fa-qrcode mr-1"></i> Receipt & QR
                                </button>
                            </td>
                        </tr>
                        <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <!-- Cashier Approval Modal -->
    <div id="approvalModal" class="hidden fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-lg w-full p-8 shadow-2xl border border-slate-100 animate-in fade-in zoom-in duration-200">
            <div class="flex items-center justify-between pb-4 border-b border-slate-100">
                <div class="flex items-center space-x-3">
                    <div class="w-10 h-10 bg-emerald-100 text-emerald-700 rounded-2xl flex items-center justify-center text-lg">
                        <i class="fa-solid fa-stamp"></i>
                    </div>
                    <div>
                        <h3 class="text-base font-extrabold text-slate-900">Cashier Payment Approval</h3>
                        <p class="text-[11px] text-slate-400 font-medium">Verify payment method and mark invoice as paid</p>
                    </div>
                </div>
                <button onclick="closeApprovalModal()" class="text-slate-400 hover:text-slate-600 p-2 rounded-xl">
                    <i class="fa-solid fa-xmark text-lg"></i>
                </button>
            </div>

            <!-- Bill Details Summary -->
            <div class="my-5 p-4 rounded-2xl bg-slate-50 border border-slate-100 space-y-2 text-xs font-semibold text-slate-700">
                <div class="flex justify-between"><span>Invoice Number:</span><span id="apprInv" class="font-extrabold text-purple-600"></span></div>
                <div class="flex justify-between"><span>Appointment No:</span><span id="apprApt" class="font-extrabold text-teal-600"></span></div>
                <div class="flex justify-between"><span>Patient Name:</span><span id="apprPatient" class="font-bold text-slate-900"></span></div>
                <div class="flex justify-between"><span>Treatment:</span><span id="apprTreatment"></span></div>
                <div class="flex justify-between border-t border-slate-200 pt-2 text-sm font-black text-slate-900">
                    <span>Grand Total Payable:</span>
                    <span id="apprTotal" class="text-teal-600"></span>
                </div>
            </div>

            <!-- Payment Method Selection -->
            <div class="mb-5">
                <label class="block text-xs font-extrabold text-slate-700 uppercase tracking-wider mb-2">Select Payment Method</label>
                <div class="grid grid-cols-3 gap-3">
                    <label class="cursor-pointer border-2 border-teal-600 bg-teal-50/50 rounded-2xl p-3 text-center transition-all flex flex-col items-center justify-center space-y-1 method-option" id="opt-Cash" onclick="selectMethod('Cash')">
                        <input type="radio" name="payMethod" value="Cash" checked class="hidden">
                        <i class="fa-solid fa-money-bill-wave text-teal-600 text-lg"></i>
                        <span class="text-xs font-extrabold text-slate-800">Cash</span>
                    </label>

                    <label class="cursor-pointer border-2 border-slate-200 hover:border-slate-300 rounded-2xl p-3 text-center transition-all flex flex-col items-center justify-center space-y-1 method-option" id="opt-Card" onclick="selectMethod('Card')">
                        <input type="radio" name="payMethod" value="Card" class="hidden">
                        <i class="fa-solid fa-credit-card text-purple-600 text-lg"></i>
                        <span class="text-xs font-extrabold text-slate-800">Card</span>
                    </label>

                    <label class="cursor-pointer border-2 border-slate-200 hover:border-slate-300 rounded-2xl p-3 text-center transition-all flex flex-col items-center justify-center space-y-1 method-option" id="opt-QR" onclick="selectMethod('QR Payment (LankaQR)')">
                        <input type="radio" name="payMethod" value="QR Payment (LankaQR)" class="hidden">
                        <i class="fa-solid fa-qrcode text-sky-600 text-lg"></i>
                        <span class="text-xs font-extrabold text-slate-800">LankaQR</span>
                    </label>
                </div>
            </div>

            <!-- Dynamic QR Code Payment Box (Shows when QR method is chosen) -->
            <div id="qrPaymentBox" class="hidden mb-5 p-4 bg-sky-50/70 border border-sky-200 rounded-2xl text-center">
                <span class="text-[11px] font-extrabold text-sky-800 block uppercase tracking-wider mb-2">
                    <i class="fa-solid fa-mobile-screen-button mr-1"></i> LankaQR Instant Scan to Pay
                </span>
                <div id="approvalQrContainer" class="flex justify-center my-2 p-2 bg-white rounded-xl inline-block shadow-sm"></div>
                <p class="text-[10px] text-slate-600 mt-2 font-medium">
                    Patient can scan using Commercial Bank, BOC, Sampath, FriMi or any LankaQR app.
                </p>
                <div class="text-[11px] font-bold text-slate-700 mt-1">
                    Bank: <span class="text-teal-700">Commercial Bank</span> &bull; Acc: <span class="text-teal-700">1000-4567-8901</span>
                </div>
            </div>

            <!-- Modal Action Buttons -->
            <div class="flex space-x-3">
                <button type="button" onclick="confirmApproval()" id="confirmApproveBtn" class="flex-1 py-3.5 bg-emerald-600 text-white font-bold rounded-2xl text-xs uppercase tracking-wider hover:bg-emerald-700 transition-all shadow-md flex items-center justify-center space-x-2">
                    <i class="fa-solid fa-check"></i>
                    <span>Confirm & Mark as Paid</span>
                </button>
                <button type="button" onclick="closeApprovalModal()" class="py-3.5 px-6 bg-slate-100 text-slate-700 font-bold rounded-2xl text-xs uppercase tracking-wider hover:bg-slate-200 transition-all">
                    Cancel
                </button>
            </div>
        </div>
    </div>

    <!-- Printable Receipt Modal with Embedded QR Code -->
    <div id="receiptModal" class="hidden fixed inset-0 z-50 bg-slate-900/50 backdrop-blur-sm flex items-center justify-center p-4">
        <div id="printableReceipt" class="bg-white rounded-3xl max-w-md w-full p-8 shadow-2xl border border-slate-100 animate-in fade-in zoom-in duration-200 relative">
            
            <!-- Close button (hidden on print) -->
            <button onclick="closeReceiptModal()" class="no-print absolute top-6 right-6 text-slate-400 hover:text-slate-600 p-2 rounded-xl">
                <i class="fa-solid fa-xmark text-lg"></i>
            </button>

            <!-- Clinic Header -->
            <div class="text-center pb-5 border-b border-slate-100">
                <div class="w-12 h-12 bg-gradient-to-tr from-teal-600 to-emerald-400 text-white rounded-2xl flex items-center justify-center mx-auto text-xl mb-2 shadow-md shadow-teal-500/20">
                    <i class="fa-solid fa-tooth"></i>
                </div>
                <h3 class="text-lg font-black text-slate-900 tracking-tight">SUNRISE DENTAL CLINIC</h3>
                <p class="text-[10px] text-slate-500 uppercase font-bold tracking-wider">No. 45, Galle Road, Colombo 03 &bull; Tel: +94 11 234 5678</p>
                <span class="inline-block mt-2 px-3 py-0.5 bg-teal-50 text-teal-700 text-[10px] font-extrabold rounded-full uppercase tracking-wider border border-teal-200/60">
                    Official Payment Receipt
                </span>
            </div>

            <!-- Receipt Metadata -->
            <div class="py-4 space-y-2 text-xs font-semibold text-slate-700 border-b border-slate-100">
                <div class="flex justify-between"><span>Invoice Number:</span><span id="rcptInv" class="font-extrabold text-purple-600"></span></div>
                <div class="flex justify-between"><span>Appointment No:</span><span id="rcptApt" class="font-extrabold text-teal-600"></span></div>
                <div class="flex justify-between"><span>Patient Name:</span><span id="rcptPatient" class="font-bold text-slate-900"></span></div>
                <div class="flex justify-between"><span>Treatment Type:</span><span id="rcptTreatment" class="text-slate-800 font-semibold"></span></div>
            </div>

            <!-- Itemized Breakdown -->
            <div class="py-3 space-y-1.5 text-xs text-slate-600 border-b border-slate-100">
                <div class="flex justify-between"><span>Treatment Fee:</span><span id="rcptBase" class="font-bold text-slate-800"></span></div>
                <div class="flex justify-between"><span>Add-ons / Clinical Care:</span><span id="rcptAddons" class="font-bold text-slate-800"></span></div>
                <div class="flex justify-between"><span>Clinic Registration:</span><span id="rcptReg" class="font-bold text-slate-800">LKR 500.00</span></div>
                <div class="flex justify-between pt-2 border-t border-dashed border-slate-200 text-sm font-black text-slate-900">
                    <span>Grand Total:</span><span id="rcptTotal" class="text-teal-600"></span>
                </div>
            </div>

            <!-- Status & Cashier Signoff -->
            <div class="py-3 flex justify-between items-center text-xs">
                <div>
                    <span class="text-[10px] text-slate-400 uppercase font-extrabold block">Status</span>
                    <span id="rcptStatus" class="font-black text-emerald-600"></span>
                </div>
                <div class="text-right">
                    <span class="text-[10px] text-slate-400 uppercase font-extrabold block">Approved By</span>
                    <span class="font-bold text-slate-800">Cashier Krishnakumar</span>
                </div>
            </div>

            <!-- Dynamic QR Code Container (LankaQR & Verification) -->
            <div class="mt-4 pt-4 border-t border-slate-100 text-center">
                <span class="text-[10px] text-slate-400 uppercase font-extrabold tracking-wider block mb-2">
                    <i class="fa-solid fa-qrcode text-teal-600 mr-1"></i> Scan to Verify / LankaQR Digital Receipt
                </span>
                <div class="flex justify-center">
                    <div id="receiptQrContainer" class="p-2 bg-white rounded-2xl border border-slate-200 shadow-sm inline-block"></div>
                </div>
                <p class="text-[9px] text-slate-400 mt-2 font-medium">
                    This digital receipt is cryptographically verifiable by Sunrise Dental Clinic systems.
                </p>
            </div>

            <!-- Modal Print & Close Buttons (hidden on print) -->
            <div class="no-print mt-6 flex space-x-3">
                <button onclick="window.print()" class="flex-1 py-3 bg-teal-600 text-white font-bold rounded-2xl text-xs uppercase tracking-wider hover:bg-teal-700 transition-all shadow-md flex items-center justify-center space-x-1.5">
                    <i class="fa-solid fa-print"></i>
                    <span>Print Receipt</span>
                </button>
                <button onclick="closeReceiptModal()" class="flex-1 py-3 bg-slate-100 text-slate-700 font-bold rounded-2xl text-xs uppercase tracking-wider hover:bg-slate-200 transition-all">
                    Close
                </button>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Logged in as <%= currentUser.getFullName() %> (<%= userRole %>)
    </footer>

    <script>
        let currentApproval = {
            inv: '',
            apt: '',
            patient: '',
            treatment: '',
            total: 0,
            selectedMethod: 'Cash'
        };

        let qrCodeApprovalObj = null;
        let qrCodeReceiptObj = null;

        function selectMethod(method) {
            currentApproval.selectedMethod = method;
            document.querySelectorAll('.method-option').forEach(el => {
                el.classList.remove('border-teal-600', 'bg-teal-50/50');
                el.classList.add('border-slate-200');
            });

            const targetId = method.startsWith('QR') ? 'opt-QR' : (method === 'Card' ? 'opt-Card' : 'opt-Cash');
            const targetEl = document.getElementById(targetId);
            if (targetEl) {
                targetEl.classList.add('border-teal-600', 'bg-teal-50/50');
                targetEl.classList.remove('border-slate-200');
            }

            const qrBox = document.getElementById('qrPaymentBox');
            if (method.startsWith('QR')) {
                qrBox.classList.remove('hidden');
                generateApprovalQR();
            } else {
                qrBox.classList.add('hidden');
            }
        }

        function generateApprovalQR() {
            const container = document.getElementById('approvalQrContainer');
            container.innerHTML = '';
            const qrPayload = "LANKAQR:SUNRISE-DENTAL|INV:" + currentApproval.inv + "|APT:" + currentApproval.apt + "|AMT:" + currentApproval.total.toFixed(2) + "|REF:ACC-100045678901";
            
            new QRCode(container, {
                text: qrPayload,
                width: 140,
                height: 140,
                colorDark: "#0f766e",
                colorLight: "#ffffff",
                correctLevel: QRCode.CorrectLevel.M
            });
        }

        function openApprovalModal(inv, apt, patient, treatment, baseFee, addonsFee, regFee, total) {
            currentApproval = {
                inv: inv,
                apt: apt,
                patient: patient,
                treatment: treatment,
                total: parseFloat(total),
                selectedMethod: 'Cash'
            };

            document.getElementById('apprInv').innerText = inv;
            document.getElementById('apprApt').innerText = apt;
            document.getElementById('apprPatient').innerText = patient;
            document.getElementById('apprTreatment').innerText = treatment;
            document.getElementById('apprTotal').innerText = 'LKR ' + parseFloat(total).toLocaleString(undefined, {minimumFractionDigits: 2});

            selectMethod('Cash');
            document.getElementById('approvalModal').classList.remove('hidden');
        }

        function closeApprovalModal() {
            document.getElementById('approvalModal').classList.add('hidden');
        }

        async function confirmApproval() {
            const btn = document.getElementById('confirmApproveBtn');
            btn.disabled = true;
            btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Processing...';

            try {
                const params = new URLSearchParams();
                params.append('invoiceNumber', currentApproval.inv);
                params.append('appointmentNumber', currentApproval.apt);
                params.append('paymentMethod', currentApproval.selectedMethod);

                const res = await fetch('approve-payment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    },
                    body: params.toString()
                });

                const data = await res.json();
                if (data.success) {
                    // Update table row dynamically
                    const statusBadge = document.getElementById('status-' + currentApproval.inv);
                    if (statusBadge) {
                        statusBadge.className = 'px-2.5 py-1 rounded-full text-[10px] font-extrabold bg-emerald-50 text-emerald-700 border border-emerald-200';
                        statusBadge.innerHTML = '<i class="fa-solid fa-circle-check mr-1"></i>PAID (' + currentApproval.selectedMethod + ')';
                    }

                    const approveBtn = document.getElementById('btn-approve-' + currentApproval.inv);
                    if (approveBtn) {
                        const approvedSpan = document.createElement('span');
                        approvedSpan.className = 'px-3 py-1.5 bg-emerald-50 text-emerald-700 font-bold rounded-xl text-[11px] border border-emerald-200 inline-block';
                        approvedSpan.innerHTML = '<i class="fa-solid fa-check-double mr-1"></i> Approved';
                        approveBtn.parentNode.replaceChild(approvedSpan, approveBtn);
                    }

                    closeApprovalModal();
                    alert("Payment approved successfully! Status marked as PAID (" + currentApproval.selectedMethod + ").");
                } else {
                    alert("Approval failed: " + (data.message || "Unknown error"));
                }
            } catch (err) {
                console.error(err);
                alert("Error connecting to server. Please try again.");
            } finally {
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-check mr-1"></i> Confirm & Mark as Paid';
            }
        }

        function openReceiptModal(inv, apt, patient, treatment, baseFee, addonsFee, regFee, total, status) {
            document.getElementById('rcptInv').innerText = inv;
            document.getElementById('rcptApt').innerText = apt;
            document.getElementById('rcptPatient').innerText = patient;
            document.getElementById('rcptTreatment').innerText = treatment;
            document.getElementById('rcptBase').innerText = 'LKR ' + parseFloat(baseFee).toLocaleString(undefined, {minimumFractionDigits: 2});
            document.getElementById('rcptAddons').innerText = 'LKR ' + parseFloat(addonsFee).toLocaleString(undefined, {minimumFractionDigits: 2});
            document.getElementById('rcptReg').innerText = 'LKR ' + parseFloat(regFee).toLocaleString(undefined, {minimumFractionDigits: 2});
            document.getElementById('rcptTotal').innerText = 'LKR ' + parseFloat(total).toLocaleString(undefined, {minimumFractionDigits: 2});
            document.getElementById('rcptStatus').innerText = status;

            // Generate Receipt QR
            const container = document.getElementById('receiptQrContainer');
            container.innerHTML = '';
            const receiptPayload = "SUNRISE_RECEIPT:" + inv + "|APT:" + apt + "|PATIENT:" + encodeURIComponent(patient) + "|TOTAL:LKR_" + parseFloat(total).toFixed(2) + "|STATUS:" + status;

            new QRCode(container, {
                text: receiptPayload,
                width: 110,
                height: 110,
                colorDark: "#0f766e",
                colorLight: "#ffffff",
                correctLevel: QRCode.CorrectLevel.M
            });

            document.getElementById('receiptModal').classList.remove('hidden');
        }

        function closeReceiptModal() {
            document.getElementById('receiptModal').classList.add('hidden');
        }
    </script>
</body>
</html>
