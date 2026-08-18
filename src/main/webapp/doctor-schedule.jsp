<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.sunrisedental.model.User" %>
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
    if (!"ADMIN".equalsIgnoreCase(userRole) && !"DOCTOR".equalsIgnoreCase(userRole)) {
        response.sendRedirect("dashboard.jsp");
        return;
    }

    DoctorScheduleDAO scheduleDAO = new DoctorScheduleDAO();
    List<DoctorSchedule> schedules = scheduleDAO.getAllSchedules();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Schedule & Leave Management - Sunrise Dental Clinic</title>
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
                    <i class="fa-solid fa-user-clock mr-1"></i> Doctor Portal & Availability Management
                </span>
                <h1 class="text-3xl font-black tracking-tight">Doctor Leave & Unavailability Schedule</h1>
                <p class="text-xs text-teal-100 mt-2 max-w-2xl leading-relaxed font-medium">
                    Doctors can schedule upcoming leave dates or unavailable time slots. Dates and times added here will automatically disable selection in the Patient/Admin appointment booking form to prevent double-booking.
                </p>
            </div>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
            
            <!-- Schedule Form -->
            <div class="lg:col-span-1 bg-white p-6 rounded-3xl border border-slate-100 shadow-sm h-fit">
                <h2 class="text-base font-bold text-slate-800 mb-4 flex items-center">
                    <i class="fa-solid fa-calendar-minus text-teal-600 mr-2"></i> Schedule Leave / Unavailability
                </h2>

                <form action="api/doctor-schedule" method="POST" class="space-y-4">
                    <input type="hidden" name="action" value="add">
                    
                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Select Doctor</label>
                        <select name="doctorId" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                            <option value="1">Dr. Chaminda Silva (General Dentistry)</option>
                            <option value="2">Dr. Nimali Fernando (Orthodontics & Root Canal)</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Unavailable Date *</label>
                        <input type="date" name="unavailableDate" required class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Time Slot *</label>
                        <select name="timeSlot" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-bold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                            <option value="ALL_DAY">All Day (Full Leave)</option>
                            <option value="09:00">Morning (09:00 AM)</option>
                            <option value="10:30">Morning (10:30 AM)</option>
                            <option value="14:00">Afternoon (02:00 PM)</option>
                            <option value="15:30">Afternoon (03:30 PM)</option>
                        </select>
                    </div>

                    <div>
                        <label class="block text-xs font-bold text-slate-700 uppercase tracking-wider mb-1.5">Reason / Note</label>
                        <input type="text" name="reason" placeholder="e.g. Annual Leave / Medical Conference" class="w-full px-4 py-3 rounded-2xl border border-slate-200 text-xs font-semibold text-slate-800 focus:outline-none focus:ring-2 focus:ring-teal-500 bg-slate-50">
                    </div>

                    <button type="submit" class="w-full py-3.5 bg-teal-600 hover:bg-teal-700 text-white font-extrabold rounded-2xl text-xs uppercase tracking-wider transition-all shadow-md">
                        <i class="fa-solid fa-plus-circle mr-1"></i> Save Unavailability Slot
                    </button>
                </form>
            </div>

            <!-- Active Schedules Table -->
            <div class="lg:col-span-2 bg-white p-6 rounded-3xl border border-slate-100 shadow-sm">
                <h2 class="text-base font-bold text-slate-800 mb-4 flex items-center">
                    <i class="fa-solid fa-list-check text-teal-600 mr-2"></i> Current Doctor Leave & Blocked Slots
                </h2>

                <div class="overflow-x-auto">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="border-b border-slate-100 text-[11px] font-extrabold text-slate-400 uppercase tracking-wider">
                                <th class="pb-3">Doctor</th>
                                <th class="pb-3">Unavailable Date</th>
                                <th class="pb-3">Time Slot</th>
                                <th class="pb-3">Reason</th>
                                <th class="pb-3 text-right">Action</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-slate-100 text-xs font-semibold text-slate-700">
                            <% if (schedules.isEmpty()) { %>
                            <tr>
                                <td colspan="5" class="py-8 text-center text-slate-400">No leave or unavailability slots registered.</td>
                            </tr>
                            <% } else {
                                for (DoctorSchedule s : schedules) { %>
                            <tr class="hover:bg-slate-50 transition-colors">
                                <td class="py-4 font-bold text-slate-800"><%= s.getDoctorName() %></td>
                                <td class="py-4 text-teal-600 font-bold"><%= s.getUnavailableDate() %></td>
                                <td class="py-4"><span class="px-2.5 py-1 bg-amber-50 text-amber-700 rounded-lg text-[10px] font-extrabold uppercase"><%= s.getTimeSlot() %></span></td>
                                <td class="py-4 text-slate-500"><%= s.getReason() %></td>
                                <td class="py-4 text-right">
                                    <form action="api/doctor-schedule" method="POST" class="inline">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="<%= s.getId() %>">
                                        <button type="submit" class="px-3 py-1.5 bg-rose-50 hover:bg-rose-100 text-rose-600 font-bold rounded-xl text-[11px] transition-all">
                                            <i class="fa-solid fa-trash mr-1"></i> Remove
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            <%  }
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

        </div>
    </main>

    <!-- Footer -->
    <footer class="bg-white border-t border-slate-200 py-6 text-center text-xs text-slate-500 font-medium">
        Sunrise Dental Clinic &copy; 2026 | Doctor Leave Management Portal
    </footer>

</body>
</html>
