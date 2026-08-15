/**
 * Shared Navigation & Session Management Component for Sunrise Dental Clinic.
 * Injects consistent top navigation header and footer across all separate pages.
 */
document.addEventListener('DOMContentLoaded', () => {
    // Check session authentication (redirect to login if not authenticated, except on login.html)
    const currentPage = window.location.pathname.split('/').pop() || 'login.html';
    const currentUser = sessionStorage.getItem('clinic_user');

    if (!currentUser && currentPage !== 'login.html') {
        window.location.href = 'login.html';
        return;
    }

    // Render Shared Header if container exists
    const navHeader = document.getElementById('shared-header');
    if (navHeader) {
        navHeader.innerHTML = `
        <header class="bg-white/90 backdrop-blur-md border-b border-sky-100 sticky top-0 z-50 shadow-sm">
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                <div class="flex justify-between h-20 items-center">
                    <!-- Clinic Brand & Logo -->
                    <div class="flex items-center space-x-3 cursor-pointer" onclick="window.location.href='dashboard.html'">
                        <div class="w-12 h-12 bg-gradient-to-tr from-teal-500 to-sky-400 rounded-2xl flex items-center justify-center text-white shadow-md shadow-sky-200 transform hover:scale-105 transition-all">
                            <i class="fa-solid fa-tooth text-2xl"></i>
                        </div>
                        <div>
                            <span class="text-xl font-bold bg-gradient-to-r from-teal-700 to-sky-600 bg-clip-text text-transparent">Sunrise Dental Clinic</span>
                            <span class="block text-xs font-medium text-slate-400 tracking-wider">COLOMBO PRIVATE CENTER</span>
                        </div>
                    </div>

                    <!-- Main Navigation Links -->
                    <nav class="hidden md:flex space-x-1 lg:space-x-2">
                        <a href="dashboard.html" class="nav-link px-3 py-2 rounded-xl text-sm font-semibold transition-all ${currentPage === 'dashboard.html' ? 'bg-sky-50 text-sky-700 shadow-sm' : 'text-slate-600 hover:text-sky-600 hover:bg-slate-50'}">
                            <i class="fa-solid fa-chart-pie mr-1.5 text-sky-500"></i> Dashboard
                        </a>
                        <a href="register-appointment.html" class="nav-link px-3 py-2 rounded-xl text-sm font-semibold transition-all ${currentPage === 'register-appointment.html' ? 'bg-sky-50 text-sky-700 shadow-sm' : 'text-slate-600 hover:text-sky-600 hover:bg-slate-50'}">
                            <i class="fa-solid fa-calendar-plus mr-1.5 text-teal-500"></i> New Appointment
                        </a>
                        <a href="appointment-details.html" class="nav-link px-3 py-2 rounded-xl text-sm font-semibold transition-all ${currentPage === 'appointment-details.html' ? 'bg-sky-50 text-sky-700 shadow-sm' : 'text-slate-600 hover:text-sky-600 hover:bg-slate-50'}">
                            <i class="fa-solid fa-hospital-user mr-1.5 text-indigo-500"></i> Patient Details
                        </a>
                        <a href="billing.html" class="nav-link px-3 py-2 rounded-xl text-sm font-semibold transition-all ${currentPage === 'billing.html' ? 'bg-sky-50 text-sky-700 shadow-sm' : 'text-slate-600 hover:text-sky-600 hover:bg-slate-50'}">
                            <i class="fa-solid fa-file-invoice-dollar mr-1.5 text-emerald-500"></i> Billing & Receipt
                        </a>
                        <a href="reports.html" class="nav-link px-3 py-2 rounded-xl text-sm font-semibold transition-all ${currentPage === 'reports.html' ? 'bg-sky-50 text-sky-700 shadow-sm' : 'text-slate-600 hover:text-sky-600 hover:bg-slate-50'}">
                            <i class="fa-solid fa-chart-line mr-1.5 text-amber-500"></i> Reports
                        </a>
                        <a href="help.html" class="nav-link px-3 py-2 rounded-xl text-sm font-semibold transition-all ${currentPage === 'help.html' ? 'bg-sky-50 text-sky-700 shadow-sm' : 'text-slate-600 hover:text-sky-600 hover:bg-slate-50'}">
                            <i class="fa-solid fa-circle-question mr-1.5 text-blue-500"></i> Help
                        </a>
                    </nav>

                    <!-- User Profile & Exit -->
                    <div class="flex items-center space-x-3">
                        ${currentUser ? `
                        <div class="hidden sm:flex items-center space-x-2 bg-slate-100/80 px-3 py-1.5 rounded-full text-xs font-semibold text-slate-700">
                            <span class="w-2 h-2 rounded-full bg-emerald-500 animate-pulse"></span>
                            <span>${currentUser}</span>
                        </div>
                        <a href="exit.html" class="px-4 py-2 rounded-xl text-xs font-bold text-rose-600 bg-rose-50 hover:bg-rose-100 transition-all border border-rose-200">
                            <i class="fa-solid fa-right-from-bracket mr-1"></i> Exit
                        </a>
                        ` : ''}
                    </div>
                </div>
            </div>
        </header>
        `;
    }

    // Render Shared Footer if container exists
    const navFooter = document.getElementById('shared-footer');
    if (navFooter) {
        navFooter.innerHTML = `
        <footer class="bg-white border-t border-slate-100 py-6 mt-16 text-center text-slate-500 text-xs">
            <div class="max-w-7xl mx-auto px-4 flex flex-col md:flex-row justify-between items-center space-y-3 md:space-y-0">
                <div class="flex items-center space-x-2">
                    <i class="fa-solid fa-tooth text-teal-500"></i>
                    <span class="font-semibold text-slate-700">Sunrise Dental Clinic System</span>
                    <span>&copy; 2026 Colombo, Sri Lanka</span>
                </div>
                <div class="flex space-x-4 text-slate-400">
                    <span class="hover:text-teal-600 transition-colors"><i class="fa-solid fa-shield-halved"></i> 3-Tier Architecture</span>
                    <span class="hover:text-teal-600 transition-colors"><i class="fa-solid fa-bell"></i> Email & SMS Notifications</span>
                    <span class="hover:text-teal-600 transition-colors"><i class="fa-solid fa-database"></i> SQL Triggers & Procedures</span>
                </div>
            </div>
        </footer>
        `;
    }
});
