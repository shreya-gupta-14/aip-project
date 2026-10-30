<%@ page contentType="text/html;charset=UTF-8" language="java"
    import="java.sql.Timestamp, java.util.*, java.util.concurrent.TimeUnit, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="60">
    <title>Checkmate — Status</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Fraunces:ital,wght@0,600;1,500&family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
</head>
<body>
<%
    String name = (String) request.getAttribute("name");
    // escape the name, since this page is public and shown to someone else
    String safeName = name.replace("&", "&amp;").replace("<", "&lt;")
                          .replace(">", "&gt;").replace("\"", "&quot;");
    String firstName = safeName.split(" ")[0];

    Timestamp lastCheckin = (Timestamp) request.getAttribute("lastCheckin");
    boolean overdue = (boolean) request.getAttribute("overdue");
    int interval = (int) request.getAttribute("interval");
    double[] loc = (double[]) request.getAttribute("location");

    SimpleDateFormat fmt = new SimpleDateFormat("MMM d, h:mm a");

    long elapsedMin = 0;
    String lastText = "never";
    String agoText = "";
    String nextText = "—";
    if (lastCheckin != null) {
        elapsedMin = TimeUnit.MILLISECONDS.toMinutes(System.currentTimeMillis() - lastCheckin.getTime());
        lastText = fmt.format(lastCheckin);
        if (elapsedMin < 1) agoText = "just now";
        else if (elapsedMin < 60) agoText = elapsedMin + " min ago";
        else agoText = (elapsedMin / 60) + "h " + (elapsedMin % 60) + "m ago";
        nextText = fmt.format(new Timestamp(lastCheckin.getTime() + interval * 3600000L));
    }

    long remMin = Math.max(0, interval * 60L - elapsedMin);
    String nextNote = (lastCheckin == null) ? "no check-in yet"
                    : overdue ? "deadline passed"
                    : (remMin / 60) + "h " + (remMin % 60) + "m left";

    String title = overdue ? firstName + " hasn't checked in" : firstName + " is doing fine";
    String sub;
    if (lastCheckin == null) sub = "No check-in has been recorded yet.";
    else if (overdue) sub = "Last heard from " + agoText + ", which is past the " + interval + "-hour limit.";
    else sub = "Checked in " + agoText + ".";

    // heartbeat line: a pulse when all is well, a flat line when overdue
    String beat = "M0 30 H150 L165 30 L177 8 L190 52 L203 18 L213 30 H400";
    String flat = "M0 30 H400";

    String mapUrl = null;
    String embedUrl = null;
    if (loc != null) {
        mapUrl = "https://www.google.com/maps?q=" + String.format(Locale.US, "%.6f,%.6f", loc[0], loc[1]);
        embedUrl = String.format(Locale.US,
            "https://www.openstreetmap.org/export/embed.html?bbox=%.6f%%2C%.6f%%2C%.6f%%2C%.6f&amp;layer=mapnik&amp;marker=%.6f%%2C%.6f",
            loc[1] - 0.012, loc[0] - 0.008, loc[1] + 0.012, loc[0] + 0.008, loc[0], loc[1]);
    }
%>
<div class="topbar">
    <div class="wordmark">checkmate</div>
    <div class="topbar-right">watching over <%= firstName %></div>
</div>

<div class="w-page">

    <section class="w-hero <%= overdue ? "is-overdue" : "is-safe" %>">
        <div class="w-caption">
            <span class="w-live"></span> <%= overdue ? "needs a look" : "all clear" %>
        </div>
        <h1 class="w-title"><%= title %></h1>
        <svg class="w-pulse" viewBox="0 0 400 60" aria-hidden="true">
            <path pathLength="100" d="<%= overdue ? flat : beat %>"/>
        </svg>
        <p class="w-sub"><%= sub %></p>
    </section>

    <div class="w-tiles">
        <div class="w-tile">
            <div class="w-tile-label">Last check-in</div>
            <div class="w-tile-value"><%= lastText %></div>
            <div class="w-tile-note"><%= agoText.isEmpty() ? "&nbsp;" : agoText %></div>
        </div>
        <div class="w-tile">
            <div class="w-tile-label">Next one due</div>
            <div class="w-tile-value"><%= nextText %></div>
            <div class="w-tile-note"><%= nextNote %></div>
        </div>
        <div class="w-tile">
            <div class="w-tile-label">Checks in every</div>
            <div class="w-tile-value"><%= interval %> hours</div>
            <div class="w-tile-note">set by <%= firstName %></div>
        </div>
    </div>

    <% if (overdue) { %>
    <section class="w-card is-alert">
        <h2>What you can do</h2>
        <ol class="w-steps">
            <li>Call or message <%= firstName %> directly.</li>
            <li>Look at the last known location below and see if someone nearby can check in on them.</li>
            <li>If you can't reach them and you're worried, contact your local emergency services.</li>
        </ol>
    </section>
    <% } %>

    <section class="w-card">
        <h2>Last known location</h2>
        <% if (embedUrl != null) { %>
            <iframe class="w-map" src="<%= embedUrl %>" loading="lazy" title="Last known location"></iframe>
            <p class="w-map-foot"><a class="map-link" href="<%= mapUrl %>" target="_blank">open in Google Maps &rarr;</a></p>
        <% } else { %>
            <div class="w-empty">No location was shared with the check-ins so far.</div>
        <% } %>
    </section>

    <p class="w-foot">This page refreshes by itself every minute.
        <a href="#" onclick="location.reload(); return false;">refresh now</a></p>
</div>
</body>
</html>