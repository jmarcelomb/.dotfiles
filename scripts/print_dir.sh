#! /bin/bash

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <printer_name> <path_to_pdfs>"
  echo "Tip: Use 'lpstat -p' to check available printers and 'lpoptions -p PRINTER -l' for printer options."
  exit 1
fi

PRINTER=$1
PATH_TO_PDFS=$2

# Check if the specified directory exists
if [ ! -d "$PATH_TO_PDFS" ]; then
  echo "Error: Directory '$PATH_TO_PDFS' does not exist."
  exit 1
fi

cd "$PATH_TO_PDFS" || exit 1

# Check if there are any PDF files in the directory
if ! ls *.pdf 1>/dev/null 2>&1; then
  echo "No PDF files found in the directory '$PATH_TO_PDFS'."
  exit 0
fi

for pdffile in *.pdf; do
  echo "Printing file: $pdffile"
  lpr -P "$PRINTER" -o media=A4 -o ColorModel=Gray -o sides=one-sided -o InputSlot=auto "$pdffile"
done

echo "All PDF files have been sent to the printer."
