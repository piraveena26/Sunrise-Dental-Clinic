<%-- shared-toast.jsp: Include this once per page before </body> to enable toast notifications --%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<!-- Toast Notification Container -->
<div id="toastContainer" class="fixed top-6 right-6 z-50 flex flex-col space-y-3 pointer-events-none max-w-sm w-full"></div>

<script>
    function showToast(message, type, title) {
        const c = document.getElementById('toastContainer');
        if (!c) return;
        const t = document.createElement('div');
        const styles = {
            success: { bg: 'bg-emerald-50/95 border-emerald-300 text-emerald-900', icon: '<i class="fa-solid fa-circle-check text-emerald-600 text-lg mt-0.5"></i>' },
            error:   { bg: 'bg-rose-50/95 border-rose-300 text-rose-900',           icon: '<i class="fa-solid fa-circle-xmark text-rose-600 text-lg mt-0.5"></i>' },
            warning: { bg: 'bg-amber-50/95 border-amber-300 text-amber-900',         icon: '<i class="fa-solid fa-triangle-exclamation text-amber-600 text-lg mt-0.5"></i>' },
            info:    { bg: 'bg-sky-50/95 border-sky-300 text-sky-900',               icon: '<i class="fa-solid fa-circle-info text-sky-600 text-lg mt-0.5"></i>' }
        };
        const s = styles[type] || styles.info;
        t.className = 'pointer-events-auto flex items-start space-x-3 p-4 rounded-2xl shadow-xl border backdrop-blur-md transform transition-all duration-300 translate-y-[-10px] opacity-0 ' + s.bg;
        t.innerHTML = s.icon +
            '<div class="flex-1 pr-2"><h4 class="text-xs font-black uppercase tracking-wider">' + title + '</h4>' +
            '<p class="text-xs font-semibold mt-0.5 leading-relaxed">' + message + '</p></div>' +
            '<button onclick="this.parentElement.remove()" class="text-slate-400 hover:text-slate-700 text-sm"><i class="fa-solid fa-xmark"></i></button>';
        c.appendChild(t);
        setTimeout(() => { t.classList.replace('translate-y-[-10px]', 'translate-y-0'); t.classList.replace('opacity-0', 'opacity-100'); }, 10);
        setTimeout(() => { t.classList.replace('translate-y-0', 'translate-y-[-10px]'); t.classList.replace('opacity-100', 'opacity-0'); setTimeout(() => t.remove(), 300); }, 4500);
    }

    // Auto-show session flash message (set by server after login/register/logout/etc.)
    <%
        String _flash = (String) session.getAttribute("flashMessage");
        String _type  = (String) session.getAttribute("flashType");
        String _title = (String) session.getAttribute("flashTitle");
        if (_flash != null) {
            session.removeAttribute("flashMessage");
            session.removeAttribute("flashType");
            session.removeAttribute("flashTitle");
        } else if ("true".equalsIgnoreCase(request.getParameter("logout"))) {
            _flash = "You have been logged out successfully.";
            _type = "info";
            _title = "Logged Out";
        }
        if (_flash != null) {
    %>
    window.addEventListener('DOMContentLoaded', function() {
        showToast('<%= _flash.replace("'", "\\'") %>', '<%= _type != null ? _type : "info" %>', '<%= _title != null ? _title.replace("'", "\\'") : "Notice" %>');
    });
    <% } %>
</script>
