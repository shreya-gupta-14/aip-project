<%@ page contentType="text/html;charset=UTF-8" language="java"
    import="java.sql.Timestamp, java.util.*, java.util.concurrent.TimeUnit, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Checkmate — Dashboard</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,600;1,500&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%
    Timestamp lastCheckin = (Timestamp) request.getAttribute("lastCheckin");
    int interval = (int) request.getAttribute("interval");
    boolean overdue = (boolean) request.getAttribute("overdue");
    List<Map<String,String>> alerts = (List<Map<String,String>>) request.getAttribute("alerts");
    String userName = (String) session.getAttribute("userName");
    String safeUserName = userName.replace("&", "&amp;").replace("<", "&lt;")
                                  .replace(">", "&gt;").replace("\"", "&quot;");

    SimpleDateFormat fmt = new SimpleDateFormat("MMM d, yyyy, h:mm a");
    String lastCheckinText = (lastCheckin == null) ? "Not yet recorded" : fmt.format(lastCheckin);

    // time maths, in minutes so nothing gets rounded off
    long elapsedMinutes = 0;
    if (lastCheckin != null) {
        elapsedMinutes = TimeUnit.MILLISECONDS.toMinutes(System.currentTimeMillis() - lastCheckin.getTime());
    }
    double elapsedHoursPrecise = elapsedMinutes / 60.0;
    double remainingHoursPrecise = Math.max(0, interval - elapsedHoursPrecise);

    long remHrsWhole = (long) remainingHoursPrecise;
    long remMinsWhole = Math.round((remainingHoursPrecise - remHrsWhole) * 60);
    if (remMinsWhole == 60) { remHrsWhole++; remMinsWhole = 0; }

    // ring shows TIME REMAINING: full right after a check-in, empty when overdue
    double pctRemaining = overdue ? 0.0 : Math.min(100.0, (remainingHoursPrecise * 100.0) / interval);

    String hoursAgoText = "";
    if (lastCheckin != null) {
        long h = elapsedMinutes / 60;
        long m = elapsedMinutes % 60;
        if (elapsedMinutes < 1) hoursAgoText = "just now";
        else if (h == 0) hoursAgoText = m + " min ago";
        else hoursAgoText = h + "h " + m + "m ago";
    }

    // last known location (from the most recent check-in that shared one)
    double[] loc = (double[]) request.getAttribute("location");
    String mapUrl = (loc == null) ? null
        : "https://www.google.com/maps?q=" + String.format(Locale.US, "%.6f,%.6f", loc[0], loc[1]);

    // private link for the emergency contact
    String shareToken = (String) request.getAttribute("shareToken");
    String shareUrl = request.getScheme() + "://" + request.getServerName() + ":"
        + request.getServerPort() + request.getContextPath() + "/status?t=" + shareToken;
%>
<div class="topbar">
    <div class="wordmark">checkmate</div>
    <div class="topbar-right"><%= safeUserName %> &middot; <a href="logout">sign out</a></div>
</div>

<div class="page">

    <% if (request.getParameter("checked") != null) { %>
        <div class="banner banner-ok">Check-in recorded.</div>
    <% } %>

    <section class="status <%= overdue ? "is-overdue" : "is-safe" %>">
        <div class="corner corner-tl">+</div>
        <div class="corner corner-br">+</div>

        <div class="status-grid">
            <div class="ring" style="--pct: <%= pctRemaining %>;">
                <div class="ring-inner">
                    <% if (overdue) { %>
                        <span class="ring-big">!</span>
                        <span class="ring-small">overdue</span>
                    <% } else { %>
                        <span class="ring-big"><%= remHrsWhole %>h <%= remMinsWhole %>m</span>
                        <span class="ring-small">remaining</span>
                    <% } %>
                </div>
            </div>

            <div class="status-text">
                <span class="status-label"><%= overdue ? "Missed check-in" : "You're on track" %></span>
                <p class="status-line">last check-in &mdash; <strong><%= lastCheckinText %></strong>
                    <% if (lastCheckin != null) { %><span class="muted">(<%= hoursAgoText %>)</span><% } %>
                </p>
                <p class="status-line muted">interval: every <%= interval %> hr</p>

                <% if (mapUrl != null) { %>
                    <p class="status-line muted">last known location &mdash;
                        <a class="map-link" href="<%= mapUrl %>" target="_blank">view on map</a></p>
                <% } else { %>
                    <p class="status-line muted">last known location &mdash; not shared yet</p>
                <% } %>

                <form action="checkin" method="post">
                    <input type="hidden" name="lat" id="lat">
                    <input type="hidden" name="lng" id="lng">
                    <button type="submit" class="btn">I'm safe — check in</button>
                </form>
            </div>
        </div>
    </section>

    <section class="share">
        <h2>Emergency contact link</h2>
        <p class="muted">Send this link to your emergency contact. Whenever they open it, they see your current status and last known location.</p>
        <div class="share-row">
            <input type="text" id="shareLink" value="<%= shareUrl %>" readonly>
            <button type="button" class="btn-small" onclick="copyLink()">Copy</button>
        </div>
    </section>

    <section class="history">
        <div class="history-head">
            <h2>History</h2>
            <a href="checkins" class="view-all">view all check-ins &rarr;</a>
        </div>
        <% if (alerts == null || alerts.isEmpty()) { %>
            <p class="muted">Nothing logged yet.</p>
        <% } else { %>
            <table>
                <thead>
                <tr><th>When</th><th>Status</th><th>Note</th></tr>
                </thead>
                <tbody>
                <% for (Map<String,String> a : alerts) {
                    Timestamp t = Timestamp.valueOf(a.get("time"));
                %>
                <tr>
                    <td><%= fmt.format(t) %></td>
                    <td><span class="tag tag-<%= a.get("status").toLowerCase() %>"><%= a.get("status") %></span></td>
                    <td class="muted"><%= a.get("message") %></td>
                </tr>
                <% } %>
                </tbody>
            </table>
        <% } %>
    </section>

</div>

<script>
// ask the browser for the user's position; if they say no, check-in still works without it
if (navigator.geolocation) {
    navigator.geolocation.getCurrentPosition(function (pos) {
        document.getElementById('lat').value = pos.coords.latitude;
        document.getElementById('lng').value = pos.coords.longitude;
    });
}

function copyLink() {
    var box = document.getElementById('shareLink');
    box.select();
    navigator.clipboard.writeText(box.value);
}
</script>
</body>
</html>