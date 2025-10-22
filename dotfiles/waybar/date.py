#!/usr/bin/env python3

import json
from datetime import datetime
from hijri_converter import convert

now = datetime.now()
time_now = now.strftime("%H:%M:%S")

# Gregorian
day = now.day
month = now.strftime("%B")
year = now.year

def ordinal(n):
    return f"{n}{'th' if 11<=n<=13 else {1:'st',2:'nd',3:'rd'}.get(n%10, 'th')}"

# Hijri
hijri = convert.Gregorian(year, now.month, day).to_hijri()
hijri_day = ordinal(hijri.day)
hijri_month = hijri.month_name()
hijri_year = hijri.year

tooltip = f"{ordinal(day)} of {month}, {year}\n{hijri_day} of {hijri_month}, {hijri_year} AH"

# Output JSON for waybar
print(json.dumps({
    "text": time_now,
    "tooltip": tooltip
}))

