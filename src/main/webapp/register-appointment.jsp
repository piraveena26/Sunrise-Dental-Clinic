<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
<%@ page import="com.sunrisedental.dao.UserDAO" %>
<%@ page import="com.sunrisedental.model.Patient" %>
<%@ page import="com.sunrisedental.dao.DoctorScheduleDAO" %>
<%@ page import="com.sunrisedental.model.DoctorSchedule" %>
<%@ page import="java.util.List" %>
<%
    User currentUser = (User) session.getAttribute("user");
    if (currentUser == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    String userRole = currentUser.getRole();
    if (!"ADMIN".equalsIgnoreCase(userRole) && !"PATIENT".equalsIgnoreCase(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    Patient patientProfile = userDAO.getPatientByUserId(currentUser.getId());
    if (patientProfile == null && currentUser.getUsername() != null) {
        patientProfile = userDAO.getPatientByUsername(currentUser.getUsername());
    }
    if (patientProfile == null) {
        patientProfile = userDAO.getPatientByEmailOrPhone(currentUser.getEmail(), currentUser.getPhone());
    }

    String nameVal = (patientProfile != null && patientProfile.getFullName() != null && !patientProfile.getFullName().isEmpty()) 
                     ? patientProfile.getFullName() : (currentUser.getFullName() != null ? currentUser.getFullName() : "");
    String phoneVal = (patientProfile != null && patientProfile.getContactNumber() != null && !patientProfile.getContactNumber().isEmpty()) 
                     ? patientProfile.getContactNumber() : (currentUser.getPhone() != null ? currentUser.getPhone() : "");
    String emailVal = (patientProfile != null && patientProfile.getEmail() != null && !patientProfile.getEmail().isEmpty()) 
                     ? patientProfile.getEmail() : (currentUser.getEmail() != null ? currentUser.getEmail() : "");
    String nicVal = (patientProfile != null && patientProfile.getNicPassport() != null) ? patientProfile.getNicPassport() : "";
    int ageVal = (patientProfile != null && patientProfile.getAge() > 0) ? patientProfile.getAge() : 0;
    String genderVal = (patientProfile != null && patientProfile.getGender() != null) ? patientProfile.getGender() : "Female";

    DoctorScheduleDAO scheduleDAO = new DoctorScheduleDAO();
    List<DoctorSchedule> doctorSchedules = scheduleDAO.getAllSchedules();
    List<com.sunrisedental.model.Doctor> doctorsList = scheduleDAO.getAllDoctors();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Appointment - Sunrise Dental Clinic</title>
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
            <div class="relative z-10">
                <span class="px-3 py-1 bg-white/20 text-white rounded-full text-xs font-extrabold uppercase tracking-wider mb-3 inline-block">
                    <i class="fa-solid fa-calendar-plus mr-1"></i> Patient Appointment Booking
                </span>
                <h1 class="text-3xl font-black tracking-tight">Register New Dental Appointment</h1>
                <p class="text-xs text-teal-100 mt-2 max-w-2xl leading-relaxed font-medium">
                    Complete patient details, choose dentist and treatment. Unavailable dates or leave slots scheduled by doctors are automatically blocked to prevent scheduling conflicts.
                </p>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <!-- Booking Form -->
            <div class="lg:col-span-2 bg-white p-8 rounded-3xl border border-slate-100 shadow-sm">
                <h2 class="text-lg font-bold text-slate-800 mb-6 flex items-center">
                    <i class="fa-solid fa-user-pen text-teal-600 mr-2"></i> Patient & Treatment Details
                </h2>

                <form id="appointmentForm" class="space-y-6">
                    
                    <!-- Patient Basic Info -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Patient Full Name *</label>
                            <input type="text" id="patientName" required value="<%= nameVal %>" placeholder="e.g. Full Name" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Phone Number *</label>
                            <input type="text" id="patientPhone" required value="<%= phoneVal %>" placeholder="+94 77 123 4567" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                        </div>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Email Address *</label>
                            <input type="email" id="patientEmail" required value="<%= emailVal %>" placeholder="name@example.com" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">NIC / Passport *</label>
                            <input type="text" id="patientNic" required value="<%= nicVal %>" placeholder="e.g. 199854321098" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Age & Gender *</label>
                            <div class="flex space-x-2">
                                <input type="number" id="patientAge" value="<%= ageVal > 0 ? String.valueOf(ageVal) : "" %>" placeholder="Age" min="1" max="120" class="w-1/2 px-3 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                                <select id="patientGender" class="w-1/2 px-2 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                                    <option value="Female" <%= "Female".equalsIgnoreCase(genderVal) ? "selected" : "" %>>Female</option>
                                    <option value="Male" <%= "Male".equalsIgnoreCase(genderVal) ? "selected" : "" %>>Male</option>
                                    <option value="Other" <%= "Other".equalsIgnoreCase(genderVal) ? "selected" : "" %>>Other</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <hr class="border-slate-100 my-4">

                    <!-- Doctor & Treatment Selection -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Select Dentist *</label>
                            <select id="dentistName" onchange="checkAvailability(true)" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                                <% for (com.sunrisedental.model.Doctor doc : doctorsList) { %>
                                <option value="<%= doc.getName() %>"><%= doc.getName() %> (<%= doc.getSpecialization() %>)</option>
                                <% } %>
                            </select>
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Treatment Type *</label>
                            <select id="treatmentType" onchange="calculateLiveFee()" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                                <option value="Routine Checkup" data-cost="3000">Routine Checkup (LKR 3,000)</option>
                                <option value="Teeth Whitening" data-cost="8000">Teeth Whitening (LKR 8,000)</option>
                                <option value="Root Canal" data-cost="15000">Root Canal Treatment (LKR 15,000)</option>
                                <option value="Orthodontic Braces" data-cost="45000">Orthodontic Braces (LKR 45,000)</option>
                                <option value="Dental Filling" data-cost="4500">Dental Filling (LKR 4,500)</option>
                                <option value="Tooth Extraction" data-cost="3500">Tooth Extraction (LKR 3,500)</option>
                            </select>
                        </div>
                    </div>

                    <!-- Date & Time Slot -->
                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Appointment Date *</label>
                            <input type="date" id="appointmentDate" onchange="checkAvailability(true)" required class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Time Slot *</label>
                            <select id="appointmentTime" onchange="checkAvailability(true)" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                                <option value="09:00">09:00 AM - Morning Slot</option>
                                <option value="10:30">10:30 AM - Morning Slot</option>
                                <option value="14:00">02:00 PM - Afternoon Slot</option>
                                <option value="15:30">03:30 PM - Afternoon Slot</option>
                            </select>
                        </div>
                    </div>

                    <!-- Doctor Availability Conflict Warning -->
                    <div id="availabilityAlert" class="hidden p-4 rounded-2xl bg-amber-50 border border-amber-200 text-amber-800 text-xs font-bold items-center space-x-2">
                        <i class="fa-solid fa-triangle-exclamation text-base text-amber-600"></i>
                        <span id="availabilityText">Selected Doctor is on Leave / Unavailable for this date/time! Please select another date or time slot.</span>
                    </div>

                    <!-- Add-on Services -->
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-2">Optional Add-on Services</label>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-3">
                            <label class="flex items-center p-3 rounded-2xl border border-slate-200 hover:border-teal-300 cursor-pointer transition-all bg-slate-50">
                                <input type="checkbox" class="addon-checkbox text-teal-600 rounded-lg focus:ring-teal-500 mr-2" value="Digital X-Ray" data-cost="1500" onchange="calculateLiveFee()">
                                <span class="text-xs font-semibold text-slate-700">Digital X-Ray (+LKR 1,500)</span>
                            </label>
                            <label class="flex items-center p-3 rounded-2xl border border-slate-200 hover:border-teal-300 cursor-pointer transition-all bg-slate-50">
                                <input type="checkbox" class="addon-checkbox text-teal-600 rounded-lg focus:ring-teal-500 mr-2" value="Local Anaesthesia" data-cost="700" onchange="calculateLiveFee()">
                                <span class="text-xs font-semibold text-slate-700">Local Anaesthesia (+LKR 700)</span>
                            </label>
                            <label class="flex items-center p-3 rounded-2xl border border-slate-200 hover:border-teal-300 cursor-pointer transition-all bg-slate-50">
                                <input type="checkbox" class="addon-checkbox text-teal-600 rounded-lg focus:ring-teal-500 mr-2" value="Fluoride Treatment" data-cost="2000" onchange="calculateLiveFee()">
                                <span class="text-xs font-semibold text-slate-700">Fluoride Treatment (+LKR 2,000)</span>
                            </label>
                            <label class="flex items-center p-3 rounded-2xl border border-slate-200 hover:border-teal-300 cursor-pointer transition-all bg-slate-50">
                                <input type="checkbox" class="addon-checkbox text-teal-600 rounded-lg focus:ring-teal-500 mr-2" value="Post-Care Hygiene Kit" data-cost="1500" onchange="calculateLiveFee()">
                                <span class="text-xs font-semibold text-slate-700">Post-Care Hygiene Kit (+LKR 1,500)</span>
                            </label>
                        </div>
                    </div>

                    <button type="button" id="submitBtn" onclick="submitAppointment()" class="w-full py-4 bg-gradient-to-r from-teal-600 to-emerald-500 text-white font-extrabold rounded-2xl text-xs uppercase tracking-wider hover:opacity-95 transition-all duration-200 shadow-lg shadow-teal-500/25">
                        <i class="fa-solid fa-check-circle mr-2"></i> Confirm & Register Appointment
                    </button>
                </form>
            </div>

            <!-- Price Breakdown Side Card -->
            <div class="lg:col-span-1 bg-white p-6 rounded-3xl border border-slate-100 shadow-sm h-fit">
                <h3 class="text-base font-bold text-slate-800 mb-4 flex items-center">
                    <i class="fa-solid fa-calculator text-teal-600 mr-2"></i> Fee Breakdown
                </h3>

                <div class="space-y-3 text-xs font-semibold text-slate-600">
                    <div class="flex justify-between py-2 border-b border-slate-100">
                        <span>Base Treatment Rate:</span>
                        <span id="baseRateText" class="font-extrabold text-slate-800">LKR 3,000.00</span>
                    </div>
                    <div class="flex justify-between py-2 border-b border-slate-100">
                        <span>Add-on Fees:</span>
                        <span id="addonRateText" class="font-extrabold text-teal-600">LKR 0.00</span>
                    </div>
                    <div class="flex justify-between py-3 text-sm font-black text-slate-900 border-t border-slate-200">
                        <span>Total Fee:</span>
                        <span id="totalRateText" class="text-teal-600">LKR 3,000.00</span>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- Success Modal -->
    <div id="successModal" class="hidden fixed inset-0 z-50 bg-slate-900/40 backdrop-blur-sm flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl max-w-md w-full p-8 text-center shadow-2xl border border-slate-100">
            <div class="w-16 h-16 bg-emerald-100 text-emerald-600 rounded-full flex items-center justify-center mx-auto text-2xl mb-4">
                <i class="fa-solid fa-circle-check"></i>
            </div>
            <h3 class="text-xl font-black text-slate-900">Appointment Registered!</h3>
            <p class="text-xs text-slate-500 mt-2">Your appointment has been registered in the system. Confirmation SMS & Email observers dispatched.</p>
            <div class="mt-4 p-4 rounded-2xl bg-slate-50 text-xs font-bold text-slate-800 text-left space-y-1">
                <div>Appointment No: <span id="modalAptNo" class="text-teal-600 font-extrabold"></span></div>
                <div>Dentist: <span id="modalDentist"></span></div>
                <div>Date & Time: <span id="modalDateTime"></span></div>
            </div>
            <button onclick="window.location.href='appointment-details.jsp'" class="mt-6 w-full py-3.5 bg-teal-600 text-white font-bold rounded-2xl text-xs uppercase tracking-wider hover:bg-teal-700 transition-all">
                View My Appointments
            </button>
        </div>
    </div>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Patient Appointment Booking Portal
    </footer>

    <script>
        // Set default date to tomorrow
        const tomorrow = new Date();
        tomorrow.setDate(tomorrow.getDate() + 1);
        document.getElementById('appointmentDate').value = tomorrow.toISOString().split('T')[0];

        // Doctor Unavailability Schedule Data from Server
        const blockedSchedules = [
            <% for (DoctorSchedule s : doctorSchedules) { %>
            { 
                doctor: "<%= s.getDoctorName() != null ? s.getDoctorName().replace("\"", "\\\"").trim() : "" %>", 
                date: "<%= s.getUnavailableDate() != null ? s.getUnavailableDate().trim() : "" %>", 
                slot: "<%= s.getTimeSlot() != null ? s.getTimeSlot().trim() : "" %>" 
            },
            <% } %>
        ];

        let lastAlertedState = false;

        function checkAvailability(userAction = false) {
            const dentist = document.getElementById('dentistName').value.trim();
            const date = document.getElementById('appointmentDate').value.trim();
            const time = document.getElementById('appointmentTime').value.trim();

            let isBlocked = false;
            let blockReason = "Selected Doctor is on Leave / Unavailable for this date/time.";
            
            const cleanDentist = dentist.toLowerCase().replace(/^dr\.\s*/i, '').trim();

            for (let s of blockedSchedules) {
                const sDoctor = (s.doctor || "").toLowerCase().replace(/^dr\.\s*/i, '').trim();
                const matchDoctor = sDoctor === cleanDentist || sDoctor.includes(cleanDentist) || cleanDentist.includes(sDoctor);
                const matchDate = s.date === date;
                const matchSlot = (s.slot === 'ALL_DAY' || s.slot === 'ALL' || s.slot === time);

                if (matchDoctor && matchDate && matchSlot) {
                    isBlocked = true;
                    if (s.slot === 'ALL_DAY' || s.slot === 'ALL') {
                        blockReason = dentist + " is on FULL DAY LEAVE on " + date + ". Please choose another date or doctor.";
                    } else {
                        blockReason = dentist + " is UNAVAILABLE at " + time + " on " + date + ". Please choose another time slot or doctor.";
                    }
                    break;
                }
            }

            const alertDiv = document.getElementById('availabilityAlert');
            const alertText = document.getElementById('availabilityText');
            const submitBtn = document.getElementById('submitBtn');

            if (isBlocked) {
                alertDiv.classList.remove('hidden');
                alertDiv.classList.add('flex');
                if (alertText) alertText.innerText = blockReason;
                submitBtn.disabled = true;
                submitBtn.classList.add('opacity-50', 'cursor-not-allowed');

                if (userAction || !lastAlertedState) {
                    showToast(blockReason, "warning", "Doctor Not Available");
                    lastAlertedState = true;
                }
            } else {
                alertDiv.classList.add('hidden');
                alertDiv.classList.remove('flex');
                submitBtn.disabled = false;
                submitBtn.classList.remove('opacity-50', 'cursor-not-allowed');
                lastAlertedState = false;
            }
            return isBlocked;
        }

        let currentBaseCost = 3000;
        let currentTotalCost = 3000;

        function calculateLiveFee() {
            const select = document.getElementById('treatmentType');
            currentBaseCost = parseFloat(select.options[select.selectedIndex].getAttribute('data-cost') || 3000);
            
            let addonCost = 0;
            document.querySelectorAll('.addon-checkbox:checked').forEach(cb => {
                addonCost += parseFloat(cb.getAttribute('data-cost'));
            });

            currentTotalCost = currentBaseCost + addonCost;
            document.getElementById('baseRateText').innerText = 'LKR ' + currentBaseCost.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('addonRateText').innerText = 'LKR ' + addonCost.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            document.getElementById('totalRateText').innerText = 'LKR ' + currentTotalCost.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }

        async function submitAppointment() {
            if (checkAvailability(true)) {
                showToast('Cannot register: Selected Doctor is on Leave / Unavailable for this date and time slot.', 'error', 'Doctor Unavailable');
                return;
            }

            const name = document.getElementById('patientName').value.trim();
            const phone = document.getElementById('patientPhone').value.trim();
            const email = document.getElementById('patientEmail').value.trim();
            const nic = document.getElementById('patientNic').value.trim();
            const age = document.getElementById('patientAge').value.trim();
            const gender = document.getElementById('patientGender').value;
            const dentist = document.getElementById('dentistName').value;
            const treatment = document.getElementById('treatmentType').value;
            const date = document.getElementById('appointmentDate').value;
            const time = document.getElementById('appointmentTime').value;

            if (!name || !phone || !email || !nic || !age || !date) {
                showToast('Please fill out all required appointment fields (Name, Phone, Email, NIC, Age, Date).', 'warning', 'Missing Details');
                return;
            }

            const formData = new URLSearchParams();
            formData.append('patientName', name);
            formData.append('patientPhone', phone);
            formData.append('patientEmail', email);
            formData.append('patientNic', nic);
            formData.append('patientAge', age);
            formData.append('patientGender', gender);
            formData.append('dentistName', dentist);
            formData.append('treatmentType', treatment);
            formData.append('appointmentDate', date);
            formData.append('appointmentTime', time);
            formData.append('baseCost', currentBaseCost);
            formData.append('totalCost', currentTotalCost);

            document.querySelectorAll('.addon-checkbox:checked').forEach(cb => {
                formData.append('addOns', cb.value);
            });

            try {
                const res = await fetch('book-appointment', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Accept': 'application/json'
                    },
                    body: formData.toString()
                });

                const data = await res.json();
                if (data.success) {
                    showToast('Appointment ' + data.appointmentNumber + ' booked successfully! Email and SMS alerts dispatched.', 'success', 'Booking Confirmed');
                    document.getElementById('modalAptNo').innerText = data.appointmentNumber;
                    document.getElementById('modalDentist').innerText = data.dentist || dentist;
                    document.getElementById('modalDateTime').innerText = data.dateTime || (date + ' @ ' + time);
                    document.getElementById('successModal').classList.remove('hidden');
                } else {
                    showToast(data.message || 'Error registering appointment.', 'error', 'Booking Error');
                }
            } catch (err) {
                console.error(err);
                // Fallback direct redirection
                window.location.href = 'appointment-details.jsp';
            }
        }

        // Initial check
        calculateLiveFee();
        checkAvailability();
    </script>

    <!-- Shared Toast Notifications -->
    <jsp:include page="shared-toast.jsp" />
</body>
</html>
