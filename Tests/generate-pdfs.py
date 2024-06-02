import os

path = './'

current_path = os.getcwd().split('/')[-1]
if current_path != "Tests":
    path = 'Tests/'

folder = path + "test-files"
T_dir = os.path.join(folder, "True")
F_dir = os.path.join(folder, "False")

os.makedirs(T_dir, exist_ok=True)
os.makedirs(F_dir, exist_ok=True)

n = 10

# Function to create a valid PDF file
def create_valid_pdf(file_path):
    print(f"Creating valid PDF file: {file_path}")
    with open(file_path, 'w') as f:
        f.write("%PDF-1.7\n")
        f.write("1 0 obj\n")
        f.write("<< /Type /Catalog /Pages 2 0 R >>\n")
        f.write("endobj\n")
        f.write("2 0 obj\n")
        f.write("<< /Type /Pages /Count 1 /Kids [3 0 R] >>\n")
        f.write("endobj\n")
        f.write("3 0 obj\n")
        f.write("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R >>\n")
        f.write("endobj\n")
        f.write("4 0 obj\n")
        f.write("<< /Length 44 >>\n")
        f.write("stream\n")
        f.write("BT\n")
        f.write("/F1 24 Tf\n")
        f.write("100 700 Td\n")
        f.write("(Hello World) Tj\n")
        f.write("ET\n")
        f.write("endstream\n")
        f.write("endobj\n")
        f.write("xref\n")
        f.write("0 5\n")
        f.write("0000000000 65535 f\n")
        f.write("0000000010 00000 n\n")
        f.write("0000000067 00000 n\n")
        f.write("0000000123 00000 n\n")
        f.write("0000000189 00000 n\n")
        f.write("trailer\n")
        f.write("<< /Root 1 0 R /Size 5 >>\n")
        f.write("startxref\n")
        f.write("258\n")
        f.write("%%EOF\n")

# Function to create an invalid PDF file
def create_invalid_pdf(file_path, first_line_valid=True, last_number_valid=True):
    print(f"Creating invalid PDF file: {file_path}")
    with open(file_path, 'w') as f:
        if first_line_valid:
            f.write("%PDF-1.7\n")
        else:
            f.write("%PD-1.7\n")
        f.write("1 0 obj\n")
        f.write("<< /Type /Catalog /Pages 2 0 R >>\n")
        f.write("endobj\n")
        f.write("2 0 obj\n")
        f.write("<< /Type /Pages /Count 1 /Kids [3 0 R] >>\n")
        f.write("endobj\n")
        f.write("3 0 obj\n")
        f.write("<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R >>\n")
        f.write("endobj\n")
        f.write("4 0 obj\n")
        f.write("<< /Length 44 >>\n")
        f.write("stream\n")
        f.write("BT\n")
        f.write("/F1 24 Tf\n")
        f.write("100 700 Td\n")
        f.write("(Hello World) Tj\n")
        f.write("ET\n")
        f.write("endstream\n")
        f.write("endobj\n")
        f.write("xref\n")
        f.write("0 5\n")
        f.write("0000000000 65535 f\n")
        f.write("0000000010 00000 n\n")
        f.write("0000000067 00000 n\n")
        f.write("0000000123 00000 n\n")
        f.write("0000000189 00000 n\n")
        f.write("trailer\n")
        f.write("<< /Root 1 0 R /Size 5 >>\n")
        f.write("startxref\n")
        if last_number_valid:
            f.write("258\n")
        else:
            f.write("abc\n")
        f.write("%%EOF\n")

# Create valid PDF files
print("Creating valid PDF files...")
for i in range(n // 2):
    create_valid_pdf(os.path.join(T_dir, f"test{i + 1}.pdf"))

# Create invalid PDF files with various errors
print("Creating invalid PDF files...")
for i in range(n // 4):
    create_invalid_pdf(os.path.join(F_dir, f"test{i + 1}.pdf"), first_line_valid=False)

for i in range(n // 4):
    create_invalid_pdf(os.path.join(F_dir, f"test{i + 1 + (n // 4)}.pdf"), last_number_valid=False)

print("PDF creation completed.")
