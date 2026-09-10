"""
FirePredict — Risk Map Generator
=================================
Generates an interactive HTML fire risk map for Mount Kilimanjaro.

Usage:
    python generate_risk_map.py

Output:
    kilimanjaro_risk_map.html  — open in any browser, no server needed

Requirements:
    pip install folium requests

By default the script tries to fetch live risk scores from the FirePredict
backend. If the server is offline, it uses the built-in demo data below.

Author : FirePredict / University of Dodoma (UDOM), Tanzania
License: MIT
"""

import json
import os

try:
    import folium
except ImportError:
    raise SystemExit("Please install folium first:  pip install folium")

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

# Change this to your backend IP if you have the server running
BACKEND_URL = "http://localhost:8080"

# Output file
OUTPUT_FILE = "kilimanjaro_risk_map.html"

# ---------------------------------------------------------------------------
# Built-in zone data (used when server is offline)
# ---------------------------------------------------------------------------

DEMO_ZONES = [
    {
        "zone_name": "Machame Route",
        "lat": -3.0674, "lon": 37.2556,
        "risk_score": 0.82, "risk_label": "High",
        "risk_color": "#D32F2F",
        "description": (
            "Dry conditions with low humidity (28%) and strong winds (22 km/h). "
            "NDVI = 0.24 — critically dry vegetation."
        ),
    },
    {
        "zone_name": "Shira Plateau",
        "lat": -3.0522, "lon": 37.2109,
        "risk_score": 0.71, "risk_label": "High",
        "risk_color": "#D32F2F",
        "description": (
            "NDVI = 0.22 — extremely dry heath vegetation. "
            "NBR = 0.44 — high burn severity potential."
        ),
    },
    {
        "zone_name": "Mweka Route",
        "lat": -3.1330, "lon": 37.3640,
        "risk_score": 0.76, "risk_label": "High",
        "risk_color": "#D32F2F",
        "description": (
            "Maximum temperature 31°C. Zero rainfall for 9 consecutive days. "
            "Agricultural burning reported in adjacent lower slopes."
        ),
    },
    {
        "zone_name": "Rongai Corridor",
        "lat": -2.9852, "lon": 37.4100,
        "risk_score": 0.55, "risk_label": "Moderate",
        "risk_color": "#F57C00",
        "description": (
            "Agricultural burning detected 3 km south of corridor. "
            "Humidity: 42% — declining trend."
        ),
    },
    {
        "zone_name": "Marangu Gate",
        "lat": -3.0396, "lon": 37.5231,
        "risk_score": 0.38, "risk_label": "Low",
        "risk_color": "#FBC02D",
        "description": (
            "Conditions currently manageable. "
            "Humidity holding above 50%."
        ),
    },
    {
        "zone_name": "Karanga Valley",
        "lat": -3.1012, "lon": 37.3200,
        "risk_score": 0.22, "risk_label": "Very Low",
        "risk_color": "#388E3C",
        "description": (
            "Good vegetation moisture. "
            "Recent rainfall has reduced risk significantly."
        ),
    },
    {
        "zone_name": "Kilema Area",
        "lat": -3.0200, "lon": 37.4600,
        "risk_score": 0.16, "risk_label": "Very Low",
        "risk_color": "#388E3C",
        "description": (
            "Low fire risk. Dense vegetation with adequate moisture levels."
        ),
    },
]

# ---------------------------------------------------------------------------
# Fetch live data or fall back to demo
# ---------------------------------------------------------------------------

def fetch_zones():
    if not REQUESTS_AVAILABLE:
        print("requests not installed — using built-in demo data.")
        return DEMO_ZONES

    try:
        resp = requests.get(f"{BACKEND_URL}/zones", timeout=5)
        if resp.status_code == 200:
            data = resp.json()
            zones = data.get("zones", [])
            if zones:
                print(f"Live data fetched from {BACKEND_URL} — {len(zones)} zones.")
                return zones
        print("Server returned unexpected response — using demo data.")
    except Exception:
        print("Server offline or unreachable — using built-in demo data.")

    return DEMO_ZONES

# ---------------------------------------------------------------------------
# Build the map
# ---------------------------------------------------------------------------

def risk_radius(score):
    """Circle radius scaled by risk score."""
    return 800 + score * 1200  # 800m (Very Low) to 2000m (High)

def build_map(zones):
    # Centre on Kilimanjaro summit
    m = folium.Map(
        location=[-3.0674, 37.3556],
        zoom_start=11,
        tiles="OpenStreetMap",
    )

    # Title box
    title_html = """
    <div style="position:fixed; top:15px; left:55px; z-index:1000;
                background:white; padding:12px 18px; border-radius:8px;
                border:2px solid #D32F2F; font-family:Arial; box-shadow:3px 3px 8px rgba(0,0,0,0.3);">
        <b style="font-size:16px; color:#D32F2F;">🔥 FirePredict — Fire Risk Map</b><br>
        <span style="font-size:12px; color:#555;">Mount Kilimanjaro | Open Source Tool</span>
    </div>
    """
    m.get_root().html.add_child(folium.Element(title_html))

    # Legend
    legend_html = """
    <div style="position:fixed; bottom:30px; right:15px; z-index:1000;
                background:white; padding:12px; border-radius:8px;
                border:1px solid #ccc; font-family:Arial; font-size:13px;
                box-shadow:2px 2px 6px rgba(0,0,0,0.2);">
        <b>Fire Risk Level</b><br><br>
        <span style="color:#D32F2F;">&#9679;</span> High (&ge; 0.75)<br>
        <span style="color:#F57C00;">&#9679;</span> Moderate (&ge; 0.50)<br>
        <span style="color:#FBC02D;">&#9679;</span> Low (&ge; 0.30)<br>
        <span style="color:#388E3C;">&#9679;</span> Very Low (< 0.30)
    </div>
    """
    m.get_root().html.add_child(folium.Element(legend_html))

    # Zone circles
    for zone in zones:
        name  = zone.get("zone_name") or zone.get("name", "Unknown Zone")
        lat   = zone["lat"]
        lon   = zone["lon"]
        score = zone["risk_score"]
        label = zone["risk_label"]
        color = zone.get("risk_color", "#888888")
        desc  = zone.get("description", "")

        popup_html = f"""
        <div style="font-family:Arial; min-width:200px;">
            <b style="font-size:14px;">{name}</b><br>
            <span style="color:{color}; font-weight:bold; font-size:13px;">
                {label} Risk
            </span><br>
            <span style="font-size:12px; color:#555;">
                Score: {score:.2f}
            </span><br><br>
            <span style="font-size:12px;">{desc}</span>
        </div>
        """

        folium.CircleMarker(
            location=[lat, lon],
            radius=risk_radius(score) / 80,
            color=color,
            fill=True,
            fill_color=color,
            fill_opacity=0.55,
            popup=folium.Popup(popup_html, max_width=280),
            tooltip=f"{name} — {label} ({score:.2f})",
        ).add_to(m)

        # Zone label
        folium.Marker(
            location=[lat, lon],
            icon=folium.DivIcon(
                html=f'<div style="font-size:10px; font-weight:bold; '
                     f'color:{color}; text-shadow:1px 1px 2px white;">'
                     f'{name}</div>',
                icon_size=(150, 20),
                icon_anchor=(75, -8),
            ),
        ).add_to(m)

    return m

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("FirePredict — Risk Map Generator")
    print("=" * 40)

    zones = fetch_zones()
    m = build_map(zones)
    m.save(OUTPUT_FILE)

    print(f"\nMap saved to: {os.path.abspath(OUTPUT_FILE)}")
    print("Open it in any web browser — no server needed.")
    print("\nZone Summary:")
    print(f"  {'Zone':<22} {'Risk':<10} {'Score'}")
    print(f"  {'-'*22} {'-'*10} {'-'*5}")
    for z in zones:
        name  = z.get("zone_name") or z.get("name", "?")
        print(f"  {name:<22} {z['risk_label']:<10} {z['risk_score']:.2f}")
