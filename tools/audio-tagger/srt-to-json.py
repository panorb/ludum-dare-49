import json
from datetime import timedelta
import re

RGX_TIMESTAMP_MAGNITUDE_DELIM = r"[,.:，．。：]"
RGX_TIMESTAMP_FIELD = r"[0-9]+"
RGX_TIMESTAMP_FIELD_OPTIONAL = r"[0-9]*"
RGX_TIMESTAMP = "".join(
    [
        RGX_TIMESTAMP_MAGNITUDE_DELIM.join([RGX_TIMESTAMP_FIELD] * 3),
        RGX_TIMESTAMP_MAGNITUDE_DELIM,
        "?",
        RGX_TIMESTAMP_FIELD_OPTIONAL,
    ]
)
RGX_TIMESTAMP_PARSEABLE = r"^{}$".format(
    "".join(
        [
            RGX_TIMESTAMP_MAGNITUDE_DELIM.join(
                ["(" + RGX_TIMESTAMP_FIELD + ")"] * 3),
            RGX_TIMESTAMP_MAGNITUDE_DELIM,
            "?",
            "(",
            RGX_TIMESTAMP_FIELD_OPTIONAL,
            ")",
        ]
    )
)

TS_REGEX = re.compile(RGX_TIMESTAMP_PARSEABLE)


def srt_timestamp_to_timedelta(timestamp):
    match = TS_REGEX.match(timestamp)
    if match is None:
        raise TimestampParseError(
            "Unparseable timestamp: {}".format(timestamp))
    hrs, mins, secs, msecs = [int(m) if m else 0 for m in match.groups()]
    return timedelta(hours=hrs, minutes=mins, seconds=secs, milliseconds=msecs)


with open("input.srt", "r") as f:
    srt_lines = f.readlines()

list_ = []

for i in range(0, len(srt_lines), 4):
    section_lines = srt_lines[i:i+3]

    index = int(section_lines[0])
    start_time, end_time = [el.strip() for el in section_lines[1].split("-->")]
    text = section_lines[2].strip()

    list_.append({
        "index": index,
        "start": srt_timestamp_to_timedelta(start_time).total_seconds(),
        "end": srt_timestamp_to_timedelta(end_time).total_seconds(),
        "text": text
    })

with open("output.json", "w+") as f:
    f.write(json.dumps(list_, indent=2))
