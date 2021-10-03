
with open("input.txt", "r") as f:
    text = f.read()

# Remove all new lines
text = text.replace("\n", " ")
output_text = ""
words = text.split(" ")
word_count = 4

for i in range(0, len(words), word_count):
    output_text += words[i]

    for j in range(i+1, i+word_count):
        if len(words) > j:
            output_text += " " + words[j]

    output_text += "\n\n"

with open("output.txt", "w+") as f:
    f.write(output_text)
