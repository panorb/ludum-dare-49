import json

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
        "start": start_time,
        "end": end_time,
        "text": text
    })

with open("output.json", "w+") as f:
    f.write(json.dumps(list_, indent=2))
